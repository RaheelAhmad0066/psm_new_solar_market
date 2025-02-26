import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/profile/edit_profile_screen.dart';
import 'package:solar_market/screens/dashboard/profile/verify_profile_screen.dart';
import 'package:solar_market/utils/auth_service.dart';
import 'package:solar_market/widgets/drawer_widget.dart';

import '../../../controllers/user_controller/user_controller.dart';
import '../../../utils/toas_message.dart';
import '../followers/follower_screen.dart';
import '../my_posts/users_post_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController controller = Get.put(ProfileController());
  final UserController userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    userController.fetchUserProfile(currentUserId, currentUserId);
    userController.fetchRealTimecurentData(currentUserId);
    return Scaffold(
      backgroundColor: kblack,
      drawer: AuthService.isAuthenticated() ? const DrawerWidget() : null,
      appBar: AppBar(
        automaticallyImplyLeading: AuthService.isAuthenticated() ? true : false,
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
        actions: [
          // TextButton(
          //     onPressed: () {},
          //     child: Text(
          //       'Verify Number',
          //       style: GoogleFonts.inter(
          //         color: const Color(0xFF00BF63),
          //         fontSize: 10.sp,
          //         fontWeight: FontWeight.w800,
          //       ),
          //     ),
          //   )
          // ),
          IconButton(
              onPressed: () {
                Get.to(() => EditProfileScreen());
              },
              tooltip: 'Edit Profile',
              icon: Icon(
                Icons.edit,
                size: 28,
                // color: kPrimaryColor,.3+
              )),
        ],
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 10.h,
                              ),
                              Stack(
                                children: [
                                  Obx(() => Container(
                                        height: 99.h,
                                        width: 99.w,
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade100,
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.black12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(222.r),
                                          child: controller.userImage.isEmpty
                                              ? const Icon(
                                                  Icons.person,
                                                  size: 38,
                                                )
                                              : Image.network(
                                                  controller.userImage.value,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                      color: Colors.white,
                                                    ));
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error);
                                                  },
                                                ),
                                        ),
                                      )),
                                  Positioned(
                                    bottom: 2.h,
                                    right: 2.w,
                                    child: Icon(
                                      Icons.verified,
                                      color: controller.isVerified.value
                                          ? Colors.blueAccent
                                          : Colors.grey.shade600,
                                      size: 22.sp,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Obx(
                                    () => Text(
                                      controller.userName.value,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Obx(
                                        () => Text(
                                          controller.uniqueId.value,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                      Obx(
                                        () => Text(
                                          ' (${controller.tag.value})',
                                          style: GoogleFonts.inter(
                                            color: kPrimaryColor,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 12.h,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Get.to(() => FollowersFollowingsScreen(
                                          isFollowers: true,
                                          userId: FirebaseAuth
                                              .instance.currentUser!.uid));
                                    },
                                    child: Column(
                                      children: [
                                        Obx(() => Text(
                                              userController
                                                  .myfollowersCount.value
                                                  .toString(),
                                              style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 21.sp,
                                                  fontWeight: FontWeight.w700),
                                            )),
                                        Text(
                                          'Followers',
                                          style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.to(() => FollowersFollowingsScreen(
                                          isFollowers: false,
                                          userId: FirebaseAuth
                                              .instance.currentUser!.uid));
                                    },
                                    child: Column(
                                      children: [
                                        Obx(() => Text(
                                              userController
                                                  .myfollowingCount.value
                                                  .toString(),
                                              style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 21.sp,
                                                  fontWeight: FontWeight.w700),
                                            )),
                                        Text(
                                          'Following',
                                          style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 19),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Date of Joining:',
                                    style: GoogleFonts.inter(
                                      color: kPrimaryColor,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      controller.joiningDate.value,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6.h,
                              ),
                              Obx(
                                () => Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 7.w),
                                  child: Text(
                                    controller.userDescription.value,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 14.h,
                          ),
                          Divider(
                            thickness: 0.6,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 14.h,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Verify your account to activate more features',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 14.w,
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (!controller.isPhoneVerified.value) {
                                    MessageToast.showToast(
                                        msg:
                                            'Please verify your phone number first.');
                                    Get.to(() => EditProfileScreen());
                                  } else {
                                    Get.to(() => VerifyProfileScreen(
                                          profileStatus:
                                              controller.profileStatus.value,
                                        ));
                                  }
                                },
                                icon: Icon(
                                  Icons.verified,
                                  size: 18,
                                  color: controller.profileStatus.value ==
                                          'verified'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 14.w),
                                    backgroundColor:
                                        controller.profileStatus.value ==
                                                'verified'
                                            ? kPrimaryColor
                                            : Colors.yellow),
                                label: Text(
                                  controller.profileStatus.value == 'pending'
                                      ? 'Verification Pending'
                                      : controller.profileStatus.value ==
                                              'verified'
                                          ? 'Verified'
                                          : 'Verify Now',
                                  style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: controller.profileStatus.value ==
                                              'verified'
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                              // : Center(
                              //     child: PhoneVerificationWidget(
                              //       isPhoneVerified: isPhoneVerified,
                              //       onVerified:
                              //           updatePhoneNumberInFirestore,
                              //     ),
                              // )
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: 22.h,
                          ),
                          Divider(
                            thickness: 0.2,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 24.h,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'My Posts',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.to(() => UsersPostScreen(
                                        postType: 'userPanels',
                                        categoryType: 'categories',
                                        appBarText: 'Panels Posts',
                                      ));
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 28.w, vertical: 18),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.pink),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/panels.svg',
                                        height: 26.h,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Panels',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(() => UsersPostScreen(
                                        postType: 'userLithium',
                                        categoryType: 'Lithiumcategories',
                                        appBarText: 'Batteris Posts',
                                      ));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(18.r),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(0xFF2E5FFF)),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/lithium.svg',
                                        height: 26.h,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Battereies',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(() => UsersPostScreen(
                                        postType: 'userInverters',
                                        categoryType: 'invertercategories',
                                        appBarText: 'Inverters Posts',
                                      ));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(18.r),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: kPrimaryColor),
                                  child: Column(
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/inverters.svg',
                                        height: 26.h,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Inverters',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
