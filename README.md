Personal Budget Manager

A lightweight Flutter application demonstrating clean UI design, local state management, and basic financial data handling.
Built as a front-end–only project to showcase Flutter fundamentals and app architecture.

Author: Dek Abdi
Role: Flutter Developer
Platform: Android · iOS · Web · Desktop

Overview

The Personal Budget Manager enables users to:

Record income and expenses

Categorize transactions

View financial summaries

Analyze spending distribution by category

The project focuses on clarity, simplicity, and maintainable Flutter code.

Key Features

Dashboard with balance, income, and expense totals

Transaction creation and deletion

Category-based expense tracking

Basic statistics with visual indicators

Material 3 UI and bottom navigation

Technical Details

Framework: Flutter (Dart)

State Management: Local state (StatefulWidget)

UI: Material Design 3

Data Handling: In-memory models (no persistence)

Architecture: Single-entry app with reusable widgets

Project Structure
lib/
 └── main.dart   // Complete application logic and UI


The app is intentionally kept in a single file for demonstration purposes and can be refactored into a layered architecture if scaled.

Getting Started
git clone https://github.com/Dek28/personal_budget_manager.git
cd personal_budget_manager
flutter pub get
flutter run

Limitations & Future Work

No persistent storage (data resets on restart)

No backend or authentication

Planned improvements:

Local database (SQLite / Hive)

Backend integration (REST / Firebase)

Advanced analytics and charts

Purpose

This project serves as a portfolio demonstration of Flutter development skills, UI composition, and application logic design