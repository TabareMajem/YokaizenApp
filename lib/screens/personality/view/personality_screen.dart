/// personality_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yokai_quiz_app/api/database_api.dart';
import 'package:yokai_quiz_app/global.dart';
import 'package:yokai_quiz_app/models/assessment_model.dart';
import 'package:yokai_quiz_app/screens/challenge/controller/challenge_controller.dart';
import 'package:yokai_quiz_app/screens/chat/controller/chat_controller.dart';
import 'package:yokai_quiz_app/screens/home/controller/home_controller.dart';
import 'package:yokai_quiz_app/screens/personality/controller/controller.dart';
import 'package:yokai_quiz_app/screens/profile/view/profile_screen.dart';
import 'package:yokai_quiz_app/screens/read/controller/read_controller.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Widgets/second_custom_button.dart';
import '../../assessments/view/test_details_screen.dart';
import '../../read/view/open_story_screen.dart';
import '../../read/view/story_details_screen.dart';

class PersonalityScreen extends StatefulWidget {
  const PersonalityScreen({super.key});

  @override
  State<PersonalityScreen> createState() => _PersonalityScreenState();
}

class _PersonalityScreenState extends State<PersonalityScreen> {
  int selectedType = 0;
  bool isLoading = true;
  Map<String, dynamic> currentAssessmentData = {};
  
  List<String> typeOfPersonality = [
    "Bartle".tr,
    "EQ".tr,
    "Big Five".tr,
    "Mental Health".tr,
    "Values & Strengths".tr,
  ];
  
  List<String> fixedType = [
    "bartle-test",
    "eq",
    "big-five-personality",
    "personality-assessment",
    "values-strengths"
  ];

  Map<String, Map<String, dynamic>> testInfo = {
    'bartle-test': {
      'name': 'Bartle Test'.tr,
      'image': 'images/bartle.jpeg',
      'type': 'Personality Type'.tr,
      'description': 'Discover your gaming personality type and understand how you interact with virtual worlds.'.tr,
    },
    'eq': {
      'name': 'Emotional Intelligence'.tr,
      'image': 'images/eq.jpg',
      'type': 'EQ Assessment'.tr,
      'description': 'Measure your emotional intelligence and understand how you perceive, use, understand, and manage emotions.'.tr,
    },
    'big-five-personality': {
      'name': 'Big Five Personality'.tr,
      'image': 'images/big5.jpeg',
      'type': 'Personality Traits'.tr,
      'description': 'Explore your personality through the five fundamental dimensions: Openness, Conscientiousness, Extraversion, Agreeableness, and Neuroticism.'.tr,
    },
    'personality-assessment': {
      'name': 'Mental Health Assessment'.tr,
      'image': 'images/mental.jpeg',
      'type': 'Mental Wellness'.tr,
      'description': 'Evaluate your mental well-being and identify areas for personal growth and support.'.tr,
    },
    'values-strengths': {
      'name': 'Values & Strengths'.tr,
      'image': 'images/value.jpeg',
      'type': 'Character Strengths'.tr,
      'description': 'Identify your core values and character strengths to better understand what drives and motivates you.'.tr,
    }
  };

  // Add citations map
  final Map<String, List<Map<String, String>>> citations = {
    'bartle-test': [
      {
        'title': 'Hearts, Clubs, Diamonds, Spades: Players Who Suit MUDs'.tr,
        'authors': 'Bartle, R. (1996)',
        'link': 'https://www.researchgate.net/publication/247190693_Hearts_Clubs_Diamonds_Spades_Players_Who_Suit_MUDs',
      },
      {
        'title': "Author's Official Website".tr,
        'authors': 'Richard Bartle',
        'link': 'https://mud.co.uk/richard/hcds.htm',
      },
    ],
    'big-five-personality': [
      {
        'title': 'Revised NEO Personality Inventory (NEO-PI-R) and NEO Five-Factor Inventory (NEO-FFI) manual'.tr,
        'authors': 'Costa, P. T., & McCrae, R. R. (1992)',
        'link': 'https://www.sciencedirect.com/science/article/abs/pii/S0191886996000335',
      },
      {
        'title': 'The structure of phenotypic personality traits'.tr,
        'authors': 'Goldberg, L. R. (1993)',
        'link': 'https://psycnet.apa.org/record/1993-14736-001',
        'doi': '10.1037/0003-066X.48.1.26',
      },
    ],
    'eq': [
      {
        'title': 'Emotional Intelligence'.tr,
        'authors': 'Salovey, P., & Mayer, J. D. (1990)',
        'link': 'https://journals.sagepub.com/doi/10.2190/DUGG-P24E-52WK-6CDG',
        'doi': '10.2190/DUGG-P24E-52WK-6CDG',
      },
      {
        'title': 'What Makes a Leader?.tr',
        'authors': 'Goleman, D. (2004)',
        'link': 'https://hbr.org/2004/01/what-makes-a-leader',
      },
    ],
    'values-strengths': [
      {
        'title': 'Character Strengths and Virtues: A Handbook and Classification'.tr,
        'authors': 'Peterson, C., & Seligman, M. E. P. (2004)',
        'link': 'https://www.apa.org/pubs/books/4316045',
      },
      {
        'title': 'An Overview of the Schwartz Theory of Basic Values'.tr,
        'authors': 'Schwartz, S. H. (2012)',
        'link': 'https://scholarworks.gvsu.edu/orpc/vol2/iss1/11/',
        'doi': '10.9707/2307-0919.1116',
      },
    ],
    'personality-assessment': [
      {
        'title': 'The Mental Health Continuum: From Languishing to Flourishing in Life'.tr,
        'authors': 'Keyes, C. L. M. (2002)',
        'link': 'https://www.jstor.org/stable/3090197',
        'doi': '10.2307/3090197',
      },
      {
        'title': 'The Satisfaction with Life Scale'.tr,
        'authors': 'Diener, E., Emmons, R. A., Larsen, R. J., & Griffin, S. (1985)',
        'link': 'https://www.tandfonline.com/doi/abs/10.1207/s15327752jpa4901_13',
        'doi': '10.1207/s15327752jpa4901_13',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    
    // Fetch assessment averages from API
    await PersonalityController.fetchAssessmentAverages();
    
    // Update current assessment data based on selected type
    updateCurrentAssessmentData();
    
    setState(() {
      isLoading = false;
    });
  }

  void updateCurrentAssessmentData() {
    final String currentType = fixedType[selectedType];
    
    if (PersonalityController.assessmentAverages.value.containsKey(currentType)) {
      currentAssessmentData = PersonalityController.assessmentAverages.value[currentType];
    } else {
      currentAssessmentData = {};
    }
  }

  List<String> getCategories() {
    if (currentAssessmentData.containsKey('radar_data') && 
        currentAssessmentData['radar_data'].containsKey('categories')) {
      return List<String>.from(currentAssessmentData['radar_data']['categories']);
    }
    return [];
  }

  List<double> getValues() {
    if (currentAssessmentData.containsKey('radar_data') && 
        currentAssessmentData['radar_data'].containsKey('values')) {
      return List<double>.from(
        currentAssessmentData['radar_data']['values'].map((v) => v.toDouble())
      );
    }
    return [];
  }

  Map<String, dynamic> getInsights() {
    if (currentAssessmentData.containsKey('insights')) {
      return currentAssessmentData['insights'];
    }
    return {
      'dominant_strength': 'Dominant Strength'.tr,
      'dominant_description': 'No assessments completed for this type'.tr,
      'supporting_strength': 'Supporting Strength'.tr,
      'supporting_description': 'Complete an assessment to receive insights'.tr,
      'development_areas': 'Development Areas'.tr
    };
  }

  void _showCitationsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: coral500.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scientific Sources and Citations'.tr,
                    style: AppTextStyle.normalBold16.copyWith(color: coral500),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: coral500),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Our assessments are based on established scientific research and validated psychological frameworks. Below are the key academic sources that inform our tests'.tr,
                    style: AppTextStyle.normalRegular14.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 24),
                  ...citations[fixedType[selectedType]]!.map((citation) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        citation['title']!,
                        style: AppTextStyle.normalBold14.copyWith(color: indigo950),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        citation['authors']!,
                        style: AppTextStyle.normalRegular12.copyWith(color: Colors.grey[600]),
                      ),
                      if (citation['doi'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'DOI: ${citation['doi']}',
                          style: AppTextStyle.normalRegular12.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse(citation['link']!)),
                        child: Text(
                          'View Source'.tr,
                          style: AppTextStyle.normalSemiBold12.copyWith(
                            color: coral500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (citations[fixedType[selectedType]]!.last != citation)
                        const Divider(height: 24),
                    ],
                  )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(right: 20, left: 20, top: 60, bottom: 10),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: SvgPicture.asset(
                              'icons/arrowLeft.svg',
                              height: 35,
                              width: 35,
                            ),
                          ),
                          1.pw,
                          Text(
                            "Personality Insights".tr,
                            style: AppTextStyle.normalBold16.copyWith(
                              color: coral500,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _showCitationsBottomSheet,
                        icon: const Icon(Icons.info_outline),
                        tooltip: 'View Scientific Sources'.tr,
                        color: coral500,
                      ),
                    ],
                  ),
                  3.ph,
                  SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: typeOfPersonality.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedType = index;
                              updateCurrentAssessmentData();
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  typeOfPersonality[index],
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    color: AppColors.black,
                                    fontWeight: selectedType == index
                                        ? FontWeight.w800
                                        : FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (selectedType == index)
                                  Container(
                                    height: 3,
                                    width: 25,
                                    decoration: BoxDecoration(
                                      color: coral500,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  6.ph,
                  _buildRadarChart(),
                  6.ph,
                  commonWidget(
                    color: const Color(0xFF6FD18C),
                    title: "Dominant Strength".tr,
                    // text: getInsights()['dominant_strength'] ?? "Not Available".tr,
                    description: getInsights()['dominant_description'] ?? "Complete the assessment to receive insights".tr,
                  ),
                  4.ph,
                  commonWidget(
                    color: const Color(0xFFEE9D1A),
                    title: "Supporting Strength".tr,
                    text: getInsights()['supporting_strength'] ?? "Not Available".tr,
                    description: getInsights()['supporting_description'] ?? "Complete the assessment to receive insights".tr,
                  ),
                  4.ph,
                  commonWidget(
                    color: const Color(0xFF7086FD),
                    title: "Development Areas".tr,
                    description: getInsights()['development_areas'] ?? "Take this assessment to get personalized development recommendations".tr,
                  ),
                  4.ph,
                  Center(
                    child: SecondCustomButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TestDetailsScreen(
                              testName: testInfo[fixedType[selectedType]]!['name']!,
                              testImage: testInfo[fixedType[selectedType]]!['image']!,
                              testType: testInfo[fixedType[selectedType]]!['type']!,
                              testDescription: testInfo[fixedType[selectedType]]!['description']!,
                            ),
                          ),
                        );
                      },
                      width: screenSize.width / 2,
                      iconSvgPath: 'icons/arrowRight.svg',
                      text: "Start Assessment".tr,
                      textSize: 14,
                    ),
                  ),
                  6.ph,
                  _buildRecommendedStories(screenSize),
                  4.ph,
                  _buildInviteFriendsCard(),
                  2.ph,
                ],
              ),
            ),
      ),
    );
  }

  Widget _buildRadarChart() {
    final categories = getCategories();
    final values = getValues();
    
    // If no data, show empty chart with default values
    if (categories.isEmpty || values.isEmpty) {
      return AspectRatio(
        aspectRatio: 1.3,
        child: RadarChart(
          RadarChartData(
            radarTouchData: RadarTouchData(enabled: false),
            dataSets: [
              RadarDataSet(
                fillColor: Colors.green.withOpacity(0.2),
                borderColor: Colors.green,
                entryRadius: 2,
                dataEntries: List.generate(
                  5, // Default number of points
                  (index) => const RadarEntry(value: 0),
                ),
              ),
            ],
            radarShape: RadarShape.polygon,
            radarBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
            ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 1),
            titleTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
            tickBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
            gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
            titlePositionPercentageOffset: 0.2,
            radarBackgroundColor: const Color(0x8BFFF2ED),
            tickCount: 5,
            getTitle: (index, angle) {
              return RadarChartTitle(text: "Category ${index + 1}".tr, angle: angle);
            },
          ),
        ),
      );
    }
    
    // Show actual data
    return AspectRatio(
      aspectRatio: 1.3,
      child: RadarChart(
        RadarChartData(
          radarTouchData: RadarTouchData(enabled: false),
          dataSets: [
            RadarDataSet(
              fillColor: Colors.green.withOpacity(0.2),
              borderColor: Colors.green,
              entryRadius: 2,
              dataEntries: List.generate(
                values.length,
                (index) => RadarEntry(value: values[index]),
              ),
            ),
          ],
          radarShape: RadarShape.polygon,
          radarBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 1),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 12),
          tickBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
          gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
          titlePositionPercentageOffset: 0.2,
          radarBackgroundColor: const Color(0x8BFFF2ED),
          tickCount: 5,
          getTitle: (index, angle) {
            if (index < categories.length) {
              return RadarChartTitle(text: categories[index].tr, angle: angle);
            }
            return const RadarChartTitle(text: "");
          },
        ),
      ),
    );
  }

  Widget _buildRecommendedStories(Size screenSize) {
    if ((ReadController.getAllStoriesBy.value.data?.length ?? 0) <= 0) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommended for you'.tr,
          textAlign: TextAlign.start,
          style: AppTextStyle.normalBold16.copyWith(color: coral500),
        ),
        1.ph,
        SizedBox(
          height: screenSize.height / 4,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: ((ReadController.getAllStoriesBy.value.data?.length ?? 0) > 5)
                ? 5
                : ReadController.getAllStoriesBy.value.data?.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    HomeController.backToHome(false);
                    ChatController.backToCharacters(false);
                    ReadController.backToStories(false);
                    ChallengeController.backToChallenge(true);
                    ReadController.storyId('');
                    nextPage(StoryDetailsScreen(
                      storyId: ReadController.getAllStoriesBy.value.data?[index].id.toString() ?? '',
                    ));
                    ReadController.storyId(
                      ReadController.getAllStoriesBy.value.data?[index].id.toString() ?? '',
                    );
                  },
                  child: Container(
                    height: screenSize.height / 4,
                    width: screenSize.width / 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: indigo50, width: 2),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 5,
                          spreadRadius: 3,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        children: [
                          CachedNetworkImage(
                            imageUrl: "${DatabaseApi.mainUrlImage}${ReadController.getAllStoriesBy.value.data?[index].storiesImage}",
                            placeholder: (context, url) => const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [CircularProgressIndicator()],
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: const BoxDecoration(color: AppColors.red),
                              child: const Icon(Icons.error_outline, color: AppColors.black),
                            ),
                            height: screenSize.height / 5.3,
                            width: screenSize.width / 3,
                            fit: BoxFit.cover,
                          ),
                          0.5.ph,
                          Text(
                            ((ReadController.getAllStoriesBy.value.data?[index].name.toString() ?? '').length > 25)
                                ? '${(ReadController.getAllStoriesBy.value.data?[index].name.toString() ?? '').substring(0, 25)}...'
                                : ReadController.getAllStoriesBy.value.data?[index].name.toString() ?? '',
                            style: AppTextStyle.normalBold12.copyWith(color: headingColour),
                            maxLines: 2,
                          ),
                          0.5.ph,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInviteFriendsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFFFF2EC),
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Invite your friends".tr,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .55,
                  child: Text(
                    "Invite friends and get special perks and badges.".tr,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .2,
                  child: Image.asset("images/gift.png"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget commonWidget({
    Color? color,
    String? title,
    String? text,
    String? description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * .8,
              child: Text(
                title ?? "",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Text(
        //   text ?? "",
        //   style: GoogleFonts.inter(
        //     fontSize: 13,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
        if (description != null) ...[
          const SizedBox(height: 5),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
        ],
      ],
    );
  }
}
