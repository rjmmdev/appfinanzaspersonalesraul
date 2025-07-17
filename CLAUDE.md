# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter application for personal finance management called "finanzasraul". The app tracks personal finances with Mexican tax regime considerations (RESICO), featuring:
- Multi-bank account management (BBVA, Mercado Pago, Nu, DIDI)
- Daily interest calculations for interest-bearing accounts
- Expense tracking with IVA (Mexican VAT) support and deductible expense tracking
- Credit card management
- Modern UI with custom theming and responsive design

## Common Commands

### Flutter Development
```bash
# Get dependencies
flutter pub get

# Run the app (default device)
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

### Hot Reload and Restart
During `flutter run`:
- `r` - Hot reload (preserves state)
- `R` - Hot restart (resets state)
- `q` - Quit

## Architecture

### Tech Stack
- **Framework**: Flutter 3.8.1+
- **State Management**: Provider pattern with ChangeNotifier
- **Database**: SQLite via sqflite package for local persistence
- **Backend**: Firebase (Core, Firestore, Storage, Auth)
- **Internationalization**: Spanish Mexico (es_MX) locale
- **Charts**: fl_chart for financial visualizations

### Project Structure
```
lib/
├── main.dart                    # App entry point with Firebase setup
├── firebase_options.dart       # Firebase configuration
├── models/                     # Data models
│   ├── account.dart            # Bank account model
│   ├── transaction.dart        # Financial transaction model
│   ├── credit_card.dart        # Credit card model
│   └── daily_interest.dart     # Interest calculation model
├── providers/                  # State management
│   ├── finance_provider.dart   # Main finance state manager
│   ├── account_provider.dart   # Account-specific operations
│   ├── transaction_provider.dart # Transaction operations
│   └── credit_card_provider.dart # Credit card operations
├── screens/                    # UI screens
│   ├── modern_dashboard_screen.dart # Main dashboard
│   ├── modern_accounts_screen.dart  # Account management
│   ├── compatible_transaction_screen.dart # Add transactions
│   ├── transactions_screen.dart     # Transaction history
│   ├── cfdi_guide_screen.dart      # Mexican tax guide
│   └── invoices_screen.dart        # Invoice management
├── services/                   # Business logic
│   ├── database_service.dart   # SQLite operations
│   ├── firebase_service.dart   # Firebase operations
│   └── storage_service.dart    # Local storage
├── theme/
│   └── app_theme.dart         # Custom Material theme
└── widgets/
    └── modern_card.dart       # Reusable UI components
```

### Data Models
- **Account**: Bank accounts with balance, interest rates, and bank-specific configurations
- **Transaction**: Financial transactions with IVA calculations and deductible status tracking
- **CreditCard**: Credit card management with limits and payment tracking
- **DailyInterest**: Automatic interest calculations for investment accounts

### Key Features Implemented
1. **Multi-Account Dashboard**: Real-time overview of all financial accounts
2. **Transaction Management**: Complete CRUD operations with IVA calculations
3. **Interest Calculations**: Automated daily interest for DIDI (15%) and Mercado Pago (14%)
4. **Mexican Tax Support**: RESICO regime support with deductible expense tracking
5. **Modern UI**: Material Design 3 with custom theming and responsive layouts
6. **Firebase Integration**: Cloud backup and synchronization capabilities

### State Management Pattern
The app uses Provider pattern with a centralized `FinanceProvider` that coordinates:
- Account balances and updates
- Transaction history and calculations
- Interest accrual automation
- Real-time financial summaries
- Local and cloud data synchronization

### Database Schema
SQLite database with tables for:
- `accounts`: Bank account information and balances
- `transactions`: Financial transactions with IVA data
- `credit_cards`: Credit card details and usage
- `daily_interests`: Interest calculation history

### Mexican Banking Integration Research
The project includes comprehensive research on Mexican banking APIs and Open Banking regulations in `investigacion_apis_bancarias_mexico.md`, covering integration options with major Mexican financial institutions.

## Important Dependencies

Key packages from pubspec.yaml:
- **provider**: ^6.1.1 - State management
- **sqflite**: ^2.3.0 - Local SQLite database
- **firebase_core**: ^2.24.0 - Firebase initialization
- **cloud_firestore**: ^4.13.3 - Cloud database
- **fl_chart**: ^0.66.0 - Financial charts and graphs
- **intl**: ^0.18.1 - Internationalization and date/number formatting
- **file_picker**: ^6.1.1 - Document/file selection
- **image_picker**: ^1.0.4 - Photo capture for receipts