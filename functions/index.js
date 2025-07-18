const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

const ACCOUNTS_COLLECTION = 'accounts';
const TRANSACTIONS_COLLECTION = 'transactions';
const DAILY_INTEREST_RECORDS = 'daily_interest_records';
const SYSTEM_METADATA = 'system_metadata';

// Scheduled function at 00:10 AM America/Mexico_City
exports.applyDailyInterest = functions.pubsub
  .schedule('10 0 * * *')
  .timeZone('America/Mexico_City')
  .onRun(async () => {
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startISO = today.toISOString();
    const endISO = new Date(today.getFullYear(), today.getMonth(), today.getDate(), 23, 59, 59).toISOString();

    const accountsSnap = await db.collection(ACCOUNTS_COLLECTION).get();

    for (const doc of accountsSnap.docs) {
      const account = doc.data();
      if (account.accountType !== 0) continue; // only debit accounts
      if (!account.annualInterestRate || account.annualInterestRate <= 0) continue;
      if (!account.balance || account.balance <= 0) continue;

      const existingSnap = await db
        .collection(DAILY_INTEREST_RECORDS)
        .where('accountId', '==', account.id)
        .where('appliedDate', '>=', startISO)
        .where('appliedDate', '<=', endISO)
        .limit(1)
        .get();

      if (!existingSnap.empty) {
        continue;
      }

      const dailyInterest = account.balance * (account.annualInterestRate / 100) / 365;
      if (dailyInterest <= 0) continue;

      const record = {
        accountId: account.id,
        interestAmount: dailyInterest,
        balanceBeforeInterest: account.balance,
        balanceAfterInterest: account.balance + dailyInterest,
        appliedDate: startISO,
        createdAt: now.toISOString(),
      };

      await db.collection(DAILY_INTEREST_RECORDS).add(record);

      await doc.ref.update({
        balance: record.balanceAfterInterest,
        updatedAt: now.toISOString(),
      });

      await db.collection(TRANSACTIONS_COLLECTION).add({
        accountId: account.id,
        description: `Intereses diarios - ${account.name}`,
        amount: dailyInterest,
        subtotal: dailyInterest,
        ivaAmount: 0,
        hasIva: 0,
        isDeductibleIva: 0,
        type: 0, // income
        category: 'Intereses',
        source: 0, // personal
        transactionDate: startISO,
        createdAt: now.toISOString(),
      });
    }

    await db.collection(SYSTEM_METADATA).doc('interest_calculation').set({
      lastCalculationDate: now.toISOString(),
      lastCalculationTimestamp: admin.firestore.FieldValue.serverTimestamp(),
    }, { merge: true });

    return null;
  });
