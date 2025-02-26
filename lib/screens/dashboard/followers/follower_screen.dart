import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/screens/dashboard/dashboard_screen.dart';
import 'package:solar_market/screens/dashboard/detail_screens/user_detail_screen.dart';
import '../../../controllers/user_controller/user_controller.dart';

class FollowersFollowingsScreen extends StatefulWidget {
  final String userId;
  final bool isFollowers;
  final Function? onBackPressed; // Callback for back button action

  FollowersFollowingsScreen({
    required this.userId,
    required this.isFollowers,
    Key? key,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<FollowersFollowingsScreen> createState() =>
      _FollowersFollowingsScreenState();
}

class _FollowersFollowingsScreenState extends State<FollowersFollowingsScreen> {
  final UserController userController = Get.put(UserController());

  String searchQuery = "";

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return WillPopScope(
      onWillPop: () async {
        if (widget.onBackPressed != null) {
          widget
              .onBackPressed!(); // Trigger the callback when back button is pressed
        }
        Get.back(); // Navigate back to the previous screen
        return true; // Allow the pop action
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: kblack,
            ),
            onPressed: () {
              if (widget.onBackPressed != null) {
                widget.onBackPressed!();
              }
              Get.back();
            },
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.isFollowers ? 'Followers' : 'Following',
            style:
                GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
                padding: EdgeInsets.all(16.w),
                child: TextField(
                  controller: searchController,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: GoogleFonts.inter(
                        color: Colors.grey.shade500, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: kPrimaryColor),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon:
                                Icon(Icons.cancel, color: Colors.grey.shade500),
                            onPressed: () {
                              searchController.clear();
                              searchQuery='';
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    isDense: true,
                    
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kPrimaryColor, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300, width: 1.0),
                    ),
                  ),
                    onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim();
                  });
                },
                )),
            Expanded(
              child: Obx(
                () {
                  // Show loading only when fetching users initially
                  if (userController.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    );
                  }

                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    child: StreamBuilder<List<String>>(
                      stream: userController.fetchUserList(
                          widget.userId, widget.isFollowers),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child:
                                CircularProgressIndicator(color: kPrimaryColor),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error fetching ${widget.isFollowers ? 'followers' : 'following'}',
                              style: GoogleFonts.inter(fontSize: 16.sp),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              widget.isFollowers
                                  ? 'No followers yet!'
                                  : 'No following yet!',
                              style: GoogleFonts.kameron(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }

                        final userIds = snapshot.data!;
                        return ListView.builder(
                          itemCount: userIds.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            final userId = userIds[index];
                            return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('pmsUsers')
                                  .doc(userId)
                                  .snapshots(),
                              builder: (context, userSnapshot) {
                                if (userSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return ListTile(
                                    leading: CircularProgressIndicator(
                                        color: Colors.white),
                                  );
                                }

                                if (userSnapshot.hasError ||
                                    !userSnapshot.hasData ||
                                    !userSnapshot.data!.exists) {
                                  return ListTile(
                                    title: Text('User not found'),
                                  );
                                }

                                final userData = userSnapshot.data!;
                                final profileImage = userData['image'] ?? '';
                                final fullName =
                                    userData['fullName'] ?? 'Unknown';
                                final uniqueId =
                                    userData['uniqueId'] ?? '00000';
                                final phoneNumber = userData['phoneNumber'] ??
                                    'No phone number';
                                final currentIsFollowing = userData['followers']
                                    .any((f) => f['userId'] == currentUserId);

                                // Check if the follow/unfollow action is loading for this user
                                bool isUserFollowLoading =
                                    userController.userFollowLoading[userId] ??
                                        false;
                                if (searchQuery.isNotEmpty &&
                                    !fullName
                                        .toLowerCase()
                                        .contains(searchQuery.toLowerCase()) &&
                                    !uniqueId
                                        .toLowerCase()
                                        .contains(searchQuery.toLowerCase())) {
                                  return SizedBox();
                                }
                                return ListTile(
                                  onTap: () {
                                    Get.to(() => UserDetailScreen(
                                          userId: userData['userId'],
                                          phoneNumber: phoneNumber,
                                        ));
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.shade300,
                                    radius: 28.r,
                                    backgroundImage: profileImage.isNotEmpty
                                        ? NetworkImage(profileImage)
                                        : null,
                                    child: profileImage.isEmpty
                                        ? Text(
                                            fullName[0].toUpperCase(),
                                            style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: kPrimaryColor),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    fullName,
                                    style: GoogleFonts.inter(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Text(uniqueId,
                                      style: GoogleFonts.inter(fontSize: 11.sp)),
                                  trailing: userId == currentUserId
                                      ? InkWell(
                                          onTap: () {
                                            Get.to(() =>
                                                Dashboard(initialTabIndex: 4));
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.h,
                                                horizontal: 20.w),
                                            decoration: BoxDecoration(
                                              color: kPrimaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Text(
                                              'My Profile',
                                              style: GoogleFonts.inter(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: isUserFollowLoading
                                              ? null // Disable button while loading
                                              : () async {
                                                  userController
                                                      .setUserFollowLoading(
                                                          userId,
                                                          true); // Show loading for this user only

                                                  try {
                                                    if (currentIsFollowing) {
                                                      await userController
                                                          .unfollowUser(userId,
                                                              currentUserId);
                                                    } else {
                                                      await userController
                                                          .followUser(
                                                              userId,
                                                              currentUserId,
                                                              fullName,
                                                              phoneNumber);
                                                    }
                                                  } catch (e) {
                                                    print(e);
                                                    Get.snackbar('Error',
                                                        'Something went wrong: $e');
                                                  } finally {
                                                    userController
                                                        .setUserFollowLoading(
                                                            userId,
                                                            false); // Hide loading after action
                                                  }
                                                },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 8.h,
                                                horizontal: 20.w),
                                            decoration: BoxDecoration(
                                              color: isUserFollowLoading
                                                  ? Colors.grey
                                                      .shade400 // Disabled color when loading
                                                  : (currentIsFollowing
                                                      ? Colors.grey.shade200
                                                      : Color(0xffEE1D52)),
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                            ),
                                            child: Text(
                                              currentIsFollowing
                                                  ? 'Unfollow'
                                                  : 'Follow',
                                              style: GoogleFonts.inter(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                                color: isUserFollowLoading
                                                    ? Colors.black38
                                                    : (currentIsFollowing
                                                        ? Colors.black
                                                        : Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
