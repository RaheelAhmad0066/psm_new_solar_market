import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/screens/auth/register_screen.dart';
import 'package:solar_market/utils/toas_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

import 'signup_controller.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var user = Rxn<User>();

  // Function to get current user
  User? get currentUser => user.value;

  
  
  // Get current user UID
  String? get currentUserId => user.value?.uid;
  RxBool isLoading = false.obs;
  RxBool isgettingOtp = false.obs;
  RxString verificationId = ''.obs;
  RxInt timerValue = 0.obs; // Timer countdown value

  Timer? _timer;

  // Twilio credentials
  final String accountSid = 'AC5da169bebb035f1c70a49eccf6f071f3';
  final String authToken = 'e8f0e79f51b9f1b029f6cdc57e470e49';
  final String twilioNumber = '+18452762759';

  late TwilioFlutter twilioFlutter;

  @override
  void onInit() {
    super.onInit();
    FirebaseAuth.instance.authStateChanges().listen((userData) {
      user.value = userData;
    });
    twilioFlutter = TwilioFlutter(
      accountSid: accountSid,
      authToken: authToken,
      twilioNumber: twilioNumber,
    );
  }
Future<void> getOtp(String phoneNumber) async {
  try {
    isgettingOtp.value = true;
    startTimer();

    // Generate a random OTP
    String otp = generateOtp();

    // Save the OTP in Firestore
    await _firestore.collection('otp').doc(phoneNumber).set({
      'otp': otp,
      'createdAt': FieldValue.serverTimestamp(),
    }).then((_) async {
      // Ensure Firestore write is successful before proceeding
      print('OTP saved successfully in Firestore.');

      // Send OTP via Twilio
      final response = await twilioFlutter.sendSMS(
        toNumber: phoneNumber,
        messageBody: 'Your OTP is: $otp',
        fromNumber: twilioNumber,
      );

      print('Twilio Response: ${response.responseCode}');

      if (response.responseCode == 200) {
        Get.snackbar('OTP Sent', 'Check your phone for the OTP.',
            backgroundColor: kPrimaryColor, colorText: Colors.white);
      } else {
        MessageToast.showToast(msg: 'Failed to send OTP. Please try again.');
      }
    }).catchError((error) {
      print('Firestore Error: $error');
      MessageToast.showToast(msg: 'Failed to save OTP. Please try again.');
    });
  } catch (e) {
    print('Error: $e');
    MessageToast.showToast(msg: 'An unexpected error occurred.');
  } finally {
    isgettingOtp.value = false;
  }
}


  String generateOtp() {
    // Generate a 6-digit OTP
    return (100000 + Random().nextInt(900000)).toString();
  }

  void startTimer() {
    timerValue.value = 30; // Set timer to 1 minute (60 seconds)
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
            msg: 'User Already Exist!',
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

  Future<void> verifyOtpAndSignUp({
    required String otp,
    required String phoneNumber,
    required String fullName, // Full name as username
    required String password,
  }) async {
    try {
      isLoading.value = true;

      // Get OTP from Firestore
      DocumentSnapshot otpDoc =
          await _firestore.collection('otp').doc(phoneNumber).get();

      if (otpDoc.exists && otpDoc['otp'] == otp) {
        DateTime createdAt = (otpDoc['createdAt'] as Timestamp).toDate();
        DateTime now = DateTime.now();

        if (now.difference(createdAt).inMinutes <= 5) {
          print("OTP verified successfully!");

          // Step 1: Create User in Firebase Auth with a random email
          String tempEmail =
              '${fullName.replaceAll(" ", "").toLowerCase()}@temp.com'; // Temporary email using full name
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: tempEmail,
            password: password,
          );
          User? user = userCredential.user;

          if (user != null) {
            print("User signed up successfully: ${user.uid}");

            // Step 2: Save user data in Firestore with the UID as the document ID
            await _saveUserDataToFirestore(
                user, fullName, phoneNumber, tempEmail);

            await updateFcmToken(user);

            Get.offAll(() => AccountCreationAnimationScreen(
                  titleText: 'Account Created Successfully!',
                  descriptionText: 'Redirecting to Dashboard...',
                ));
          } else {
            Get.snackbar('Error', 'Failed to create user in Firebase!',
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          MessageToast.showToast(msg: 'OTP has expired!');
        }
      } else {
        MessageToast.showToast(msg: 'Invalid OTP!');
      }
    } catch (e) {
      print('Error: $e');
      MessageToast.showToast(msg: 'An error occurred. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyFullNameAndLogin(String fullName, String password) async {
    try {
      isLoading.value = true;

      // Step 1: Fetch the user's data from Firestore using fullName
      print('Fetching user data from Firestore...');
      QuerySnapshot userDoc = await _firestore
          .collection('pmsUsers')
          .where('fullName', isEqualTo: fullName)
          .get();

      if (userDoc.docs.isNotEmpty) {
        print('User found: ${userDoc.docs.first.data()}');
        String email =
            userDoc.docs.first['email']; // Retrieve stored email from Firestore
        print('Retrieved email: $email');

        // Step 2: Sign in with email and password
        print('Signing in with email and password...');
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          print("User logged in successfully: ${user.uid}");

          await updateFcmToken(user);

          Get.offAll(() => AccountCreationAnimationScreen(
                titleText: 'Welcome Back!',
                descriptionText: 'Login successful! Redirecting...',
              ));
        } else {
          MessageToast.showToast(msg: 'Failed to log in. Please try again.');
        }
      } else {
        MessageToast.showToast(
            msg: 'User not found. Please check your full name.');
      }
    } catch (e) {
      String errorMessage = 'An unexpected error occurred. Please try again.';

      print('Error during login: ${e.toString()}');

      if (e is FirebaseAuthException) {
        // Handle Firebase Auth errors
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this full name.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many requests. Please try again later.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
        }
      } else if (e is FirebaseException) {
        // Handle Firestore errors
        errorMessage = 'Firestore error: ${e.message}';
      } else if (e is PlatformException) {
        // Handle platform-specific errors
        errorMessage = 'Platform error: ${e.message}';
      } else {
        errorMessage = 'An unexpected error occurred: ${e.toString()}';
      }

      MessageToast.showToast(msg: errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  //

  Future<void> _saveUserDataToFirestore(
      User? user, String fullName, String phoneNumber, String email) async {
    if (user == null) {
      print("User is null, cannot save data.");
      return;
    }

    print("Saving data for User ID: ${user.uid}");

    try {
      String? token = await FirebaseMessaging.instance.getToken();
      String uniqueId = await _generateUniqueId();

      await _firestore.collection('pmsUsers').doc(user.uid).set({
        'fullName': fullName,
        'userId': user.uid,
        'uniqueId': uniqueId,
        'description': '',
        'image': '',
        'fcmToken': token,
        'phoneNumber': phoneNumber,
        'email': email,
        'profileStatus': "notVerified",
        'isVerified': false,
        'isBanned': false,
        'followers': [],
        'following': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("User data successfully stored!");
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  Future<String> _generateUniqueId() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('pmsUsers').get();
      int userCount = querySnapshot.docs.length + 1;
      return 'PSM-${userCount.toString().padLeft(5, '0')}';
    } catch (e) {
      MessageToast.showToast(msg: 'Failed to generate unique ID.');
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
}
