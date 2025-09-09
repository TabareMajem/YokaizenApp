import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/screens/ring/controller/ring_controller.dart';
import 'package:yokai_quiz_app/screens/ring/view/direct_device_list.dart';
import 'package:yokai_quiz_app/screens/ring/view/ring_sleep_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:yokai_quiz_app/global.dart'; // Import for customPrint
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/api/local_storage.dart'; // Import for LocalStorage
import 'package:yokai_quiz_app/screens/ring/models/smart_ring_response.dart'; // Import SmartRingResponse

class RingScreen extends StatefulWidget {
  const RingScreen({super.key});

  @override
  State<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends State<RingScreen> with WidgetsBindingObserver {
  final RingController _controller = Get.put(RingController());
  bool isDialogShowing = false;
  bool _isReturningFromSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Check for saved device and verify with API
    _checkSavedDevice();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (Platform.isIOS) {
      // Handle iOS specific behavior when returning from Settings
      if (state == AppLifecycleState.resumed && _isReturningFromSettings) {
        _isReturningFromSettings = false;
        // Delay the permission check to ensure iOS has time to update permission status
        Future.delayed(const Duration(milliseconds: 500), () {
          _refreshPermissionStatus();
        });
      } else if (state == AppLifecycleState.paused) {
        // Mark that we might be going to settings
        _isReturningFromSettings = true;
      }
    }
  }
  
  // Add method to check and request permissions
  Future<bool> _checkAndRequestPermissions({bool silentCheck = false}) async {
    try {
      if (kDebugMode) {
        print("🔍 Checking Bluetooth permissions");
      }
      
      if (Platform.isAndroid) {
        // Android permissions
        final locationPermission = await Permission.location.status;
        final bluetoothPermission = await Permission.bluetooth.status;
        final bluetoothConnectPermission = await Permission.bluetoothConnect.status;
        final bluetoothScanPermission = await Permission.bluetoothScan.status;
        
        if (kDebugMode) {
          print("📱 Android permission status: location=${locationPermission.isGranted}, "
              "bluetooth=${bluetoothPermission.isGranted}, "
              "bluetoothConnect=${bluetoothConnectPermission.isGranted}, "
              "bluetoothScan=${bluetoothScanPermission.isGranted}");
        }
        
        // If silently checking, only return status
        if (silentCheck) {
          return locationPermission.isGranted && 
                (bluetoothPermission.isGranted || 
                (bluetoothConnectPermission.isGranted && bluetoothScanPermission.isGranted));
        }
        
        // Request permissions if needed
        if (!locationPermission.isGranted) {
          final result = await Permission.location.request();
          if (!result.isGranted) return false;
        }
        
        // On Android 12+, use the new permissions
        if (await Permission.bluetoothConnect.request().isGranted &&
            await Permission.bluetoothScan.request().isGranted) {
          return true;
        }
        
        // Legacy permission for older Android
        if (await Permission.bluetooth.request().isGranted) {
          return true;
        }
        
        return false;
      } else if (Platform.isIOS) {
        // iOS permissions - simpler as iOS handles this at system level
        try {
          final isAvailable = await FlutterBluePlus.isAvailable;
          
          if (kDebugMode) {
            print("🍎 iOS Bluetooth available: $isAvailable");
          }
          
          if (silentCheck) {
            return isAvailable;
          }
          
          // If not available, we need to ask the user to enable it in settings
          if (!isAvailable) {
            // This will show our custom dialog asking the user to go to settings
            return false;
          }
          
          return true;
        } catch (e) {
          if (kDebugMode) {
            print("🍎 iOS permission check error: $e");
          }
          return false;
        }
      }
      
      // Unsupported platform
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ Permission check error: $e");
      }
      return false;
    }
  }
  
  // Add a method to refresh permission status safely
  Future<void> _refreshPermissionStatus() async {
    try {
      if (kDebugMode) {
        print("🔄 Refreshing permission status after returning from settings");
      }
      
      // For iOS, check Bluetooth access directly first
      bool permissionsGranted = false;
      bool bluetoothOn = false;
      
      if (Platform.isIOS) {
        try {
          // Try direct FlutterBluePlus checks first
          final isAvailable = await FlutterBluePlus.isAvailable;
          final isOn = await FlutterBluePlus.isOn;
          
          if (kDebugMode) {
            print("🍎 iOS direct check: isAvailable=$isAvailable, isOn=$isOn");
          }
          
          permissionsGranted = isAvailable;
          bluetoothOn = isOn;
        } catch (e) {
          if (kDebugMode) {
            print("🍎 iOS direct check failed, falling back: $e");
          }
          
          // Fall back to regular check if direct access fails
          permissionsGranted = await _checkAndRequestPermissions(silentCheck: true);
          final btState = await _controller.checkBluetoothPermissionAndState();
          bluetoothOn = btState['isOn'] ?? false;
        }
      } else {
        // Regular check for other platforms
        permissionsGranted = await _checkAndRequestPermissions(silentCheck: true);
        final btState = await _controller.checkBluetoothPermissionAndState();
        bluetoothOn = btState['isOn'] ?? false;
      }
      
      if (kDebugMode) {
        print("📊 Refresh result: permissionsGranted=$permissionsGranted, bluetoothOn=$bluetoothOn, isDialogShowing=$isDialogShowing");
      }
      
      if (permissionsGranted && bluetoothOn && isDialogShowing) {
        // If we have all permissions and Bluetooth is on, close any dialog and start scanning
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        _showActualScanDialog(context);
      } else if (permissionsGranted && !bluetoothOn && isDialogShowing) {
        // We have permissions but Bluetooth is off
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        _showBluetoothOffDialog(context);
      } else if (!permissionsGranted && isDialogShowing) {
        // Still need permissions, but dialog is already showing - no action needed
      } else if (!permissionsGranted && !isDialogShowing) {
        // Need to show permission dialog
        _showPermissionDeniedDialog(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error refreshing permission status: $e');
      }
      // Don't crash the app, handle gracefully
    }
  }

  // Add the dialog methods that were missing
  void _showActualScanDialog(BuildContext context) {
    // Set flag to indicate dialog is showing
    setState(() {
      isDialogShowing = true;
    });
    
    // Use a separate variable to track if this specific dialog is active
    bool isThisDialogActive = true;
    
    // Start a real scan for actual Bluetooth devices
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Define a safe setState function that checks if the dialog is still active
            void safeSetState(VoidCallback fn) {
              // Only call setState if the dialog is still active
              if (isThisDialogActive && context.mounted) {
                setDialogState(fn);
              }
            }
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(25.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Scanning for Devices'.tr,
                            style: AppTextStyle.normalBold18,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Please wait while we look for nearby devices'.tr,
                            style: AppTextStyle.normalRegular14,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    StreamBuilder<List<ScanResult>>(
                      stream: FlutterBluePlus.scanResults,
                      initialData: const [],
                      builder: (c, snapshot) {
                        List<ScanResult> scanResults = snapshot.data ?? [];
                        
                        // Filter for likely ring devices
                        final filteredResults = scanResults.where((result) {
                          final name = result.device.platformName;
                          // Filter for common ring device names
                          return name.isNotEmpty && 
                                 (name.contains('Ring') || 
                                  name.contains('R02') || 
                                  name.contains('RO2') || 
                                  name.contains('QRING') ||
                                  name.contains('JODU') ||
                                  name.startsWith('Colmi'));
                        }).toList();
                        
                        if (filteredResults.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                const CircularProgressIndicator(),
                                const SizedBox(height: 20),
                                Text(
                                  'Searching for devices...'.tr,
                                  style: AppTextStyle.normalRegular14,
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredResults.length,
                            itemBuilder: (context, index) {
                              final result = filteredResults[index];
                              final device = result.device;
                              final deviceName = device.platformName.isNotEmpty
                                  ? device.platformName
                                  : 'Unknown Device'.tr;
                              
                              return ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.purple.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.bluetooth,
                                      color: AppColors.purple,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  deviceName,
                                  style: AppTextStyle.normalBold14,
                                ),
                                subtitle: Text(
                                  'RSSI: ${result.rssi} dBm',
                                  style: AppTextStyle.normalRegular12,
                                ),
                                trailing: const Icon(Icons.bluetooth, color: Colors.blue, size: 20),
                                onTap: () async {
                                  // Stop scanning
                                  FlutterBluePlus.stopScan();
                                  
                                  // Mark dialog as inactive before closing it
                                  isThisDialogActive = false;
                                  
                                  // Close the dialog
                                  Navigator.of(context).pop();
                                  
                                  // Show loading
                                  _controller.isLoading.value = true;
                                  
                                  try {
                                    if (kDebugMode) {
                                      print('User selected device: ${device.platformName} (${device.remoteId.str})');
                                      print('Starting device connection and API registration process...');
                                    }
                                    
                                    // Log using custom print
                                    customPrint('🔍 User selected device: ${device.platformName} (${device.remoteId.str})');
                                    customPrint('⚙️ Starting device connection and API registration...');
                                    
                                    // Clear any existing snackbars
                                    Get.closeAllSnackbars();
                                    
                                    // Connect to the device and register with API
                                    final result = await _controller.connectToRingAndRegister(device);
                                    final bool success = result['success'] ?? false;
                                    final String message = result['message'] ?? 'An unknown error occurred.';
                                    final bool isConnected = result['isConnected'] ?? false;

                                    customPrint('✅ Device connection process completed. Success: $success, Message: $message, IsConnected: $isConnected');
                                    
                                    // Clear any existing snackbars before showing the final one
                                    Get.closeAllSnackbars();

                                    // Show a single snackbar with the final result
                                    Get.snackbar(
                                      success ? 'Status'.tr : 'Error'.tr,
                                      message,
                                      backgroundColor: success ? (isConnected ? Colors.green.shade700 : Colors.orange.shade700) : Colors.red.shade700,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 4),
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    
                                    if (success && isConnected) {
                                      customPrint('Connection and registration successful, device is connected. Showing dashboard view.');
                                      if (mounted) {
                                        setState(() {
                                          // This will trigger a rebuild, showing the connected dashboard
                                          // as _controller.isConnected.value should be true
                                        });
                                      }
                                    } else if (success && !isConnected) {
                                       customPrint('Registration was successful, but device is not connected. Staying on disconnected view.');
                                       // UI will remain in disconnected state or show relevant message.
                                       // _controller.isConnected.value should be false
                                       if (mounted) {
                                          setState(() {}); // Rebuild to reflect controller state
                                       }
                                    }
                                    else {
                                      // Handle failure: Show error, stay on scan/disconnected screen
                                      _controller.hasConnectionError.value = true;
                                      _controller.connectionError.value = message;
                                      customPrint('❌ Setting error message: $message');
                                      if (mounted) {
                                          setState(() {}); // Rebuild to reflect controller state
                                       }
                                    }
                                  } catch (e) {
                                    // Show error
                                    _controller.hasConnectionError.value = true;
                                    _controller.connectionError.value = 'Error connecting: ${e.toString()}'.tr;
                                    
                                    if (kDebugMode) {
                                      print('Device connection error: $e');
                                    }
                                    
                                    customPrint('🚨 Device connection error: $e');
                                    
                                    // Clear any existing snackbars before showing error
                                    Get.closeAllSnackbars();
                                    
                                    // Show error using GetX
                                    Get.snackbar(
                                      'Error'.tr,
                                      'Connection failed: ${e.toString()}'.tr,
                                      backgroundColor: Colors.red.shade700,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 5),
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  } finally {
                                    // Hide loading
                                    _controller.isLoading.value = false;
                                    customPrint('➡️ Connection process finished, loading state set to false');
                                    // Ensure UI reflects the final state from the controller
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Stop scanning
                              FlutterBluePlus.stopScan();
                              
                              // Mark this dialog as inactive
                              isThisDialogActive = false;
                              
                              // Close dialog
                              Navigator.of(context).pop();
                              
                              // Update parent state safely
                              if (mounted) {
                                setState(() {
                                  isDialogShowing = false;
                                });
                              }
                            },
                            child: Text(
                              'Cancel'.tr,
                              style: AppTextStyle.normalBold14.copyWith(color: Colors.black87),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              // Restart scan
                              try {
                                await FlutterBluePlus.stopScan();
                                await Future.delayed(const Duration(milliseconds: 200));
                                
                                // Check if dialog is still active
                                if (isThisDialogActive) {
                                  await FlutterBluePlus.startScan(
                                    timeout: const Duration(seconds: 15),
                                    androidScanMode: AndroidScanMode.lowLatency,
                                  );
                                  
                                  // Use safe setState
                                  safeSetState(() {
                                    // Update dialog state if needed
                                  });
                                }
                              } catch (e) {
                                if (kDebugMode) {
                                  print('Error restarting scan: $e');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.purple,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Text(
                              'Rescan'.tr,
                              style: AppTextStyle.normalBold14.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    ).then((_) {
      // Mark the dialog as inactive when it's closed
      isThisDialogActive = false;
      
      // Always stop scanning when dialog is closed
      FlutterBluePlus.stopScan();
      
      // Update state if the widget is still mounted
      if (mounted) {
        setState(() {
          isDialogShowing = false;
        });
      }
    });
    
    // Start scanning
    try {
      FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidScanMode: AndroidScanMode.lowLatency,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error starting scan: $e');
      }
    }
  }
  
  void _showBluetoothOffDialog(BuildContext context) {
    // Set flag to indicate dialog is showing
    setState(() {
      isDialogShowing = true;
    });
    
    // Track if this specific dialog is active
    bool isThisDialogActive = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Bluetooth is Off'.tr),
          content: Text('Please turn on Bluetooth to scan for devices.'.tr),
          actions: [
            TextButton(
              onPressed: () {
                // Mark dialog as inactive
                isThisDialogActive = false;
                
                Navigator.of(dialogContext).pop();
                
                // Update parent state if still mounted
                if (mounted) {
                  setState(() {
                    isDialogShowing = false;
                  });
                }
              },
              child: Text('Cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                // Mark dialog as inactive
                isThisDialogActive = false;
                
                Navigator.of(dialogContext).pop();
                _openBluetoothSettings();
                
                // Update parent state if still mounted
                if (mounted) {
                  setState(() {
                    isDialogShowing = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
              ),
              child: Text('Open Settings'.tr),
            ),
          ],
        );
      },
    ).then((_) {
      // Additional cleanup when dialog is closed
      isThisDialogActive = false;
      
      // Update parent state if still mounted
      if (mounted) {
        setState(() {
          isDialogShowing = false;
        });
      }
    });
  }
  
  void _showPermissionDeniedDialog(BuildContext context) {
    // Set flag to indicate dialog is showing
    setState(() {
      isDialogShowing = true;
    });
    
    // Track if this specific dialog is active
    bool isThisDialogActive = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Permission Required'.tr),
          content: Text(
            'Bluetooth and Location permissions are required to scan for devices. '
            'Please grant the required permissions.'.tr
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Mark dialog as inactive
                isThisDialogActive = false;
                
                Navigator.of(dialogContext).pop();
                
                // Update parent state if still mounted
                if (mounted) {
                  setState(() {
                    isDialogShowing = false;
                  });
                }
              },
              child: Text('Cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                // Mark dialog as inactive
                isThisDialogActive = false;
                
                Navigator.of(dialogContext).pop();
                final granted = await _checkAndRequestPermissions();
                
                // Update parent state if still mounted
                if (mounted) {
                  setState(() {
                    isDialogShowing = false;
                  });
                  
                  if (granted) {
                    // If permissions were granted, show the scan dialog
                    _showScanDialog(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
              ),
              child: Text('Grant Permissions'.tr),
            ),
          ],
        );
      },
    ).then((_) {
      // Additional cleanup when dialog is closed
      isThisDialogActive = false;
      
      // Update parent state if still mounted
      if (mounted) {
        setState(() {
          isDialogShowing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProgressHUD(
        isLoading: _controller.isLoading.value,
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: SvgPicture.asset(
                'icons/arrowLeft.svg',
                height: 35,
                width: 35,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Ring Data'.tr,
              style: AppTextStyle.normalBold16.copyWith(color: coral500),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _controller.isConnected.value ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _controller.isConnected.value ? 'Connected'.tr : 'Disconnected'.tr,
                      style: AppTextStyle.normalBold14,
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: _controller.isConnected.value
              ? _buildConnectedBody()
              : _buildDisconnectedBody(),
        ),
      );
    });
  }

  Widget _buildConnectedBody() {
    return RefreshIndicator(
      onRefresh: _controller.refreshData,
      color: coral500,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time period selector
              _buildTimePeriodSelector(),
              
              const SizedBox(height: 24),
              
              // Health metrics cards in a grid layout similar to the image
              _buildSimpleHealthMetricsGrid(),
              
              const SizedBox(height: 24),
              
              // Health Trends Chart
              _buildHealthTrendsChart(),
              
              const SizedBox(height: 24),
              
              // Sleep data
              _buildSleepAnalysisSection(),
              
              const SizedBox(height: 24),
              
              // Device info
              _buildDeviceInfoCard(),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _buildPeriodButton('Day'.tr)),
          Expanded(child: _buildPeriodButton('Week'.tr)),
          Expanded(child: _buildPeriodButton('Month'.tr)),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _controller.selectedPeriod.value == period;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? coral500 : Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _controller.setPeriod(period),
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Center(
              child: Text(
                period.tr,
                style: AppTextStyle.normalBold16.copyWith(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleHealthMetricsGrid() {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSimpleMetricCard(
          title: 'Heart Rate'.tr,
          value: '${_controller.heartRate.value}',
          unit: 'bpm',
          trend: '— 0',
        ),
        _buildSimpleMetricCard(
          title: 'SPO2'.tr,
          value: '${_controller.spo2.value}',
          unit: '%',
          trend: '— 0',
        ),
        _buildSimpleMetricCard(
          title: 'Steps'.tr,
          value: '${_controller.steps.value}',
          unit: 'Steps'.tr,
          trend: '— 0',
        ),
        _buildSimpleMetricCard(
          title: 'Stress'.tr,
          value: _controller.stressLevel.value,
          unit: '/100',
          trend: '— 0',
        ),
      ],
    );
  }

  Widget _buildSimpleMetricCard({
    required String title,
    required String value,
    required String unit,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.normalRegular14,
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyle.normalBold24.copyWith(
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey[500]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTrendsChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Health Trends'.tr,
                style: AppTextStyle.normalBold18.copyWith(color: indigo700),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: coral500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Heart Rate'.tr,
                    style: AppTextStyle.normalRegular12,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: indigo700,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SPO2'.tr,
                    style: AppTextStyle.normalRegular12,
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            height: 200,
            child: _controller.ringData.isEmpty
                ? Center(
                    child: Text(
                      'No data available'.tr,
                      style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey[600]),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[200],
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey[200],
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: AppTextStyle.normalRegular12.copyWith(color: Colors.grey[600]),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 23,
                      minY: 40,
                      maxY: 120,
                      lineBarsData: [
                        // Heart rate line
                        LineChartBarData(
                          spots: _controller.heartRateSpots.value,
                          isCurved: true,
                          color: coral500,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: false,
                          ),
                        ),
                        
                        // SPO2 line
                        LineChartBarData(
                          spots: _controller.spo2Spots.value,
                          isCurved: true,
                          color: indigo700,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: false,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepAnalysisSection() {
    if (_controller.sleepData.value == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sleep Analysis'.tr,
              style: AppTextStyle.normalBold18.copyWith(color: indigo700),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                'No sleep data available'.tr,
                style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }
    
    final sleepData = _controller.sleepData.value!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Analysis'.tr,
            style: AppTextStyle.normalBold18.copyWith(color: indigo700),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration'.tr,
                    style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: indigo700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quality'.tr,
                    style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 4,
                          decoration: BoxDecoration(
                            color: indigo700,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Device Info'.tr,
            style: AppTextStyle.normalBold18.copyWith(color: indigo700),
          ),
          
          const SizedBox(height: 16),
          
          // Fixed device info rows to prevent overflow
          _buildDeviceInfoRow(
            icon: Icons.watch,
            label: 'Name'.tr, 
            value: _controller.deviceName.value
          ),
          const SizedBox(height: 12),
          
          // Address row with proper overflow handling
          _buildDeviceInfoRow(
            icon: Icons.bluetooth,
            label: 'Address'.tr, 
            value: _controller.deviceAddress.value
          ),
          const SizedBox(height: 12),
          
          // Battery level
          Obx(() {
            final batteryLevel = _controller.batteryLevel.value;
            
            Color batteryColor = Colors.green;
            if (batteryLevel < 15) {
              batteryColor = Colors.red;
            } else if (batteryLevel < 30) {
              batteryColor = Colors.orange;
            }
            
            return _buildDeviceInfoRow(
              icon: batteryLevel < 15 
                  ? Icons.battery_alert 
                  : (batteryLevel < 30 
                      ? Icons.battery_1_bar
                      : Icons.battery_full),
              iconColor: batteryColor,
              label: 'Battery'.tr,
              value: '${_controller.batteryLevel.value}%',
            );
          }),
          
          const SizedBox(height: 12),
          // Firmware Version
          Obx(() => _buildDeviceInfoRow(
            icon: Icons.memory, // Or other appropriate icon
            label: 'Firmware'.tr,
            value: _controller.firmwareVersion.value.isNotEmpty 
                   ? _controller.firmwareVersion.value 
                   : 'N/A'.tr,
          )),
          
          const SizedBox(height: 16),
          
          // Auto-reconnect toggle switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.autorenew, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    'Auto-reconnect'.tr,
                    style: AppTextStyle.normalRegular14,
                  ),
                ],
              ),
              Obx(() => Switch(
                value: _controller.autoReconnectEnabled.value,
                onChanged: (value) => _controller.setAutoReconnect(value),
                activeColor: indigo700,
              )),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // "Forget Ring" Button (New Row)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showForgetDeviceDialog();
                  },
                  icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[700]),
                  label: Text(
                    'Forget Ring'.tr,
                    style: AppTextStyle.normalBold14.copyWith(color: Colors.red[700]),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12), // Spacing between button rows
          
          // Action buttons (Disconnect & Find Ring) - Existing Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _controller.disconnectFromRing();
                  },
                  icon: Icon(Icons.power_settings_new, size: 18, color: Colors.orange[700]), // Changed color for differentiation
                  label: Text(
                    'Disconnect'.tr,
                    style: AppTextStyle.normalBold14.copyWith(color: Colors.orange[700]),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.orange[700]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _controller.findRing();
                  },
                  icon: Icon(Icons.vibration, size: 18, color: indigo700),
                  label: Text(
                    'Find Ring'.tr,
                    style: AppTextStyle.normalBold14.copyWith(color: indigo700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: indigo700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfoRow({
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyle.normalRegular14,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: AppTextStyle.normalBold14,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDisconnectedBody() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        image: DecorationImage(
          image: AssetImage('images/background_pattern.png'),
          opacity: 0.05,
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: indigo100.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'icons/ring.png',
                width: 100,
                height: 100,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Not Connected'.tr,
              style: AppTextStyle.normalBold18.copyWith(color: indigo950),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please connect your smart ring to track health metrics and sleep data'.tr,
                style: AppTextStyle.normalRegular14,
                textAlign: TextAlign.center,
              ),
            ),
            
            // Display error message if there is one
            Obx(() {
              if (_controller.hasConnectionError.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _controller.connectionError.value,
                          style: AppTextStyle.normalBold14.copyWith(color: Colors.red[700]),
                          textAlign: TextAlign.center,
                        ),
                        
                        // If Bluetooth is off, show button to settings
                        if (_controller.connectionError.value.contains('Bluetooth is turned off'))
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: ElevatedButton.icon(
                              onPressed: () => _openBluetoothSettings(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: indigo600,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.bluetooth, color: Colors.white, size: 18),
                              label: Text(
                                'Enable Bluetooth'.tr,
                                style: AppTextStyle.normalBold14.copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox(height: 0);
            }),
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _showScanDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: indigo700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bluetooth_searching, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Scan for Devices'.tr,
                    style: AppTextStyle.normalBold16.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showScanDialog(BuildContext context) {
    // Skip directly to the actual scan dialog with real devices
    _showActualScanDialog(context);
  }

  // Open Bluetooth settings
  void _openBluetoothSettings() async {
    _isReturningFromSettings = true;
    if (Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (e) {
        // If automatic turn on fails, open settings
        if (kDebugMode) {
          print('Error turning on Bluetooth: $e');
        }
        await _openAppSettings();
      }
    } else {
      // On iOS, can only direct to settings
      await _openAppSettings();
    }
  }

  // Helper function to open app settings
  Future<bool> _openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      if (kDebugMode) {
        print('Error opening app settings: $e');
      }
      return false;
    }
  }

  // Check if we have a saved device and verify with API
  Future<void> _checkSavedDevice() async {
    try {
      final savedDeviceId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString(LocalStorage.ringDeviceId));
      
      if (savedDeviceId != null && savedDeviceId.isNotEmpty) {
        customPrint("Found saved device ID: $savedDeviceId");
        
        // Show loading indicator
        _controller.isLoading.value = true;
        
        // Check device details from API using the specific method
        final deviceData = await _controller.getDeviceDetailsFromApi(savedDeviceId, silent: true);
        
        // Hide loading indicator
        _controller.isLoading.value = false;
        
        // Check if widget is still mounted before proceeding
        if (!mounted) return;
        
        // Clear any existing snackbars
        Get.closeAllSnackbars();
        
        if (deviceData != null) {
          customPrint("Device verified with API. Device Name: ${deviceData.deviceName}, ID: ${deviceData.deviceId}");
          
          _controller.deviceName.value = deviceData.deviceName ?? "Saved Ring";
          _controller.deviceAddress.value = deviceData.deviceId;
          _controller.batteryLevel.value = deviceData.batteryLevel ?? 0;
          // The controller's API response might already be set by getDeviceDetailsFromApi
          // If not, we can construct a minimal one.
          if (_controller.apiResponse.value == null || _controller.apiResponse.value!.data == null) {
              _controller.apiResponse.value = SmartRingResponse(success: true, message: "Device details loaded.", data: deviceData);
          }

          // IMPORTANT: We assume if getDeviceDetailsFromApi returns data, the device *should* be considered
          // "connected" from an API/account perspective. Physical BT connection is separate.
          // The UI will reflect _controller.isConnected which is managed by BT events.
          // For now, we'll assume if a device is saved and verified, we *try* to show the dashboard.
          // The RingController's auto-reconnect logic or a manual refreshData might establish BT connection.

          // We might not want to force isConnected.value = true here,
          // as the physical connection might not be active.
          // Instead, let's rely on the controller's existing logic to determine this.
          // For now, we will set it true to attempt to show connected view,
          // and the controller can update if actual BT connection is missing.
          _controller.isConnected.value = true; // Tentatively set to true


          Get.snackbar(
            'Device Loaded'.tr,
            '${'Details for'.tr} ${deviceData.deviceName ?? savedDeviceId} ${'loaded'.tr}',
            backgroundColor: Colors.green.shade700,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );

          if(mounted) setState(() {}); // Refresh UI

        } else {
          customPrint("Device not verified with API or error fetching details. Saved ID: $savedDeviceId");
          
          String message = _controller.apiResponse.value?.message ?? "Device not found or doesn't belong to this user".tr;
          if (message.isEmpty) message = "Failed to verify saved device.".tr;
          
          Get.snackbar(
            'API Error'.tr,
            message,
            backgroundColor: Colors.red.shade700,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
          );
          
          // Reset connection status to ensure scan view is shown if device verification fails
          _controller.isConnected.value = false;
          if(mounted) setState(() {}); // Refresh UI
        }
      } else {
        customPrint("No saved device ID found");
        _controller.isConnected.value = false; // Ensure disconnected state if no saved device
        if(mounted) setState(() {}); // Refresh UI
      }
    } catch (e) {
      _controller.isLoading.value = false;
      customPrint("Error checking saved device: $e");
      
      if (!mounted) return;
      
      Get.closeAllSnackbars();
      Get.snackbar(
        'Error'.tr,
        'Error checking saved device: ${e.toString()}'.tr,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
      _controller.isConnected.value = false;
      if(mounted) setState(() {}); // Refresh UI
    }
  }

  void _showForgetDeviceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Forget This Ring?'.tr),
          content: Text('This will unpair the ring from your account. You will need to scan and register it again to use it.'.tr),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'.tr),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text('Forget', style: TextStyle(color: Colors.red[700])),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog first
                _controller.isLoading.value = true;
                final deviceId = _controller.deviceAddress.value;
                if (deviceId.isNotEmpty) {
                  final success = await _controller.deleteDeviceFromApi(deviceId);
                  if (success) {
                    await _controller.disconnectFromRing(); // Disconnect Bluetooth
                    // Clear from SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove(LocalStorage.ringDeviceId);
                    await prefs.remove('device_name_$deviceId');
                    customPrint("Device $deviceId forgotten and removed from prefs.");
                    // Update UI to disconnected state
                    _controller.isConnected.value = false;
                    _controller.deviceName.value = '';
                    _controller.deviceAddress.value = '';
                    _controller.batteryLevel.value = 0;
                    _controller.firmwareVersion.value = '';
                    Get.snackbar('Success'.tr, 'Ring has been forgotten.'.tr, backgroundColor: Colors.green, colorText: Colors.white);
                  } else {
                    Get.snackbar('Error'.tr, _controller.apiResponse.value?.message ?? 'Could not forget ring. Please try again.'.tr, backgroundColor: Colors.red, colorText: Colors.white);
                  }
                } else {
                  Get.snackbar('Error'.tr, 'No device selected to forget'.tr, backgroundColor: Colors.red, colorText: Colors.white);
                }
                _controller.isLoading.value = false;
                if (mounted) {
                  setState(() {}); // Refresh screen to show disconnected view
                }
              },
            ),
          ],
        );
      },
    );
  }
} 