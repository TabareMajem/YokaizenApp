/// activity_view_screen.dart --->

import 'package:flutter/material.dart';

import '../../../controller/exercises_controller.dart';
import '../widgets/activity_card.dart';


class ActivityViewScreen extends StatelessWidget {
  const ActivityViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ExercisesController.getChallengeAll.value.exercises!.length,
      itemBuilder: (context, index) {
        return ActivityCard(
          activity: ExercisesController.getChallengeAll.value.exercises![index], onPressed: () {  },
        );
      },
    );
  }
}