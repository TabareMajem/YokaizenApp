import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:yokai_quiz_app/screens/ring/controller/ring_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class DeviceListDialog extends StatelessWidget {
  final RingController controller;
  
  const DeviceListDialog({
    Key? key,
    required this.controller,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Hardcoded devices to show immediately without any scanning
    final hardcodedDevices = [
      {'name': 'R02_6A05', 'id': 'R02_6A05_ID', 'isRing': 'true'},
      {'name': 'R02_2307', 'id': 'R02_2307_ID', 'isRing': 'true'},
      {'name': 'RO2_3F12', 'id': 'RO2_3F12_ID', 'isRing': 'true'},
      {'name': 'ColmiRing_A845', 'id': 'ColmiRing_A845_ID', 'isRing': 'true'},
      {'name': 'QRING_8732', 'id': 'QRING_8732_ID', 'isRing': 'true'},
      {'name': 'JODU51642_5C6C', 'id': '23E2FF92-A7E5-DFF7-2E9B-D880F6C642D4', 'isRing': 'true'},
      {'name': 'JR_JioSTB-RKISBLJ60435947', 'id': '5241D395-7D35-A4E2-A3E8-91AD10A91C26', 'isRing': 'true'},
      {'name': 'JODU51643_AE6D', 'id': '60E57E5B-C4BA-F618-6D0F-CA4092765492', 'isRing': 'true'},
      {'name': 'Device (E4AEB508-E104-9DB4-AF80-AAED5B9A8DE2)', 'id': 'E4AEB508-E104-9DB4-AF80-AAED5B9A8DE2', 'isRing': 'true'},
    ];
    
    // Update controller with hardcoded devices
    controller.scanResults.clear();
    controller.scanResults.addAll(hardcodedDevices);
    
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
                  const Text(
                    'Available Devices',
                    style: AppTextStyle.normalBold18,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Select your device from the list below',
                    style: AppTextStyle.normalRegular14,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: hardcodedDevices.length,
                itemBuilder: (context, index) {
                  final device = hardcodedDevices[index];
                  final deviceName = device['name'] ?? 'Unknown Device';
                  final deviceId = device['id'] ?? '';
                  
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
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
                    subtitle: const Text(
                      'Bluetooth Device',
                      style: AppTextStyle.normalRegular12,
                    ),
                    trailing: const Icon(Icons.bluetooth, color: Colors.blue, size: 20),
                    onTap: () async {
                      // Close the dialog
                      Navigator.of(context).pop();
                      
                      // Show loading
                      controller.isLoading.value = true;
                      
                      try {
                        // Get the BluetoothDevice by creating it from the ID
                        final deviceIdentifier = DeviceIdentifier(deviceId);
                        final targetDevice = BluetoothDevice(remoteId: deviceIdentifier);
                        
                        // Connect to the device and register with API
                        final success = await controller.connectToRingAndRegister(targetDevice);
                        
                        if (success == false) {
                          // Show error if connection failed
                          controller.hasConnectionError.value = true;
                          controller.connectionError.value = 'Failed to connect to the device. Please try again.';
                        }
                      } catch (e) {
                        // Show error
                        controller.hasConnectionError.value = true;
                        controller.connectionError.value = 'Error connecting: ${e.toString()}';
                        print('Device connection error: $e');
                      } finally {
                        // Hide loading
                        controller.isLoading.value = false;
                      }
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
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
}

// Helper function to show the device list dialog
void showDeviceListDialog(BuildContext context, RingController controller) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return DeviceListDialog(controller: controller);
    },
  );
} 