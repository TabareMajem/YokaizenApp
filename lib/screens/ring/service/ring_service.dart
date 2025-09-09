import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for communicating with the Colmi R02 smart ring over Bluetooth LE
class RingService {
  // UUID constants for the Colmi R02 ring
  static const String _serviceUuid = '6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String _rxCharUuid = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String _txCharUuid = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';
  
  // Command codes for Colmi R02 rings
  static const int _cmdBattery = 0x03;
  static const int _cmdSteps = 0x07;
  static const int _cmdSetTime = 0x08;
  static const int _cmdHeartRate = 0x15;
  static const int _cmdSpO2 = 0x19;
  static const int _cmdSleep = 0x22;
  static const int _cmdFindRing = 0x10;
  
  // Command constants
  static const int _cmdStart = 0x01;
  static const int _cmdStop = 0x00;
  
  // Connection state
  BluetoothDevice? _device;
  BluetoothCharacteristic? _rxCharacteristic;
  BluetoothCharacteristic? _txCharacteristic;
  StreamSubscription? _txSubscription;
  StreamSubscription? _connectionSubscription;
  
  // Data streaming
  final StreamController<List<int>> _dataStreamController = StreamController<List<int>>.broadcast();
  Stream<List<int>> get dataStream => _dataStreamController.stream;
  
  // Reconnection management
  bool _autoReconnect = true;
  String? _lastConnectedDeviceId;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectInterval = Duration(seconds: 5);
  
  // Power management
  Timer? _powerSavingTimer;
  static const Duration _powerSavingInterval = Duration(minutes: 1);
  bool _isInActiveMeasurement = false;
  
  RingService() {
    if (kDebugMode) {
      print('RingService initialized');
    }
    _loadLastConnectedDevice();
  }
  
  // Load last connected device from preferences
  Future<void> _loadLastConnectedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastConnectedDeviceId = prefs.getString('last_connected_ring');
      if (kDebugMode) {
        print('Last connected device: $_lastConnectedDeviceId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading last connected device: $e');
      }
    }
  }
  
  // Save last connected device to preferences
  Future<void> _saveLastConnectedDevice(String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_connected_ring', deviceId);
      _lastConnectedDeviceId = deviceId;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving last connected device: $e');
      }
    }
  }
  
  // Scan for Colmi R02 rings
  Future<List<Map<String, String>>> scanForRings() async {
    final results = <Map<String, String>>[];
    // Track raw devices for backup
    final allDetectedDevices = <Map<String, String>>[];
    
    try {
      // Check if Bluetooth is on
      if (!(await FlutterBluePlus.isOn)) {
        if (kDebugMode) {
          print('Bluetooth is turned off, cannot scan');
        }
        return results;
      }
      
      // Clear any previous scan results
      await FlutterBluePlus.stopScan();
      
      if (kDebugMode) {
        print('Starting scan for ALL Bluetooth devices - will filter later...');
      }
      
      // Debug: Print adapter state
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (kDebugMode) {
        print('Bluetooth adapter state: $adapterState');
      }
      
      // Use a longer timeout and more aggressive scanning mode
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 60),  // Longer timeout for better discovery
        androidScanMode: AndroidScanMode.lowLatency, // Higher power scan mode
        withServices: [], // Don't filter by services
      );
      
      // Debug print helper to show we're scanning
      if (kDebugMode) {
        print('⚡ Scan started, waiting for devices...');
      }
      
      // Wait for scan results with a more robust approach
      bool receivedAnyResults = false;
      
      await for (final scanResult in FlutterBluePlus.scanResults) {
        if (kDebugMode && !receivedAnyResults) {
          print('📱 Received first scan result batch with ${scanResult.length} devices');
          receivedAnyResults = true;
        }
        
        // Process ALL devices - absolutely no filtering
        for (final result in scanResult) {
          final device = result.device;
          final name = device.platformName.trim();
          final address = device.remoteId.str;
          
          // Keep track of ALL detected devices, regardless of whether we add them to results
          allDetectedDevices.add({
            'name': name.isNotEmpty ? name : "Device ($address)",
            'address': address,
            'rssi': result.rssi.toString(),
            'isLikelyRing': 'true',
          });
          
          // Print ALL devices to help with debugging
          if (kDebugMode) {
            print('📡 Device: "$name" ($address) - RSSI: ${result.rssi} - ADV DATA: ${result.advertisementData.manufacturerData.isNotEmpty ? "YES" : "NO"}');
            // Dump the raw advertisement data to look for ring identifiers
            if (result.advertisementData.manufacturerData.isNotEmpty) {
              print('  📊 Manufacturer Data: ${result.advertisementData.manufacturerData}');
            }
            if (result.advertisementData.serviceData.isNotEmpty) {
              print('  📊 Service Data: ${result.advertisementData.serviceData}');
            }
            if (name.isEmpty) {
              print('  ⚠️ Empty name, but address matches ring format? ${address.contains("RO2") || address.contains("R02")}');
            }
          }
          
          // Add ALL devices without any filtering whatsoever
          // No deduplication, no checking anything - just add everything
          String displayName = name.isNotEmpty ? name : "Device ($address)";
          
          results.add({
            'name': displayName,
            'address': address,
            'isLikelyRing': 'true', // Mark ALL devices as potential rings
            'rssi': result.rssi.toString(),
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scanning for devices: $e');
      }
    } finally {
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        if (kDebugMode) {
          print('Error stopping scan: $e');
        }
      }
      
      if (kDebugMode) {
        print('🔍 Scan completed. Found ${results.length} total devices');
        if (results.isEmpty) {
          print('❗ WARNING: No devices found with names!');
          
          // If no results but we detected devices, use those as a fallback
          if (allDetectedDevices.isNotEmpty) {
            print('⚠️ Results list is empty but we detected ${allDetectedDevices.length} devices during scan.');
            print('🔄 Using ALL detected devices as results:');
            for (final device in allDetectedDevices) {
              print('   - ${device['name']} (${device['address']})');
            }
            return allDetectedDevices;
          }
        } else {
          print('📋 Device List:');
          for (final device in results) {
            print('   - ${device['name']} (${device['address']})');
          }
        }
      }
    }
    
    // Double check: if results is empty but we have detected devices, use those
    if (results.isEmpty && allDetectedDevices.isNotEmpty) {
      if (kDebugMode) {
        print('⚠️ Using backup list of ${allDetectedDevices.length} detected devices');
      }
      return allDetectedDevices;
    }
    
    // Return all devices without any sorting or filtering
    return results;
  }
  
  // Connect to a specific ring device
  Future<bool> connectToRing(String address) async {
    try {
      // Stop any ongoing scan
      await FlutterBluePlus.stopScan();
      
      // Cancel any running reconnect timer
      _reconnectTimer?.cancel();
      
      // Reset reconnect attempts
      _reconnectAttempts = 0;
      
      // Get the device by address
      final remoteId = DeviceIdentifier(address);
      _device = BluetoothDevice(remoteId: remoteId);
      
      // Connect to the device
      await _device!.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
      
      // Save as last connected device
      await _saveLastConnectedDevice(address);
      
      // Setup connection state monitoring for auto-reconnect
      _connectionSubscription?.cancel();
      _connectionSubscription = _device!.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected && _autoReconnect) {
          _handleDisconnection();
        }
      });
      
      // Discover services
      final services = await _device!.discoverServices();
      
      // Find the ring service
      BluetoothService? ringService;
      for (final service in services) {
        if (service.uuid.toString().toUpperCase() == _serviceUuid) {
          ringService = service;
          break;
        }
      }
      
      if (ringService == null) {
        if (kDebugMode) {
          print('Ring service not found');
        }
        await disconnectFromRing();
        return false;
      }
      
      // Find the RX and TX characteristics
      for (final characteristic in ringService.characteristics) {
        final uuid = characteristic.uuid.toString().toUpperCase();
        if (uuid == _rxCharUuid) {
          _rxCharacteristic = characteristic;
        } else if (uuid == _txCharUuid) {
          _txCharacteristic = characteristic;
        }
      }
      
      if (_rxCharacteristic == null || _txCharacteristic == null) {
        if (kDebugMode) {
          print('Required characteristics not found');
        }
        await disconnectFromRing();
        return false;
      }
      
      // Subscribe to TX notifications
      await _txCharacteristic!.setNotifyValue(true);
      _txSubscription = _txCharacteristic!.onValueReceived.listen((value) {
        _dataStreamController.add(value);
        // Reset power saving timer whenever we receive data
        _resetPowerSavingTimer();
      });
      
      // Set the time on the ring
      await setTime();
      
      // Start power saving timer
      _resetPowerSavingTimer();
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to device: $e');
      }
      await disconnectFromRing();
      return false;
    }
  }
  
  // Handle disconnection events and auto-reconnect
  void _handleDisconnection() {
    if (_reconnectAttempts >= _maxReconnectAttempts || !_autoReconnect || _lastConnectedDeviceId == null) {
      return;
    }
    
    _reconnectAttempts++;
    
    if (kDebugMode) {
      print('Device disconnected. Attempting to reconnect (${_reconnectAttempts}/$_maxReconnectAttempts)...');
    }
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectInterval, () async {
      if (_device == null && _lastConnectedDeviceId != null) {
        await connectToRing(_lastConnectedDeviceId!);
      }
    });
  }
  
  // Power saving timer management
  void _resetPowerSavingTimer() {
    // Cancel existing timer
    _powerSavingTimer?.cancel();
    
    // Create new timer only if we're not in an active measurement
    if (!_isInActiveMeasurement) {
      _powerSavingTimer = Timer(_powerSavingInterval, () {
        if (_device != null && _device!.isConnected) {
          // When timer expires, we can do power-saving operations
          // such as reducing notification frequency
          if (kDebugMode) {
            print('Entering power saving mode');
          }
        }
      });
    }
  }
  
  // Enable or disable auto reconnection
  void setAutoReconnect(bool enable) {
    _autoReconnect = enable;
    if (!enable) {
      _reconnectTimer?.cancel();
    }
  }
  
  // Disconnect from the ring
  Future<void> disconnectFromRing() async {
    try {
      _powerSavingTimer?.cancel();
      _reconnectTimer?.cancel();
      _connectionSubscription?.cancel();
      _txSubscription?.cancel();
      
      _connectionSubscription = null;
      _txSubscription = null;
      
      if (_device != null) {
        await _device!.disconnect();
        _device = null;
      }
      
      _rxCharacteristic = null;
      _txCharacteristic = null;
      _autoReconnect = true;
      _reconnectAttempts = 0;
      _isInActiveMeasurement = false;
    } catch (e) {
      if (kDebugMode) {
        print('Error disconnecting from device: $e');
      }
    }
  }
  
  // Send a command to the ring
  Future<bool> sendCommand(List<int> data) async {
    try {
      if (_rxCharacteristic == null) {
        return false;
      }
      
      // Mark as active measurement if this is a continuous sampling command
      if (data.length >= 2 && 
          (data[0] == _cmdHeartRate || data[0] == _cmdSpO2) && 
          data[1] == _cmdStart) {
        _isInActiveMeasurement = true;
      } else if (data.length >= 2 && 
                (data[0] == _cmdHeartRate || data[0] == _cmdSpO2) && 
                data[1] == _cmdStop) {
        _isInActiveMeasurement = false;
        // Reset power saving timer after stopping a measurement
        _resetPowerSavingTimer();
      }
      
      final packet = List<int>.from(data);
      // Pad with zeros to standard Colmi packet length (16 bytes incl. checksum)
      while (packet.length < 15) {
        packet.add(0);
      }
      
      // Add checksum
      final checksum = _calculateChecksum(packet);
      packet.add(checksum);
      
      // Implement a retry mechanism for reliability
      int retries = 0;
      const maxRetries = 3;
      
      while (retries < maxRetries) {
        try {
          await _rxCharacteristic!.write(packet, withoutResponse: false);
          return true;
        } catch (e) {
          retries++;
          if (retries >= maxRetries) {
            throw e;
          }
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error sending command: $e');
      }
      return false;
    }
  }
  
  // Get the battery level of the ring
  Future<int> getBatteryLevel() async {
    try {
      // Battery request command
      final success = await sendCommand([_cmdBattery]);
      if (!success) {
        return 0;
      }
      
      // Wait for response with improved parsing
      final completer = Completer<int>();
      final subscription = dataStream.listen((data) {
        if (data.isNotEmpty && data[0] == _cmdBattery) {
          // Validate range of battery level (0-100)
          final batteryLevel = data[1];
          if (batteryLevel >= 0 && batteryLevel <= 100) {
            completer.complete(batteryLevel);
          } else {
            if (kDebugMode) {
              print('Invalid battery level: $batteryLevel');
            }
            completer.complete(0);
          }
        }
      });
      
      final result = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => 0,
      );
      
      subscription.cancel();
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting battery level: $e');
      }
      return 0;
    }
  }
  
  // Get real-time heart rate with improved measurement reliability
  Future<int> getRealtimeHeartRate() async {
    try {
      // Real-time heart rate request command
      final success = await sendCommand([_cmdHeartRate, _cmdStart]);
      if (!success) {
        return 0;
      }
      
      // Wait for response with validation
      final completer = Completer<int>();
      final heartRateValues = <int>[];
      
      final subscription = dataStream.listen((data) {
        if (data.isNotEmpty && data[0] == _cmdHeartRate) {
          final heartRate = data[1];
          
          // Validate heart rate (typically 40-220 bpm for humans)
          if (heartRate >= 40 && heartRate <= 220) {
            heartRateValues.add(heartRate);
            
            // Once we have 3 consistent readings, we complete
            if (heartRateValues.length >= 3) {
              // Get median value for more reliable reading
              heartRateValues.sort();
              final medianValue = heartRateValues[heartRateValues.length ~/ 2];
              completer.complete(medianValue);
            }
          }
        }
      });
      
      final result = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          // If we have at least one valid reading, use that
          if (heartRateValues.isNotEmpty) {
            heartRateValues.sort();
            return heartRateValues[heartRateValues.length ~/ 2];
          }
          return 0;
        },
      );
      
      // Stop heart rate measurement
      await sendCommand([_cmdHeartRate, _cmdStop]);
      
      subscription.cancel();
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting real-time heart rate: $e');
      }
      // Make sure to stop measurement on error
      await sendCommand([_cmdHeartRate, _cmdStop]);
      return 0;
    }
  }
  
  // Get real-time SPO2 with improved accuracy
  Future<int> getRealtimeSpo2() async {
    try {
      // Real-time SPO2 request command
      final success = await sendCommand([_cmdSpO2, _cmdStart]);
      if (!success) {
        return 0;
      }
      
      // Wait for response with validation
      final completer = Completer<int>();
      final spo2Values = <int>[];
      
      final subscription = dataStream.listen((data) {
        if (data.isNotEmpty && data[0] == _cmdSpO2) {
          final spo2 = data[1];
          
          // Validate SPO2 (typically 80-100% for healthy individuals)
          if (spo2 >= 80 && spo2 <= 100) {
            spo2Values.add(spo2);
            
            // Once we have 3 consistent readings, we complete
            if (spo2Values.length >= 3) {
              // Sort and take the median for better reliability
              spo2Values.sort();
              final medianValue = spo2Values[spo2Values.length ~/ 2];
              completer.complete(medianValue);
            }
          }
        }
      });
      
      final result = await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          // If we have at least one valid reading, use that
          if (spo2Values.isNotEmpty) {
            spo2Values.sort();
            return spo2Values[spo2Values.length ~/ 2];
          }
          return 0;
        },
      );
      
      // Stop SPO2 measurement
      await sendCommand([_cmdSpO2, _cmdStop]);
      
      subscription.cancel();
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting real-time SPO2: $e');
      }
      // Make sure to stop measurement on error
      await sendCommand([_cmdSpO2, _cmdStop]);
      return 0;
    }
  }
  
  // Get step count with improved parsing
  Future<int> getStepCount() async {
    try {
      // Step count request command
      final success = await sendCommand([_cmdSteps]);
      if (!success) {
        return 0;
      }
      
      // Wait for response
      final completer = Completer<int>();
      final subscription = dataStream.listen((data) {
        if (data.isNotEmpty && data[0] == _cmdSteps && data.length >= 5) {
          try {
            // Parse step count - Colmi rings use little endian format
            // Steps are in bytes 1-4
            final steps = data[1] + (data[2] << 8) + (data[3] << 16) + (data[4] << 24);
            
            // Sanity check (steps shouldn't exceed reasonable daily amount)
            if (steps >= 0 && steps <= 100000) {
              completer.complete(steps);
            } else {
              if (kDebugMode) {
                print('Invalid step count: $steps');
              }
              completer.complete(0);
            }
          } catch (e) {
            completer.complete(0);
          }
        }
      });
      
      final result = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => 0,
      );
      
      subscription.cancel();
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting step count: $e');
      }
      return 0;
    }
  }
  
  // Get sleep data (only available on some Colmi models)
  Future<Map<String, dynamic>?> getSleepData() async {
    try {
      // Sleep data request command
      final success = await sendCommand([_cmdSleep]);
      if (!success) {
        return null;
      }
      
      // Wait for response - sleep data can be complex and multi-packet
      final completer = Completer<Map<String, dynamic>?>();
      final buffer = <int>[];
      
      final subscription = dataStream.listen((data) {
        if (data.isNotEmpty && data[0] == _cmdSleep) {
          // Colmi sleep data typically has multiple records
          // Format: [cmd, total_len, current_packet, ...]
          buffer.addAll(data.sublist(3));
          
          // Check if we have received the complete sleep data
          // This is simplified - actual implementation would need
          // to track packet numbers and handle partial data
          if (buffer.length >= data[1]) {
            try {
              // Parse sleep data based on Colmi format
              // This is a simplified implementation
              final sleepData = _parseSleepData(buffer);
              completer.complete(sleepData);
            } catch (e) {
              if (kDebugMode) {
                print('Error parsing sleep data: $e');
              }
              completer.complete(null);
            }
          }
        }
      });
      
      final result = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      
      subscription.cancel();
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sleep data: $e');
      }
      return null;
    }
  }
  
  // Parse sleep data from Colmi format
  Map<String, dynamic>? _parseSleepData(List<int> buffer) {
    // This is a placeholder implementation
    // Actual parsing would depend on Colmi's specific data format
    if (buffer.length < 10) {
      return null;
    }
    
    try {
      // Parse time asleep in minutes
      final timeAsleep = buffer[0] + (buffer[1] << 8);
      
      // Parse sleep quality (0-100)
      final quality = buffer[2];
      
      // Parse sleep stages
      // Format is typically: [stage_type, duration_minutes, stage_type, duration_minutes, ...]
      final sleepStages = <Map<String, dynamic>>[];
      
      for (int i = 3; i < buffer.length - 1; i += 2) {
        final stageType = buffer[i];
        final duration = buffer[i + 1];
        
        // Only add valid sleep stages
        if (duration > 0) {
          sleepStages.add({
            'stage': _mapSleepStage(stageType),
            'durationMinutes': duration,
          });
        }
      }
      
      return {
        'timeAsleepMinutes': timeAsleep,
        'quality': quality,
        'stages': sleepStages,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error in sleep data parsing: $e');
      }
      return null;
    }
  }
  
  // Map Colmi sleep stage values to our app's sleep stage types
  String _mapSleepStage(int stageValue) {
    switch (stageValue) {
      case 0: return 'awake';
      case 1: return 'light';
      case 2: return 'deep';
      case 3: return 'rem';
      default: return 'light';
    }
  }
  
  // Find ring (makes the ring vibrate to locate it)
  Future<bool> findRing() async {
    try {
      // Find ring command
      return await sendCommand([_cmdFindRing, 0x01]);
    } catch (e) {
      if (kDebugMode) {
        print('Error finding ring: $e');
      }
      return false;
    }
  }
  
  // Set the time on the ring
  Future<bool> setTime() async {
    try {
      final now = DateTime.now();
      
      // Set time command (0x08)
      final data = [
        _cmdSetTime,
        now.year & 0xFF,
        (now.year >> 8) & 0xFF,
        now.month,
        now.day,
        now.hour,
        now.minute,
        now.second,
      ];
      
      return await sendCommand(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting time: $e');
      }
      return false;
    }
  }
  
  // Get the connection status of the device
  bool isConnected() {
    return _device != null && _device!.isConnected;
  }
  
  // Get the current device name
  String getDeviceName() {
    return _device?.platformName ?? '';
  }
  
  // Calculate a checksum for a packet
  // Based on the Colmi R02 protocol
  int _calculateChecksum(List<int> bytes) {
    int sum = 0;
    for (int i = 0; i < bytes.length; i++) {
      sum += bytes[i];
    }
    return sum % 255;
  }
  
  // Dispose method to clean up resources
  void dispose() {
    _powerSavingTimer?.cancel();
    _reconnectTimer?.cancel();
    _connectionSubscription?.cancel();
    _txSubscription?.cancel();
    _dataStreamController.close();
    disconnectFromRing();
  }

  // Get device information such as firmware version, battery level, etc.
  Future<Map<String, dynamic>> getDeviceInfo(BluetoothDevice device) async {
    Map<String, dynamic> deviceInfo = {
      'firmwareVersion': '1.0.0',
      'batteryLevel': 0,
      'model': 'Colmi R02',
      'manufacturer': 'Colmi',
    };
    
    try {
      // Try to read the device info if connected
      if (device.isConnected) {
        // Get device name
        deviceInfo['name'] = device.platformName;
        
        // Get battery level if available
        final batteryLevel = await getBatteryLevel();
        if (batteryLevel != null) {
          deviceInfo['batteryLevel'] = batteryLevel;
        }
        
        // Try to read firmware version from service data if available
        try {
          final services = await device.discoverServices();
          for (final service in services) {
            // Device Information Service
            if (service.uuid.toString().toUpperCase() == '180A') {
              for (final characteristic in service.characteristics) {
                // Firmware Revision String
                if (characteristic.uuid.toString().toUpperCase() == '2A26') {
                  final data = await characteristic.read();
                  final firmware = String.fromCharCodes(data);
                  deviceInfo['firmwareVersion'] = firmware;
                }
                // Model Number String
                else if (characteristic.uuid.toString().toUpperCase() == '2A24') {
                  final data = await characteristic.read();
                  final model = String.fromCharCodes(data);
                  deviceInfo['model'] = model;
                }
                // Manufacturer Name String
                else if (characteristic.uuid.toString().toUpperCase() == '2A29') {
                  final data = await characteristic.read();
                  final manufacturer = String.fromCharCodes(data);
                  deviceInfo['manufacturer'] = manufacturer;
                }
              }
              break;
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error reading device info: $e');
          }
          // Use defaults if there's an error
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getDeviceInfo: $e');
      }
      // Return defaults on error
    }
    
    return deviceInfo;
  }
} 