/// Model for storing ring data points over time
class RingDataPoint {
  final DateTime timestamp;
  final int heartRate;
  final int spo2;
  final int steps;
  final int stressLevel; // 0-100 scale

  RingDataPoint({
    required this.timestamp,
    required this.heartRate,
    required this.spo2,
    required this.steps,
    required this.stressLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
      'spo2': spo2,
      'steps': steps,
      'stressLevel': stressLevel,
    };
  }

  factory RingDataPoint.fromJson(Map<String, dynamic> json) {
    return RingDataPoint(
      timestamp: DateTime.parse(json['timestamp']),
      heartRate: json['heartRate'],
      spo2: json['spo2'],
      steps: json['steps'],
      stressLevel: json['stressLevel'],
    );
  }
} 