import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/screens/auth/register_screen.dart';
import 'package:solar_market/screens/dashboard/dashboard_screen.dart';
import 'package:solar_market/utils/toas_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SignupController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RxBool isLoading = false.obs;
  RxBool isgogleLoading = false.obs;
  RxBool isgettingOtp = false.obs;
  RxString verificationId = ''.obs;
  RxInt timerValue = 0.obs; // Timer countdown value
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  int? _resendToken; // Store the resend token for OTP resends

  Timer? _timer;

  void startTimer() {
    timerValue.value = 60; // Set timer to 1 minute (60 seconds)
    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerValue.value > 0) {
        timerValue.value--; // Decrement timer
      } else {
        timer.cancel(); // Cancel the timer when it reaches zero
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel(); // Cancel timer when controller is disposed
    super.onClose();
  }

  Future<void> checkIfUserExists(String phoneNumber, bool isSignup) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('pmsUsers')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (result.docs.isNotEmpty) {
        if (isSignup) {
          MessageToast.showToast(
            msg: 'User Already Exist!. Please login',
          );

          return;
        }
      } else if (!isSignup) {
        MessageToast.showToast(
          msg: 'User Not Found',
        );
        Get.to(() => RegisterSccreen(phoneNumber: phoneNumber));

        return;
      }
      getOtp(phoneNumber);
    } catch (e) {
      Get.snackbar('Error', 'Failed to check user existence.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> getOtp(String phoneNumber) async {
    try {
      if (isgettingOtp.value) return; // Prevent multiple OTP requests

      isgettingOtp.value = true;
      startTimer();
      print('Phone Number: $phoneNumber'); // Debugging

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Verification Completed'); // Debugging
          // Automatically sign in if verification is completed
          // await _auth.signInWithCredential(credential);
          // MessageToast.showToast(msg: 'Phone number automatically verified!');
        },
        verificationFailed: (FirebaseAuthException e) {
              print('Verification Failed: ${e.code} - ${e.message}');

          print('Verification Failed: $e'); // Debugging
          String errorMessage = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'The provided phone number is invalid.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          } else if (e.code == 'network-request-failed') {
            errorMessage =
                'Network error. Please check your internet connection.';
          } else if (e.code == 'captcha-check-failed') {
            errorMessage = 'reCAPTCHA verification failed. Please try again.';
          } else if (e.code == 'quota-exceeded') {
            errorMessage = 'Quota exceeded. Please try again later.';
          } else if (e.code == 'session-expired') {
            errorMessage =
                'The OTP session has expired. Please request a new OTP.';
          } else if (e.code == '139') {
            errorMessage = 'An unexpected error occurred. Please try again.';
          }
          Get.snackbar('Error', errorMessage,
              backgroundColor: Colors.red, colorText: Colors.white);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('Code Sent: $verificationId'); // Debugging
          this.verificationId.value = verificationId;
          _resendToken = resendToken; // Store the resend token
          Get.snackbar('OTP Sent', 'Check your phone for the OTP.',
              backgroundColor: kPrimaryColor, colorText: Colors.white);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Code Auto Retrieval Timeout: $verificationId'); // Debugging
          this.verificationId.value = verificationId;
        },
        timeout: const Duration(seconds: 120),
        forceResendingToken: _resendToken, // Use the resend token for resends
      );
    } catch (e) {
      print('Error: $e'); // Debugging
      MessageToast.showToast(msg: 'Failed to get OTP');
    } finally {
      isgettingOtp.value = false;
    }
  }

  Future<void> verifyOtp(
      String otp, String fullName, String phoneNumber, bool isSignup) async {
    try {
      isLoading.value = true;

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (isSignup) {
        bool userExists = await _checkIfUserExists(userCredential.user);
        if (!userExists) {
          await saveUserDataToFirestore(
              user: userCredential.user,
              fullName: fullName,
              phoneNumber: phoneNumber,
              isPhoneVerified: true,
              isGoogleVerified: false,
              isAppleVerified: false,
              email: '');
        }
      }

      await updateFcmToken(userCredential.user);

      final String titleText =
          isSignup ? 'Account Created Successfully!' : 'Welcome Back!';
      final String descriptionText = isSignup
          ? 'You are being redirected to the Dashboard'
          : 'Login successful! Redirecting to the Dashboard.';

      Get.offAll(() => AccountCreationAnimationScreen(
            titleText: titleText,
            descriptionText: descriptionText,
          ));
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Invalid OTP!';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'The OTP is invalid or has expired.';
      } else if (e.code == 'session-expired') {
        errorMessage = 'The OTP session has expired. Please request a new OTP.';
      } else if (e.code == '139') {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }
      MessageToast.showToast(msg: errorMessage);
    } catch (e) {
      MessageToast.showToast(msg: 'An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithApple() async {
    try {
      isgogleLoading.value = true;

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      bool userExists = await _checkIfUserExists(userCredential.user);
      if (!userExists) {
        // Get.to(() => AdditionalInfoScreen(user: userCredential.user!));
        saveUserDataToFirestore(
            user: userCredential.user!,
            fullName: appleCredential.givenName ?? '',
            phoneNumber: '',
            isPhoneVerified: false,
            isGoogleVerified: true,
            isAppleVerified: true,
            email: appleCredential.email ?? '');
        Get.to(() => AccountCreationAnimationScreen(
            titleText: 'Account Created Successfully!',
            descriptionText: 'You are being redirected to the Dashboard'));
      } else {
        Get.to(() => AccountCreationAnimationScreen(
            titleText: 'Welcome Back!',
            descriptionText:
                'Login successful! Redirecting to the Dashboard.'));
        await updateFcmToken(userCredential.user!);
      }
    
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign in with Apple',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isgogleLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isgogleLoading.value = true;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isgogleLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      bool userExists = await _checkIfUserExists(userCredential.user);
      if (!userExists) {
        // Get.to(() => AdditionalInfoScreen(user: userCredential.user!));
        saveUserDataToFirestore(
            user: userCredential.user!,
            fullName: googleUser.displayName ?? '',
            phoneNumber: '',
            isPhoneVerified: false,
            isGoogleVerified: true,
            isAppleVerified: false,
            email: googleUser.email);
        Get.to(() => AccountCreationAnimationScreen(
            titleText: 'Account Created Successfully!',
            descriptionText: 'You are being redirected to the Dashboard'));
      } else {
        Get.to(() => AccountCreationAnimationScreen(
            titleText: 'Welcome Back!',
            descriptionText:
                'Login successful! Redirecting to the Dashboard.'));
        await updateFcmToken(userCredential.user!);
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      Get.snackbar('Error', 'Failed to sign in with Google.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isgogleLoading.value = false;
    }
  }

  Future<void> saveUserDataToFirestore({
    User? user,
    required String fullName,
    required String phoneNumber,
    required bool isPhoneVerified,
    required bool isGoogleVerified,
    required bool isAppleVerified,
    required String email,
  }) async {
    // isLoading.value = true;
    String? token = await FirebaseMessaging.instance.getToken();
    if (user != null) {
      String uniqueId = await _generateUniqueId();
      await _firestore.collection('pmsUsers').doc(user.uid).set({
        'fullName': fullName,
        'email': email,
        'tag': 'user',
        'userId': user.uid,
        'uniqueId': uniqueId,
        'description': '',
        'image': '',
        'fcmToken': token,
        'phoneNumber': phoneNumber,
        'profileStatus': "notVerified",
        'isVerified': false,
        'isBanned': false,
        'isPhoneVerified': isPhoneVerified,
        'isGoogleVerified': isGoogleVerified,
        'isAppleVerified': isAppleVerified,
        'followers': [],
        'following': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
      // isLoading.value = false;
    }
  }

  Future<String> _generateUniqueId() async {
    try {
      // Query the collection and order by 'uniqueId' in descending order
      QuerySnapshot querySnapshot = await _firestore
          .collection('pmsUsers')
          .orderBy('uniqueId', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the highest existing uniqueId
        String lastUniqueId = querySnapshot.docs.first['uniqueId'];
        // Extract the numeric part of the ID
        int lastNumber = int.parse(lastUniqueId.split('-')[1]);
        // Increment the number by 1
        int newNumber = lastNumber + 1;
        // Format the new ID with leading zeros
        return 'PSM-${newNumber.toString().padLeft(5, '0')}';
      } else {
        // If no users exist, start with 'PSM-00001'
        return 'PSM-00001';
      }
    } catch (e) {
      print('Failed to generate unique ID: $e');
      return 'PSM-00001'; // Default ID in case of failure
    }
  }

  Future<void> updateFcmToken(User? user) async {
    if (user != null) {
      try {
        String? token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await FirebaseFirestore.instance
              .collection('pmsUsers')
              .doc(user.uid)
              .update({'fcmToken': token});
        }
      } catch (e) {
        print('Error updating FCM token: $e');
      }
    }
  }

  Future<bool> _checkIfUserExists(User? user) async {
    if (user == null) return false;

    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('pmsUsers').doc(user.uid).get();
      return userDoc.exists;
    } catch (e) {
      MessageToast.showToast(msg: 'Error checking user data.');
      return false;
    }
  }
}

class AccountCreationAnimationScreen extends StatelessWidget {
  final String titleText; // Text for the title
  final String descriptionText; // Text for the description

  const AccountCreationAnimationScreen({
    Key? key,
    required this.titleText,
    required this.descriptionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wait for 5 seconds before navigating to the dashboard
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAll(() => const Dashboard());
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/success.json',
                  width: 244.w, height: 200.h),
              SizedBox(height: 20.h),
              Text(
                titleText,
                style: GoogleFonts.poppins(
                    color: kPrimaryColor,
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                descriptionText,
                style: GoogleFonts.poppins(fontSize: 15.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:solar_market/constants.dart';
// import 'package:solar_market/screens/auth/register_screen.dart';
// import 'package:solar_market/screens/dashboard/dashboard_screen.dart';
// import 'package:solar_market/utils/toas_message.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import '../screens/auth/phone_verification_screen.dart';


// class SignupController extends GetxController {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

//   RxBool isLoading = false.obs;
//   RxBool isgettingOtp = false.obs;
//   RxString verificationId = ''.obs;
//   RxInt timerValue = 0.obs; // Timer countdown value

//   Timer? _timer;

//   void startTimer() {
//     timerValue.value = 30; // Set timer to 30 seconds
//     _timer?.cancel(); // Cancel any existing timer

//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (timerValue.value > 0) {
//         timerValue.value--; // Decrement timer
//       } else {
//         timer.cancel(); // Cancel the timer when it reaches zero
//       }
//     });
//   }

//   @override
//   void onClose() {
//     _timer?.cancel(); // Cancel timer when controller is disposed
//     super.onClose();
//   }

//   Future<void> checkIfUserExists(String phoneNumber, bool isSignup) async {
//     try {
//       final QuerySnapshot result = await _firestore
//           .collection('pmsUsers')
//           .where('phoneNumber', isEqualTo: phoneNumber)
//           .get();

//       if (result.docs.isNotEmpty) {
//         if (isSignup) {
//           MessageToast.showToast(
//             msg: 'User Already Exist!. Please login',
//           );

//           return;
//         }
//       } else if (!isSignup) {
//         MessageToast.showToast(
//           msg: 'User Not Found',
//         );
//         Get.to(() => RegisterSccreen(phoneNumber: phoneNumber));

//         return;
//       }
//       getOtp(phoneNumber);
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to check user existence.',
//           backgroundColor: Colors.red, colorText: Colors.white);
//     }
//   }
//     void loginWithUsernameAndPin(String username, String pin) async {
//     try {
//       isLoading.value = true;

//       String tempEmail =
//           '${username.replaceAll(" ", "").toLowerCase()}@temp.com'; // Temporary email format

//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: tempEmail,
//         password: pin,
//       );

//       // Check if the user is authenticated
//       User? user = userCredential.user;
//       if (user != null) {
//         await updateFcmToken(user);
//         Get.offAll(() => AccountCreationAnimationScreen(
//               titleText: 'Welcome Back!',
//               descriptionText:
//                   'Login successful! Redirecting to the Dashboard.',
//             ));
//       } else {
//         // If authentication fails
//         MessageToast.showToast(msg: 'Invalid username or pin');
//       }
//     } on FirebaseAuthException catch (e) {
//       String errorMessage = 'Login failed. Please try again.';
//       if (e.code == 'user-not-found') {
//         errorMessage = 'No user found with this username';
//       } else if (e.code == 'wrong-password') {
//         errorMessage = 'Incorrect pin';
//       }
//       MessageToast.showToast(msg: errorMessage);
//     } catch (e) {
//       MessageToast.showToast(msg: 'An unexpected error occurred');
//     } finally {
//       isLoading.value = false;
//     }
//   }

  

// Future<void> updateFcmToken(User user) async {
//   if (user == null) return;

//   try {
//     String? token = await FirebaseMessaging.instance.getToken();
//     if (token == null) return;

//     DocumentReference userDocRef = _firestore.collection('pmsUsers').doc(user.uid);

//     // Check if the document exists before updating FCM token
//     DocumentSnapshot userDoc = await userDocRef.get();
//     if (userDoc.exists) {
//       await userDocRef.update({'fcmToken': token});
//       print("FCM token updated successfully.");
//     } else {
//       print("User document does not exist! Skipping FCM token update.");
//     }
//   } catch (e) {
//     print("Error updating FCM token: $e");
//   }
// }




 

//   void getOtp(String phoneNumber) async {
//     try {
//       isgettingOtp.value = true;
//       startTimer();
//       print('Phone Number: $phoneNumber'); // Debugging
//       await _auth.verifyPhoneNumber(
//         phoneNumber: phoneNumber,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           print('Verification Completed'); // Debugging
//           await _auth.signInWithCredential(credential);
//           // MessageToast.showToast(msg: 'Phone number automatically verified!');
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           print('Verification Failed: $e'); // Debugging
//           String errorMessage = 'Verification failed';
//           if (e.code == 'invalid-phone-number') {
//             errorMessage = 'The provided phone number is invalid.';
//           } else if (e.code == 'too-many-requests') {
//             errorMessage = 'Too many requests. Please try again later.';
//           } else if (e.code == 'network-request-failed') {
//             errorMessage =
//                 'Network error. Please check your internet connection.';
//           } else if (e.code == 'captcha-check-failed') {
//             errorMessage = 'reCAPTCHA verification failed. Please try again.';
//           } else if (e.code == 'quota-exceeded') {
//             errorMessage = 'Quota exceeded. Please try again later.';
//           }
//           Get.snackbar('Error', errorMessage,
//               backgroundColor: Colors.red, colorText: Colors.white);
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           print('Code Sent: $verificationId'); // Debugging
//           this.verificationId.value = verificationId;
//           Get.snackbar('OTP Sent', 'Check your phone for the OTP.',
//               backgroundColor: kPrimaryColor, colorText: Colors.white);
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           print('Code Auto Retrieval Timeout: $verificationId'); // Debugging
//           this.verificationId.value = verificationId;
//         },
//         timeout: const Duration(seconds: 120),
//       );
//     } catch (e) {
//       print('Error: $e'); // Debugging
//       MessageToast.showToast(msg: 'Failed to get OTP');
//     } finally {
//       isgettingOtp.value = false;
//     }
//   }



//   Future<void> _saveUserDataToFirestore(User? user, String fullName,
//     String userName, String pin, String phoneNumber) async {
//   String? token = await FirebaseMessaging.instance.getToken();
//   if (user != null) {
//     String uniqueId = await _generateUniqueId();
//     await _firestore.collection('pmsUsers').doc(user.uid).set({
//       'fullName': fullName,
//       'pin': pin,
//       'userName': userName,
//       'userId': FirebaseAuth.instance.currentUser!.uid,
//       'uniqueId': uniqueId,
//       'description': '',
//       'image': '',
//       'fcmToken': token,
//       'phoneNumber': phoneNumber,
//       'profileStatus': "notVerified",
//       'isVerified': false,
//       'isBanned': false,
//       'isPhoneVerified': false,
//       'followers': [],
//       'following': [],
//       'createdAt': FieldValue.serverTimestamp(),
//     }); // Merge ensures existing data is not overwritten
//   }
// }



//   Future<void> signInWithApple() async {
//     try {
//       isLoading.value = true;

//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );

//       final OAuthCredential credential = OAuthProvider("apple.com").credential(
//         idToken: appleCredential.identityToken,
//         accessToken: appleCredential.authorizationCode,
//       );

//       UserCredential userCredential =
//           await _auth.signInWithCredential(credential);

//       if (userCredential.user != null) {
//         bool userExists = await _checkIfUserExists(userCredential.user);

//         if (!userExists) {
//           await _saveUserDataToFirestore(
//             userCredential.user!,
//             appleCredential.givenName ?? '',
//             appleCredential.email?.split('@').first ?? '',
//             '',
//             '',
//           );

//           Get.to(() => PhoneVerificationScreen());
//         } else {
//         bool verified = await isPhoneVerified(userCredential.user!.uid);
//           if (!verified) {
//             Get.to(() => PhoneVerificationScreen());
//           } else {
//             Get.to(() => Dashboard());
//           }
//         }
//               await updateFcmToken(userCredential.user!);

//       }
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to sign in with Apple',
//           backgroundColor: Colors.red, colorText: Colors.white);
//     } finally {
//       isLoading.value = false;
//     }
//   }


// Future<void> signInWithGoogle() async {
//   try {
//     isLoading.value = true;

//     // Google sign-in
//     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//     if (googleUser == null) {
//       isLoading.value = false;
//       return;
//     }

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//     final OAuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     // Sign in using Google credential
//     UserCredential userCredential = await _auth.signInWithCredential(credential);

//     if (userCredential.user != null) {
//       // Store Google UID in local storage
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('googleUid', userCredential.user!.uid);

//       // Check if the user document exists in Firestore
//       DocumentReference userDocRef = _firestore.collection('pmsUsers').doc(userCredential.user!.uid);
//       DocumentSnapshot userDoc = await userDocRef.get();

//       if (!userDoc.exists) {
//         // Create a new user document if it doesn't exist
//         await userDocRef.set({
//           'fullName': userCredential.user!.displayName ?? '',
//           'userName': userCredential.user!.email?.split('@').first ?? '',
//           'userId': userCredential.user!.uid,
//           'uniqueId': await _generateUniqueId(),
//           'description': '',
//           'image': '',
//           'fcmToken': await FirebaseMessaging.instance.getToken(),
//           'phoneNumber': '', // Initially empty
//           'profileStatus': "notVerified",
//           'isVerified': false,
//           'isBanned': false,
//           'isPhoneVerified': false, // Initially false
//           'followers': [],
//           'following': [],
//           'createdAt': FieldValue.serverTimestamp(),
//         });
//         print("User document created with UID: ${userCredential.user!.uid}");
//       }

//       // Update FCM token
//       await updateFcmToken(userCredential.user!);

//       // Navigate to phone verification screen
//       Get.to(() => PhoneVerificationScreen());
//     }
//   } catch (e) {
//     print("Error signing in with Google: $e");
//     Get.snackbar('Error', 'Failed to sign in with Google.', backgroundColor: Colors.red, colorText: Colors.white);
//   } finally {
//     isLoading.value = false;
//   }
// }

// Future<void> verifyOtp(String otp, String phoneNumber) async {
//   try {
//     isLoading.value = true;

//     if (verificationId.value.isEmpty) {
//       MessageToast.showToast(msg: 'Session expired. Request a new OTP.');
//       return;
//     }

//     PhoneAuthCredential credential = PhoneAuthProvider.credential(
//       verificationId: verificationId.value,
//       smsCode: otp,
//     );

//     // Sign in with phone number
//     UserCredential userCredential = await _auth.signInWithCredential(credential);

//     // Retrieve the stored Google UID
//     final prefs = await SharedPreferences.getInstance();
//     String? googleUid = prefs.getString('googleUid');

//     if (googleUid != null) {
//       User googleUser = _auth.currentUser!;

//       // Check if the phone provider is already linked
//       bool isPhoneAlreadyLinked = googleUser.providerData.any((provider) => provider.providerId == 'phone');
      
//       if (!isPhoneAlreadyLinked) {
//         // If the phone is not already linked, link it
//         await googleUser.linkWithCredential(credential);
//         print("Phone number linked to Google account successfully!");

//         // Reload to update the current user
//         await googleUser.reload();
//         googleUser = _auth.currentUser!;

//         // Now both accounts are linked, proceed with Firestore update
//         DocumentReference userDocRef = _firestore.collection('pmsUsers').doc(googleUser.uid);
//         DocumentSnapshot userDoc = await userDocRef.get();

//         if (userDoc.exists) {
//           // Update phone verification status in Firestore
//           await userDocRef.update({
//             'phoneNumber': phoneNumber,
//             'isPhoneVerified': true,
//           });
//           print("Phone verification status updated for UID: ${googleUser.uid}");
//         } else {
//           // If the document doesn't exist, create a new one (unlikely if it's linked)
//           await userDocRef.set({
//             'fullName': googleUser.displayName ?? '',
//             'userName': googleUser.email?.split('@').first ?? '',
//             'userId': googleUser.uid,
//             'uniqueId': await _generateUniqueId(),
//             'description': '',
//             'image': '',
//             'fcmToken': await FirebaseMessaging.instance.getToken(),
//             'phoneNumber': phoneNumber,
//             'profileStatus': "notVerified",
//             'isVerified': false,
//             'isBanned': false,
//             'isPhoneVerified': true,
//             'followers': [],
//             'following': [],
//             'createdAt': FieldValue.serverTimestamp(),
//           });
//           print("User document created with UID: ${googleUser.uid}");
//         }

//         // Update FCM token
//         await updateFcmToken(googleUser);
//       } else {
//         // If phone is already linked, skip linking and proceed with Firestore update
//         print("Phone is already linked. Proceeding with Firestore update...");

//         DocumentReference userDocRef = _firestore.collection('pmsUsers').doc(googleUser.uid);
//         DocumentSnapshot userDoc = await userDocRef.get();

//         if (userDoc.exists) {
//           // Update phone verification status in Firestore
//           await userDocRef.update({
//             'phoneNumber': phoneNumber,
//             'isPhoneVerified': true,
//           });
//           print("Phone verification status updated for UID: ${googleUser.uid}");
//         } else {
//           print("User document does not exist. Skipping Firestore update.");
//         }
//       }

//       // Navigate to Dashboard
//       Get.offAll(() => AccountCreationAnimationScreen(
//         titleText: 'Account Created Successfully!',
//         descriptionText: 'You are being redirected to the Dashboard',
//       ));
//     } else {
//       print("Google UID is not stored or doesn't match. Cannot link phone number.");
//     }
//   } on FirebaseAuthException catch (e) {
//     String errorMessage = 'Invalid OTP!';
//     if (e.code == 'invalid-verification-code') {
//       errorMessage = 'The OTP is invalid or has expired.';
//     } else if (e.code == 'session-expired') {
//       errorMessage = 'Session expired. Request a new OTP.';
//       verificationId.value = ''; // Clear expired verification ID
//     }
//     MessageToast.showToast(msg: errorMessage);
//   } catch (e) {
//     print("Error: $e");
//     MessageToast.showToast(msg: 'An error occurred. Please try again.');
//   } finally {
//     isLoading.value = false;
//   }
// }

// Future<void> savePhoneVerificationStatus(User user, String phoneNumber) async {
//   if (user != null) {
//     DocumentReference userDocRef = _firestore.collection('pmsUsers').doc(user.uid);

//     DocumentSnapshot userDoc = await userDocRef.get();
//     if (userDoc.exists) {
//       await userDocRef.update({
//         'isPhoneVerified': true,
//         'phoneNumber': phoneNumber,
//       });

//       // Optionally, save to SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isPhoneVerified', true);
//       print("Phone verification status updated for UID: ${user.uid}");
//     } else {
//       print("User document does not exist for UID: ${user.uid}. Cannot update phone number status.");
//     }
//   }
// }
// Future<bool> isPhoneVerified(String userId) async {
//   final userDoc = await FirebaseFirestore.instance
//       .collection('pmsUsers')
//       .doc(userId)
//       .get();
//   return userDoc.exists ? (userDoc.data()?['isPhoneVerified'] ?? false) : false;
// }


//   Future<String> _generateUniqueId() async {
//     try {
//       QuerySnapshot querySnapshot =
//           await _firestore.collection('pmsUsers').get();
//       int userCount = querySnapshot.docs.length + 1;
//       return 'PSM-${userCount.toString().padLeft(5, '0')}';
//     } catch (e) {
//       MessageToast.showToast(msg: 'Failed to generate unique ID.');
//       return 'PSM-00001'; // Default ID in case of failure
//     }
//   }

//   // Future<void> updateFcmToken(User? user) async {
//   //   if (user != null) {
//   //     try {
//   //       String? token = await FirebaseMessaging.instance.getToken();
//   //       if (token != null) {
//   //         await FirebaseFirestore.instance
//   //             .collection('pmsUsers')
//   //             .doc(user.uid)
//   //             .update({'fcmToken': token});
//   //       }
//   //     } catch (e) {
//   //       print('Error updating FCM token: $e');
//   //     }
//   //   }
//   // }

//   Future<bool> _checkIfUserExists(User? user) async {
//     if (user == null) return false;

//     try {
//       DocumentSnapshot userDoc =
//           await _firestore.collection('pmsUsers').doc(user.uid).get();
//       return userDoc.exists;
//     } catch (e) {
//       MessageToast.showToast(msg: 'Error checking user data.');
//       return false;
//     }
//   }
// }

// class AccountCreationAnimationScreen extends StatelessWidget {
//   final String titleText; // Text for the title
//   final String descriptionText; // Text for the description

//   const AccountCreationAnimationScreen({
//     Key? key,
//     required this.titleText,
//     required this.descriptionText,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Wait for 5 seconds before navigating to the dashboard
//     Future.delayed(const Duration(seconds: 3), () {
//       Get.offAll(() => const Dashboard());
//     });

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(10.r),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset('assets/animations/success.json',
//                   width: 244.w, height: 200.h),
//               SizedBox(height: 20.h),
//               Text(
//                 titleText,
//                 style: GoogleFonts.poppins(
//                     color: kPrimaryColor,
//                     fontSize: 21.sp,
//                     fontWeight: FontWeight.w600),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 10.h),
//               Text(
//                 descriptionText,
//                 style: GoogleFonts.poppins(fontSize: 15.sp),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
