import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/screens/ring/controller/ring_controller.dart';
import 'package:yokai_quiz_app/screens/ring/models/sleep_data_model.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';

class RingSleepScreen extends StatefulWidget {
  const RingSleepScreen({super.key});

  @override
  State<RingSleepScreen> createState() => _RingSleepScreenState();
}

class _RingSleepScreenState extends State<RingSleepScreen> {
  final RingController _controller = Get.find<RingController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ProgressHUD(
        isLoading: _controller.isSleepDataLoading.value,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: indigo700),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Sleep Data'.tr,
              style: AppTextStyle.normalBold20.copyWith(color: indigo950),
            ),
          ),
          body: _controller.sleepData.value == null
              ? _buildNoDataView()
              : _buildSleepDataView(),
        ),
      );
    });
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nightlight_round,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'No Sleep Data Available'.tr,
            style: AppTextStyle.normalBold18,
          ),
          const SizedBox(height: 10),
          Text(
            'Wear your ring while sleeping to track your sleep patterns'.tr,
            style: AppTextStyle.normalRegular14,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSleepDataView() {
    final sleepData = _controller.sleepData.value!;
    
    // Calculate stage percentages
    final totalMinutes = sleepData.totalSleepTime.inMinutes;
    final deepMinutes = sleepData.getTimeInStage(SleepStageType.deep).inMinutes;
    final remMinutes = sleepData.getTimeInStage(SleepStageType.rem).inMinutes;
    final lightMinutes = sleepData.getTimeInStage(SleepStageType.light).inMinutes;
    final awakeMinutes = sleepData.getTimeInStage(SleepStageType.awake).inMinutes;
    
    final deepPercent = (deepMinutes / totalMinutes * 100).round();
    final remPercent = (remMinutes / totalMinutes * 100).round();
    final lightPercent = (lightMinutes / totalMinutes * 100).round();
    final awakePercent = (awakeMinutes / totalMinutes * 100).round();
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sleep summary card
            _buildSleepSummaryCard(sleepData),
            
            const SizedBox(height: 20),
            
            // Sleep stages visualization
            _buildSleepStagesCard(sleepData),
            
            const SizedBox(height: 20),
            
            // Sleep breakdown
            _buildSleepBreakdownCard(
              deepPercent: deepPercent,
              remPercent: remPercent,
              lightPercent: lightPercent,
              awakePercent: awakePercent,
              deepMinutes: deepMinutes,
              remMinutes: remMinutes,
              lightMinutes: lightMinutes,
              awakeMinutes: awakeMinutes,
            ),
            
            const SizedBox(height: 20),
            
            // Sleep quality explanation
            _buildSleepQualityCard(sleepData.sleepQuality),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepSummaryCard(SleepData sleepData) {
    final date = sleepData.date;
    final dateStr = '${date.day}/${date.month}/${date.year}';
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sleep Summary'.tr,
                style: AppTextStyle.normalBold18,
              ),
              Text(
                dateStr,
                style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sleepData.totalSleepTime.inHours}h ${sleepData.totalSleepTime.inMinutes % 60}m',
                    style: AppTextStyle.normalBold24.copyWith(color: AppColors.purple),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Total Sleep Time'.tr,
                    style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${sleepData.sleepQuality}%',
                    style: AppTextStyle.normalBold24.copyWith(color: AppColors.purple),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Sleep Quality'.tr,
                    style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSleepTimeInfo(
                icon: Icons.nightlight,
                label: 'Bedtime'.tr,
                time: '${sleepData.sleepStages.first.startTime.hour}:${sleepData.sleepStages.first.startTime.minute.toString().padLeft(2, '0')}',
              ),
              _buildSleepTimeInfo(
                icon: Icons.wb_sunny_outlined,
                label: 'Wake Up'.tr,
                time: '${sleepData.sleepStages.last.endTime.hour}:${sleepData.sleepStages.last.endTime.minute.toString().padLeft(2, '0')}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTimeInfo({
    required IconData icon,
    required String label,
    required String time,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.purple,
          size: 24,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppTextStyle.normalRegular12.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: AppTextStyle.normalBold16,
        ),
      ],
    );
  }

  Widget _buildSleepStagesCard(SleepData sleepData) {
    // Generate sleep stage blocks
    final sleepBlocks = _generateSleepBlocks(sleepData.sleepStages);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Stages'.tr,
            style: AppTextStyle.normalBold18,
          ),
          
          const SizedBox(height: 20),
          
          SizedBox(
            height: 100,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    // Sleep stage labels
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Awake', style: AppTextStyle.normalRegular12),
                        Text('REM', style: AppTextStyle.normalRegular12),
                        Text('Light', style: AppTextStyle.normalRegular12),
                        Text('Deep', style: AppTextStyle.normalRegular12),
                      ],
                    ),
                    
                    const SizedBox(width: 10),
                    
                    // Sleep stage blocks
                    Expanded(
                      child: Stack(
                        children: sleepBlocks,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Time markers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) {
                final hour = (sleepData.sleepStages.first.startTime.hour + index * 2) % 24;
                return Text(
                  '$hour:00',
                  style: AppTextStyle.normalRegular10.copyWith(color: Colors.grey),
                );
              },
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Legend
          Wrap(
            spacing: 15,
            runSpacing: 10,
            children: [
              _buildSleepStageLegend('Awake'.tr, _getSleepStageColor(SleepStageType.awake)),
              _buildSleepStageLegend('REM'.tr, _getSleepStageColor(SleepStageType.rem)),
              _buildSleepStageLegend('Light'.tr, _getSleepStageColor(SleepStageType.light)),
              _buildSleepStageLegend('Deep'.tr, _getSleepStageColor(SleepStageType.deep)),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _generateSleepBlocks(List<SleepStage> stages) {
    if (stages.isEmpty) {
      return [];
    }
    
    final blocks = <Widget>[];
    final firstTime = stages.first.startTime;
    final lastTime = stages.last.endTime;
    final totalDuration = lastTime.difference(firstTime).inMinutes;
    
    for (final stage in stages) {
      final startOffset = stage.startTime.difference(firstTime).inMinutes;
      final duration = stage.duration.inMinutes;
      
      // Calculate position and width percentages
      final leftPercent = startOffset / totalDuration;
      final widthPercent = duration / totalDuration;
      
      // Determine vertical position based on sleep stage
      double topPercent;
      switch (stage.stage) {
        case SleepStageType.awake:
          topPercent = 0.0;
          break;
        case SleepStageType.rem:
          topPercent = 0.25;
          break;
        case SleepStageType.light:
          topPercent = 0.5;
          break;
        case SleepStageType.deep:
          topPercent = 0.75;
          break;
      }
      
      blocks.add(
        Positioned(
          left: leftPercent * 100,
          top: topPercent * 100,
          width: widthPercent * 100,
          height: 25,
          child: Container(
            decoration: BoxDecoration(
              color: _getSleepStageColor(stage.stage),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      );
    }
    
    return blocks;
  }

  Color _getSleepStageColor(SleepStageType stage) {
    switch (stage) {
      case SleepStageType.awake:
        return Colors.orange;
      case SleepStageType.rem:
        return Colors.blue;
      case SleepStageType.light:
        return Colors.teal;
      case SleepStageType.deep:
        return indigo700;
    }
  }

  Widget _buildSleepStageLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyle.normalRegular12,
        ),
      ],
    );
  }

  Widget _buildSleepBreakdownCard({
    required int deepPercent,
    required int remPercent,
    required int lightPercent,
    required int awakePercent,
    required int deepMinutes,
    required int remMinutes,
    required int lightMinutes,
    required int awakeMinutes,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Breakdown'.tr,
            style: AppTextStyle.normalBold18,
          ),
          
          const SizedBox(height: 20),
          
          // Sleep stage progress bars
          _buildSleepStageProgress(
            label: 'Deep Sleep'.tr,
            percent: deepPercent,
            duration: '${deepMinutes ~/ 60}h ${deepMinutes % 60}m',
            color: _getSleepStageColor(SleepStageType.deep),
          ),
          
          const SizedBox(height: 15),
          
          _buildSleepStageProgress(
            label: 'REM Sleep'.tr,
            percent: remPercent,
            duration: '${remMinutes ~/ 60}h ${remMinutes % 60}m',
            color: _getSleepStageColor(SleepStageType.rem),
          ),
          
          const SizedBox(height: 15),
          
          _buildSleepStageProgress(
            label: 'Light Sleep'.tr,
            percent: lightPercent,
            duration: '${lightMinutes ~/ 60}h ${lightMinutes % 60}m',
            color: _getSleepStageColor(SleepStageType.light),
          ),
          
          const SizedBox(height: 15),
          
          _buildSleepStageProgress(
            label: 'Awake'.tr,
            percent: awakePercent,
            duration: '${awakeMinutes ~/ 60}h ${awakeMinutes % 60}m',
            color: _getSleepStageColor(SleepStageType.awake),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStageProgress({
    required String label,
    required int percent,
    required String duration,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyle.normalRegular14,
            ),
            Text(
              '$percent% ($duration)',
              style: AppTextStyle.normalBold14,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildSleepQualityCard(int quality) {
    String qualityText;
    String description;
    Color qualityColor;
    
    if (quality >= 90) {
      qualityText = 'Excellent'.tr;
      description = 'Your sleep quality is excellent. You had a balanced mix of deep, REM, and light sleep, with minimal awake time.'.tr;
      qualityColor = Colors.green;
    } else if (quality >= 80) {
      qualityText = 'Very Good'.tr;
      description = 'Your sleep quality is very good. You had good proportions of sleep stages with some room for improvement.'.tr;
      qualityColor = Colors.green[600]!;
    } else if (quality >= 70) {
      qualityText = 'Good'.tr;
      description = 'Your sleep quality is good. Consider consistent sleep and wake times to further improve.'.tr;
      qualityColor = Colors.lightGreen;
    } else if (quality >= 60) {
      qualityText = 'Fair'.tr;
      description = 'Your sleep quality is fair. You may have had some interruptions or imbalance in sleep stages.'.tr;
      qualityColor = Colors.amber;
    } else {
      qualityText = 'Poor'.tr;
      description = 'Your sleep quality needs improvement. Consider reviewing your sleep environment and habits.'.tr;
      qualityColor = Colors.orange;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleep Quality Analysis'.tr,
            style: AppTextStyle.normalBold18,
          ),
          
          const SizedBox(height: 15),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: qualityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  qualityText,
                  style: AppTextStyle.normalBold14.copyWith(color: qualityColor),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 15),
          
          Text(
            description,
            style: AppTextStyle.normalRegular14,
          ),
          
          const SizedBox(height: 15),
          
          Text(
            'For better sleep:'.tr,
            style: AppTextStyle.normalBold14,
          ),
          
          const SizedBox(height: 8),
          
          _buildSleepTip('Maintain a consistent sleep schedule'.tr),
          _buildSleepTip('Ensure your bedroom is cool, dark, and quiet'.tr),
          _buildSleepTip('Avoid screens before bedtime'.tr),
          _buildSleepTip('Limit caffeine and alcohol'.tr),
        ],
      ),
    );
  }

  Widget _buildSleepTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTextStyle.normalRegular14),
          Expanded(
            child: Text(
              tip,
              style: AppTextStyle.normalRegular14,
            ),
          ),
        ],
      ),
    );
  }
} 