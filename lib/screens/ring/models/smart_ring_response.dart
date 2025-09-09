/// smart_ring_response.dart
/// Model class for Smart Ring API response

class SmartRingResponse {
  final bool success;
  final String message;
  final SmartRingData? data;

  SmartRingResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SmartRingResponse.fromJson(Map<String, dynamic> json) {
    // API returns "status" (as string "true"/"false") instead of "success" boolean
    bool isSuccess = false;
    if (json['status'] != null) {
      isSuccess = json['status'].toString().toLowerCase() == 'true';
    } else if (json['success'] != null) {
      isSuccess = json['success'] == true;
    }
    
    return SmartRingResponse(
      success: isSuccess,
      message: json['message'] ?? '',
      data: json['data'] != null ? SmartRingData.fromJson(json['data']) : null,
    );
  }
}

class SmartRingData {
  final int id;
  final String deviceId;
  final int? userId;
  final String? deviceName;
  final String? deviceModel;
  final String? macAddress;
  final String? firmwareVersion;
  final int? batteryLevel;
  final String? connectionStatus;
  final DateTime? lastSyncTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SmartRingData({
    required this.id,
    required this.deviceId,
    this.userId,
    this.deviceName,
    this.deviceModel,
    this.macAddress,
    this.firmwareVersion,
    this.batteryLevel,
    this.connectionStatus,
    this.lastSyncTime,
    this.createdAt,
    this.updatedAt,
  });

  factory SmartRingData.fromJson(Map<String, dynamic> json) {
    // Handle minimal data case (only id and device_id)
    if (json.length <= 2) {
      return SmartRingData(
        id: json['id'] ?? 0,
        deviceId: json['device_id'] ?? '',
      );
    }
    
    // Handle full data case
    return SmartRingData(
      id: json['id'] ?? 0,
      deviceId: json['device_id'] ?? '',
      userId: json['user_id'],
      deviceName: json['device_name'],
      deviceModel: json['device_model'],
      macAddress: json['mac_address'],
      firmwareVersion: json['firmware_version'],
      batteryLevel: json['battery_level'],
      connectionStatus: json['connection_status'],
      lastSyncTime: json['last_sync_time'] != null
          ? DateTime.parse(json['last_sync_time'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
} 