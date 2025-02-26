import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/controllers/user_controller/user_controller.dart';
import 'package:solar_market/screens/dashboard/about_us/about_us_screen.dart';
import 'package:solar_market/screens/dashboard/bids_request/bid_screen.dart';
import 'package:solar_market/screens/dashboard/contact_us/contact_us_screen.dart';
import 'package:solar_market/screens/dashboard/my_posts/users_post_screen.dart';
import 'package:solar_market/screens/dashboard/notifications/notifications.dart';
import 'package:solar_market/widgets/common_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({
    super.key,
  });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  ProfileController profileController = Get.put(ProfileController());
  UserController userController = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    userController.fetchUserProfile(currentUserId, currentUserId);
    userController.fetchRealTimecurentData(currentUserId);
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Obx(() => Stack(
                          children: [
                            Container(
                              // height: MediaQuery.of(context).size.height * .12,
                              // width: MediaQuery.of(context).size.width * .23,

                              height: 66,
                              width: 66,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white38),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(222),
                                child: profileController.userImage.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 33.sp,
                                      )
                                    : Image.network(
                                        profileController.userImage.value,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                              child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ));
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              right: 2,
                              child: Icon(
                                Icons.verified,
                                color:
                                    profileController.isVerified.value == false
                                        ? Colors.grey.shade600
                                        : Colors.blueAccent,
                                size: 18.sp,
                              ),
                            ),
                          ],
                        )),
                    SizedBox(
                      width: 6.w,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              profileController.userName.value,
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Obx(
                                () => Text(
                                  profileController.uniqueId.value,
                                  style: GoogleFonts.inter(
                                    color: Colors.grey.shade700,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                               Obx(
                            () => Text(
                              ' (${profileController.tag.value})',
                              style: GoogleFonts.inter(
                                color: kPrimaryColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Obx(() => Text(
                          'Followers: ${userController.myfollowersCount.value.toString()}',
                          style: GoogleFonts.inter(
                              // color: ,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500),
                        )),
                  ],
                )
              ],
            ),
          ),
          const Divider(),
          // DrawerTile(
          //   text: 'Home',
          //   iconPath: 'assets/icons/home.svg',
          //   onTap: () {
          //     Get.back(); // Close the drawer
          //     // Get.offAll(() => Dashboard()); // Navigate to the HomeScreen
          //   },
          // ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: SvgPicture.asset(
                'assets/icons/post.svg',
                height: 21.h,
              ),
              title: Text(
                'My Posts',
                style: GoogleFonts.inter(
                  color: Color(0xFF00BF63),
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(Icons.arrow_drop_down),
              childrenPadding:
                  EdgeInsets.symmetric(horizontal: 13, vertical: 3),
              children: [
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/icons/panels.svg',
                    color: kPrimaryColor,
                  ),
                  title: Text(
                    'Panels Post',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                    ),
                  ),
                  onTap: () {
                    Get.to(() => UsersPostScreen(
                          postType: 'userPanels',
                          categoryType: 'categories',
                          appBarText: 'Panels Posts',
                        ));
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/icons/lithium.svg',
                    color: kPrimaryColor,
                  ),
                  title: Text(
                    'Batteries Post',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                    ),
                  ),
                  onTap: () {
                    Get.to(() => UsersPostScreen(
                          postType: 'userLithium',
                          categoryType: 'Lithiumcategories',
                          appBarText: 'Batteries Posts',
                        ));
                  },
                ),
                ListTile(
                  leading: SvgPicture.asset(
                    'assets/icons/inverters.svg',
                    color: kPrimaryColor,
                  ),
                  title: Text(
                    'Inverters Post',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                    ),
                  ),
                  onTap: () {
                    Get.to(() => UsersPostScreen(
                          postType: 'userInverters',
                          categoryType: 'invertercategories',
                          appBarText: 'Inverters Posts',
                        ));
                  },
                )
              ],
            ),
          ),
          DrawerTile(
            text: 'Bids Request',
            iconPath: 'assets/icons/bids.svg',
            onTap: () {
              Get.to(() => UserBidsScreen());
            },
          ),
          // DrawerTile(
          //   text: 'PMS Market Place',
          //   iconPath: 'assets/icons/pms.svg',
          //   onTap: () {},
          // ),

          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/call.svg',
              height: 23.h,
              color: kPrimaryColor,
              allowDrawingOutsideViewBox: true,
            ),
            title: Text(
              'Contact Us',
              style: GoogleFonts.inter(
                color: Color(0xFF00BF63),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Get.to(() => ContactUsScreen());
            },
          ),
          ListTile(
            leading: Icon(
              Icons.outbond,
              color: kPrimaryColor,
              size: 25.sp,
            ),
            title: Text(
              'About Us',
              style: GoogleFonts.inter(
                color: Color(0xFF00BF63),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Get.to(() => AboutUsScreen());
            },
          ),
          ListTile(
            leading: SvgPicture.asset(
              'assets/icons/notifications.svg',
              height: 22.h,
              color: kPrimaryColor,
              allowDrawingOutsideViewBox: true,
            ),
            title: Text(
              'Notifications',
              style: GoogleFonts.inter(
                color: Color(0xFF00BF63),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              Get.to(() => NotificationScreen());
            },
          ),

          ListTile(
            leading: Icon(
              Icons.star_rounded,
              size: 30.sp,
              color: kPrimaryColor,
            ),
            title: Text(
              'Rate Us',
              style: GoogleFonts.inter(
                color: Color(0xFF00BF63),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              launchUrl(Uri.parse('https://surl.li/iwpjzw'));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.share,
              size: 25.sp,
              color: kPrimaryColor,
            ),
            title: Text(
              'Share',
              style: GoogleFonts.inter(
                color: Color(0xFF00BF63),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () async {
              Share.share(
                  'Download the app from the following link \n\n https://surl.li/iwpjzw');
            },
          ),

          DrawerTile(
            text: 'Delete Account',
            iconPath: 'assets/icons/delete.svg',
            onTap: () {
              showDeleteAccountDialog(context, profileController);
            },
          ),
          DrawerTile(
            text: 'Logout',
            iconPath: 'assets/icons/logout.svg',
            onTap: () {
              showLogoutDialog(context, profileController);
              // showDialog(
              //   context: context,
              //   builder: (BuildContext context) {
              //     return LogoutDialog(profileController: profileController,);
              //   },
              // );
            },
          ),
        ],
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onTap;
  const DrawerTile({
    super.key,
    required this.text,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
            splashColor: kblack,
            leading: SvgPicture.asset(
              iconPath,
              height: 22.sp,
              allowDrawingOutsideViewBox: true,
            ),
            title: Text(
              text,
              style: GoogleFonts.inter(
                color: Color(0xFF00BF63),
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: onTap),
        SizedBox(
          height: 4.h,
        )
      ],
    );
  }
}

void showDeleteAccountDialog(
    BuildContext context, ProfileController profileController) {
  showDialog(
    context: context,
    builder: (context) => CommonDialog(
      title: 'Delete Account',
      message:
          'Do you want to delete your account? This action cannot be undone.',
      icon: Icons.delete_forever_outlined,
      iconColor: Color(0xFFE60101),
      negativeButtonText: 'NO',
      positiveButtonText: 'YES',
      onPositiveButtonPressed: () async {
        Navigator.of(context).pop();
        await profileController.deleteAccount();
        await profileController.logOut(); // Perform logout action

        await profileController.deleteUserPosts();
        await profileController.deleteUserBids();
      },
    ),
  );
}

void showLogoutDialog(
    BuildContext context, ProfileController profileController) {
  showDialog(
    context: context,
    builder: (context) => CommonDialog(
      title: 'Logout',
      message: 'Do you want to logout your account?',
      icon: Icons.logout,
      iconColor: kPrimaryColor,
      negativeButtonText: 'NO',
      positiveButtonText: 'YES',
      onPositiveButtonPressed: () async {
        Navigator.of(context).pop(); // Close the dialog
        await profileController.logOut(); // Perform logout action
      },
    ),
  );
}
