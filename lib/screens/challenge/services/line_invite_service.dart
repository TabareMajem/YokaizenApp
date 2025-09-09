// lib/screens/services/line_invite_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_line_sdk/flutter_line_sdk.dart';
import 'line_auth_service.dart';

class LineInviteService {
  static final LineInviteService _instance = LineInviteService._internal();
  factory LineInviteService() => _instance;
  LineInviteService._internal();

  final LineAuthService _authService = LineAuthService();

  Future<void> handleInviteFriends(BuildContext context) async {
    try {
      final userProfile = await _authService.loginOrSignUp();

      if (userProfile == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Please try again.')),
          );
        }
        return;
      }

      print('Fetching friends list...');
      final friends = await _authService.getFriends();

      if (friends.isEmpty) {
        print('No friends found.');
        return;
      }

      if (context.mounted) {
        await _showFriendSelectionDialog(context, friends);
      }
    } catch (e) {
      print('Error in handleInviteFriends: $e');
    }
  }

  Future<List<UserProfile>> _getFriendsList() async {
    // Since LINE SDK doesn't allow fetching friends, return mock data
    return [
      // UserProfile(userId: '1', displayName: 'John Doe'),
      // UserProfile(userId: '2', displayName: 'Jane Smith'),
    ];
  }

  Future<void> _showFriendSelectionDialog(BuildContext context, List<UserProfile> friends) async {
    List<UserProfile> selectedFriends = [];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Select Friends to Invite'),
              content: SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    final friend = friends[index];
                    final bool isSelected = selectedFriends.contains(friend);

                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedFriends.add(friend);
                          } else {
                            selectedFriends.remove(friend);
                          }
                        });
                      },
                      title: Text(friend.displayName ?? 'Unknown'),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Invite Selected'),
                  onPressed: selectedFriends.isEmpty
                      ? null
                      : () {
                    print('Inviting ${selectedFriends.length} friends');
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
