// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:solar_market/constants.dart';
// import 'package:solar_market/controllers/signup_controller.dart';
// import 'package:solar_market/screens/dashboard/dashboard_screen.dart';
// import 'package:solar_market/screens/dashboard/privacy_policy/privacy_policy_screen.dart';
// import 'package:solar_market/screens/dashboard/terms_and_conditions/terms_and_conditioin_screen.dart';
// import 'package:solar_market/utils/toas_message.dart';
// import 'package:solar_market/widgets/primary_textfield.dart';
// import 'package:solar_market/widgets/round_button.dart';

// class AdditionalInfoScreen extends StatefulWidget {
//   final User? user;
//   const AdditionalInfoScreen({super.key, this.user});

//   @override
//   State<AdditionalInfoScreen> createState() => _AdditionalInfoScreenState();
// }

// class _AdditionalInfoScreenState extends State<AdditionalInfoScreen> {
//   TextEditingController phoneController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   final SignupController signupController = Get.put(SignupController());
//   bool isAgreedToTerms = false;
//   String countryCode = "+92";
//   @override
//   Widget build(BuildContext context) {
//     print('${countryCode}${phoneController.text}');

//     return Scaffold(
//         backgroundColor: kblack,
//         appBar: AppBar(
//           backgroundColor: kblack,
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Get.to(() => const Dashboard());
//               },
//               child: Text(
//                 'Skip',
//                 style: GoogleFonts.inter(
//                   color: const Color(0xFF00BF63),
//                   fontSize: 12.sp,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             )
//           ],
//         ),
//         body: Column(
//           children: [
//             SvgPicture.asset(
//               'assets/icons/login.svg',
//               // width: Get.width * .44,
//               allowDrawingOutsideViewBox: true,
//             ),
//             SizedBox(
//               height: Get.height * .05.h,
//             ),
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(70.sp),
//                   topRight: Radius.circular(70.sp),
//                 ),
//                 child: Container(
//                   // height: Get.height * .595,
//                   padding:
//                       EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
//                   decoration: ShapeDecoration(
//                     color: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(70.sp),
//                         topRight: Radius.circular(70.sp),
//                       ),
//                     ),
//                   ),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Text(
//                           'Welcome Back',
//                           style: GoogleFonts.inter(
//                             color: Colors.black,
//                             fontSize: 19.sp,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         SizedBox(
//                           height: 31.h,
//                         ),
//                         PhoneTextField(
//                           controller: phoneController,
//                           onCountryCodeChanged: (value) {
//                             setState(() {
//                               countryCode = value;
//                             });
//                           },
//                         ),
//                         SizedBox(
//                           height: 16.h,
//                         ),
//                         PrimaryTextField(
//                             controller: nameController,
//                             hintText: 'Enter your name',
//                             headerText: 'Full Name'),
//                         Row(
//                           children: [
//                             Transform.scale(
//                               scale:
//                                   0.8, // Adjust the scale to decrease the size (smaller value for smaller size)
//                               child: Checkbox(
//                                 value: isAgreedToTerms,
//                                 checkColor: Colors.white,
//                                 fillColor:
//                                     MaterialStateProperty.resolveWith<Color?>(
//                                   (states) =>
//                                       isAgreedToTerms ? kPrimaryColor : null,
//                                 ),
//                                 onChanged: (value) {
//                                   setState(() {
//                                     isAgreedToTerms = value!;
//                                   });
//                                 },
//                               ),
//                             ),
//                             Expanded(
//                               child: Text.rich(
//                                 TextSpan(
//                                   children: [
//                                     TextSpan(
//                                       text: 'I agree to the ',
//                                       style: GoogleFonts.inter(
//                                           color: Colors.black, fontSize: 11),
//                                     ),
//                                     TextSpan(
//                                       text: 'Terms and Conditions ',
//                                       style: GoogleFonts.inter(
//                                           color: kPrimaryColor,
//                                           fontSize: 9.sp,
//                                           // fontSize: 12,
//                                           decoration: TextDecoration.underline),
//                                       recognizer: TapGestureRecognizer()
//                                         ..onTap = () {
//                                           Get.to(() => TermsConditionsScreen());
//                                         },
//                                     ),
//                                     TextSpan(
//                                       text: '& ',
//                                       style: GoogleFonts.inter(
//                                           color: Colors.black, fontSize: 11),
//                                     ),
//                                     TextSpan(
//                                       text: 'Privacy Policy',
//                                       style: GoogleFonts.inter(
//                                           color: kPrimaryColor,
//                                           fontSize: 9.sp,
//                                           decoration: TextDecoration.underline),
//                                       recognizer: TapGestureRecognizer()
//                                         ..onTap = () {
//                                           Get.to(() => PrivacyPolicyScreen());
//                                         },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                         Obx(() => signupController.isLoading.value
//                             ? const CircularProgressIndicator(
//                                 color: kPrimaryColor)
//                             : RoundButton(
//                                 onPressed: () {
//                                   if (phoneController.text.isEmpty) {
//                                     MessageToast.showToast(
//                                       msg: 'Please enter your number',
//                                     );
//                                   } else if (nameController.text.isEmpty) {
//                                     MessageToast.showToast(
//                                       msg: 'Please enter your name',
//                                     );
//                                   } else if (!isAgreedToTerms) {
//                                     MessageToast.showToast(
//                                       msg:
//                                           'Please accept terms and conditions & privacy policy',
//                                     );
//                                   } else {
//                                     signupController
//                                         .saveUserDataToFirestore(
//                                       widget.user,
//                                       nameController.text,
//                                       '$countryCode${phoneController.text.trim()}',
//                                     )
//                                         .whenComplete(
//                                       () {
//                                         Get.to(() => AccountCreationAnimationScreen(
//                                             titleText:
//                                                 'Account Created Successfully!',
//                                             descriptionText:
//                                                 'You are being redirected to the Dashboard'));
//                                       },
//                                     );
//                                   }
//                                 },
//                                 text: 'Submit')),
//                         const SizedBox(
//                           height: 8,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ));
//   }
// }
