import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yokai_quiz_app/Widgets/progressHud.dart';
import 'package:yokai_quiz_app/screens/Authentication/controller/auth_screen_controller.dart';
import 'package:yokai_quiz_app/screens/assistance/assistance_screen.dart';
import 'package:yokai_quiz_app/screens/challenge/controller/challenge_controller.dart';
import 'package:yokai_quiz_app/screens/navigation/view/navigation.dart';
import 'package:yokai_quiz_app/screens/todo/view/todo_screen.dart';
import 'package:yokai_quiz_app/util/colors.dart';
import 'package:yokai_quiz_app/util/const.dart';
import 'package:yokai_quiz_app/util/constants.dart';
import 'package:yokai_quiz_app/util/text_styles.dart';
import '../../../api/database_api.dart';
import '../../../api/local_storage.dart';
import '../../../global.dart';
import '../../../main.dart';
import '../../chat/controller/chat_controller.dart';
import '../../chat/view/characters_details_page.dart';
import '../../read/controller/read_controller.dart';
import '../../read/view/read_stories_page.dart';
import '../../read/view/story_open_story_page.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RxBool isLoading = false.obs;
  String deviceId = "Fetching device info...";
  String deviceName = "";
  String ipAddress = "192.168.0.1";

  @override
  void initState() {
    super.initState();
    isLoading(true);
    fetchData();
  }

  String hashString(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString().substring(0, 10);
  }

  fetchData() async {
    await HomeController.getLastReadChapter().then((value) async {
      await AuthScreenController.fetchData().then((value) async {
        await HomeController.incrementUserLog().then((value) async {
          await ChallengeController.getAllChallenges().then((value) async {
            await getDeviceInfo().then((value) async {
              await HomeController.recordDevice(deviceId, deviceName, ipAddress)
                  .then((value) async {
                isLoading(false);
              });
            });
          });
        });
      });
    });
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (GetPlatform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
        setState(() {
          deviceId = hashString('${androidInfo.device}${androidInfo.id}');
          deviceName = androidInfo.device;
        });
      } else if (GetPlatform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        setState(() {
          deviceId = '${iosInfo.name}${iosInfo.identifierForVendor}';
          deviceName = iosInfo.name;
        });
      }
    } catch (e) {
      setState(() {
        deviceId = 'Failed to get device info: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Obx(() {
      return ProgressHUD(
        isLoading: isLoading.value,
        child: Scaffold(
          backgroundColor: colorWhite,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${"Hi".tr} ${(prefs.getString(LocalStorage.username) != null) ? prefs.getString(LocalStorage.username) : ''}${(prefs.getString(LocalStorage.username) != null) ? '!' : ''}',
                          style: AppTextStyle.normalBold20
                              .copyWith(color: headingColour),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => const YokaiAssistanceScreen());
                        },
                        child: constants.appYokaiPath == null
                            ? Image.asset(
                                'images/appLogo_yokai.png',
                                // color: headingOrange,
                                height: 50,
                                width: 50,
                              )
                            : Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(constants.appYokaiPath!),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  2.ph,
                  if ((ReadController.getAllStoriesBy.value.data?.length ?? 0) >
                      0)
                    Text(
                      'Trending'.tr,
                      style:
                          AppTextStyle.normalBold16.copyWith(color: coral500),
                    ),
                  1.ph,
                  if ((ReadController.getAllStoriesBy.value.data?.length ?? 0) >
                      0)
                    SizedBox(
                      height: screenSize.height / 3.7,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: ((ReadController
                                        .getAllStoriesBy.value.data?.length ??
                                    0) >
                                5)
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
                                nextPage(OpenStoryPage(
                                  storyId: ReadController
                                          .getAllStoriesBy.value.data?[index].id
                                          .toString() ??
                                      '',
                                ));
                                ReadController.storyId(
                                  ReadController
                                          .getAllStoriesBy.value.data?[index].id
                                          .toString() ??
                                      '',
                                );
                              },
                              child: Container(
                                height: screenSize.height / 3.7,
                                width: screenSize.width / 2.8,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: indigo50, width: 2),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.05),
                                          blurRadius: 5,
                                          spreadRadius: 3)
                                    ]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Column(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl:
                                            "${DatabaseApi.mainUrlImage}${ReadController.getAllStoriesBy.value.data?[index].storiesImage}",
                                        placeholder: (context, url) =>
                                            const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                          ],
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          decoration: const BoxDecoration(
                                              color: AppColors.red),
                                          child: const Icon(
                                            Icons.error_outline,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        height: screenSize.height / 5.3,
                                        width: screenSize.width / 2.8,
                                        fit: BoxFit.cover,
                                      ),
                                      0.5.ph,
                                      Container(
                                        alignment: Alignment.center,
                                        height: screenSize.height / 15.5,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 3),
                                          child: Text(
                                            ((ReadController
                                                                .getAllStoriesBy
                                                                .value
                                                                .data?[index]
                                                                .name
                                                                .toString() ??
                                                            '')
                                                        .length >
                                                    25)
                                                ? '${(ReadController.getAllStoriesBy.value.data?[index].name.toString() ?? '').substring(0, 25)}...'
                                                : ReadController.getAllStoriesBy
                                                        .value.data?[index].name
                                                        .toString() ??
                                                    '',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyle.normalBold12
                                                .copyWith(color: headingColour),
                                            maxLines: 2,
                                          ),
                                        ),
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
                  2.ph,
                  Text(
                    'Explore'.tr,
                    style: AppTextStyle.normalBold16.copyWith(color: coral500),
                  ),
                  1.ph,
                  ChallengeController.getChallengeAll.value.data == null
                      ? const SizedBox()
                      : SizedBox(
                          height: screenSize.height / 14,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: ChallengeController
                                .getChallengeAll.value.data!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NavigationPage(index: 3),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Container(
                                    height: screenSize.height / 10,
                                    width: screenSize.width / 2.8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: AppColors.white,
                                      border:
                                          Border.all(color: indigo50, width: 2),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          "${DatabaseApi.mainUrlImage}${ChallengeController.getChallengeAll.value.data![index].image!}",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        ChallengeController.getChallengeAll
                                            .value.data![index].name!,
                                        maxLines: 1,
                                        style:
                                            AppTextStyle.normalBold12.copyWith(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  2.ph,
                  GestureDetector(
                    onTap: () {
                      HomeController.backToHome(false);
                      ChatController.backToCharacters(false);
                      ReadController.backToStories(false);
                      ChallengeController.backToChallenge(true);
                      nextPage(const TodoScreen());
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(209, 76, 223, 0.86),
                            Color.fromRGBO(135, 77, 188, 0.77),
                            Color.fromRGBO(63, 78, 153, 0.98),
                          ],
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Opacity(
                              opacity: .4,
                              child: Image.asset(
                                'images/bgviewprofile.png',
                                width: 70, // Adjust the width as needed
                                height: 70, // Adjust the height as needed
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                "To Do List".tr,
                                style: AppTextStyle.normalBold20
                                    .copyWith(color: Colors.white),
                              ),
                              1.ph,
                              Row(
                                children: [
                                  Image.asset(
                                    'icons/todo.png',
                                    height: 40,
                                    width: 40,
                                  ),
                                  Flexible(
                                    child: Text(
                                      "Complete tasks & win exclusive badges and premium subscriptions."
                                          .tr,
                                      style: AppTextStyle.normalBold12.copyWith(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  2.ph,
                  if ((HomeController
                              .getLastReadChapterModel.value.data?.length ??
                          0) >
                      0)
                    Text(
                      'Pick up where you left off'.tr,
                      style:
                          AppTextStyle.normalBold16.copyWith(color: coral500),
                    ),
                  1.ph,
                  if ((HomeController
                              .getLastReadChapterModel.value.data?.length ??
                          0) >
                      0)
                    SizedBox(
                      height: screenSize.height / 4,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: HomeController
                            .getLastReadChapterModel.value.data?.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () async {
                              final body = {
                                "read_status": "1",
                                "read_date": '${DateTime.now()}'
                              };
                              await ReadController.updateChapterReadStatus(
                                      context,
                                      HomeController.getLastReadChapterModel
                                              .value.data?[index].id
                                              .toString() ??
                                          '',
                                      body)
                                  .then(
                                (value) {
                                  HomeController.backToHomeChapter(true);
                                  nextPage(ReadStoriesPage(
                                    // chapter: ReadController.chapter[index]['chapter'],
                                    chapterId: HomeController
                                            .getLastReadChapterModel
                                            .value
                                            .data?[index]
                                            .id
                                            .toString() ??
                                        '',
                                    storyName: HomeController
                                            .getLastReadChapterModel
                                            .value
                                            .data?[index]
                                            .storyName
                                            .toString() ??
                                        '',
                                  ));
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Container(
                                height: screenSize.height / 4,
                                width: screenSize.width / 3,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: indigo50, width: 2),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.withOpacity(0.05),
                                          blurRadius: 5,
                                          spreadRadius: 3)
                                    ]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          alignment: Alignment.topCenter,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl:
                                                  "${DatabaseApi.mainUrlImage}${HomeController.getLastReadChapterModel.value.data?[index].storyImage.toString() ?? ''}",
                                              placeholder: (context, url) =>
                                                  const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircularProgressIndicator(),
                                                ],
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                decoration: const BoxDecoration(
                                                    color: AppColors.red),
                                                child: const Icon(
                                                  Icons.error_outline,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                              height: screenSize.height / 4,
                                              width: screenSize.width / 3,
                                              fit: BoxFit.cover,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ((HomeController
                                                                  .getLastReadChapterModel
                                                                  .value
                                                                  .data?[index]
                                                                  .name
                                                                  .toString() ??
                                                              '')
                                                          .length >
                                                      12)
                                                  ? '${(HomeController.getLastReadChapterModel.value.data?[index].name.toString() ?? '').substring(0, 12)}...'
                                                  : HomeController
                                                          .getLastReadChapterModel
                                                          .value
                                                          .data?[index]
                                                          .name
                                                          .toString() ??
                                                      '',
                                              style: AppTextStyle.normalBold12
                                                  .copyWith(
                                                      color: headingColour),
                                            ),
                                            Text(
                                              HomeController
                                                      .getLastReadChapterModel
                                                      .value
                                                      .data?[index]
                                                      .chapterNo
                                                      .toString() ??
                                                  '',
                                              style: AppTextStyle.normalBold12
                                                  .copyWith(color: greyCh),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  2.ph,
                  if ((ChatController
                              .getAllCharactersModel.value.data?.length ??
                          0) >
                      0)
                    Text(
                      'Buddies'.tr,
                      style:
                          AppTextStyle.normalBold16.copyWith(color: coral500),
                    ),
                  if ((ChatController
                              .getAllCharactersModel.value.data?.length ??
                          0) >
                      0)
                    1.ph,
                  if ((ChatController
                              .getAllCharactersModel.value.data?.length ??
                          0) >
                      0)
                    SizedBox(
                      height: screenSize.height / 10,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: ((ChatController.getAllCharactersModel.value
                                        .data?.length ??
                                    0) >
                                5)
                            ? 5
                            : ChatController
                                .getAllCharactersModel.value.data?.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 30),
                            child: GestureDetector(
                              onTap: () {
                                HomeController.backToHomeFromCharactersDetails(
                                    true);
                                ChatController
                                    .backToCharactersForCharactersDetails(
                                        false);
                                nextPage(
                                  CharactersDetailsPage(
                                    characterId: ChatController
                                            .getAllCharactersModel
                                            .value
                                            .data?[index]
                                            .id
                                            .toString() ??
                                        '',
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(35),
                                          // half of the height/width
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                "${DatabaseApi.mainUrlImage}${ChatController.getAllCharactersModel.value.data?[index].characterImage.toString() ?? ''}",
                                            placeholder: (context, url) =>
                                                const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(),
                                              ],
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Container(
                                              decoration: const BoxDecoration(
                                                  color: AppColors.red),
                                              child: const Icon(
                                                Icons.error_outline,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            height: 60,
                                            width: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SvgPicture.asset('icons/lock.svg'),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    ((ChatController.getAllCharactersModel.value
                                                        .data?[index].name
                                                        .toString() ??
                                                    '')
                                                .length >
                                            10)
                                        ? '${(ChatController.getAllCharactersModel.value.data?[index].name.toString() ?? '').substring(0, 10)}...'
                                        : ChatController.getAllCharactersModel
                                                .value.data?[index].name
                                                .toString() ??
                                            '',
                                    style: AppTextStyle.normalBold10
                                        .copyWith(color: indigo700),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  2.ph,
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
