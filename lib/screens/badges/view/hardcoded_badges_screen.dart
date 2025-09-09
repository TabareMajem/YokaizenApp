import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/custom_app_bar.dart';

import '../../../Widgets/new_button.dart';
import '../../../Widgets/progressBar.dart';
import '../../../api/database_api.dart';
import '../../../util/colors.dart';
import '../../../util/text_styles.dart';
import '../../Authentication/controller/auth_screen_controller.dart';
import '../../challenge/services/line_invite_service.dart';
import '../../navigation/view/navigation.dart';

class HardcodedBadgesScreen extends StatefulWidget {
  const HardcodedBadgesScreen({super.key});

  @override
  State<HardcodedBadgesScreen> createState() => _HardcodedBadgesScreenState();
}

class _HardcodedBadgesScreenState extends State<HardcodedBadgesScreen> {


  List<Map<String, dynamic>> map = [
    {
      "title": "Share the app with your friends : ",
      "badges": [
        {
          "badge_title": "App Promoter",
          "badge_image_path": "images/badges/app_promoter.png",
          "badge_description": "Shared the app with at least one friend."
        },
        {
          "badge_title": "App Ambassador",
          "badge_image_path": "images/badges/app_ambassador.png",
          "badge_description": "Referred multiple friends to the app."
        },
        {
          "badge_title": "App Evangelist",
          "badge_image_path": "images/badges/app_evangelist.png",
          "badge_description": "Significantly contributed to app promotion."
        }
      ]
    },
    {
      "title": "Chat regularly : ",
      "badges": [
        {
          "badge_title": "Daily Conversation 1",
          "badge_image_path": "images/badges/daily_conversation1.png",
          "badge_description": "Chatted for 3 consecutive days."
        },
        {
          "badge_title": "Daily Conversation 2",
          "badge_image_path": "images/badges/daily_conversation2.png",
          "badge_description": "Chatted for 7 consecutive days."
        },
        {
          "badge_title": "Daily Conversation 3",
          "badge_image_path": "images/badges/daily_conversation3.png",
          "badge_description": "Chatted for 14 consecutive days."
        },
        {
          "badge_title": "Consistent Chat 1",
          "badge_image_path": "images/badges/consistent1.png",
          "badge_description": "Maintained a regular chat schedule."
        },
        {
          "badge_title": "Consistent Chat 2",
          "badge_image_path": "images/badges/consistent2.png",
          "badge_description": "Engaged in meaningful chats frequently."
        },
        {
          "badge_title": "Consistent Chat 3",
          "badge_image_path": "images/badges/consistent3.png",
          "badge_description": "A true conversation champion!"
        }
      ]
    },
    {
      "title": "Complete Story Arc : ",
      "badges": [
        {
          "badge_title": "Story Arc Completer 1",
          "badge_image_path": "images/badges/story_arc1.png",
          "badge_description": "Completed 1 story arc."
        },
        {
          "badge_title": "Story Arc Completer 2",
          "badge_image_path": "images/badges/story_arc2.png",
          "badge_description": "Completed 5 story arcs."
        },
        {
          "badge_title": "Story Arc Completer 3",
          "badge_image_path": "images/badges/story_arc3.png",
          "badge_description": "Completed 10 story arcs."
        },
        {
          "badge_title": "Story Enthusiast 1",
          "badge_image_path": "images/badges/story_enthusiast1.png",
          "badge_description": "Engaged deeply in story-based interactions."
        },
        {
          "badge_title": "Story Enthusiast 2",
          "badge_image_path": "images/badges/story_enthusiast2.png",
          "badge_description": "Passionate about completing multiple story arcs."
        },
        {
          "badge_title": "Story Enthusiast 3",
          "badge_image_path": "images/badges/story_enthusiast3.png",
          "badge_description": "Master of interactive storytelling!"
        }
      ]
    },
    {
      "title": "Engage with Mental Health Activities : ",
      "badges": [
        {
          "badge_title": "Mindfulness 1",
          "badge_image_path": "images/badges/mindfulness1.png",
          "badge_description": "Completed 1 mindfulness activity."
        },
        {
          "badge_title": "Mindfulness 2",
          "badge_image_path": "images/badges/mindfulness2.png",
          "badge_description": "Completed 5 mindfulness activities."
        },
        {
          "badge_title": "Mindfulness 3",
          "badge_image_path": "images/badges/mindfulness3.png",
          "badge_description": "Completed 10 mindfulness activities."
        },
        {
          "badge_title": "Mental Wellness 1",
          "badge_image_path": "images/badges/mental_wellness1.png",
          "badge_description": "Started focusing on mental well-being."
        },
        {
          "badge_title": "Mental Wellness 2",
          "badge_image_path": "images/badges/mental_wellness2.png",
          "badge_description": "Actively engaging in mental health exercises."
        },
        {
          "badge_title": "Mental Wellness 3",
          "badge_image_path": "images/badges/mental_wellness3.png",
          "badge_description": "A champion of mental wellness!"
        }
      ]
    },
    {
      "title": "Share the app with your friends : ",
      "badges": [
        {
          "badge_title": "Mindfulness 4",
          "badge_image_path": "images/badges/mindfulness4.png",
          "badge_description": "Advanced mindfulness participant."
        },
        {
          "badge_title": "Mindfulness 5",
          "badge_image_path": "images/badges/mindfulness5.png",
          "badge_description": "Expert in mindfulness exercises."
        },
        {
          "badge_title": "Mindfulness 6",
          "badge_image_path": "images/badges/mindfulness6.png",
          "badge_description": "Mindfulness master."
        },{
          "badge_title": "Mental Wellness 1",
          "badge_image_path": "images/badges/mental_wellness1.png",
          "badge_description": "Started focusing on mental well-being."
        },
        {
          "badge_title": "Mental Wellness 2",
          "badge_image_path": "images/badges/mental_wellness2.png",
          "badge_description": "Actively engaging in mental health exercises."
        },
        {
          "badge_title": "Mental Wellness 3",
          "badge_image_path": "images/badges/mental_wellness3.png",
          "badge_description": "A champion of mental wellness!"
        },
        {
          "badge_title": "Daily Devoted 1",
          "badge_image_path": "images/badges/daily_devoted1.png",
          "badge_description": "Engaged daily for a week."
        },
        {
          "badge_title": "Daily Devoted 2",
          "badge_image_path": "images/badges/daily_devoted2.png",
          "badge_description": "Maintained daily engagement for two weeks."
        },
        {
          "badge_title": "Daily Devoted 3",
          "badge_image_path": "images/badges/daily_devoted3.png",
          "badge_description": "A devoted daily user of the app!"
        }
      ]
    }
  ];


  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        // padding: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomAppBar(
                  title: "Badges",
                  isBackButton: true,
                  isColor: false,
                  onButtonPressed: () {
                    Navigator.pop(context);
                  }
              ),
              SizedBox(height: 20,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: map.map((badges) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badges["title"],
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            // color: Colors.deepPurple,
                            color: Color.fromRGBO(84, 3, 117, 1)
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: badges["badges"].length,
                        itemBuilder: (context, index) {
                          var badge = badges["badges"][index];
                          return GestureDetector(
                            onTap: () {
                              print("Clicked on ${badge["badge_title"]}");
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(0),
                                  child: Image.asset(
                                    badge["badge_image_path"],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  badge["badge_title"],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color.fromRGBO(155, 26, 214, 1),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

