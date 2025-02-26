import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/bidding_controller.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/panels/panel_detail_screen.dart';
import 'package:solar_market/screens/dashboard/panels/timer.dart';
import 'package:solar_market/widgets/tabbar_item.dart';

import '../../../controllers/user_controller/user_controller.dart';
import '../followers/follower_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  final String? phoneNumber;

  UserDetailScreen({
    Key? key,
    required this.userId,
    this.phoneNumber,
  }) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  late Future<Map<String, dynamic>?> userDetailsFuture;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
    tabController.addListener(() {
      setState(() {});
    });

    // Load user details once when the page is first opened
    userDetailsFuture = fetchUserDetails(widget.userId);
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    String collection = widget.userId == '9jQGdhx4zQfEgWfmLjHHlx6Xq0r2'
        ? 'adminDetail'
        : 'pmsUsers';
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user details: $e');
    }
    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh the follower and following count when returning to the screen
    userController.fetchUserProfile(
        widget.userId, FirebaseAuth.instance.currentUser!.uid);
    userController.fetchRealTimeData(widget.userId);
  }

  final BiddingController controller = Get.put(BiddingController());
  final UserController userController = Get.put(UserController());
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    // userController.fetchRealTimeData(widget.userId);
    String currentUserName = profileController.userName.value;
    String currentUserPhone = profileController.userPhone.value;
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    bool isAdmin = widget.userId == '9jQGdhx4zQfEgWfmLjHHlx6Xq0r2';

    if (!isAdmin) {
      userController.fetchUserProfile(widget.userId, currentUserId);
      userController.fetchRealTimeData(widget.userId);
    }

    return Scaffold(
      backgroundColor: kblack,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: kblack,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: userDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('No user found'),
            );
          }

          final userDetails = snapshot.data!;
          final String userName = userDetails['fullName'] ?? 'No Name';
          final String userImage = userDetails['image'] ?? '';
          final String phoneNumber = userDetails['phoneNumber'] ?? 'N/A';
          final String uniqueId = userDetails['uniqueId'] ?? 'N/A';
          final String tag = userDetails['tag'] ?? 'N/A';
          final String userId = userDetails['userId'] ?? 'N/A';
          final bool isVerified = userDetails['isVerified'];

          return Column(
            children: [
              Padding(
                padding:  EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            height: 124.h,
                            width: 124.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade100,
                              border: Border.all(color: Colors.black12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(222),
                              child: userName == 'PSM Official'
                                  ? Image.asset(
                                      'assets/images/appLogo.png',
                                      fit: BoxFit.cover,
                                    )
                                  : userImage.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 66.sp,
                                        )
                                      : Image.network(
                                          userImage,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                        ),
                            ),
                          ),
                          Positioned(
                            bottom: 8.h,
                            right: 8.w,
                            child: Icon(
                              Icons.verified,
                              color: isVerified == false
                                  ? Colors.grey.shade600
                                  : Colors.blueAccent,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            userName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        FirebaseAuth.instance.currentUser != null &&
                                userId == FirebaseAuth.instance.currentUser!.uid
                            ? Text(
                                ' (You)',
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: kPrimaryColor,
                                ),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          uniqueId,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                       isAdmin||tag=='user'
                        ? SizedBox.shrink()
                        :   Text(
                          ' ($tag)',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: kPrimaryColor,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                     SizedBox(
                      height: 8.h,
                    ),
                    isAdmin
                        ? SizedBox.shrink()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  Get.to(() => FollowersFollowingsScreen(
                                        isFollowers: true,
                                        userId: widget.userId,
                                        onBackPressed: () {
                                          userController.fetchUserProfile(
                                              widget.userId,
                                              FirebaseAuth
                                                  .instance.currentUser!.uid);
                                          userController
                                              .fetchRealTimeData(widget.userId);
                                        },
                                      ));
                                },
                                child: Column(
                                  children: [
                                    Obx(() => Text(
                                          userController.followersCount.value
                                              .toString(),
                                          style: GoogleFonts.inter(
                                              color: Colors.white,
                                              // color: ,
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
                                        userId: widget.userId,
                                        onBackPressed: () {
                                          userController.fetchUserProfile(
                                              widget.userId,
                                              FirebaseAuth
                                                  .instance.currentUser!.uid);
                                          userController
                                              .fetchRealTimeData(widget.userId);
                                        },
                                      ));
                                },
                                child: Column(
                                  children: [
                                    Obx(() => Text(
                                          userController.followingCount.value
                                              .toString(),
                                          style: GoogleFonts.inter(
                                              color: Colors.white,
                                              // color: ,-
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
                              )
                            ],
                          ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Call Us Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 6.h, horizontal: 16.w),
                            child: GestureDetector(
                              onTap: () {
                                controller.makeCall(phoneNumber);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/call.svg',
                                    color: kblack,
                                    width: 17,
                                  ),
                                  Text(
                                    'Call us',
                                    style: GoogleFonts.inter(
                                      // color: Colors.white,
                                      color: kblack,

                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),

                          // WhatsApp Button
                          Container(
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 6.h, horizontal: 16.w),
                            child: GestureDetector(
                              onTap: () {
                                controller.openWhatsApp(phoneNumber);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/wapp.svg',
                                    width: 17,
                                  ),
                                  Text(
                                    'Whatsapp',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),

                          // Follow/Unfollow Button
                          widget.userId == '9jQGdhx4zQfEgWfmLjHHlx6Xq0r2'
                              ? SizedBox.shrink()
                              : widget.userId ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? SizedBox.shrink()
                                  : Obx(
                                      () => GestureDetector(
                                        onTap: userController.isLoading.value
                                            ? null // Disable tap when loading
                                            : () {
                                                userController.isLoading.value =
                                                    true; // Disable button

                                                if (userController
                                                    .isFollowing.value) {
                                                  userController
                                                      .unfollowUser(
                                                          widget.userId,
                                                          currentUserId)
                                                      .then((_) {
                                                    fetchUserDetails(
                                                        widget.userId);
                                                    userController
                                                        .fetchRealTimeData(
                                                            widget.userId);
                                                    userController
                                                            .isLoading.value =
                                                        false; // Re-enable button
                                                  });
                                                } else {
                                                  userController
                                                      .followUser(
                                                          widget.userId,
                                                          currentUserId,
                                                          currentUserName,
                                                          currentUserPhone)
                                                      .then((_) {
                                                    fetchUserDetails(
                                                        widget.userId);
                                                    userController
                                                        .fetchRealTimeData(
                                                            widget.userId);
                                                    userController
                                                            .isLoading.value =
                                                        false; // Re-enable button
                                                  });
                                                }
                                              },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                userController.isFollowing.value
                                                    ? Colors.grey.shade300
                                                    : const Color(0xffEE1D52),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.h, horizontal: 16.w),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                userController.isFollowing.value
                                                    ? Icons.person_remove
                                                    : Icons.person_add,
                                                color: userController
                                                        .isFollowing.value
                                                    ? Colors.black
                                                    : Colors.white,
                                                size: 19.h,
                                              ),
                                              Text(
                                                userController.isFollowing.value
                                                    ? 'Unfollow'
                                                    : 'Follow',
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 10,
                                                  color: userController
                                                          .isFollowing.value
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

// const SizedBox(width: 5),

                          // // Chat Button (Active)
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: const Color(0xFF37A5FF),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       // showDialog for unavailable feature
                          //       showDialog(
                          //         context: context,
                          //         builder: (context) => CommonDialog(
                          //           title: 'Oops!',
                          //           message: 'This feature is unavailable right now!',
                          //           icon: Icons.not_accessible_sharp,
                          //           iconColor: kPrimaryColor,
                          //           negativeButtonText: 'Ok',
                          //           positiveButtonText: 'ok',
                          //           onPositiveButtonPressed: () async {
                          //             Navigator.of(context).pop();
                          //           },
                          //         ),
                          //       );
                          //     },
                          //     child: Column(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         SvgPicture.asset(
                          //           'assets/icons/chat.svg',
                          //           width: 16,
                          //         ),
                          //         const SizedBox(
                          //           height: 4,
                          //         ),
                          //         Text(
                          //           'Chat',
                          //           style: GoogleFonts.inter(
                          //             color: Colors.white,
                          //             fontSize: 10.sp,
                          //             fontWeight: FontWeight.w600,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        height: 40,
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          labelPadding: EdgeInsets.zero,
                          controller: tabController,
                          indicatorColor: Colors.transparent,
                          tabs: [
                            TabBarItem(
                              isProfile: true,
                              title: 'PANELS',
                              unSelectedColor: Color(0xFFD9D9D9),
                              isSelected: tabController.index == 0,
                            ),
                            TabBarItem(
                              isProfile: true,
                              title: 'INVERTERS',
                              unSelectedColor: Color(0xFFD9D9D9),
                              isSelected: tabController.index == 1,
                            ),
                            TabBarItem(
                              isProfile: true,
                              title: 'BATTERIES',
                              unSelectedColor: Color(0xFFD9D9D9),
                              isSelected: tabController.index == 2,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                          children: [
                            UserPostsList(
                                userId: widget.userId,
                                postType: 'userPanels',
                                isVerified: isVerified,
                                phoneNumber: userDetails['phoneNumber'] ?? 'Na',
                                userImage: userImage),
                            UserPostsList(
                                userId: widget.userId,
                                isVerified: isVerified,
                                postType: 'userInverters',
                                phoneNumber: phoneNumber,
                                userImage: userImage),
                            UserPostsList(
                                userId: widget.userId,
                                postType: 'userLithium',
                                isVerified: isVerified,
                                phoneNumber: phoneNumber,
                                userImage: userImage),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class UserPostsList extends StatelessWidget {
  final String userId;
  final String postType;
  final String phoneNumber;
  final String userImage;
  final bool isVerified;

  UserPostsList({
    Key? key,
    required this.userId,
    required this.postType,
    required this.phoneNumber,
    required this.userImage,
    required this.isVerified,
  }) : super(key: key);

  Stream<QuerySnapshot> fetchPosts(String postType) {
    final userPhone = phoneNumber.isEmpty ? '92' : phoneNumber;
    return FirebaseFirestore.instance
        .collection('psmPosts')
        .doc(userPhone)
        .collection(postType)
        .where('userId', isEqualTo: userId)
        .where('isShowing', isEqualTo: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: fetchPosts(postType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: kPrimaryColor,
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text(
            'Error: ${snapshot.error}',
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.red),
          ));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No data found!',
              style: GoogleFonts.kameron(
                  color: kPrimaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500),
            ),
          );
        }

        final posts = snapshot.data!.docs;
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final data = posts[index];
            String formatDateString(String deliveryDate) {
              try {
                DateTime parsedDate =
                    DateFormat('dd-MM-yyyy').parse(deliveryDate);

                return DateFormat('d MMM').format(parsedDate);
              } catch (e) {
                return 'Invalid date';
              }
            }

            String formatPrice(dynamic price) {
              if (price is num) {
                String formattedPrice = price.toStringAsFixed(2);
                if (formattedPrice.contains('.')) {
                  formattedPrice =
                      formattedPrice.replaceAll(RegExp(r'\.?0+$'), '');
                }
                return formattedPrice;
              }
              return 'Invalid price';
            }

            String price = postType == 'userLithium' ||
                    postType == 'userInverters'
                ? '${double.tryParse(data['price'].toString())?.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k'
                : formatPrice(data['price']);
            // final String price =
            //     '${double.tryParse(data['price'].toString()).toString()}k';
            String formattedDate =
                '${data['availability']} ${formatDateString(data['deliveryDate'])}';
            return InkWell(
              onTap: () {
                Get.to(() => BiddingScreen(
                      phoneNumber: data['userNumber'],
                      userId: data['userId'],
                      // isSold: data['sold'],
                      itemId: data['itemId'],
                      // userName: data['userName'],
                      // userImage: data['userImage'],
                      // userType: data['type'],
                      // itemName: data['name'],
                      // itemSize: data['size'],
                      // itemAvailability: data['availability'],
                      // itemPrice: postType == 'userLithium' ||
                      //         postType == 'userInverters'
                      //     ? price
                      //     : double.tryParse(data['price'].toString())
                      //         .toString(),
                      // formattedDate: formattedDate,
                      // location: data['location'],
                      // quantity: data['quantity'],
                      // postedTime: data['createdAt'],
                      // tokenMoney: data['tokenMoney'],
                      subCollection: postType,
                    ));
              },
              child: Card(
                color: data['sold'] || data['bought'] == true
                    ? Colors.white12
                    : const Color(0xFFEBEBEB),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                elevation: 2,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${data['name']}(${data['model']})',
                              // 'YINCLI N TYPE BIFACIAL',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF141316),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Row(
                              // mainAxisAlignment:
                              //     MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF2E5FFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: Text(
                                    postType == 'userLithium' ||
                                            postType == 'userInverters'
                                        ? '${data['quantity']} PCS'
                                        : '${data['quantity']} ${data['size']}',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 7.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: ShapeDecoration(
                                    color: kPrimaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: Text(
                                    data['location'],
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 7.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: ShapeDecoration(
                                    color: data['availability'] == 'Delivery'
                                        ? Colors.orange.shade500
                                        : const Color(0xFFFF2E2E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: data['availability'] == 'Delivery'
                                      ? Text(
                                          formattedDate,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 7.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : Text(
                                          data['availability'],
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 7.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      // const SizedBox(
                      //   width: 6,
                      // ),
                      Column(
                        children: [
                          Text(
                            price,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF141316),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: ShapeDecoration(
                              color: data['type'] == 'Seller'
                                  ? kPrimaryColor
                                  : const Color(0xFFFF2E2E),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                            child: Text(
                              data['type'],
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      data['bought'] == true
                          ? Icon(
                              Icons.production_quantity_limits_rounded,
                              color: kPrimaryColor,
                            )
                          : data['sold'] == true
                              ? Image.asset(
                                  'assets/images/sold.png',
                                  width: 32.w,
                                )
                              : Column(
                                  children: [
                                    const Icon(
                                      Icons.watch_later_outlined,
                                      color: kPrimaryColor,
                                    ),
                                    CountdownTimer(
                                        createdAt: data['createdAt'].toDate()),
                                  ],
                                )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
