# Change the IP Address in the app api url / if hosted locally

# Frontend - IVFLOW

## Installation and Setup

1. **Install Flutter globally:**

   ```bash
   npm install -g flutter
   ```

2. **Create a new Flutter project:**

   ```bash
   flutter create frontend
   cd frontend
   ```

3. **Add dependencies:**
   Update `pubspec.yaml` with the following dependencies:

   ```yaml
   dependencies:
     flutter_blue_plus: ^1.34.5
     permission_handler: ^11.3.1
   ```

4. **Fetch the dependencies:**

   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons:main # For overriding the launcher icons with our own in assets folder
   ```

5. **Run the project:**
   ```bash
   flutter run
   ```

## Key Commands during Flutter Run

- `r` - Hot reload.
- `R` - Hot restart.
- `h` - List all available interactive commands.
- `d` - Detach (terminate `flutter run` but leave application running).
- `c` - Clear the screen.
- `q` - Quit (terminate the application on the device).

## Useful Links

- [BLE Devices in Flutter - Bluetooth Low Energy Tutorial](https://protocoderspoint.com/ble-devices-in-flutter-bluetooth-low-energy/)

- [Flutter SDK Installation Tutorial](https://www.youtube.com/watch?v=wvPVt6ubF4Q/)
