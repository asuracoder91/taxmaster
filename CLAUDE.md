# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tax Master (세금 계산기) - A comprehensive Korean tax calculator Flutter application supporting:
- 종합소득세 (Income Tax)
- 법인세 (Corporate Tax)
- 양도소득세 (Capital Gains Tax)
- 상속세 (Inheritance Tax)
- 증여세 (Gift Tax)
- 퇴직소득세 (Retirement Income Tax)

Based on 2025 Korean tax law (소득세법, 법인세법, 상속세 및 증여세법).

## Common Commands

```bash
# Get dependencies
flutter pub get

# Run code generation (freezed, json_serializable, injectable, hive adapters)
dart run build_runner build --delete-conflicting-outputs

# Run code generation in watch mode
dart run build_runner watch --delete-conflicting-outputs

# Analyze code
flutter analyze

# Run tests
flutter test

# Run single test file
flutter test test/widget_test.dart

# Run app in debug mode
flutter run

# Build Android APK
flutter build apk

# Build Android App Bundle
flutter build appbundle
```

## Architecture

### Clean Architecture with Feature-First Organization

```
lib/
├── main.dart                    # App entry, Hive initialization
├── app.dart                     # TaxMasterApp root widget, theme/router config
├── injection.dart               # GetIt + Injectable DI setup
├── core/
│   ├── constants/
│   │   ├── tax_rates.dart       # Tax bracket definitions (TaxBracket class, *TaxRates classes)
│   │   ├── deduction_rates.dart # Deduction calculation logic
│   │   └── app_constants.dart   # App-wide constants
│   ├── utils/
│   │   ├── tax_calculator_utils.dart  # TaxCalculatorUtils with all tax calculation methods
│   │   └── number_formatter.dart      # Currency/number formatting
│   ├── router/app_router.dart   # GoRouter configuration with ShellRoute
│   └── theme/app_theme.dart     # Light/dark theme definitions
├── features/                    # Feature modules (Clean Architecture layers)
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/     # Local/remote data sources
│       │   ├── models/          # Data transfer objects
│       │   └── repositories/    # Repository implementations
│       ├── domain/
│       │   ├── entities/        # Business entities
│       │   ├── repositories/    # Repository interfaces
│       │   └── usecases/        # Use cases
│       └── presentation/
│           ├── bloc/            # BLoC state management
│           ├── screens/         # Screen widgets
│           └── widgets/         # Feature-specific widgets
└── shared/widgets/              # Reusable widgets (TaxInputField, TaxResultCard, MainScaffold)
```

### Key Patterns

**Tax Calculation Flow**: All tax calculations go through `TaxCalculatorUtils` which uses rate tables from `tax_rates.dart` and deduction logic from `deduction_rates.dart`. Returns `TaxCalculationResult` with breakdown details.

**Navigation**: GoRouter with `ShellRoute` wrapping `MainScaffold` for persistent bottom navigation. Routes defined in `AppRoutes` class.

**State Management**: flutter_bloc for feature-level state (BLoC pattern). Currently screens manage local state directly.

**DI**: GetIt + Injectable. Run `build_runner` after adding `@injectable` annotations.

**Local Storage**: Hive CE for persistence (adapters not yet implemented).

## Tech Stack

- **Flutter SDK**: ^3.10.0
- **State Management**: flutter_bloc 8.x, bloc 8.x
- **DI**: get_it, injectable
- **Code Gen**: freezed, json_serializable, build_runner
- **Storage**: hive_ce_flutter
- **Routing**: go_router
- **UI**: flutter_screenutil, google_fonts, fl_chart
- **Utils**: intl (formatting), dartz (functional), equatable
- **Testing**: bloc_test, mocktail

## Tax Law Reference

The `docs/` directory contains Korean tax law documents (법률, 시행령) in .docx format for reference when implementing or updating tax calculations.
