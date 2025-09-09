// badge_response.dart

class BadgeResponse {
  final int id;
  final String name;
  final String description;
  final String criteria;
  final int stepCount;
  final String type;
  final String image;
  final String typeId;
  final String japaneseName;
  final String japaneseDescription;
  final bool isUserRewarded;

  BadgeResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.criteria,
    required this.stepCount,
    required this.type,
    required this.image,
    required this.typeId,
    required this.japaneseName,
    required this.japaneseDescription,
    required this.isUserRewarded,
  });

  factory BadgeResponse.fromJson(Map<String, dynamic> json) {
    return BadgeResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      criteria: json['criteria'] ?? '',
      stepCount: json['step_count'] ?? 0,
      type: json['type'] ?? '',
      image: json['image'] ?? '',
      typeId: json['type_id'] ?? '',
      japaneseName: json['japanese_name'] ?? '',
      japaneseDescription: json['japanese_description'] ?? '',
      isUserRewarded: json['isUserRewarded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'criteria': criteria,
      'step_count': stepCount,
      'type': type,
      'image': image,
      'type_id': typeId,
      'japanese_name': japaneseName,
      'japanese_description': japaneseDescription,
      'isUserRewarded': isUserRewarded,
    };
  }
}