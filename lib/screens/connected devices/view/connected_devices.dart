import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart'; // For the reactive list
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/screens/connected%20devices/controllers/connected_devices_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class ConnectedDevicesPage extends StatefulWidget {
  const ConnectedDevicesPage({super.key});

  @override
  State<ConnectedDevicesPage> createState() => _ConnectedDevicesPageState();
}

class _ConnectedDevicesPageState extends State<ConnectedDevicesPage> {
  RxBool isLoading = false.obs;
  @override
  void initState() {
    super.initState();
    isLoading(true);
    fetchDevices();
  }

  fetchDevices() async {
    ConnectedDevicesController.getAllUserDevices()
        .then((value) => {isLoading(false)});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProgressHUD(
        isLoading: isLoading.value,
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      SvgPicture.asset('icons/arrowLeft.svg'),
                      Text(
                        "Connected Devices".tr,
                        style:
                            AppTextStyle.normalBold20.copyWith(color: coral500),
                      ),
                    ],
                  ),
                ),
                5.ph,
                Obx(() => Column(
                      children: List.generate(
                        ConnectedDevicesController.connectectedDevices.length,
                        (index) {
                          final device = ConnectedDevicesController
                              .connectectedDevices[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            child: Row(
                              children: [
                                // Device icon
                                Image.asset(
                                  device['icon'],
                                  width: 40,
                                  height: 40,
                                ),
                                2.ph,

                                // Device name and date column
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      device['name'],
                                      style: AppTextStyle.normalBold14,
                                    ),
                                    1.ph,
                                    Text(
                                      device['connectedAt'],
                                      style: AppTextStyle.normalBold12.copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: Colors
                                            .grey, // Make date text less prominent
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),

                                GestureDetector(
                                  onTap: () {
                                    ConnectedDevicesController.deleteDevice(
                                            device['id'])
                                        .then((value) => {
                                              setState(() {
                                                ConnectedDevicesController
                                                    .connectectedDevices
                                                    .removeAt(index);
                                              })
                                            });
                                  },
                                  child: Text(
                                    'Remove'.tr,
                                    style: AppTextStyle.normalBold12.copyWith(
                                        color: coral500,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )),
              ],
            ),
          ),
        ),
      );
    });
  }
}
