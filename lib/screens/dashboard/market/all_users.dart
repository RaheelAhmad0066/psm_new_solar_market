import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import '../../../controllers/user_controller/user_controller.dart';
import '../../../utils/toas_message.dart';
import '../detail_screens/user_detail_screen.dart';
import '../profile/edit_profile_screen.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserController userController = Get.put(UserController());
  final ProfileController profileController = Get.put(ProfileController());
  final TextEditingController _searchController = TextEditingController();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          children: [
            _buildSearchField(),
            SizedBox(height: 10.h),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pmsUsers')
                    .where('userId',
                        isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: kPrimaryColor));
                  }

                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: GoogleFonts.inter(fontSize: 16.sp)));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No users available',
                        style: GoogleFonts.kameron(
                            fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  // var users = snapshot.data!.docs
                  //     .where((user) =>
                  //         user['fullName']
                  //             .toLowerCase()
                  //             .contains(searchQuery) ||
                  //         user['uniqueId'].contains(searchQuery))
                  //     .toList();
                  var users = snapshot.data!.docs.where((user) {
                    var fullName = user['fullName']?.toLowerCase() ?? '';
                    var uniqueId = user['uniqueId'] ?? '';
                    return fullName.contains(searchQuery) ||
                        uniqueId.contains(searchQuery);
                  }).toList();

                  if (users.isEmpty) {
                    return Center(
                      child: Text(
                        'No users found',
                        style: GoogleFonts.kameron(
                            fontSize: 16.sp, fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      String userId = user.id;
                      String fullName =
                          user['fullName']?.trim().isNotEmpty == true
                              ? user['fullName']
                              : 'Anonymous';
                      String phoneNumber = user['phoneNumber'] ?? '';
                      String profileImage = user['image'] ?? '';
                      bool isFollowing = user['followers']
                          .any((f) => f['userId'] == currentUserId);

                      return GetX<UserController>(
                        builder: (controller) {
                          bool isUserLoading =
                              controller.followingLoading[userId] ?? false;

                          return ListTile(
                            onTap: () {
                              if (!profileController.isPhoneVerified.value) {
                                MessageToast.showToast(
                                    msg:
                                        'Please verify your phone number before proceeding.');

                                Get.to(() => EditProfileScreen());
                              } else {
                                Get.to(() => UserDetailScreen(
                                    userId: userId, phoneNumber: phoneNumber));
                              }
                            },
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade300,
                              radius: 32.r,
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
                                  fontSize: 15.sp, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(user['uniqueId'] ?? '',
                                style: GoogleFonts.inter(fontSize: 11.sp)),
                            trailing: InkWell(
                              onTap: isUserLoading
                                  ? null // Disable button while loading
                                  : () async {
                                      if (!profileController
                                          .isPhoneVerified.value) {
                                        // Show a message if the phone number is not verified
                                        MessageToast.showToast(
                                            msg:
                                                'Please verify your phone number before proceeding.');

                                        Get.to(() => EditProfileScreen());
                                        return;
                                      }

                                      controller.setUserLoading(userId, true);

                                      try {
                                        if (isFollowing) {
                                          await controller.unfollowUser(
                                              userId, currentUserId);
                                        } else {
                                          await controller.followUser(
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
                                        controller.setUserLoading(
                                            userId, false);
                                      }
                                    },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.h, horizontal: 20.w),
                                decoration: BoxDecoration(
                                  color: (isFollowing
                                      ? Colors.grey.shade200
                                      : Color(0xffEE1D52)),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  isFollowing ? 'Unfollow' : 'Follow',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: (isFollowing
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search users...',
        hintStyle: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Icon(Icons.search, color: kPrimaryColor),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.cancel, color: Colors.grey.shade500),
                onPressed: () {
                  _searchController.clear();
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
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
    );
  }
}
