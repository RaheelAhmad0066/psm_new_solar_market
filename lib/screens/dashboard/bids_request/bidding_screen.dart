// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'package:solar_market/constants.dart';
// import 'package:solar_market/controllers/bidding_controller.dart';
// import 'package:solar_market/controllers/data_controller.dart';
// import 'package:solar_market/controllers/notifications.dart';
// import 'package:solar_market/controllers/profile/profile_controller.dart';
// import 'package:solar_market/screens/dashboard/detail_screens/user_detail_screen.dart';
// import 'package:solar_market/screens/dashboard/panels/timer.dart';
// import 'package:solar_market/utils/toas_message.dart';

// class BiddingScreen extends StatefulWidget {
//   final String phoneNumber;
//   final String userId;
//   final String itemId;
//   final String tokenMoney;
//   final String location;
//   final String quantity;
//   final String formattedDate;
//   // final String userName;
//   // final String userImage;
//   final String userType;
//   final String itemName;
//   final String itemSize;
//   final String itemPrice;
//   final String subCollection;
//   final bool isSold;
//   final Timestamp postedTime;
//   final String itemAvailability;
//   BiddingScreen({
//     Key? key,
//     required this.phoneNumber,
//     required this.userId,
//     required this.itemId,
//     required this.tokenMoney,
//     required this.location,
//     required this.quantity,
//     required this.formattedDate,
//     required this.userType,
//     required this.itemName,
//     required this.itemSize,
//     required this.itemPrice,
//     required this.subCollection,
//     required this.isSold,
//     required this.postedTime,
//     required this.itemAvailability,
//   }) : super(key: key);

//   @override
//   State<BiddingScreen> createState() => _BiddingScreenState();
// }

// class _BiddingScreenState extends State<BiddingScreen> {
//   final BiddingController controller = Get.put(BiddingController());

//   final ProfileController profileController = Get.put(ProfileController());
//   final DataController dataController = Get.put(DataController());
//   String? userName;
//   String? fcmToken;
//   String? image;
//   String? uniqueId;
//   bool? isVerified;
//   bool isLoading = true;
//   int? minBidPrice;
//   int? maxBidPrice;
//   @override
//   void initState() {
//     super.initState();
//     fetchUserDetails();
//     fetchBidPriceRange();
//   }

//   Future<void> fetchUserDetails() async {
//     String collection = widget.userId == '9jQGdhx4zQfEgWfmLjHHlx6Xq0r2'
//         ? 'adminDetail'
//         : 'pmsUsers';
//     try {
//       final userDoc = await FirebaseFirestore.instance
//           .collection(collection)
//           .doc(widget.userId)
//           .get();

//       if (userDoc.exists) {
//         final data = userDoc.data()!;
//         setState(() {
//           userName = data['fullName'];
//           fcmToken = data['fcmToken'];
//           image = data['image'];
//           uniqueId = data['uniqueId'];
//           isVerified = data['isVerified'];
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchBidPriceRange() async {
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('BidPrice')
//           .doc('1Q82KX3FyOqd6K1n4o6B')
//           .get();
//       if (doc.exists) {
//         setState(() {
//           minBidPrice = doc['minBidPrice'];
//           maxBidPrice = doc['maxBidPrice'];
//         });
//       }
//     } catch (error) {
//       print(error);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String currentUserName = profileController.userName.value;
//     String currentUserimage = profileController.userImage.value;
//     String currentUserPhone = profileController.userPhone.value;
//     String currentUserId = FirebaseAuth.instance.currentUser!.uid;
//     final bool isOwner = currentUserId == widget.userId;
//     print(widget.itemId);
//     controller.fetchBidders(
//       widget.itemId,
//     );
//     print(widget.phoneNumber);
//     print(widget.subCollection);
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           'View Post',
//           style: GoogleFonts.inter(
//             color: Colors.black,
//             fontSize: 19.sp,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         backgroundColor: Colors.white,
//       ),
//       body: isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                 color: kPrimaryColor,
//               ),
//             )
//           : Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Center(
//                     child: Column(
//                       children: [
//                         Stack(
//                           children: [
//                             GestureDetector(
//                                 onTap: () {
//                                   Get.to(() => UserDetailScreen(
//                                       userId: widget.userId,
//                                       phoneNumber: widget.phoneNumber));
//                                 },
//                                 child: Container(
//                                   height: 124,
//                                   width: 124,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: Colors.blue.shade100,
//                                     border: Border.all(color: Colors.black12),
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(222),
//                                     child: userName == 'PSM Official'
//                                         ? Image.asset(
//                                             'assets/images/appLogo.png',
//                                             fit: BoxFit.cover,
//                                           )
//                                         : image.toString().isEmpty
//                                             ? Icon(
//                                                 Icons.person,
//                                                 size: 66,
//                                               )
//                                             : Image.network(
//                                                 image.toString(),
//                                                 fit: BoxFit.cover,
//                                                 loadingBuilder: (context, child,
//                                                     loadingProgress) {
//                                                   if (loadingProgress == null) {
//                                                     return child;
//                                                   }
//                                                   return const Center(
//                                                       child:
//                                                           CircularProgressIndicator(
//                                                     color: Colors.white,
//                                                   ));
//                                                 },
//                                                 errorBuilder: (context, error,
//                                                     stackTrace) {
//                                                   return const Icon(
//                                                       Icons.error);
//                                                 },
//                                               ),
//                                   ),
//                                 )),
//                             Positioned(
//                               bottom: 8,
//                               right: 8,
//                               child: Icon(
//                                 Icons.verified,
//                                 color: isVerified == false
//                                     ? Colors.grey.shade600
//                                     : Colors.blueAccent,
//                                 size: 22,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(
//                           height: 12,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               userName.toString(),
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.inter(
//                                 color: Colors.black,
//                                 fontSize: 20.sp,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             FirebaseAuth.instance.currentUser != null &&
//                                     widget.userId ==
//                                         FirebaseAuth.instance.currentUser!.uid
//                                 ? Text(
//                                     ' (You)',
//                                     style: GoogleFonts.inter(
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w600,
//                                       color: kPrimaryColor,
//                                     ),
//                                   )
//                                 : SizedBox.shrink(),
//                           ],
//                         ),
//                         Text(
//                           uniqueId.toString(),
//                           style: GoogleFonts.inter(
//                             color: Colors.black,
//                             fontSize: 12.sp,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton(
//                           style:
//                               ElevatedButton.styleFrom(backgroundColor: kblack),
//                           onPressed: () {
//                             controller.makeCall(widget.phoneNumber);
//                           },
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/icons/call.svg',
//                                 width: 17,
//                               ),
//                               const SizedBox(
//                                 width: 4,
//                               ),
//                               Text(
//                                 'Call us',
//                                 style: GoogleFonts.inter(
//                                   color: Colors.white,
//                                   fontSize: 10.sp,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           )),
//                       SizedBox(
//                         width: 5,
//                       ),
//                       ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: kPrimaryColor),
//                           onPressed: () {
//                             controller.openWhatsApp(widget.phoneNumber);
//                           },
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(
//                                 'assets/icons/wapp.svg',
//                                 width: 17,
//                               ),
//                               const SizedBox(
//                                 width: 4,
//                               ),
//                               Text(
//                                 'Whatsapp',
//                                 style: GoogleFonts.inter(
//                                   color: Colors.white,
//                                   fontSize: 10.sp,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           )),
//                       // SizedBox(
//                       //   width: 5,
//                       // ),
//                       // ElevatedButton(
//                       //     style: ElevatedButton.styleFrom(
//                       //         backgroundColor: const Color(0xFF37A5FF)),
//                       //     onPressed: () {
//                       //       // controller.makeCall(phoneNumber);
//                       //       showDialog(
//                       //         context: context,
//                       //         builder: (context) => CommonDialog(
//                       //           title: 'Oops!',
//                       //           message:
//                       //               'This feature is unavailable right now!',
//                       //           icon: Icons.not_accessible_sharp,
//                       //           iconColor: kPrimaryColor,
//                       //           negativeButtonText: 'Ok',
//                       //           positiveButtonText: 'ok',
//                       //           onPositiveButtonPressed: () async {
//                       //             Navigator.of(context).pop();
//                       //           },
//                       //         ),
//                       //       );
//                       //     },
//                       //     child: Row(
//                       //       children: [
//                       //         SvgPicture.asset(
//                       //           'assets/icons/chat.svg',
//                       //           width: 16,
//                       //         ),
//                       //         const SizedBox(
//                       //           width: 4,
//                       //         ),
//                       //         Text(
//                       //           'Chat',
//                       //           style: GoogleFonts.inter(
//                       //             color: Colors.white,
//                       //             fontSize: 10.sp,
//                       //             fontWeight: FontWeight.w600,
//                       //           ),
//                       //         ),
//                       //       ],
//                       //     )),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 22,
//                   ),
//                   InkWell(
//                     onTap: () {
//                       Get.to(() => UserDetailScreen(
//                           userId: widget.userId,
//                           phoneNumber: widget.phoneNumber));
//                     },
//                     child: Card(
//                       color: widget.isSold == true
//                           ? Colors.white12
//                           : const Color(0xFFEBEBEB),
//                       margin: const EdgeInsets.symmetric(
//                           horizontal: 1, vertical: 4),
//                       elevation: 2,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 4, vertical: 10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Container(
//                               height: 52,
//                               width: 52,
//                               decoration: BoxDecoration(
//                                   color: Colors.blue.shade100,
//                                   shape: BoxShape.circle),
//                               child: image.toString().isNotEmpty
//                                   ? ClipRRect(
//                                       borderRadius: BorderRadius.circular(66),
//                                       child: Image.network(
//                                         image.toString(),
//                                         fit: BoxFit.cover,
//                                         loadingBuilder:
//                                             (context, child, loadingProgress) {
//                                           if (loadingProgress == null) {
//                                             return child;
//                                           }
//                                           return const Center(
//                                               child: CircularProgressIndicator(
//                                             color: Colors.white,
//                                           ));
//                                         },
//                                         errorBuilder:
//                                             (context, error, stackTrace) {
//                                           return const Icon(Icons.error);
//                                         },
//                                       ))
//                                   : Icon(Icons.person_2_outlined),
//                             ),
//                             SizedBox(
//                               width: 5.w,
//                             ),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     widget.itemName,
//                                     style: GoogleFonts.inter(
//                                       color: const Color(0xFF141316),
//                                       fontSize: 12.sp,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 8.h,
//                                   ),
//                                   Row(
//                                     // mainAxisAlignment:
//                                     //     MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Container(
//                                         padding: EdgeInsets.all(4.r),
//                                         decoration: ShapeDecoration(
//                                           color: const Color(0xFF2E5FFF),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(40),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           widget.subCollection ==
//                                                       'userLithium' ||
//                                                   widget.subCollection ==
//                                                       'userInverters'
//                                               ? '${widget.quantity} PCS'
//                                               : '${widget.quantity} ${widget.itemSize}',
//                                           style: GoogleFonts.inter(
//                                             color: Colors.white,
//                                             fontSize: 7.sp,
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 4.w,
//                                       ),
//                                       Container(
//                                         padding: EdgeInsets.all(4.r),
//                                         decoration: ShapeDecoration(
//                                           color: kPrimaryColor,
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(40),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           widget.location,
//                                           style: GoogleFonts.inter(
//                                             color: Colors.white,
//                                             fontSize: 7.sp,
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(
//                                         width: 5.w,
//                                       ),
//                                       Container(
//                                         padding: EdgeInsets.all(4.r),
//                                         decoration: ShapeDecoration(
//                                           color: widget.itemAvailability ==
//                                                   'Delivery'
//                                               ? Colors.orange.shade500
//                                               : const Color(0xFFFF2E2E),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(40.r),
//                                           ),
//                                         ),
//                                         child: widget.itemAvailability ==
//                                                 'Delivery'
//                                             ? Text(
//                                                 widget.formattedDate,
//                                                 style: GoogleFonts.inter(
//                                                   color: Colors.white,
//                                                   fontSize: 7.sp,
//                                                   fontWeight: FontWeight.w700,
//                                                 ),
//                                               )
//                                             : Text(
//                                                 widget.itemAvailability,
//                                                 style: GoogleFonts.inter(
//                                                   color: Colors.white,
//                                                   fontSize: 7.sp,
//                                                   fontWeight: FontWeight.w700,
//                                                 ),
//                                               ),
//                                       ),
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 4.w,
//                             ),
//                             Column(
//                               children: [
//                                 Text(
//                                   widget.itemPrice.toString(),
//                                   style: GoogleFonts.inter(
//                                     color: const Color(0xFF141316),
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   height: 6.h,
//                                 ),
//                                 Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 7.w, vertical: 4.h),
//                                   decoration: ShapeDecoration(
//                                     color: widget.userType == 'Seller'
//                                         ? kPrimaryColor
//                                         : const Color(0xFFFF2E2E),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(40),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     widget.userType,
//                                     style: GoogleFonts.inter(
//                                       color: Colors.white,
//                                       fontSize: 8.sp,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               width: 6,
//                             ),
//                             widget.isSold == true
//                                 ? Image.asset(
//                                     'assets/images/sold.png',
//                                     width: 32.w,
//                                   )
//                                 : SizedBox.shrink()
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(
//                     height: 6,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           widget.tokenMoney.isEmpty
//                               ? 'Token Money: 0'
//                               : 'Token Money: ${widget.tokenMoney}',
//                           style: GoogleFonts.inter(
//                               // color: Colors.blue,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 13.sp),
//                         ),
//                         Row(
//                           children: [
//                             // Text(
//                             //   'Posted ',
//                             //   style: GoogleFonts.inter(
//                             //       color: const Color(0xFF00BF63),
//                             //       fontWeight: FontWeight.w500,
//                             //       fontSize: 13.sp),
//                             // ),
//                             CountdownTimer(
//                                 createdAt: widget.postedTime.toDate()),
//                             Text(
//                               ' Remainng',
//                               style: GoogleFonts.inter(
//                                   color: const Color(0xFF00BF63),
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 13.sp),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Obx(() {
//                     if (controller.isLoading.value) {
//                       return const Center(
//                         child: CircularProgressIndicator(
//                           color: kPrimaryColor,
//                         ),
//                       );
//                     }
//                     if (widget.isSold) {
//                       return Center(
//                         child: Text(
//                           'This item is already sold.',
//                           style: GoogleFonts.inter(
//                             color: kPrimaryColor,
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14.sp,
//                           ),
//                         ),
//                       );
//                     }

//                     if (isOwner) {
//                       return SizedBox.shrink();
//                     } else if (controller.userHasBid(currentUserId)) {
//                       return Center(
//                         child: Text(
//                           'You have already placed a bid.',
//                           style: GoogleFonts.inter(
//                               color: kPrimaryColor,
//                               fontWeight: FontWeight.w500,
//                               fontSize: 14.sp),
//                         ),
//                       );
//                     } else {
//                       return Padding(
//                         padding: const EdgeInsets.all(3.0),
//                         child: Column(
//                           children: [
//                             TextField(
//                               onChanged: (value) {
//                                 controller.bidAmount.value = value;
//                               },
//                               style: GoogleFonts.inter(fontSize: 14.sp),
//                               inputFormatters: [
//                                 widget.subCollection == 'userPanels'
//                                     ? FilteringTextInputFormatter.allow(RegExp(
//                                         r'^\d*\.?\d*$'))
//                                     : FilteringTextInputFormatter
//                                         .digitsOnly,
//                                 widget.subCollection == 'userPanels'
//                                     ? LengthLimitingTextInputFormatter(
//                                         -1)
//                                     : LengthLimitingTextInputFormatter(
//                                         3),
//                               ],
//                               cursorColor: Colors.black,
//                               decoration: InputDecoration(
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 15, horizontal: 22),
//                                 enabledBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(33),
//                                   borderSide: const BorderSide(
//                                       color: Color(0xFFECECEC)),
//                                 ),
//                                 focusedBorder: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(33),
//                                   borderSide:
//                                       const BorderSide(color: Colors.black26),
//                                 ),
//                                 fillColor: const Color(0xFFECECEC),
//                                 filled: true,
//                                 hintStyle: GoogleFonts.inter(
//                                   color: const Color(0xFF868686),
//                                   fontSize: 13.sp,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                                 hintText: 'Enter your bid',
//                                 suffixIcon: IconButton(
//                                   icon: const Icon(Icons.send,
//                                       color: kPrimaryColor),
//                                   onPressed: () {
//                                     if (controller.bidAmount.value.isEmpty) {
//                                       MessageToast.showToast(
//                                           msg: 'Please enter a valid bid.');
//                                       return;
//                                     }

//                                     final double? bid = double.tryParse(
//                                         controller.bidAmount.value);

//                                     if (widget.subCollection == 'userPanels') {
//                                       // Enforce min/max bid restriction for 'userPanels'
//                                       if (bid == null ||
//                                           bid < minBidPrice! ||
//                                           bid > maxBidPrice!) {
//                                         MessageToast.showToast(
//                                           msg:
//                                               'Bidding must be between $minBidPrice and $maxBidPrice.',
//                                         );
//                                         return;
//                                       }
//                                     }

//                                     // Submit the bid
//                                     controller.submitBid(
//                                       itemId: widget.itemId,
//                                       itemName: widget.itemName,
//                                       userName: currentUserName,
//                                       userId: currentUserId,
//                                       userImage: currentUserimage,
//                                       phoneNumber: currentUserPhone,
//                                       ownerNumber: widget.phoneNumber,
//                                       itemPrice: widget.itemPrice,
//                                       subCollection: widget.subCollection,
//                                       ownerId: widget.userId,
//                                     );

//                                     LocalNotificationService
//                                         .sendNotificationUsingApi(
//                                       title:
//                                           'Bidding request from ${currentUserName}',
//                                       body:
//                                           'Received a bid on ${widget.itemName}(Price: ${widget.itemPrice})',
//                                       data: {"screen": "bidding"},
//                                       token: fcmToken,
//                                     );

//                                     dataController.createNotification(
//                                       toSenderId: widget.userId.toString(),
//                                       message:
//                                           'sent you a bid on ${widget.itemName}(Price: ${widget.itemPrice})',
//                                     );
//                                   },
//                                 ),
//                               ),
//                               keyboardType: TextInputType.number,
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//                   }),
//                   const SizedBox(height: 20),
//                   const Divider(),
//                   Text(
//                     'Bidders',
//                     style: GoogleFonts.inter(
//                         fontSize: 18.sp, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 6),
//                   Obx(() {
//                     if (controller.isLoading.value) {
//                       return const Center(
//                           child: CircularProgressIndicator(
//                         color: kPrimaryColor,
//                       ));
//                     }
//                     return Expanded(
//                       child: ListView.builder(
//                         itemCount: controller.bidders.length,
//                         itemBuilder: (context, index) {
//                           final bidder = controller.bidders[index];
//                           final String price =
//                               '${double.tryParse(bidder['bid'].toString())?.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';

//                           return InkWell(
//                             onTap: () {
//                               Get.to(() => UserDetailScreen(
//                                   userId: bidder['userId'],
//                                   phoneNumber: bidder['phoneNumber']));
//                               // print(bidder['phoneNumber']);
//                               // print(bidder['userId']);
//                             },
//                             child: Card(
//                                 color: const Color(0xFFEBEBEB),
//                                 margin: const EdgeInsets.symmetric(
//                                     horizontal: 2, vertical: 6),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Container(
//                                               height: 52,
//                                               width: 52,
//                                               decoration: BoxDecoration(
//                                                   color: Colors.blue.shade100,
//                                                   shape: BoxShape.circle),
//                                               child: bidder['userImage'] == ''
//                                                   ? Icon(
//                                                       Icons.person_2_outlined)
//                                                   : ClipRRect(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               66),
//                                                       child: Image.network(
//                                                         bidder['userImage'],
//                                                         fit: BoxFit.cover,
//                                                       ))),
//                                           const SizedBox(
//                                             width: 9,
//                                           ),
//                                           Text(
//                                             bidder['userName'],
//                                             textAlign: TextAlign.center,
//                                             style: GoogleFonts.inter(
//                                               color: const Color(0xFF141316),
//                                               fontSize: 14.sp,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                             horizontal: 22, vertical: 5),
//                                         decoration: BoxDecoration(
//                                             color: kPrimaryColor,
//                                             borderRadius:
//                                                 BorderRadius.circular(22)),
//                                         child: Text(
//                                           widget.subCollection == 'userPanels'
//                                               ? '${double.tryParse(bidder['bid'].toString())?.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}'
//                                               : price,
//                                           // bidder['bid'].toString(),
//                                           textAlign: TextAlign.center,
//                                           style: GoogleFonts.inter(
//                                             color: Colors.white,
//                                             fontSize: 13.sp,
//                                             fontWeight: FontWeight.w700,
//                                           ),
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 )),
//                           );
//                         },
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//     );
//   }
// }