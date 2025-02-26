// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:solar_market/constants.dart';
// import 'package:solar_market/screens/auth/login_screen.dart';
// import 'package:solar_market/screens/dashboard/dashboard_screen.dart';
// import 'package:solar_market/screens/dashboard/privacy_policy/privacy_policy_screen.dart';
// import 'package:solar_market/screens/dashboard/terms_and_conditions/terms_and_conditioin_screen.dart';
// import 'package:solar_market/utils/toas_message.dart';
// import 'package:solar_market/widgets/primary_textfield.dart';
// import 'package:solar_market/widgets/round_button.dart';

// import '../../controllers/auth_controller.dart';
// import '../../widgets/backbutton.dart';

// class RegisterSccreen extends StatefulWidget {
//   final String? phoneNumber;
//   const RegisterSccreen({super.key, this.phoneNumber});

//   @override
//   State<RegisterSccreen> createState() => _RegisterSccreenState();
// }

// class _RegisterSccreenState extends State<RegisterSccreen> {
//   // final SignupController signupController = Get.put(SignupController());

//   TextEditingController nameController = TextEditingController();
//   TextEditingController otpController = TextEditingController();
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   TextEditingController emailController = TextEditingController();
//   final AuthController authController = Get.put(AuthController());

//   String countryCode = "+92";
//   bool isAgreedToTerms = false;
//   String removeCountryCode(String phoneNumber) {
//     // Remove the country code if it's present in the beginning of the phone number
//     if (phoneNumber.startsWith(countryCode)) {
//       return phoneNumber.substring(countryCode.length);
//     } else {
//       // If no country code is found, return the phone number as is
//       return phoneNumber;
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     if (widget.phoneNumber != null) {
//       // If phone number is passed, populate the phoneController
//       phoneController.text = widget.phoneNumber!.replaceFirst(countryCode, '');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kblack,
//       appBar: AppBar(
//         backgroundColor: kblack,
//         leading: const BackNavigatingButton(
//           color: Colors.white,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Get.to(() => const Dashboard());
//             },
//             child: Text(
//               'Skip',
//               style: GoogleFonts.inter(
//                 color: const Color(0xFF00BF63),
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           SvgPicture.asset(
//             'assets/icons/register.svg',
//             width: Get.width *.44.h,
//             allowDrawingOutsideViewBox: true,
//           ),
//           SizedBox(
//             height: Get.height * .036.h,
//           ),
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(70.sp),
//                 topRight: Radius.circular(70.sp),
//               ),
//               child: Container(
//                 // height: Get.height * .7,
//                 padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
//                 decoration: ShapeDecoration(
//                   color: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(70.sp),
//                       topRight: Radius.circular(70.sp),
//                     ),
//                   ),
//                 ),
//                 child: SingleChildScrollView(
//                   child: Column(
//                     children: [
//                       Text(
//                         'Register',
//                         style: GoogleFonts.inter(
//                           color: Colors.black,
//                           fontSize: 20.sp,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       SizedBox(
//                         height: 16.h,
//                       ),
//                       PrimaryTextField(
//                         controller: nameController,
//                         hintText: 'Enter your full name',
//                         headerText: 'Full Name',
//                       ),
//                       SizedBox(
//                         height: 16.h,
//                       ),
//                       // PrimaryTextField(
//                       //   controller: emailController,
//                       //   hintText: 'Enter your email',
//                       //   headerText: 'Email',
//                       // ),
//                       // SizedBox(
//                       //   height: 16.h,
//                       // ),
//                       PrimaryTextField(
//                         controller: passwordController,
//                         hintText: 'Enter your password',
//                         headerText: 'Password',
//                       ),
//                       SizedBox(
//                         height: 16.h,
//                       ),
//                       PhoneTextField(
//                         controller: phoneController,
//                         onCountryCodeChanged: (value) {
//                           setState(() {
//                             countryCode = value;
//                           });
//                         },
//                       ),
//                       Obx(() {
//                         if (authController.timerValue.value > 0) {
//                           return Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               Padding(
//                                 padding:
//                                     EdgeInsets.only(top: 8.sp, right: 12.sp),
//                                 child: Text(
//                                   'Retry in ${authController.timerValue.value}s',
//                                   style: GoogleFonts.inter(
//                                     color: const Color(0xFFFF0000),
//                                     fontSize: 12.sp,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           );
//                         } else {
//                           return InkWell(
//                             onTap: () {
//                               if (phoneController.text.isEmpty) {
//                                 MessageToast.showToast(
//                                   msg: 'Please enter number',
//                                 );
//                               }

//                               //  else if (phoneController.text.length != 10) {
//                               //   MessageToast.showToast(
//                               //     msg: 'Phone enter a valid number',
//                               //   );
//                               // }

//                               else {
//                                 authController.checkIfUserExists(
//                                     '$countryCode${phoneController.text.trim()}',
//                                     true);
//                               }
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.end,
//                               children: [
//                                 Padding(
//                                   padding:
//                                       EdgeInsets.only(top: 8.h, right: 12.w),
//                                   child: Text(
//                                     'Get OTP',
//                                     style: GoogleFonts.inter(
//                                       color: kPrimaryColor,
//                                       fontSize: 12.sp,
//                                       fontWeight: FontWeight.w800,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }
//                       }),
//                       PrimaryTextField(
//                           controller: otpController,
//                           fieldType: TextInputType.number,
//                           hintText: 'Enter OTP code',
//                           headerText: 'Enter OTP'),
//                       Row(
//                         children: [
//                           Transform.scale(
//                             scale:
//                                 0.8, // Adjust the scale to decrease the size (smaller value for smaller size)
//                             child: Checkbox(
//                               value: isAgreedToTerms,
//                               checkColor: Colors.white,
//                               fillColor:
//                                   MaterialStateProperty.resolveWith<Color?>(
//                                 (states) =>
//                                     isAgreedToTerms ? kPrimaryColor : null,
//                               ),
//                               onChanged: (value) {
//                                 setState(() {
//                                   isAgreedToTerms = value!;
//                                 });
//                               },
//                             ),
//                           ),
//                           Expanded(
//                             child: Text.rich(
//                               TextSpan(
//                                 children: [
//                                   TextSpan(
//                                     text: 'I agree to the ',
//                                     style: GoogleFonts.inter(
//                                         color: Colors.black, fontSize: 11),
//                                   ),
//                                   TextSpan(
//                                     text: 'Terms and Conditions ',
//                                     style: GoogleFonts.inter(
//                                         color: kPrimaryColor,
//                                         fontSize: 9.sp,
//                                         // fontSize: 12,
//                                         decoration: TextDecoration.underline),
//                                     recognizer: TapGestureRecognizer()
//                                       ..onTap = () {
//                                         Get.to(() => TermsConditionsScreen());
//                                       },
//                                   ),
//                                   TextSpan(
//                                     text: '& ',
//                                     style: GoogleFonts.inter(
//                                         color: Colors.black, fontSize: 11),
//                                   ),
//                                   TextSpan(
//                                     text: 'Privacy Policy',
//                                     style: GoogleFonts.inter(
//                                         color: kPrimaryColor,
//                                         fontSize: 9.sp,
//                                         decoration: TextDecoration.underline),
//                                     recognizer: TapGestureRecognizer()
//                                       ..onTap = () {
//                                         Get.to(() => PrivacyPolicyScreen());
//                                       },
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       // Row(
//                       //   mainAxisAlignment: MainAxisAlignment.end,
//                       //   children: [
//                       //     Padding(
//                       //       padding: const EdgeInsets.symmetric(
//                       //           horizontal: 16, vertical: 5),
//                       //       child: Text(
//                       //         'Resend OTP',
//                       //         style: GoogleFonts.inter(
//                       //           color: const Color(0xFFFF0000),
//                       //           fontSize: 12,
//                       //           fontWeight: FontWeight.w400,
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                       const SizedBox(
//                         height: 8,
//                       ),
//                       Obx(() {
//                         return authController.isLoading.value
//                             ? const CircularProgressIndicator(
//                                 color: kPrimaryColor)
//                             : RoundButton(
//                                 onPressed: () {
//                                   if (nameController.text.isEmpty) {
//                                     MessageToast.showToast(
//                                       msg: 'Please enter your name',
//                                     );
//                                   } else if (passwordController.text.isEmpty) {
//                                     MessageToast.showToast(
//                                       msg: 'Please enter your password',
//                                     );
//                                   } else if (phoneController.text.isEmpty) {
//                                     MessageToast.showToast(
//                                       msg: 'Please enter your number',
//                                     );
//                                   } else if (otpController.text.isEmpty) {
//                                     MessageToast.showToast(
//                                       msg: 'Please enter OTP',
//                                     );
//                                   } else if (!isAgreedToTerms) {
//                                     MessageToast.showToast(
//                                       msg:
//                                           'Please accept terms and conditions & privacy policy',
//                                     );
//                                   } else {
//                                     authController.verifyOtpAndSignUp(
//                                         otp: otpController.text.trim(),
//                                         phoneNumber:
//                                             '$countryCode${phoneController.text.trim()}',
//                                         fullName: nameController.text.trim(),
//                                         password:
//                                             passwordController.text.trim());
//                                   }
//                                 },
//                                 text: 'Sign Up',
//                               );
//                       }),
//                       SizedBox(
//                         height: 8.h,
//                       ),
//                       Text(
//                         'Or',
//                         style: GoogleFonts.inter(
//                           color: kPrimaryColor,
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                       InkWell(
//                         onTap: () {
//                           Get.to(() => const LoginScreen());
//                         },
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'Already have an account ? ',
//                               style: GoogleFonts.inter(
//                                 color: Color(0xFF939598),
//                                 fontSize: 13.sp,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             Text(
//                               'Sign in',
//                               style: GoogleFonts.inter(
//                                 color: kPrimaryColor,
//                                 fontSize: 14.sp,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/signup_controller.dart';
import 'package:solar_market/screens/auth/login_screen.dart';
import 'package:solar_market/screens/dashboard/dashboard_screen.dart';
import 'package:solar_market/screens/dashboard/privacy_policy/privacy_policy_screen.dart';
import 'package:solar_market/screens/dashboard/terms_and_conditions/terms_and_conditioin_screen.dart';
import 'package:solar_market/utils/toas_message.dart';
import 'package:solar_market/widgets/primary_textfield.dart';
import 'package:solar_market/widgets/round_button.dart';

import '../../widgets/backbutton.dart';

class RegisterSccreen extends StatefulWidget {
  final String? phoneNumber;
  const RegisterSccreen({super.key, this.phoneNumber});

  @override
  State<RegisterSccreen> createState() => _RegisterSccreenState();
}

class _RegisterSccreenState extends State<RegisterSccreen> {
  final SignupController signupController = Get.put(SignupController());

  TextEditingController nameController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String countryCode = "+92";
  bool isAgreedToTerms = false;
  String removeCountryCode(String phoneNumber) {
    // Remove the country code if it's present in the beginning of the phone number
    if (phoneNumber.startsWith(countryCode)) {
      return phoneNumber.substring(countryCode.length);
    } else {
      // If no country code is found, return the phone number as is
      return phoneNumber;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      // If phone number is passed, populate the phoneController
      phoneController.text = widget.phoneNumber!.replaceFirst(countryCode, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kblack,
      appBar: AppBar(
        backgroundColor: kblack,
        leading: const BackNavigatingButton(
          color: Colors.white,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.to(() => const Dashboard());
            },
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                color: const Color(0xFF00BF63),
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          SvgPicture.asset(
            'assets/icons/register.svg',
            width: Get.width * .44.h,
            allowDrawingOutsideViewBox: true,
          ),
          SizedBox(
            height: Get.height * .03.h,
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(70.sp),
                topRight: Radius.circular(70.sp),
              ),
              child: Container(
                // height: Get.height * .7,
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70.sp),
                      topRight: Radius.circular(70.sp),
                    ),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Register',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      PrimaryTextField(
                        controller: nameController,
                        hintText: 'Enter your full name',
                        headerText: 'Full Name',
                      ),
                      SizedBox(
                        height: 16.h,
                      ),
                      PhoneTextField(
                        controller: phoneController,
                        onCountryCodeChanged: (value) {
                          setState(() {
                            countryCode = value;
                          });
                        },
                      ),
                      Obx(() {
                        if (signupController.timerValue.value > 0) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(top: 8.sp, right: 12.sp),
                                child: Text(
                                  'Retry in ${signupController.timerValue.value}s',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFFFF0000),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return InkWell(
                            onTap: () {
                              if (phoneController.text.isEmpty) {
                                MessageToast.showToast(
                                  msg: 'Please enter number',
                                );
                              } else if (phoneController.text.length != 10) {
                                MessageToast.showToast(
                                  msg: 'Phone enter a valid number',
                                );
                              } else {
                                signupController.checkIfUserExists(
                                    '$countryCode${phoneController.text.trim()}',
                                    true);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.h, right: 12.w),
                                  child: Text(
                                    'Get OTP',
                                    style: GoogleFonts.inter(
                                      color: kPrimaryColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }),
                      PrimaryTextField(
                          controller: otpController,
                          fieldType: TextInputType.number,
                          hintText: 'Enter OTP code',
                          headerText: 'Enter OTP'),
                      Row(
                        children: [
                          Transform.scale(
                            scale:
                                0.8, // Adjust the scale to decrease the size (smaller value for smaller size)
                            child: Checkbox(
                              value: isAgreedToTerms,
                              checkColor: Colors.white,
                              fillColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                (states) =>
                                    isAgreedToTerms ? kPrimaryColor : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  isAgreedToTerms = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'I agree to the ',
                                    style: GoogleFonts.inter(
                                        color: Colors.black, fontSize: 11),
                                  ),
                                  TextSpan(
                                    text: 'Terms and Conditions ',
                                    style: GoogleFonts.inter(
                                        color: kPrimaryColor,
                                        fontSize: 9.sp,
                                        // fontSize: 12,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Get.to(() => TermsConditionsScreen());
                                      },
                                  ),
                                  TextSpan(
                                    text: '& ',
                                    style: GoogleFonts.inter(
                                        color: Colors.black, fontSize: 11),
                                  ),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: GoogleFonts.inter(
                                        color: kPrimaryColor,
                                        fontSize: 9.sp,
                                        decoration: TextDecoration.underline),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Get.to(() => PrivacyPolicyScreen());
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.symmetric(
                      //           horizontal: 16, vertical: 5),
                      //       child: Text(
                      //         'Resend OTP',
                      //         style: GoogleFonts.inter(
                      //           color: const Color(0xFFFF0000),
                      //           fontSize: 12,
                      //           fontWeight: FontWeight.w400,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(
                        height: 8,
                      ),
                      Obx(() {
                        return signupController.isLoading.value
                            ? const CircularProgressIndicator(
                                color: kPrimaryColor)
                            : RoundButton(
                                onPressed: () {
                                  if (nameController.text.isEmpty) {
                                    MessageToast.showToast(
                                      msg: 'Please enter your name',
                                    );
                                  } else if (phoneController.text.isEmpty) {
                                    MessageToast.showToast(
                                      msg: 'Please enter your number',
                                    );
                                  } else if (otpController.text.isEmpty) {
                                    MessageToast.showToast(
                                      msg: 'Please enter OTP',
                                    );
                                  } else if (!isAgreedToTerms) {
                                    MessageToast.showToast(
                                      msg:
                                          'Please accept terms and conditions & privacy policy',
                                    );
                                  } else {
                                    signupController.verifyOtp(
                                        otpController.text.trim(),
                                        nameController.text,
                                        '$countryCode${phoneController.text.trim()}',
                                        true);
                                  }
                                },
                                text: 'Sign Up',
                              );
                      }),
                      SizedBox(
                        height: 8.h,
                      ),
                      Text(
                        'Or',
                        style: GoogleFonts.inter(
                          color: kPrimaryColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(() => const LoginScreen());
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account ? ',
                              style: GoogleFonts.inter(
                                color: Color(0xFF939598),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Sign in',
                              style: GoogleFonts.inter(
                                color: kPrimaryColor,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Platform.isAndroid
                            ?  Obx(() => GestureDetector(
                                  onTap: signupController.isLoading.value
                                      ? null
                                      : signupController.signInWithGoogle,
                                  child: Container(
                                    padding: EdgeInsets.all(12.r),
                                    margin: EdgeInsets.only(
                                        top: 15.h, left: 9.w, right: 9.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8.r),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (signupController.isgogleLoading.value)
                                          SizedBox(
                                            width: 24.w,
                                            height: 24.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: kPrimaryColor,
                                            ),
                                          )
                                        else
                                          SvgPicture.asset(
                                              'assets/icons/google_icon.svg'),
                                        SizedBox(width: 10.w),
                                        Text(
                                          "Sign in with Google",
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )):SizedBox.shrink(),
                        Platform.isIOS
                            ?
                             Obx(() => GestureDetector(
                                  onTap: signupController.isgogleLoading.value
                                      ? null
                                      : signupController.signInWithApple,
                                  child: Container(
                                    padding: EdgeInsets.all(12.r),
                                    margin: EdgeInsets.only(
                                        top: 12.h, left: 9.w, right: 9.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (signupController.isLoading.value)
                                          SizedBox(
                                            width: 24.w,
                                            height: 24.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: kPrimaryColor,
                                            ),
                                          )
                                        else
                                          SvgPicture.asset(
                                              'assets/icons/apple_icon.svg'),
                                        SizedBox(width: 10.w),
                                        Text(
                                          "Sign in with Apple",
                                          style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                            : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
