import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/widgets/primary_textfield.dart';
import 'package:solar_market/widgets/round_button.dart';

import '../../../widgets/phone_verification_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kblack,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: kblack,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       Get.to(() => VerifyProfileScreen(
        //             profileStatus: controller.profileStatus.value,
        //           ));
        //     },
        //     child: Text(
        //       'Verify now',
        //       style: GoogleFonts.inter(
        //         color: const Color(0xFF00BF63),
        //         fontSize: 12.sp,
        //         fontWeight: FontWeight.w800,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(
                color: kPrimaryColor,
              ))
            : controller.errorMessage.value.isNotEmpty
                ? Center(
                    child: Text(
                    controller.errorMessage.value,
                    style: GoogleFonts.poppins(color: Colors.white),
                  ))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Obx(() => Container(
                                  height: 114,
                                  width: 114,
                                  // height:
                                  //     MediaQuery.of(context).size.height * .15,
                                  // width:
                                  //     MediaQuery.of(context).size.width * .29,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white38),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(222),
                                    child: controller.userImage.isEmpty
                                        ? Icon(
                                            Icons.person,
                                            size: 68,
                                          )
                                        : Image.network(
                                            controller.userImage.value,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                color: Colors.white,
                                              ));
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(Icons.error);
                                            },
                                          ),
                                  ),
                                )),
                            Positioned(
                              top: 7,
                              right: 7,
                              child: GestureDetector(
                                onTap: () {
                                  controller.pickImage(context);
                                },
                                child: Container(
                                  height: 24,
                                  width: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.grey.shade700,
                                    size: 19,
                                  ),
                                ),
                              ),
                            ),
                            // Verified Badge
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Icon(
                                Icons.verified,
                                color: controller.isVerified.value == false
                                    ? Colors.grey.shade600
                                    : Colors.blueAccent,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => Text(
                            controller.userName.value,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 23.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        //  const SizedBox(height: 6),
                         Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Obx(
                                        () => Text(
                                          controller.uniqueId.value,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Obx(
                                        () => Text(
                                          ' (${controller.tag.value})',
                                          style: GoogleFonts.inter(
                                            color: kPrimaryColor,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                       
                        

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Obx(() {
                            if (!controller.isPhoneVerified.value) {
                              // Show Verify Phone Button
                              return PhoneVerificationWidget(
                                isPhoneVerified: controller.isPhoneVerified,
                                onVerified: (phoneNumber) {
                                  controller.updatePhoneNumberInFirestore(
                                      phoneNumber);
                                },
                              );
                            } else if (!controller.isGoogleVerified.value &&
                                Platform.isAndroid) {
                              // Show Link Google Button with loader
                              return GestureDetector(
                                onTap: controller.isgogleLoading.value
                                    ? null
                                    : controller
                                        .linkGoogleAccount, // Prevent tap if loading
                                child: Container(
                                  padding: EdgeInsets.all(10.r),
                                  margin: EdgeInsets.only(
                                      top: 15.h, left: 22.w, right: 22.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (controller.isgogleLoading
                                          .value) // Show Google loading
                                        SizedBox(
                                          width: 22.w,
                                          height: 22.h,
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
                                        "Link with Google",
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (!controller.isAppleVerified.value &&
                                Platform.isIOS) {
                              // Show Link Apple Button with loader
                              return GestureDetector(
                                onTap: controller.isAppleLoading.value
                                    ? null
                                    : controller
                                        .linkAppleAccount, // Prevent tap if loading
                                child: Container(
                                  padding: EdgeInsets.all(12.r),
                                  margin: EdgeInsets.only(
                                      top: 15.h, left: 22.w, right: 22.w),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border:
                                        Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (controller.isAppleLoading
                                          .value) // Show Apple loading
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
                              );
                            } else {
                              // Both Verified, Show Empty Container
                              return Obx(
                                () => Text(
                                  controller.email.value,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }
                          }),
                        ),

                        SizedBox(height: Get.height * .03),
                        Container(
                          height: Get.height * .595,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          decoration: const ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(70),
                                topRight: Radius.circular(70),
                              ),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 38),
                                PrimaryTextField(
                                  controller: controller.nameController,
                                  fieldType: TextInputType.name,
                                  hintText: 'Enter your name',
                                  headerText: 'Full Name',
                                ),
                                const SizedBox(height: 16),
                                Obx(
                                  () => PrimaryTextField(
                                    controller: TextEditingController(
                                        text: controller.userPhone.value),
                                    fieldType: TextInputType.phone,
                                    readOnly: true,
                                    hintText: 'Phone Number',
                                    headerText: 'Phone Number',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                PrimaryTextField(
                                  controller: controller.descriptionController,
                                  hintText: 'Description',
                                  headerText: 'Description',
                                  maxLines: 4,
                                ),
                                const SizedBox(height: 16),
                                Obx(
                                  () => controller.isUpdating.value
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                          color: kPrimaryColor,
                                        ))
                                      : RoundButton(
                                          onPressed: () {
                                            controller.updateUserName();
                                          },
                                          text: 'Update',
                                        ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
