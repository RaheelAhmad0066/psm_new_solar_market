import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/bidding_controller.dart';
import 'package:solar_market/controllers/data_controller.dart';
import 'package:solar_market/controllers/notifications.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/detail_screens/user_detail_screen.dart';
import 'package:solar_market/screens/dashboard/panels/timer.dart';
import 'package:solar_market/utils/toas_message.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/panels/fetch_panels_controller.dart';
import '../../../controllers/user_controller/user_controller.dart';
import '../../../widgets/report_button.dart';
import '../followers/follower_screen.dart';

class BiddingScreen extends StatefulWidget {
  final String phoneNumber;
  final String userId;
  final String itemId;
  final bool? myPost;

  final String subCollection;

  BiddingScreen({
    Key? key,
    required this.phoneNumber,
    required this.userId,
    required this.itemId,
    required this.subCollection,
    this.myPost,
  }) : super(key: key);

  @override
  State<BiddingScreen> createState() => _BiddingScreenState();
}

class _BiddingScreenState extends State<BiddingScreen> {
  final BiddingController controller = Get.put(BiddingController());

  final ProfileController profileController = Get.put(ProfileController());
  final DataController dataController = Get.put(DataController());
  String? userName;
  String? fcmToken;
  String? image;
  String? uniqueId;
  String? tag;
  bool? isVerified;
  bool isLoading = true;
  int? minBidPrice;
  int? maxBidPrice;
  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    fetchBidPriceRange();
    fetchPostData();
  }

  Future<void> fetchUserDetails() async {
    String collection = widget.userId == '9jQGdhx4zQfEgWfmLjHHlx6Xq0r2'
        ? 'adminDetail'
        : 'pmsUsers';
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          userName = data['fullName'];
          fcmToken = data['fcmToken'];
          image = data['image'];
          uniqueId = data['uniqueId'];
          tag = data['tag'];
          isVerified = data['isVerified'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchBidPriceRange() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('BidPrice')
          .doc('1Q82KX3FyOqd6K1n4o6B')
          .get();
      if (doc.exists) {
        setState(() {
          minBidPrice = doc['minBidPrice'];
          maxBidPrice = doc['maxBidPrice'];
        });
      }
    } catch (error) {
      print(error);
    }
  }

  Map<String, dynamic>? postData;

  Future<void> fetchPostData() async {
    try {
      if (widget.myPost == true) {
        // Fetch the document directly by its itemId
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('psmPosts')
            .doc(widget.phoneNumber)
            .collection(widget.subCollection)
            .doc(widget.itemId)
            .get();

        if (doc.exists) {
          setState(() {
            postData = doc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Document not found');
        }
      } else {
        // Use where query to fetch the document
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('psmPosts')
            .doc(widget.phoneNumber)
            .collection(widget.subCollection)
            .where('itemId', isEqualTo: widget.itemId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;

          setState(() {
            postData = doc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Document not found');
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching post data: $e');
    }
  }

  final UserController userController = Get.put(UserController());
    final FetchPanelsController controller1 = Get.find();
  final CommentController commentController = Get.put(CommentController());
  final AuthController authController = Get.put(AuthController());
 final CommentController _commentController = Get.put(CommentController());
  final TextEditingController _commentControllerField = TextEditingController();
  String? _replyingTo;
  final TextEditingController commentControler = TextEditingController();
  final TextEditingController replyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
       final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;
    String currentUserName = profileController.userName.value;
    String currentUserimage = profileController.userImage.value;
    String currentUserPhone = profileController.userPhone.value;
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final bool isOwner = currentUserId == widget.userId;
    bool isAdmin = widget.userId == '9jQGdhx4zQfEgWfmLjHHlx6Xq0r2';

    print(widget.itemId);
    controller.fetchBidders(
      widget.itemId,
    );
    if (!isAdmin) {
      userController.fetchUserProfile(widget.userId, currentUserId);
      userController.fetchRealTimeData(widget.userId);
    }

    // print(widget.phoneNumber);
    // print(widget.subCollection);

    String formatDateString(String? deliveryDate) {
      if (deliveryDate == null || deliveryDate.isEmpty) return 'Invalid date';
      try {
        DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(deliveryDate);
        return DateFormat('d MMM').format(parsedDate);
      } catch (e) {
        return 'Invalid date';
      }
    }

    String formatPrice(dynamic price) {
      if (price is num) {
        String formattedPrice = price.toStringAsFixed(2);
        if (formattedPrice.contains('.')) {
          formattedPrice = formattedPrice.replaceAll(RegExp(r'\.?0+$'), '');
        }
        return formattedPrice;
      }
      return 'Invalid price';
    }

    String formattedDate =
        '${postData?['availability'] ?? 'N/A'} ${formatDateString(postData?['deliveryDate'])}';
    String price = formatPrice(postData?['price'] ?? 'N/A');
    String itemName = postData?['name'] ?? 'N/A';
// Timestamp? postedTime = postData?['createdAt'] as Timestamp?;
    Timestamp postedTime = postData?['createdAt'] ?? Timestamp.now();

    String location = postData?['location'] ?? 'N/A';
    String quantity = postData?['quantity'] ?? 'N/A';
    String itemSize = postData?['size'] ?? 'N/A';
    String tokenMoney = postData?['tokenMoney'] ?? 'N/A';
    String userType = postData?['type'] ?? 'N/A';
    String itemAvailability = postData?['availability'] ?? 'N/A';
    bool isSold = postData?['sold'] ?? false;
    bool isBought = postData?['bought'] ?? false;
    String itemPrice = widget.subCollection == 'userLithium' ||
            widget.subCollection == 'userInverters'
        ? '${double.tryParse(postData?['price'].toString() ?? '')?.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k'
        : price;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'View Post',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          isAdmin || widget.userId == FirebaseAuth.instance.currentUser!.uid
              ? SizedBox.shrink()
              : ReportButton(
                  itemId: widget.itemId,
                  userId: widget.userId,
                  ownerName: userName ?? '',
                  phoneNumber: widget.phoneNumber,
                ),
          SizedBox(
            width: 12.w,
          )
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 13.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Expanded( // Add Expanded to ensure the Row doesn't overflow
      child: Row(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => UserDetailScreen(
                      userId: widget.userId,
                      phoneNumber: widget.phoneNumber));
                },
                child: Container(
                  height: 66.h,
                  width: 66.w,
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
                        : image.toString().isEmpty
                            ? Icon(
                                Icons.person,
                                size: 46.sp,
                              )
                            : Image.network(
                                image.toString(),
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ));
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2.5.h,
                right: 2.5.w,
                child: Icon(
                  Icons.verified,
                  color: isVerified == false
                      ? Colors.grey.shade600
                      : Colors.blueAccent,
                  size: 19.sp,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 8.h,
          ),
          Expanded( // Add Expanded to ensure the text doesn't overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName.toString(),
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ),
                    FirebaseAuth.instance.currentUser != null &&
                            widget.userId ==
                                FirebaseAuth.instance.currentUser!.uid
                        ? Text(
                            ' (You)',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: kPrimaryColor,
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      uniqueId.toString(),
                      style: GoogleFonts.inter(
                        color: Colors.black87,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    isAdmin || tag == 'user'
                        ? SizedBox.shrink()
                        : Text(
                            ' ($tag)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: kPrimaryColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    SizedBox(
      width: 8.h,
    ),
    isAdmin
        ? SizedBox.shrink()
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  Get.to(() => FollowersFollowingsScreen(
                        isFollowers: true,
                        userId: widget.userId,
                        onBackPressed: () {
                          userController.fetchUserProfile(
                              widget.userId,
                              FirebaseAuth.instance.currentUser!.uid);
                          userController.fetchRealTimeData(widget.userId);
                        },
                      ));
                },
                child: Column(
                  children: [
                    Obx(() => Text(
                          userController.followersCount.value.toString(),
                          style: GoogleFonts.inter(
                              fontSize: 15.sp, fontWeight: FontWeight.w700),
                        )),
                    Text(
                      'Followers',
                      style: GoogleFonts.inter(
                          fontSize: 10.sp, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 8.h,
              ),
              InkWell(
                onTap: () {
                  Get.to(() => FollowersFollowingsScreen(
                        isFollowers: false,
                        userId: widget.userId,
                        onBackPressed: () {
                          userController.fetchUserProfile(
                              widget.userId,
                              FirebaseAuth.instance.currentUser!.uid);
                          userController.fetchRealTimeData(widget.userId);
                        },
                      ));
                },
                child: Column(
                  children: [
                    Obx(() => Text(
                          userController.followingCount.value.toString(),
                          style: GoogleFonts.inter(
                              fontSize: 15.sp, fontWeight: FontWeight.w700),
                        )),
                    Text(
                      'Following',
                      style: GoogleFonts.inter(
                          fontSize: 10.sp, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              )
            ],
          ),
  ],
), SizedBox(
                    height: 16.h,
                  ),
                  SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Call Us Button
                        Container(
                          decoration: BoxDecoration(
                            color: kblack,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 9.h, horizontal: 16.w),
                          child: GestureDetector(
                            onTap: () {
                              controller.makeCall(widget.phoneNumber);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/call.svg',
                                  width: 17,
                                ),
                                Text(
                                  ' Call us',
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

                        // WhatsApp Button
                        Container(
                          decoration: BoxDecoration(
                            color: kPrimaryColor,
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 9.h, horizontal: 16.w),
                          child: GestureDetector(
                            onTap: () {
                              controller.openWhatsApp(widget.phoneNumber);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/wapp.svg',
                                  width: 17,
                                ),
                                Text(
                                  ' Whatsapp',
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
                                                    .unfollowUser(widget.userId,
                                                        currentUserId)
                                                    .then((_) {
                                                  fetchPostData();
                                                  fetchUserDetails();
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
                                                  fetchPostData();
                                                  fetchUserDetails();
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
                                              BorderRadius.circular(5.w),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 9.h, horizontal: 16.w),
                                        child: Row(
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

                                            SizedBox(
                                              width: 4.w,
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
                  SizedBox(
                    height: 14.h,
                  ),
                  InkWell(
                    onTap: () {
                      Get.to(() => UserDetailScreen(
                          userId: widget.userId,
                          phoneNumber: widget.phoneNumber));
                    },
                    child: Card(
                      color: isSold || isBought == true
                          ? Colors.white12
                          : const Color(0xFFEBEBEB),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 1, vertical: 4),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 50.h,
                              width: 50.w,
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle),
                              child: image.toString().isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(66),
                                      child: Image.network(
                                        image.toString(),
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
                                      ))
                                  : Icon(Icons.person_2_outlined),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${postData?['name']}(${postData?['model']})' ?? '',
                                    // widget.itemName,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF141316),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  Row(
                                    // mainAxisAlignment:
                                    //     MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFF2E5FFF),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                        ),
                                        child: Text(
                                          widget.subCollection ==
                                                      'userLithium' ||
                                                  widget.subCollection ==
                                                      'userInverters'
                                              ? '${quantity} PCS'
                                              : '${quantity} ${itemSize}',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 7.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: ShapeDecoration(
                                          color: kPrimaryColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                        ),
                                        child: Text(
                                          location,
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 7.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(4.r),
                                        decoration: ShapeDecoration(
                                          color: itemAvailability == 'Delivery'
                                              ? Colors.orange.shade500
                                              : const Color(0xFFFF2E2E),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(40.r),
                                          ),
                                        ),
                                        child: itemAvailability == 'Delivery'
                                            ? Text(
                                                formattedDate,
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 7.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                            : Text(
                                                itemAvailability,
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 7.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                      ),
                                      if (widget != null &&
                                                    (controller1.userRoles
                                                        .containsKey(
                                                            widget.userId)) &&
                                                    controller1.userRoles[
                                                            widget.userId] !=
                                                        'user')
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 7.w,
                                                        vertical: 4.h),
                                                    decoration: BoxDecoration(
                                                      color: controller1.userRoles[
                                                                  widget.userId] ==
                                                              'Importer'
                                                          ? Colors.black
                                                          : controller1
                                                                          .userRoles[
                                                                     widget.userId] ==
                                                                  'EPC'
                                                              ? Colors.orange
                                                              : Color(0xFF2E5FFF),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              44.r),
                                                    ),
                                                    child: Text(
                                                      controller1.userRoles[
                                                          widget.userId]!,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: isSmallScreen
                                                            ? 6.sp
                                                            : 7.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),

                                    ],
                                  )
                                ],
                              ),
                            ),
                            
                            SizedBox(
                              width: 4.w,
                            ),
                            Column(
                              children: [
                                Text(
                                  widget.subCollection == 'userLithium' ||
                                          widget.subCollection ==
                                              'userInverters'
                                      ? '${double.tryParse(postData?['price'].toString() ?? '')?.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k'
                                      : itemPrice,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF141316),
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(
                                  height: 6.h,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 7.w, vertical: 4.h),
                                  decoration: ShapeDecoration(
                                    color: userType == 'Seller'
                                        ? kPrimaryColor
                                        : const Color(0xFFFF2E2E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                  child: Text(
                                    userType,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 6.w,
                            ),
                            isBought == true
                                ? Icon(
                                    Icons.production_quantity_limits_rounded,
                                    color: kPrimaryColor,
                                  )
                                : isSold == true
                                    ? Image.asset(
                                        'assets/images/sold.png',
                                        width: 32.w,
                                      )
                                    : SizedBox.shrink()
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 4.h,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tokenMoney == ''
                              ? 'Token Money: 0'
                              : 'Token Money: ${tokenMoney}',
                          style: GoogleFonts.inter(
                              // color: Colors.blue,
                              fontWeight: FontWeight.w500,
                              fontSize: 13.sp),
                        ),
                        Row(
                          children: [
                            // Text(
                            //   'Posted ',
                            //   style: GoogleFonts.inter(
                            //       color: const Color(0xFF00BF63),
                            //       fontWeight: FontWeight.w500,
                            //       fontSize: 13.sp),
                            // ),
                            CountdownTimer(createdAt: postedTime.toDate()),
                            // Text(
                            //   ' Remainng',
                            //   style: GoogleFonts.inter(
                            //       color: const Color(0xFF00BF63),
                            //       fontWeight: FontWeight.w500,
                            //       fontSize: 13.sp),
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  // Obx(() {
                  //   if (controller.isLoading.value) {
                  //     return const Center(
                  //       child: CircularProgressIndicator(
                  //         color: kPrimaryColor,
                  //       ),
                  //     );
                  //   }
                  //   if (isSold) {
                  //     return Center(
                  //       child: Text(
                  //         'This item is already sold.',
                  //         style: GoogleFonts.inter(
                  //           color: kPrimaryColor,
                  //           fontWeight: FontWeight.w500,
                  //           fontSize: 14.sp,
                  //         ),
                  //       ),
                  //     );
                  //   }
                  //   if (isBought) {
                  //     return Center(
                  //       child: Text(
                  //         'This item is already bought.',
                  //         style: GoogleFonts.inter(
                  //           color: kPrimaryColor,
                  //           fontWeight: FontWeight.w500,
                  //           fontSize: 14.sp,
                  //         ),
                  //       ),
                  //     );
                  //   }

                  //   if (isOwner) {
                  //     return SizedBox.shrink();
                  //   } else if (controller.userHasBid(currentUserId)) {
                  //     return Center(
                  //       child: Text(
                  //         'You have already placed a bid.',
                  //         style: GoogleFonts.inter(
                  //             color: kPrimaryColor,
                  //             fontWeight: FontWeight.w500,
                  //             fontSize: 14.sp),
                  //       ),
                  //     );
                  //   } else {
                  //     return Padding(
                  //       padding: const EdgeInsets.all(3.0),
                  //       child: Column(
                  //         children: [
                  //           TextField(
                  //             onChanged: (value) {
                  //               controller.bidAmount.value = value;
                  //             },
                  //             style: GoogleFonts.inter(fontSize: 14.sp),
                  //             inputFormatters: [
                  //               widget.subCollection == 'userPanels'
                  //                   ? FilteringTextInputFormatter.allow(
                  //                       RegExp(r'^\d*\.?\d*$'))
                  //                   : FilteringTextInputFormatter.digitsOnly,
                  //               widget.subCollection == 'userPanels'
                  //                   ? LengthLimitingTextInputFormatter(-1)
                  //                   : LengthLimitingTextInputFormatter(5),
                  //             ],
                  //             cursorColor: Colors.black,
                  //             decoration: InputDecoration(
                  //               contentPadding: const EdgeInsets.symmetric(
                  //                   vertical: 15, horizontal: 22),
                  //               enabledBorder: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(33),
                  //                 borderSide: const BorderSide(
                  //                     color: Color(0xFFECECEC)),
                  //               ),
                  //               focusedBorder: OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(33),
                  //                 borderSide:
                  //                     const BorderSide(color: Colors.black26),
                  //               ),
                  //               fillColor: const Color(0xFFECECEC),
                  //               filled: true,
                  //               hintStyle: GoogleFonts.inter(
                  //                 color: const Color(0xFF868686),
                  //                 fontSize: 13.sp,
                  //                 fontWeight: FontWeight.w400,
                  //               ),
                  //               hintText: 'Enter your bid',
                  //               suffixIcon: IconButton(
                  //                 icon: const Icon(Icons.send,
                  //                     color: kPrimaryColor),
                  //                 onPressed: () {
                  //                   if (controller.bidAmount.value.isEmpty) {
                  //                     MessageToast.showToast(
                  //                         msg: 'Please enter a valid bid.');
                  //                     return;
                  //                   }

                  //                   final double? bid = double.tryParse(
                  //                       controller.bidAmount.value);

                  //                   if (widget.subCollection == 'userPanels') {
                  //                     // Enforce min/max bid restriction for 'userPanels'
                  //                     if (bid == null ||
                  //                         bid < minBidPrice! ||
                  //                         bid > maxBidPrice!) {
                  //                       MessageToast.showToast(
                  //                         msg:
                  //                             'Bidding must be between $minBidPrice and $maxBidPrice.',
                  //                       );
                  //                       return;
                  //                     }
                  //                   }

                  //                   // Submit the bid
                  //                   controller.submitBid(
                  //                     itemId: widget.itemId,
                  //                     itemName: itemName,
                  //                     userName: currentUserName,
                  //                     userId: currentUserId,
                  //                     userImage: currentUserimage,
                  //                     phoneNumber: currentUserPhone,
                  //                     ownerNumber: widget.phoneNumber,
                  //                     itemPrice: itemPrice,
                  //                     subCollection: widget.subCollection,
                  //                     ownerId: widget.userId,
                  //                   );
                  //                   LocalNotificationService
                  //                       .sendNotificationUsingApi(
                  //                     title:
                  //                         'Bidding request from ${currentUserName}',
                  //                     body:
                  //                         'Received a bid on ${itemName}(Price: ${itemPrice})',
                  //                     data: {
                  //                       "screen": "bidding",
                  //                       "itemId": widget.itemId,
                  //                       "subCollection": widget.subCollection,
                  //                       "userId": widget.userId,
                  //                       "phoneNumber": widget
                  //                           .phoneNumber, // Pass phone number if needed
                  //                     },
                  //                     token: fcmToken,
                  //                   );

                  //                   dataController.createNotification(
                  //                     toSenderId: widget.userId.toString(),
                  //                     message:
                  //                         'sent you a bid on ${itemName}(Price: ${itemPrice})',
                  //                     itemId: widget.itemId,
                  //                     subCollection: widget.subCollection,
                  //                     userId: widget.userId,
                  //                     phoneNumber: widget.phoneNumber,
                  //                   );
                  //                 },
                  //               ),
                  //             ),
                  //             // keyboardType: TextInputType.number,
                  //             keyboardType:
                  //                 const TextInputType.numberWithOptions(
                  //                     decimal: true),
                  //           ),
                  //         ],
                  //       ),
                  //     );
                  //   }
                  // }),
                
                
                  const Divider(),
                 
                 Column(
        children: [
        
          
          // Display Comments and Replies
        Obx(() {
          return SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _commentController.comments.length,
              itemBuilder: (context, index) {
                final comment = _commentController.comments[index];
                return CommentWidget(
                  comment: comment,
                  onReply: (name) {
                    _replyingTo = name;
                    _commentControllerField.text = '@$name ';
                  },
                  replies: comment.replies,
                );
              },
            ),
          );
        }),


            Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
              Expanded(
                child: TextField(
                controller: _commentControllerField,
                decoration: InputDecoration(
                  hintText: _replyingTo != null ? 'Replying to $_replyingTo' : 'Write a comment...',
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.circular(12.0),
                ),
                child: IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  if (_commentControllerField.text.isNotEmpty) {
                  _commentController.addComment(
                    'User Name', // Replace with actual user name
                    'https://via.placeholder.com/150', // Replace with actual profile picture
                    _commentControllerField.text,
                    parentId: _replyingTo != null ? _replyingTo : null,
                  );
                  _commentControllerField.clear();
                  _replyingTo = null;
                  }
                },
                ),
              ),
              ],
            ),
            ),
        
      
    
       
      
      
        ],
      ),
    
                  SizedBox(
                    height: 11.h,
                  )
                ],
              ),
            ),
    );
  }
}



class Comment {
  String id;
  String name;
  String profilePicture;
  String message;
  String? parentId; // For replies
  DateTime timestamp;
  List<Comment> replies; // Add this field

  Comment({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.message,
    this.parentId,
    required this.timestamp,
    List<Comment>? replies, // Initialize replies
  }) : replies = replies ?? [];

  factory Comment.fromMap(Map<String, dynamic> data) {
    return Comment(
      id: data['id'],
      name: data['name'],
      profilePicture: data['profilePicture'],
      message: data['message'],
      parentId: data['parentId'],
      timestamp: data['timestamp'].toDate(),
      replies: data['replies'] != null
          ? (data['replies'] as List).map((reply) => Comment.fromMap(reply)).toList()
          : [], // Initialize replies if they exist
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profilePicture': profilePicture,
      'message': message,
      'parentId': parentId,
      'timestamp': timestamp,
      'replies': replies.map((reply) => reply.toMap()).toList(), // Include replies in the map
    };
  }
}

class CommentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var comments = <Comment>[].obs;

  @override
  void onInit() {
    fetchComments();
    super.onInit();
  }

  void fetchComments() {
    _firestore
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final allComments = snapshot.docs.map((doc) {
        return Comment.fromMap(doc.data());
      }).toList();

      // Group replies under their parent comments
      final parentComments = allComments.where((comment) => comment.parentId == null).toList();
      for (var comment in parentComments) {
        comment.replies = allComments.where((reply) => reply.parentId == comment.id).toList();
      }

      comments.assignAll(parentComments);
    });
  }

  void addComment(String name, String profilePicture, String message, {String? parentId}) {
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      profilePicture: profilePicture,
      message: message,
      parentId: parentId,
      timestamp: DateTime.now(),
    );

    _firestore.collection('comments').doc(comment.id).set(comment.toMap());
  }
}

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final Function(String) onReply;
  final List<Comment> replies;

  CommentWidget({
    required this.comment,
    required this.onReply,
    required this.replies,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
             CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  child: Icon(Icons.person,color: Colors.white,),
                  ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comment.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
            children: [
              Text(comment.message),
                 TextButton(
            onPressed: () => onReply(comment.name),
            child: Text('Reply',style: TextStyle(color: Colors.black,fontSize: 11,fontWeight: FontWeight.bold),),
          ),
            ],
          ),
                ],
              ),
            ],
          ),
        
       
        
    
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: replies.map((reply) {
                  return CommentWidget(
                    comment: reply,
                    onReply: onReply,
                    replies: reply.replies, // Pass the replies of the reply
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}