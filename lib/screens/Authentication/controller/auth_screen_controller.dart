import 'dart:convert';
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
        final jsonData = jsonDecode(value.body);
        if (jsonData["status"].toString() != "true") {
          showErrorMessage(jsonData["message"], colorError);
          customPrint("createActivity response :: ${value.body}");
          customPrint("createActivity message::${jsonData["message"]}");
          return false;
        } else {
          showSucessMessage(jsonData["message"], colorSuccess);
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
          customPrint("createActivity message::${jsonData["message"]}");
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
            showErrorMessage(jsonData["message"], colorError);
          }
          print('login :: ${jsonData["message"]}');
          return false;
        } else {
          isApiLoginSuccess(true);
          showSucessMessage(jsonData["message"], colorSuccess);
          prefs.clear();
          prefs.setString(LocalStorage.token, jsonData["token"].toString());
          prefs.setBool(LocalStorage.isLogin, true);
          print('token :: ${prefs.getString(LocalStorage.token)}');
        }
        print("login::${value.body}");
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

  static Future<bool> nodeLogin(BuildContext context, body) async {
    final String url = NodeDatabaseApi.login;
    final headers = {
      "Content-Type": "application/json",
      "accept": "application/json",
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
        if (jsonData["success"].toString() != "true") {
          isApiLoginSuccess(false);
          if (isFirebaseLoginSuccess.isFalse) {
            showErrorMessage(jsonData["message"], colorError);
          }
          print('login :: ${jsonData["message"]}');
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
      showErrorMessage("$e", colorError);
      print('loginWithFirebase Error: $e');
      return false;
    }
  }

  static Future<bool> signUpWithFirebase(
      BuildContext context, String email, String password) async {
    customPrint("signUpWithFirebase body::$email - $password");
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      print('Signup successful!');
      return true;
    } catch (e) {
      print('signUpWithFirebase Error: $e');
      return false;
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
      "AdminToken": prefs.getString(LocalStorage.token).toString()
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
  static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static RxString googleName = ''.obs;
  static RxString googleEmail = ''.obs;
  static RxString googlePhoneNumber = ''.obs;
  static RxString googleUid = ''.obs;

  static Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth.UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final auth.User? user = userCredential.user;

      if (user != null) {
        googleEmail(user.email);
        googleUid(user.uid);
        googleName(user.displayName);
        googlePhoneNumber(user.phoneNumber);
        print('Signed in as googleName :: ${user.displayName}');
        print('Signed in as googleEmail :: ${user.email}');
        print('Signed in as googlePhoneNumber :: ${user.phoneNumber}');
        print('Signed in as googleUid :: ${user.uid}');
      }
    } catch (e) {
      print('Error signing in with Google: $e');
    }
  }

  ///
  // static final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  static RxString appleName = ''.obs;
  static RxString appleEmail = ''.obs;
  static RxString appleUid = ''.obs;
  static RxString applePhoneNumber = ''.obs;

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
  static Future<void> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.fullName,
          AppleIDAuthorizationScopes.email,
        ],
      );

      final auth.AuthCredential firebaseCredential =
          auth.OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final auth.UserCredential userCredential =
          await _auth.signInWithCredential(firebaseCredential);
      final auth.User? user = userCredential.user;

      if (user != null) {
        // Check if the user's full name is available
        if (credential.givenName != null && credential.familyName != null) {
          appleName('${credential.givenName} ${credential.familyName}');
        } else {
          // Handle the case where the user's full name is not available
          appleName('Name not available');
        }

        // Check if the user's email address is available
        if (credential.email != null && credential.email!.isNotEmpty) {
          appleEmail(credential.email);
        } else {
          // Handle the case where the user chooses not to share their email address
          appleEmail('Email not available');
        }

        // appleUid(user.uid);
        // print('Signed in as appleName :: $appleName');
        // print('Signed in as appleEmail :: $appleEmail');
        // print('Signed in as appleUid :: $appleUid');

        final auth.User? user = userCredential.user;
        if (user != null) {
          appleEmail(user.email);
          appleName(user.displayName);
          appleUid(user.uid);
          print('Signed in as appleName :: ${user.displayName}');
          print('Signed in as appleEmail :: ${user.email}');
          print('Signed in as appleUid :: ${user.uid}');
        } else {
          print('user == null');
        }
      }
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException) {
        print('Authorization error: ${e.code}, ${e.message}');
      } else if (e is PlatformException) {
        print('Platform error: ${e.code}, ${e.message}');
      } else {
        print('Error signing in with Apple: $e');
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
          showErrorMessage(jsonData["message"].toString(), colorError);
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
}
