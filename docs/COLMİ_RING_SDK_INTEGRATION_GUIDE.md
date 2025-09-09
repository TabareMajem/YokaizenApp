# Colmi Ring SDK Integration Guide

## Overview

This guide explains how the Colmi ring SDK has been integrated into the YokaiZen Flutter application. The integration provides a unified notification system that combines Firebase Cloud Messaging with direct ring notifications.

## Architecture

### Hybrid Approach
- **SDK as Primary Interface**: Uses the native Colmi SDK for reliable ring communication
- **Unified Backend Service**: Single API endpoint for notifications that decides whether to use SDK or direct API
- **Fallback Mechanism**: Falls back to app notifications if ring is not connected

### File Structure
```
lib/
├── services/
│   ├── colmi_ring_service.dart          # Flutter service for ring operations
│   ├── unified_notification_service.dart # Combined notification service
│   └── notification_service.dart        # Original Firebase service
├── screens/
│   └── ring_management/
│       └── ring_management_screen.dart  # Test UI for ring operations
android/
├── app/
│   ├── libs/
│   │   └── qc_sdk.aar                   # Android SDK
│   └── src/main/kotlin/
│       └── ColmiRingPlugin.kt           # Android native implementation
ios/
├── Runner/
│   ├── QCBandSDK.framework/             # iOS SDK
│   └── ColmiRingPlugin.swift            # iOS native implementation
```

## Features Implemented

### 1. Device Management
- **Scan for Devices**: Discover available Colmi rings
- **Connect/Disconnect**: Manage ring connections
- **Connection State Monitoring**: Real-time connection status

### 2. Notification System
- **Unified Notifications**: Send to both app and ring simultaneously
- **Notification Types**: Health, workout, medication, and custom reminders
- **Smart Routing**: Automatically routes notifications based on content

### 3. Health Data
- **Battery Level**: Get ring battery status
- **Firmware Version**: Check device firmware
- **Health Metrics**: Steps, heart rate, sleep data
- **Real-time Data**: Stream health data updates

### 4. Device Controls
- **Find Phone**: Trigger ring's find phone feature
- **Set Time**: Synchronize device time
- **Custom Commands**: Send custom notifications

## Usage Examples

### Initialize the Service
```dart
final notificationService = UnifiedNotificationService();
await notificationService.initialize();
```

### Scan and Connect to Ring
```dart
// Start scanning
final devices = await notificationService.startRingScan();

// Connect to a device
final success = await notificationService.connectToRing(
  deviceId, 
  deviceName: 'My Ring'
);
```

### Send Notifications
```dart
// Send health reminder
await notificationService.sendHealthReminder(
  message: 'Time for your health check!',
  title: 'Health Reminder',
);

// Send custom notification
await notificationService.sendCustomNotification(
  title: 'Custom Title',
  message: 'Custom message',
  type: RingNotificationType.custom,
  duration: 5000,
);
```

### Monitor Connection State
```dart
notificationService.ringConnectionStateStream.listen((state) {
  switch (state) {
    case RingConnectionState.connected:
      print('Ring connected');
      break;
    case RingConnectionState.disconnected:
      print('Ring disconnected');
      break;
    case RingConnectionState.connecting:
      print('Connecting to ring...');
      break;
    case RingConnectionState.error:
      print('Connection error');
      break;
  }
});
```

### Get Health Data
```dart
// Get battery level
final batteryLevel = await notificationService.getRingBatteryLevel();

// Get health data
final healthData = await notificationService.getRingHealthData();

// Listen to real-time health data
notificationService.healthDataStream.listen((data) {
  print('Steps: ${data['steps']}');
  print('Heart Rate: ${data['heartRate']}');
});
```

## Backend Integration

### Recommended Backend Structure
```javascript
// Single notification endpoint
POST /api/notifications
{
  "type": "health_reminder",
  "userId": "123",
  "message": "Time for your workout!",
  "priority": "high",
  "sendToRing": true
}
```

### Backend Decision Logic
```javascript
class NotificationService {
  async sendNotification(data) {
    // 1. Send to Firebase (always)
    await this.sendToFirebase(data);
    
    // 2. Send to ring if requested and user has connected ring
    if (data.sendToRing && await this.userHasConnectedRing(data.userId)) {
      await this.sendToRing(data);
    }
  }
}
```

## Testing

### Ring Management Screen
Navigate to the ring management screen to test all features:
```dart
Get.to(() => const RingManagementScreen());
```

### Test Features
1. **Device Scanning**: Test device discovery
2. **Connection Management**: Test connect/disconnect
3. **Notification Testing**: Send test notifications
4. **Health Data**: Retrieve battery and health information
5. **Real-time Monitoring**: Monitor connection state and data streams

## Troubleshooting

### Common Issues

1. **SDK Not Found**
   - Ensure `qc_sdk.aar` is in `android/app/libs/`
   - Ensure `QCBandSDK.framework` is in `ios/Runner/`

2. **Bluetooth Permissions**
   - Android: Check manifest permissions
   - iOS: Check Info.plist permissions

3. **Connection Failures**
   - Verify ring is in pairing mode
   - Check Bluetooth is enabled
   - Ensure ring is within range

4. **Notification Not Sending**
   - Verify ring is connected
   - Check notification permissions
   - Review notification type mapping

### Debug Logs
Enable debug logging in the native implementations:
```kotlin
// Android
Log.d("ColmiRingPlugin", "Debug message")
```
```swift
// iOS
print("Debug message")
```

## Performance Considerations

### Battery Optimization
- Stop scanning when not needed
- Disconnect when app goes to background
- Use appropriate notification durations

### Memory Management
- Dispose of streams when not needed
- Clean up native resources
- Monitor connection state changes

## Security

### Data Protection
- Health data is processed locally
- No sensitive data sent to external servers
- Bluetooth communication is encrypted

### Permission Handling
- Request permissions only when needed
- Graceful fallback when permissions denied
- Clear permission explanations

## Future Enhancements

### Planned Features
1. **Offline Support**: Queue notifications when ring is disconnected
2. **Batch Operations**: Send multiple notifications efficiently
3. **Custom Ring Patterns**: Define custom vibration patterns
4. **Health Analytics**: Advanced health data analysis
5. **Multi-device Support**: Connect to multiple rings

### API Improvements
1. **Webhook Integration**: Real-time health data to backend
2. **Scheduled Notifications**: Time-based notification scheduling
3. **Conditional Notifications**: Context-aware notifications
4. **User Preferences**: Customizable notification settings

## Support

For technical support or questions about the integration:
1. Check the debug logs for error messages
2. Verify SDK versions are compatible
3. Test with the provided ring management screen
4. Review the native implementation code

## Conclusion

The Colmi ring SDK integration provides a robust foundation for ring-based notifications and health monitoring. The hybrid approach ensures reliability while maintaining a clean API for the backend team. The unified notification service automatically handles the complexity of different notification types and device states. 