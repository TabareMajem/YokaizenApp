/// Enum representing different sleep stages
enum SleepStageType {
  awake,
  light,
  deep,
  rem
}

/// Model for sleep stage data
class SleepStage {
  final DateTime startTime;
  final DateTime endTime;
  final SleepStageType stage;

  SleepStage({
    required this.startTime,
    required this.endTime,
    required this.stage,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'stage': stage.toString(),
    };
  }

  factory SleepStage.fromJson(Map<String, dynamic> json) {
    return SleepStage(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      stage: SleepStageType.values.firstWhere(
        (e) => e.toString() == json['stage'],
        orElse: () => SleepStageType.light,
      ),
    );
  }
}

/// Model for aggregated sleep data
class SleepData {
  final DateTime date;
  final Duration totalSleepTime;
  final int sleepQuality; // 0-100 scale
  final List<SleepStage> sleepStages;

  SleepData({
    required this.date,
    required this.totalSleepTime,
    required this.sleepQuality,
    required this.sleepStages,
  });

  // Calculate the total time spent in each sleep stage
  Duration getTimeInStage(SleepStageType stage) {
    final stagesOfType = sleepStages.where((s) => s.stage == stage);
    if (stagesOfType.isEmpty) {
      return Duration.zero;
    }
    
    return stagesOfType
        .map((s) => s.duration)
        .reduce((value, element) => value + element);
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalSleepTime': totalSleepTime.inMinutes,
      'sleepQuality': sleepQuality,
      'sleepStages': sleepStages.map((stage) => stage.toJson()).toList(),
    };
  }

  factory SleepData.fromJson(Map<String, dynamic> json) {
    return SleepData(
      date: DateTime.parse(json['date']),
      totalSleepTime: Duration(minutes: json['totalSleepTime']),
      sleepQuality: json['sleepQuality'],
      sleepStages: (json['sleepStages'] as List)
          .map((stageJson) => SleepStage.fromJson(stageJson))
          .toList(),
    );
  }
} 