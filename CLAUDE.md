# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application for personal finance management called "finanzasraul". The app is designed to help track personal finances for someone registered under the RESICO tax regime in Mexico, with specific features for:
- Multiple bank account management (BBVA, Mercado Pago, Nu, DIDI)
- Daily interest calculations (DIDI: 15% annual, Mercado Pago: 14% annual)
- Expense tracking with VAT (IVA) support and deductible VAT tracking
- Credit card management (Nu card with $2,000 MXN limit)

## Common Commands

### Flutter Development
```bash
# Get dependencies
flutter pub get

# Run the app
flutter run

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices

# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Build for production
flutter build apk          # Android
flutter build ios          # iOS (requires macOS)
flutter build web          # Web

# Clean build artifacts
flutter clean

# Analyze code
flutter analyze

# Format code
dart format lib test
```

## Architecture Considerations

### Data Models Required
- **Account**: Bank accounts with balance, interest rates, and bank type
- **Transaction**: Expenses/income with VAT information and deductibility status
- **CreditCard**: Credit card information with limit and current balance
- **DailyInterest**: Calculated daily interest for DIDI and Mercado Pago accounts

### Key Features to Implement
1. **Multi-Account Dashboard**: Overview of all bank accounts and total balance
2. **Transaction Management**: Add/edit/delete transactions with VAT calculations
3. **Interest Calculator**: Automatic daily interest calculations for DIDI (15%) and MP (14%)
4. **RESICO Tax Support**: Track deductible expenses and generate reports
5. **Credit Card Tracker**: Monitor Nu credit card usage against $2,000 limit

### Database Considerations
Consider using SQLite with sqflite package for local data persistence, as this is financial data that should be stored securely on device.

### State Management
For a financial app with multiple interconnected features, consider using Provider or Riverpod for state management to handle account balances, transactions, and real-time calculations efficiently.