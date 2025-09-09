import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../models/chat/chat_model.dart';
import '../../../../../util/colors.dart';
import 'companion_avatar.dart';

class MessageBubble extends StatelessWidget {
  final Messages message;
  final VoidCallback audioPlay;
  final int? playingState;
  final Duration? duration;

  const MessageBubble(
      {required this.message,
        required this.audioPlay,
        this.playingState,
        this.duration});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CompanionAvatar(),
                const SizedBox(width: 8),
              ],
              if (message.messageType == "TEXT") ...[
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(
                      colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
                    )
                        : null,
                    color: isUser ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Linkify(
                        onOpen: (link) async {
                          if (!await launchUrl(Uri.parse(link.url))) {
                            throw Exception('Could not launch ${link.url}');
                          }
                        },
                        text: message.content ?? "",
                        style: GoogleFonts.montserrat(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                        linkStyle: GoogleFonts.montserrat(
                          color: AppColors.black,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        DateFormat('hh:mm a').format(
                          DateTime.parse(
                            message.sentAt!,
                          ),
                        ),
                        style: GoogleFonts.montserrat(
                          fontSize: 10.0,
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      )
                    ],
                  ),
                ),
              ] else if (message.messageType == "AUDIO") ...[
                Container(
                  width: MediaQuery.of(context).size.width * .52,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF7F42), Color(0xFFFF4761)],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(right: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: audioPlay,
                                  child: Icon(
                                    playingState == 0
                                        ? Icons.play_arrow
                                        : playingState == 1
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: AppColors.white,
                                    size: 22,
                                  ),
                                ),
                                Text(
                                  playingState == 0
                                      ? message.duration
                                      : duration == null
                                      ? message.duration
                                      : duration != null
                                      ? (duration!.inSeconds
                                      .toString()
                                      .length ==
                                      1)
                                      ? "0${duration!.inMinutes} : 0${duration!.inSeconds}"
                                      : "0${duration!.inMinutes} : ${duration!.inSeconds}"
                                      : "00 : 00",
                                  maxLines: 1,
                                  style: GoogleFonts.montserrat(
                                    color: AppColors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * .3,
                                  child: Text(
                                    message.content!.split("/").last,
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                    style: GoogleFonts.montserrat(
                                      color: AppColors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  DateFormat('hh:mm a').format(
                                    DateTime.parse(
                                      message.sentAt!,
                                    ),
                                  ),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10.0,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
          if (message.isMessageSend) ...[
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CompanionAvatar(),
                const SizedBox(width: 8),
                Container(
                  alignment: Alignment.centerLeft,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.3,
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Skeletonizer(
                    enabled: true,
                    child: SizedBox(
                      height: 20,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(0),
                        itemCount: 5,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 10,
                            width: 10,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFF4761),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }
}