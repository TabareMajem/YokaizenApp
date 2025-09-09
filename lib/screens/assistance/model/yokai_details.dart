// yokai_details.dart

import 'package:get/get.dart';

class YokaiDetails {
  final String name;
  final String description;
  final String imageUrl;
  final String type;

  YokaiDetails({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
  });
}

final Map<String, YokaiDetails> yokaiDetailsMap = {
  'tanuki': YokaiDetails(
      name: "Tanuki".tr,
      description: "Tanuki Description".tr,
      imageUrl: 'gif/tanuki1.gif',
      type: 'tanuki'
  ),
  'water': YokaiDetails(
      name: "Water".tr,
      description: "Water Description".tr,
      imageUrl: 'gif/water1.gif',
      type: 'water'
  ),
  'spirit': YokaiDetails(
      name: "Spirit".tr,    /// Spirit
      description: "Water Description".tr,
      imageUrl: 'gif/spirit1.gif',
      type: 'spirit'
  ),
  'purple': YokaiDetails(
      name: "Purple".tr,     /// purple
      description: "Water Description".tr,
      imageUrl: 'gif/purple1.gif',
      type: 'purple'
  ),
};