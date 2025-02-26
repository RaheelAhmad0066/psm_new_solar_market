import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/dashboard_screen.dart';

import '../constants.dart';
import '../utils/toas_message.dart';
import 'primary_textfield.dart';
import 'round_button.dart';

class PhoneVerificationWidget extends StatefulWidget {
  final Function(String) onVerified;
  final RxBool isPhoneVerified; // To control posting/bidding

  const PhoneVerificationWidget({
    Key? key,
    required this.onVerified,
    required this.isPhoneVerified,
  }) : super(key: key);

  @override
  _PhoneVerificationWidgetState createState() =>
      _PhoneVerificationWidgetState();
}

class _PhoneVerificationWidgetState extends State<PhoneVerificationWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  ProfileController profileController = Get.put(ProfileController());
  final RxBool isVerifying = false.obs;
  final RxString verificationId = ''.obs;
  final RxInt timerSeconds = 50.obs; // Timer starts from 30
  final RxBool canResendOtp = true.obs; // Enable OTP resend initially
  String countryCode = "+92";
  int? _resendToken; // Store the resend token for OTP resends

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: widget.isPhoneVerified.value
              ? null
              : showPhoneVerificationBottomSheet,
          child: Container(
            width: Get.width * .4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              color: widget.isPhoneVerified.value ? Colors.grey : Colors.red,
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8.w),
                Text(
                  widget.isPhoneVerified.value ? 'Verified' : 'Verify Phone',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void showPhoneVerificationBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 6.h),
              Text(
                "Verify Your Phone Number",
                style: GoogleFonts.inter(
                    fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 33.h),
              PhoneTextField(
                controller: phoneController,
                onCountryCodeChanged: (value) {
                  setState(() {
                    countryCode = value;
                  });
                },
              ),

              // Obx(() => canResendOtp.value
              //     ? InkWell(
              //         onTap: () {
              //           if (phoneController.text.isEmpty) {
              //             MessageToast.showToast(
              //               msg: 'Please enter number',
              //             );
              //           } else if (phoneController.text.length != 10) {
              //             MessageToast.showToast(
              //               msg: 'Please enter a valid number',
              //             );
              //           } else {
              //             checkIfUserExists(
              //                 '$countryCode${phoneController.text.trim()}');
              //           }
              //         },
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.end,
              //           children: [
              //             Padding(
              //               padding: const EdgeInsets.only(top: 8, right: 12),
              //               child: Text(
              //                 'Get OTP',
              //                 style: GoogleFonts.inter(
              //                   color: kPrimaryColor,
              //                   fontSize: 12.sp,
              //                   fontWeight: FontWeight.w800,
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       )
              //     : Row(
              //         mainAxisAlignment: MainAxisAlignment.end,
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.only(top: 8, right: 12),
              //             child: Text(
              //               'Retry in ${timerSeconds.value}s',
              //               style: GoogleFonts.inter(
              //                 color: const Color(0xFFFF0000),
              //                 fontSize: 12.sp,
              //                 fontWeight: FontWeight.w500,
              //               ),
              //             ),
              //           ),
              //         ],
              //       )),
              // PrimaryTextField(
              //     controller: otpController,
              //     fieldType: TextInputType.number,
              //     hintText: 'Enter OTP code',
              //     headerText: 'Enter OTP'),
              SizedBox(height: 40.h),
              Obx(() => isVerifying.value
                  ? const CircularProgressIndicator(color: kPrimaryColor)
                  : RoundButton(
                      onPressed: () {
                        if (phoneController.text.isEmpty) {
                          MessageToast.showToast(
                            msg: 'Please enter your number',
                          );
                        } else {
                          verifyOTP(
                            otpController.text.trim(),
                          );
                        }
                      },
                      text: 'Verify OTP')),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
      isDismissible: false,
    );
  }

  Future<void> checkIfUserExists(String phoneNumber) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('pmsUsers')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (result.docs.isNotEmpty) {
        MessageToast.showToast(
          msg: 'Phone number already in use!. Please try different number',
        );
      } else {
        sendOTP(phoneNumber);
      }
    } catch (e) {
      print(e);
      // Get.snackbar('Error', 'Failed to check user existence.',
      //     backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void startResendTimer() {
    canResendOtp.value = false;
    timerSeconds.value = 50;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
      }
    });
  }

  void sendOTP(String phoneNumber) async {
    try {
      startResendTimer(); // Start timer when OTP is sent

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // await _auth.currentUser!.linkWithCredential(credential);
          // widget.isPhoneVerified.value = true;
          // Get.back();
          // widget.onVerified(phoneNumber);
          // Get.snackbar("Success", "Phone number verified successfully!",
          //     backgroundColor: kPrimaryColor, colorText: Colors.white);
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = "Failed to send OTP";
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
          Get.snackbar("Error", errorMessage,
              backgroundColor: Colors.red, colorText: Colors.white);
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId.value = verificationId;
          _resendToken = resendToken; // Store the resend token

          Get.snackbar("OTP Sent", "Check your phone for the OTP",
              backgroundColor: kPrimaryColor, colorText: Colors.white);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId.value = verificationId;
        },
        timeout: const Duration(seconds: 120),
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred. Please try again.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void verifyOTP(String otp) async {
    isVerifying.value = true;

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('pmsUsers')
          .doc(userId)
          .update({
        'phoneNumber': '$countryCode${phoneController.text.trim()}',
      });

      Get.snackbar("Success", "Phone number verified successfully!",
          backgroundColor: kPrimaryColor, colorText: Colors.white);
      Get.offAll(() => Dashboard(
            initialTabIndex: 4,
          ));
    } catch (e) {
      print(e);
      MessageToast.showToast(msg: 'An error occurred. Please try again.');
    } finally {
      isVerifying.value = false;
    }
  }
}
