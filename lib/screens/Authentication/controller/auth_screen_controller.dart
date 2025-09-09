import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../api/database_api.dart';
import '../../../api/node_database.dart';
import '../../../api/local_storage.dart';
import '../../../global.dart';
import '../../../main.dart';
import '../../../models/get_profile_model.dart';
import '../../../util/colors.dart';

class AuthScreenController {
  static int userId = 1;
  static TextEditingController passwordcontroller = TextEditingController();
  static TextEditingController nameController = TextEditingController();
  static TextEditingController emailcontroller = TextEditingController();
  static TextEditingController phonecontroller = TextEditingController();
  static TextEditingController schoolcontroller = TextEditingController();
  static TextEditingController gradecontroller = TextEditingController();

  static Rx<GetUserProfile> getProfileModel = GetUserProfile().obs;

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<bool> createAccount(BuildContext context, body) async {
    final String url = DatabaseApi.create;
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "AdminToken": prefs.getString(LocalStorage.token).toString()
    };
    print(headers);
    customPrint("createActivity Url::$url");
    customPrint("createActivity body::${jsonEncode(body)}");
    try {
      return await http
          .post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: headers,
      )
          .then((value) async {
        print("inside http post request value :: $value");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          String errorMessage = jsonData["message"].toString().replaceAll("_", " ");
          showErrorMessage(errorMessage.tr, colorError);
          customPrint("createActivity response :: ${value.body}");
          customPrint("createActivity message 2222222 ::${jsonData["message"]}");
          return false;
        } else {
          // showSucessMessage(jsonData["message"], colorSuccess);
        }
        customPrint("createActivity::${value.body}");
        return true;
      });
    } on Exception catch (e) {
      customPrint("Error :: $e");
      return false;
    }
  }

  static Future<bool> nodeCreateAccount(BuildContext context, body) async {
    final String url = NodeDatabaseApi.createAccount;
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
    };
    customPrint("Create Account Url::$url");
    customPrint("Create Account body::${jsonEncode(body)}");
    try {
      return await http
          .post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: headers,
      )
          .then((value) async {
        final jsonData = jsonDecode(value.body);
        if (jsonData["success"].toString() != "true") {
          showErrorMessage(jsonData["message"], colorError);
          customPrint("createActivity response :: ${value.body}");
          customPrint("createActivity message 1111111::${jsonData["message"]}");
          return false;
        } else {
          prefs.setString(LocalStorage.tokenNode, jsonData["token"].toString());
          prefs.setString(LocalStorage.idNode, jsonData["userId"].toString());
          print('Node token :: ${prefs.getString(LocalStorage.tokenNode)}');
          print('Node ID :: ${prefs.getString(LocalStorage.idNode)}');
        }
        customPrint("createActivity::${value.body}");
        return true;
      });
    } on Exception catch (e) {
      customPrint("Error :: $e");
      return false;
    }
  }

  static Future<bool> updatePasswordFromApi(
      BuildContext context, String email, body) async {
    final String url = "${DatabaseApi.updatePassword}$email";
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "AdminToken": prefs.getString(LocalStorage.token).toString()
    };
    print(headers);

    customPrint("updatePasswordFromApi Url::$url");
    customPrint("updatePasswordFromApi body::${jsonEncode(body)}");
    try {
      return await http
          .put(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: headers,
      )
          .then((value) async {
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          // showErrorMessage(jsonData["message"], colorError);
          customPrint("updatePasswordFromApi response :: ${value.body}");
          customPrint("updatePasswordFromApi message::${jsonData["message"]}");
          return false;
        } else {
          // showSucessMessage(jsonData["message"], colorSuccess);
        }
        customPrint("updatePasswordFromApi::${value.body}");
        return true;
      });
    } on Exception catch (e) {
      customPrint("Error :: $e");
      // showSnackbar(
      //     context,
      //     "Some unknown error has occur, try again after some time",
      //     colorError);
      return false;
    }
  }

  static Future<bool> login(BuildContext context, body) async {
    final String url = DatabaseApi.login;
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "AdminToken": prefs.getString(LocalStorage.token).toString()
    };
    print(headers);

    print("login Url::$url");
    print("login body::${jsonEncode(body)}");
    try {
      return await http
          .post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: headers,
      )
          .then((value) async {
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          isApiLoginSuccess(false);
          if (isFirebaseLoginSuccess.isFalse) {
            showErrorMessage("Login Failed", colorError);
          }
          print('login :: ${jsonData["message"]}');
          return false;
        } else {
          isApiLoginSuccess(true);
          showSucessMessage("User Login Successfully", colorSuccess);
          prefs.clear();
          prefs.setString(LocalStorage.token, jsonData["token"].toString());
          prefs.setBool(LocalStorage.isLogin, true);
          print('token :: ${prefs.getString(LocalStorage.token)}');
        }
        print("signInWithGoogle login:: ${value.body}");
        // nodeLoginGoogle(context);
        return true;
      });
    } on Exception catch (e) {
      customPrint("Error :: $e");
      // showSnackbar(
      //     context,
      //     "Some unknown error has occur, try again after some time",
      //     colorError);
      return false;
    }
  }

  static Future<bool> nodeLoginGoogle(BuildContext context) async {
    customPrint("nodeLoginGoogle got invoked");
    try {
      // Change auth.currentUser to _auth.currentUser
      final user = _auth.currentUser;
      if (user == null) {
        print('No Firebase user found');
        return false;
      }

      // Get fresh ID token
      final idToken = await user.getIdToken(true); // Force refresh token
      
      final String url = NodeDatabaseApi.loginGoogle;
      final headers = {
        "Content-Type": "application/json",
        // "accept": "application/json",
      };
      
      final requestBody = {
        "idToken": idToken
      };

      print("Node login URL: $url");
      print("Node login body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final jsonData = jsonDecode(response.body);
      print("Node login response: ${response.body}");

      if (jsonData["success"] == true) { // Changed from string comparison to boolean
        isApiLoginSuccess(true);
        
        // Store Node backend tokens
        await prefs.setString(LocalStorage.tokenNode, jsonData["token"].toString());
        await prefs.setString(LocalStorage.idNode, jsonData["user"]["userId"].toString());
        
        print('Node token: ${prefs.getString(LocalStorage.tokenNode)}');
        print('Node ID: ${prefs.getString(LocalStorage.idNode)}');
        return true;
      } else {
        isApiLoginSuccess(false);
        if (isFirebaseLoginSuccess.isFalse) {
          showErrorMessage(jsonData["message"] ?? "Authentication failed", colorError);
        }
        print('Node login failed: ${jsonData["message"]}');
        return false;
      }

    } catch (e) {
      print("Node login error: $e");
      customPrint("Error: $e");
      showErrorMessage("Failed to authenticate with companion service", colorError);
      return false;
    }
  }

  static Future<bool> nodeLoginApple(BuildContext context) async {
    customPrint("nodeLoginApple got invoked");
    try {
      // Check for Firebase user
      final user = _auth.currentUser;
      if (user == null) {
        print('No Firebase user found');
        return false;
      }

      // Get fresh ID token from Firebase
      final idToken = await user.getIdToken(true); // Force refresh token

      final String url = NodeDatabaseApi.loginApple;
      final headers = {
        "Content-Type": "application/json",
      };

      final requestBody = {
        "idToken": idToken
      };

      print("Node login URL: $url");
      print("Node login body: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      final jsonData = jsonDecode(response.body);
      print("Node login response: ${response.body}");

      if (jsonData["success"] == true) {
        isApiLoginSuccess(true);

        // Store Node backend tokens
        await prefs.setString(LocalStorage.tokenNode, jsonData["token"].toString());
        await prefs.setString(LocalStorage.idNode, jsonData["user"]["userId"].toString());

        print('Node token: ${prefs.getString(LocalStorage.tokenNode)}');
        print('Node ID: ${prefs.getString(LocalStorage.idNode)}');
        return true;
      } else {
        isApiLoginSuccess(false);
        if (isFirebaseLoginSuccess.isFalse) {
          showErrorMessage(jsonData["message"] ?? "Authentication failed", colorError);
        }
        print('Node login failed: ${jsonData["message"]}');
        return false;
      }

    } catch (e) {
      print("Node login error: $e");
      customPrint("Error: $e");
      showErrorMessage("Failed to authenticate with companion service", colorError);
      return false;
    }
  }

  static Future<bool> nodeLogin(BuildContext context, body) async {
    final String url = NodeDatabaseApi.login;
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
    };
    print(headers);

    print("nodeLogin Url::$url");
    print("nodeLogin body::${jsonEncode(body)}");
    try {
      return await http
          .post(
        Uri.parse(url),
        body: jsonEncode(body),
        headers: headers,
      )
          .then((value) async {
        final jsonData = jsonDecode(value.body);
        if (jsonData["success"].toString() != "true") {
          customPrint("inside if means jsonData true");
          isApiLoginSuccess(false);
          if (isFirebaseLoginSuccess.isFalse) {
            customPrint("inside if if means error message ");
            showErrorMessage(jsonData["message"], colorError);
          }
          print('nodeLogin :: ${jsonData["message"]}');
          return false;
        } else {
          isApiLoginSuccess(true);

          prefs.setString(LocalStorage.tokenNode, jsonData["token"].toString());
          prefs.setString(
              LocalStorage.idNode, jsonData["user"]["userId"].toString());
          print('Node token :: ${prefs.getString(LocalStorage.tokenNode)}');
          print('Node ID :: ${prefs.getString(LocalStorage.idNode)}');
        }
        print("login Node::${value.body}");
        return true;
      });
    } on Exception catch (e) {
      customPrint("Error :: $e");
      // showSnackbar(
      //     context,
      //     "Some unknown error has occur, try again after some time",
      //     colorError);
      return false;
    }
  }

  static RxBool isFirebaseLoginSuccess = false.obs;
  static RxBool isApiLoginSuccess = false.obs;

  static Future<bool> loginWithFirebase(
      BuildContext context, String email, String password) async {
    customPrint("loginWithFirebase body::$email - $password");
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      isFirebaseLoginSuccess(true);
      print('Login successful!');
      return true;
    } catch (e) {
      isFirebaseLoginSuccess(false);
      String errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]\s*'), '');
      showErrorMessage(errorMessage, colorError);
      print('loginWithFirebase Error: $errorMessage');
      return false;
    }
  }

  static Future<String> signUpWithFirebase(
      BuildContext context, String email, String password) async {
    customPrint("signUpWithFirebase body::$email - $password");
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print('Signup successful!');
      return "true";
    } on FirebaseAuthException catch (e) {
      print('signUpWithFirebase Error: ${e.message}');
      return "${e.message}";
    }
  }

  static Future<bool> signOutWithFirebase() async {
    customPrint("signOutWithFirebase body::");
    try {
      await FirebaseAuth.instance.signOut();
      print('Signout successful!');
      return true;
    } catch (e) {
      showErrorMessage("$e", colorError);
      print('signOutWithFirebase Error: $e');
      return false;
    }
  }

  static Future<bool> updatePasswordWithFirebase(
      BuildContext context, String currentPassword, String newPassword) async {
    customPrint(
        "updatePasswordWithFirebase body::$currentPassword - $newPassword");
    try {
      auth.User? user = FirebaseAuth.instance.currentUser;
      AuthCredential credential = EmailAuthProvider.credential(
          email: user!.email.toString(), password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      print('Password updated successfully!');
      return true;
    } catch (e) {
      showErrorMessage("$e", colorError);
      print('updatePasswordWithFirebase Error: $e');
      return false;
    }
  }

  static Future<bool> forgotPasswordWithFirebase(
      BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showSucessMessage(
          "Password reset email sent successfully!", colorSuccess);
      print('Password reset email sent successfully!');
      return true;
    } catch (e) {
      showErrorMessage("$e", colorError);
      print('forgotPasswordWithFirebase Error: $e');
      return false;
    }
  }

  static Future<bool> getProfile() async {
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "UserToken": prefs.getString(LocalStorage.token).toString()
    };
    print(headers);

    final String url = '${DatabaseApi.getProfile}';
    customPrint("getProfile url :: $url");
    customPrint(
        "getProfile token :: ${prefs.getString(LocalStorage.token).toString()}");
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        print("getProfile :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        //showSnackbar("Subscription PlanPrice Details Added Successfully", colorSuccess);
        getProfileModel(getUserProfileFromJson(value.body));
        return true;
      });
    } on Exception catch (e) {
      print("getProfile:: $e");
      // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
      return false;
    }
  }

  static Future<bool> updateProfile(BuildContext context, body) async {
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "UserToken": prefs.getString(LocalStorage.token).toString()
    };
    print(headers);

    final String url = DatabaseApi.updateProfile;

    customPrint("updateProfile URL :: $url");
    print("updateProfile body :: ${jsonEncode(body)}");
    try {
      return await http
          .put(Uri.parse(url), body: jsonEncode(body), headers: headers)
          .then((value) {
        customPrint("updateProfile :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          showErrorMessage(jsonData.toString(), colorError);
          return false;
        }
        showSucessMessage("Updated Successfully", colorSuccess);
        return true;
      });
    } on Exception catch (e) {
      customPrint("Edit Device :: $e");
      showErrorMessage(
          "Some unknown error has occur, try again after some time",
          colorError);
      return false;
    }
  }

  static Future<void> fetchData() async {
    // isLoading(true);
    if (prefs.getBool(LocalStorage.isLogin) == true) {
      await getProfile().then((value) {
        if (value) {
          nameController.text =
              getProfileModel.value.user?.name.toString() ?? '';
          prefs.setString(LocalStorage.username, nameController.text);
          phonecontroller.text =
              getProfileModel.value.user?.phoneNumber.toString() ?? '';
          emailcontroller.text =
              getProfileModel.value.user?.email.toString() ?? '';

          userId = getProfileModel.value.user!.userId ?? 1;
          prefs.setString(LocalStorage.id, userId.toString());
        }


        // isLoading(false);
      });
    }
  }

  ///
  // static final FirebaseAuth _auth = FirebaseAuth.instance;
  // static final GoogleSignIn _googleSignIn = GoogleSignIn();
  //
  // static Future<void> signInWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     if (googleUser == null) {
  //       // The user canceled the sign-in
  //       print('The user canceled the sign-in');
  //       return;
  //     }
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     final UserCredential userCredential = await _auth.signInWithCredential(credential);
  //     final User? user = userCredential.user;
  //
  //     if (user != null) {
  //       print('Signed in as ${user.displayName}');
  //     }
  //   } catch (e) {
  //     print('Error signing in with Google: $e');
  //   }
  // }
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static RxString googleName = ''.obs;
  static RxString googleEmail = ''.obs;
  static RxString googlePhoneNumber = ''.obs;
  static RxString googleUid = ''.obs;

  static Future<Map<String, dynamic>> signInWithGoogle(BuildContext context) async {
    try {
      print("signInWithGoogle got invoked");

      // Clear any previous sign-in
      await GoogleSignIn().signOut();

      // For Android release builds, we don't need to explicitly specify clientId
      // as it's configured through google-services.json
      // Just use the default constructor with scopes
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      // If user cancels the sign-in flow
      if (googleUser == null) {
        print("Google Sign-In was cancelled by user");
        return {"success": false, "message": "Sign in cancelled"};
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Log tokens for debugging (remove in production)
      print("Google Auth has access token: ${googleAuth.accessToken != null}");
      print("Google Auth has ID token: ${googleAuth.idToken != null}");

      if (googleAuth.idToken == null) {
        print("Failed to obtain ID token from Google");
        return {"success": false, "message": "Failed to obtain authentication token"};
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      try {
        // Sign in to Firebase with the credential
        final UserCredential userCredential = 
            await FirebaseAuth.instance.signInWithCredential(credential);
          
        if (userCredential.user != null) {
          googleEmail(userCredential.user!.email);
          googleUid(userCredential.user!.uid);
          googleName(userCredential.user!.displayName);
          googlePhoneNumber(userCredential.user!.phoneNumber);
          print('Signed in as googleName :: ${userCredential.user!.displayName}');
          print('Signed in as googleEmail :: ${userCredential.user!.email}');
          print('Signed in as googlePhoneNumber :: ${userCredential.user!.phoneNumber}');
          print('Signed in as googleUid :: ${userCredential.user!.uid}');
          return {"success": true, "message": "Sign in successful"};
        } else {
          print("Firebase returned null user after credential sign-in");
          return {"success": false, "message": "Authentication failed"};
        }
      } catch (firebaseError) {
        print("Firebase auth error: $firebaseError");
        return {"success": false, "message": "Firebase authentication failed: $firebaseError"};
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      showErrorMessage("Google Sign In Error: ${e.toString()}", colorError);
      return {"success": false, "message": e.toString()};
    }
  }

  ///
  // static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static RxString appleName = ''.obs;
  static RxString appleEmail = ''.obs;
  static RxString appleUid = ''.obs;
  static RxString applePhoneNumber = ''.obs;

  ///
  // static Future<void> signInWithApple() async {
  //   try {
  //     final AuthorizationCredentialAppleID credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.fullName,
  //         AppleIDAuthorizationScopes.email,
  //       ],
  //
  //     );
  //
  //
  //     final auth.AuthCredential firebaseCredential = auth.OAuthProvider("apple.com").credential(
  //       idToken: credential.identityToken,
  //       accessToken: credential.authorizationCode,
  //     );
  //
  //     final auth.UserCredential userCredential = await _auth.signInWithCredential(firebaseCredential);
  //     final auth.User? user = userCredential.user;
  //
  //     if (user != null) {
  //       appleEmail(user.email ?? '');
  //       appleUid(user.uid);
  //       appleName(user.displayName ?? '');
  //       print('Signed in as appleName :: ${user.displayName}');
  //       print('Signed in as appleEmail :: ${user.email}');
  //       print('Signed in as appleUid :: ${user.uid}');
  //     }
  //   } catch (e) {
  //     if (e is SignInWithAppleAuthorizationException) {
  //       print('Authorization error: ${e.code}, ${e.message}');
  //     } else if (e is PlatformException) {
  //       print('Platform error: ${e.code}, ${e.message}');
  //     } else {
  //       print('Error signing in with Apple: $e');
  //     }
  //   }
  // }


  // static Future<void> signInWithApple() async {
  //   try {
  //     // Trigger the sign-in flow
  //     final AuthorizationCredentialAppleID credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.fullName,
  //         AppleIDAuthorizationScopes.email,
  //       ],
  //     );
  //     // Create a new credential
  //     final auth.AuthCredential firebaseCredential = auth.OAuthProvider("apple.com").credential(
  //       idToken: credential.identityToken,
  //       accessToken: credential.authorizationCode,
  //     );
  //
  //     // Sign in to Firebase with the credential
  //     final auth.UserCredential userCredential = await _auth.signInWithCredential(firebaseCredential);
  //     final auth.User? user = userCredential.user;
  //
  //     if (user != null) {
  //       appleEmail(user.email ?? '');
  //       appleUid(user.uid);
  //       appleName(user.displayName ?? '');
  //       print('Signed in as appleName :: ${user.displayName}');
  //       print('Signed in as appleEmail :: ${user.email}');
  //       print('Signed in as appleUid :: ${user.uid}');
  //     }
  //   } catch (e) {
  //     print('Error signing in with Apple: $e');
  //   }
  // }

  static Future<void> signInWithApple() async {
    print("signInWithApple got invoked");
    try {
      // Check if Apple Sign-In is available first
      print("Checking if Apple Sign-In is available...");
      bool isAvailable = await SignInWithApple.isAvailable();
      print("Apple Sign-In available: $isAvailable");
      
      if (!isAvailable) {
        throw Exception('Apple Sign-In is not available on this device. Please test on a physical device with iOS 13+ and ensure the app has Apple Sign-In capability enabled in Xcode.');
      }

      print("Requesting Apple ID credential...");
      // Request Apple ID credential with minimal configuration first
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.fullName,
          AppleIDAuthorizationScopes.email,
        ],
      );

      print("signInWithApple credential obtained");
      print("Credential givenName: ${credential.givenName}");
      print("Credential familyName: ${credential.familyName}");
      print("Credential email: ${credential.email}");

      // Create Firebase credential (without nonce for now)
      final auth.AuthCredential firebaseCredential =
          auth.OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      print("signInWithApple firebaseCredential created");

      // Sign in to Firebase
      final auth.UserCredential userCredential =
          await _auth.signInWithCredential(firebaseCredential);
      final auth.User? user = userCredential.user;

      if (user != null) {
        print("Firebase user obtained: ${user.uid}");
        
        // Set UID first
        appleUid(user.uid);
        
        // Handle name - prioritize credential data over Firebase user data
        String fullName = '';
        if (credential.givenName != null && credential.familyName != null) {
          fullName = '${credential.givenName} ${credential.familyName}';
        } else if (credential.givenName != null) {
          fullName = credential.givenName!;
        } else if (user.displayName != null && user.displayName!.isNotEmpty) {
          fullName = user.displayName!;
        }
        appleName(fullName);

        // Handle email - prioritize credential email over Firebase user email
        String emailAddress = '';
        if (credential.email != null && credential.email!.isNotEmpty) {
          emailAddress = credential.email!;
        } else if (user.email != null && user.email!.isNotEmpty) {
          emailAddress = user.email!;
        }
        
        // Only set email if we have a valid one
        if (emailAddress.isNotEmpty && emailAddress != 'null') {
          appleEmail(emailAddress);
        } else {
          // Handle the case where no email is available (common on subsequent sign-ins)
          // Apple only provides email on first sign-in, so we'll use a fallback approach
          appleEmail(''); // Set empty string - this is expected behavior
          print('Info: No email available from Apple Sign-In (normal for subsequent sign-ins)');
        }

        print('Apple Sign-In Success:');
        print('Name: ${appleName.value}');
        print('Email: ${appleEmail.value}');
        print('UID: ${appleUid.value}');
        
        // Set success flag
        isFirebaseLoginSuccess(true);
        
      } else {
        print('Error: Firebase user is null after successful credential sign-in');
        throw Exception('Firebase authentication failed');
      }
    } catch (e) {
      print("Apple Sign-In Error: $e");
      
      // Reset values on error
      appleEmail('');
      appleName('');
      appleUid('');
      isFirebaseLoginSuccess(false);
      
      if (e is SignInWithAppleAuthorizationException) {
        print('Authorization error: ${e.code}, ${e.message}');
        switch (e.code) {
          case AuthorizationErrorCode.canceled:
            throw Exception('Apple Sign-In was canceled by user');
          case AuthorizationErrorCode.failed:
            throw Exception('Apple Sign-In failed. Please try again.');
          case AuthorizationErrorCode.invalidResponse:
            throw Exception('Invalid response from Apple. Please try again.');
          case AuthorizationErrorCode.notHandled:
            throw Exception('Apple Sign-In not handled properly');
          case AuthorizationErrorCode.unknown:
            throw Exception('Apple Sign-In failed with unknown error. Please check your internet connection and try again.');
          default:
            throw Exception('Apple Sign-In failed: ${e.message}');
        }
      } else if (e is PlatformException) {
        print('Platform error: ${e.code}, ${e.message}');
        throw Exception('Platform error during Apple Sign-In: ${e.message}');
      } else if (e is auth.FirebaseAuthException) {
        print('Firebase Auth error: ${e.code}, ${e.message}');
        throw Exception('Authentication failed: ${e.message}');
      } else {
        throw Exception('Apple Sign-In failed: ${e.toString()}');
      }
    }
  }

  ///
  static String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  static String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<UserCredential> signInWithApple1() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    print("Apple Credential: ${appleCredential}");

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  ///
  ///
//   static Rx<> checkEmailModel = ().obs;
  static RxBool isCheckEmail = false.obs;

  static Future<bool> checkEmail(String email) async {
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
      "AdminToken": prefs.getString(LocalStorage.token).toString()
    };
    print(headers);

    final String url = '${DatabaseApi.checkEmail}$email';
    customPrint("checkEmail url :: $url");
    try {
      return await http
          .get(Uri.parse(url), headers: headers)
          .then((value) async {
        print("checkEmail :: ${value.body}");
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() == "true") {
          isCheckEmail(true);
        } else {
          isCheckEmail(false);
        }
        if (jsonData["status"].toString() != "true") {
          // showErrorMessage(jsonData["message"].toString(), colorError);
          return false;
        }
        return true;
      });
    } on Exception catch (e) {
      print("checkEmail:: $e");
      // showSnackbar("Some unknown error has occur, try again after some time!", colorError);
      return false;
    }
  }

  static Future<bool> handleLineLogin(BuildContext context, Map<String, dynamic> body) async {
    try {
      // First check if user exists
      final response = await checkLineUser(body['line_id']);
      
      if (response['exists']) {
        // Login existing user
        return await loginWithLine(context, body);
      } else {
        // Create new user
        return await createLineUser(context, body);
      }
    } catch (e) {
      print('LINE Login Handler Error: $e');
      return false;
    }
  }

  static Future<bool> loginWithLine(BuildContext context, Map<String, dynamic> body) async {
    final String url = DatabaseApi.login;
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          "line_id": body["line_id"],
          "login_type": "line"
        }),
      );

      final jsonData = jsonDecode(response.body);
      
      if (jsonData["status"].toString() == "true") {
        // Save user data to preferences
        await prefs.setString(LocalStorage.token, jsonData["data"]["token"]);
        await prefs.setString(LocalStorage.id, jsonData["data"]["id"].toString());
        await prefs.setBool(LocalStorage.isLogin, true);
        
        // Get user profile after successful login
        await getProfile();

        // Navigate to home screen
        // Get.offAll(() => const Navigation());
        return true;
      } else {
        showErrorMessage(jsonData["message"], colorError);
        return false;
      }
    } catch (e) {
      print("Line Login Error: $e");
      showErrorMessage("Failed to login with LINE", colorError);
      return false;
    }
  }

  static Future<bool> createLineUser(BuildContext context, Map<String, dynamic> body) async {
    print("createLineUser got invoked body : $body");
    final String url = DatabaseApi.create;
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
    };

    try {
      // Generate a random password for LINE users
      final String randomPassword = generateRandomPassword();
      
      final Map<String, dynamic> userData = {
        "name": body["name"],
        "line_id": body["line_id"],
        "avatar": body["avatar"],
        "password": randomPassword,
        "login_type": "line",
        "device_type": Platform.isIOS ? "ios" : "android",
        "device_token": await getDeviceToken()
      };

      print("createLineUser userData : $body");


      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(userData),
      );

      final jsonData = jsonDecode(response.body);
      
      if (jsonData["status"].toString() == "true") {
        // After creating user, login automatically
        return await loginWithLine(context, body);
      } else {
        showErrorMessage(jsonData["message"], colorError);
        return false;
      }
    } catch (e) {
      print("Create Line User Error: $e");
      showErrorMessage("Failed to create account with LINE", colorError);
      return false;
    }
  }

  static Future<Map<String, dynamic>> checkLineUser(String lineId) async {
    final String url = '${DatabaseApi.checkLineUser}$lineId';
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      final jsonData = jsonDecode(response.body);
      return {
        "exists": jsonData["status"].toString() == "true",
        "data": jsonData["data"]
      };
    } catch (e) {
      print("Check Line User Error: $e");
      return {"exists": false, "error": e.toString()};
    }
  }

  // Helper method to generate random password for LINE users
  static String generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Helper method to get device token
  static Future<String> getDeviceToken() async {
    // Implement your device token logic here
    // This could be FCM token or any other device identifier
    return "dummy_device_token";
  }

  static Future<bool> deleteProfile() async {
    print("deleteProfile method started");
    try {
      final headers = {
        "Content-Type": "application/json",
        "accept": "application/json",
        "UserToken": prefs.getString(LocalStorage.token).toString()
      };
      
      print("Delete Profile Headers: $headers");
      print("Delete Profile URL: ${DatabaseApi.deleteUser}");
      
      final response = await http.delete(
        Uri.parse(DatabaseApi.deleteUser),
        headers: headers,
      );

      print("Delete Profile Response Status: ${response.statusCode}");
      print("Delete Profile Response Body: ${response.body}");

      final jsonData = jsonDecode(response.body);
      
      if (jsonData["status"].toString() == "true") {
        print("Profile deletion successful");
        // Also delete Firebase account if exists
        try {
          final user = _auth.currentUser;
          if (user != null) {
            print("Deleting Firebase account");
            await user.delete();
            print("Firebase account deleted successfully");
          }
        } catch (firebaseError) {
          print("Firebase account deletion error: $firebaseError");
          // Continue even if Firebase deletion fails
        }
        return true;
      } else {
        print("Profile deletion failed: ${jsonData["message"]}");
        showErrorMessage(jsonData["message"].toString(), colorError);
        return false;
      }
    } catch (e) {
      print("Delete Profile Error: $e");
      showErrorMessage("Failed to delete profile. Please try again.", colorError);
      return false;
    }
  }
}
