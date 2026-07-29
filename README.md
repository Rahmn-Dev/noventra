# Noventra Inventory

<img width="1920" height="1440" alt="219_1x_shots_so" src="https://github.com/user-attachments/assets/86ba4b4d-3aa5-4aa8-be29-c357981d4366" />


Noventra Inventory is an offline warehouse and inventory management application built with Flutter.

The application allows users to scan item codes using OCR, manage stock movements, track inventory transactions, and monitor warehouse activities without requiring an internet connection.

---

## Features

### Inventory Management

- Add new inventory items
- Edit item information
- Search items by code or name
- View detailed item information
- Offline SQLite database

### OCR Item Scanning

- Scan item codes directly using the device camera
- OCR-based text recognition
- Automatic item lookup from local database
- Supports inventory codes such as:

```text
T.230001003.00470
```

### Stock Transactions

- Stock In
- Stock Out
- Quantity tracking
- Transaction notes

### History & Audit Trail

- Complete transaction history
- Stock movement records
- Date and time tracking
- Audit trail for inventory activities

### Dashboard

- Total inventory items
- Total stock quantity
- Daily stock movements
- Low stock monitoring

---

## Technology Stack

- Flutter
- Dart
- SQLite
- Riverpod
- Go Router
- Camera Plugin
- Google ML Kit OCR

---

## Screenshots
<img width="1920" height="1440" alt="773_1x_shots_so" src="https://github.com/user-attachments/assets/a4190f75-10a3-4405-899b-559934a22a09" />
<img width="1920" height="1440" alt="763_1x_shots_so" src="https://github.com/user-attachments/assets/2674e67a-720e-43b5-b231-9a55dd4809c5" />

---

## Project Structure

```text
lib/
├── database/
├── models/
├── providers/
├── screens/
├── main.dart
```

---

## Workflow

```text
Scan Item
    ↓
OCR Recognition
    ↓
Find Item in SQLite
    ↓
Display Item Details
    ↓
Stock In / Stock Out
    ↓
Save Transaction History
```

---

## Sample Inventory Code

```text
T.230001003.00470
T.230200300.04020
T.191511302.80320
```

---

## Installation

Clone the repository:

```bash
git clone https://github.com/Rahmn-Dev/noventra.git
```

Install dependencies:

```bash
flutter pub get
```

Run application:

```bash
flutter run
```

Build APK:

```bash
flutter build apk --release
```

---

## Future Improvements

- Realtime OCR scanning
- Multi warehouse support
- Export to Excel/PDF
- Cloud synchronization
- User authentication
- Barcode and QR code support
- Inventory reporting

---

## License

This project is developed for educational, portfolio, and warehouse inventory management purposes.
