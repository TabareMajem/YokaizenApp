# YokaizenApp - Smart Ring Integration

A Flutter app with Colmi R02 smart ring integration.

## Smart Ring Integration

This app supports integration with Colmi R02 family of smart rings, including:
- Colmi R02
- Colmi R06
- Colmi R10

The integration allows you to:
- Connect to your smart ring via Bluetooth
- Monitor heart rate in real-time
- Track SPO2 (blood oxygen) levels
- Count steps
- Analyze sleep patterns
- Check stress levels

## Getting Started

### Prerequisites

- Flutter 3.6.0 or higher
- Android device with API 21+ or iOS device with iOS 11+
- Bluetooth enabled on your device
- A compatible Colmi R02 family smart ring

### Installation

1. Clone this repository
```bash
git clone https://github.com/your-username/YokaizenApp.git
```

2. Install dependencies
```bash
cd YokaizenApp
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Using the Smart Ring Feature

1. Navigate to the Ring section in the app
2. Tap "Scan for Rings"
3. Select your ring from the list of discovered devices
4. Once connected, you'll see real-time data from your ring

## Troubleshooting

If you encounter issues connecting to your smart ring:

1. Make sure Bluetooth is enabled on your device
2. Ensure your ring is charged and within range
3. Restart your ring by placing it in the charger
4. Try restarting the app and your device

## References

- [Colmi R02 Client Python Library](https://github.com/tahnok/colmi_r02_client) - Python client for the Colmi R02 ring
- [Flutter Blue Plus](https://pub.dev/packages/flutter_blue_plus) - Bluetooth Low Energy library for Flutter

## License

This project is licensed under the MIT License - see the LICENSE file for details.
