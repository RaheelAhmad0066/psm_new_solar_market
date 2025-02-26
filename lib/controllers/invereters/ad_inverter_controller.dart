import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/invereters/fetch_inverters_controller.dart';
import 'package:solar_market/screens/dashboard/dashboard_screen.dart';
import 'package:solar_market/screens/dashboard/profile/edit_profile_screen.dart';
import 'package:solar_market/utils/toas_message.dart';

import '../../screens/dashboard/profile/verify_profile_screen.dart';
import '../notifications.dart';
import '../profile/profile_controller.dart';

class AdInverterController extends GetxController {
  var isLoading = false.obs;
  ProfileController profileController = Get.put(ProfileController());
    final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxBool isPhoneVerified = false.obs;
    final FetchInvertersController invertersController = Get.find();

  @override
  void onInit() {
    super.onInit();
    checkPhoneVerificationStatus();
  }

  void checkPhoneVerificationStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('pmsUsers').doc(user.uid).get();
      if (userDoc.exists) {
        isPhoneVerified.value = userDoc['isPhoneVerified'] ?? false;
      } else {
        isPhoneVerified.value = false;
      }
    }
  }

  Future<void> addInverter(
      {required String userPhoneNumber,
      required Map<String, dynamic> inverterData,
      required BuildContext context}) async {
    try {
      isLoading.value = true;

      // Get current user
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        MessageToast.showToast(msg: 'User not logged in.');
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('pmsUsers')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        MessageToast.showToast(msg: 'User data not found.');
        return;
      }
   if (!isPhoneVerified.value) {
        MessageToast.showToast(msg: 'Please verify your phone number before posting.');
        Get.to(() => EditProfileScreen());
        return;
      }
      final userData = userDoc.data()!;
      final isVerified = userData['isVerified'] ?? false;

      // Check post count for the day
      final postCollection = FirebaseFirestore.instance
          .collection("psmPosts")
          .doc(userPhoneNumber)
          .collection("userInverters");

      final todayStart = DateTime.now().subtract(Duration(
        hours: DateTime.now().hour,
        minutes: DateTime.now().minute,
        seconds: DateTime.now().second,
      ));

      final postsQuery = await postCollection
          .where('createdAt', isGreaterThanOrEqualTo: todayStart)
          .get();

      if (!isVerified && postsQuery.docs.length >= 5) {
        MessageToast.showToast(
          msg: 'Unverified users can post up to 5 posts per day.',
        );
        Get.to(() => VerifyProfileScreen(
            profileStatus: profileController.profileStatus.value));
        return;
      }

      // Check for duplicate posts
      final duplicateQuery = await postCollection
          .where('type', isEqualTo: inverterData['type'])
          .where('brand', isEqualTo: inverterData['brand'])
          .where('name', isEqualTo: inverterData['name'])
          .where('model', isEqualTo: inverterData['model'])
          .where('quantity', isEqualTo: inverterData['quantity'])
          .where('price', isEqualTo: inverterData['price'])
          .where('location', isEqualTo: inverterData['location'])
          .where('availability', isEqualTo: inverterData['availability'])
          .where('tokenMoney', isEqualTo: inverterData['tokenMoney'])
          .get();

      if (duplicateQuery.docs.isNotEmpty) {
        MessageToast.showToast(
          msg: 'Duplicate post detected. This post has already been added.',
        );
        return;
      }

      DocumentReference mainDocRef = FirebaseFirestore.instance
          .collection("psmPosts")
          .doc(userPhoneNumber);

      await mainDocRef.set({"created_at": FieldValue.serverTimestamp()},
          SetOptions(merge: true));

      await postCollection.doc(DateTime.now().toString()).set(inverterData);
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('pmsUsers')
          .doc(user.uid)
          .get();
      List followers = userSnapshot['followers'];

      for (var follower in followers) {
        String? fcmToken = follower['fcmToken'];
        if (fcmToken != null) {
          LocalNotificationService.sendNotificationUsingApi(
            token: fcmToken,
            title: '${profileController.userName.value}',
            body:
                'added a new post of ${inverterData['name']}(${inverterData['price']}k)',
            data: {
              "screen": "bidding",
              "itemId": inverterData['itemId'],
              "subCollection": 'userInverters',
              "userId": user.uid,
              "phoneNumber": profileController
                  .userPhone.value, // Pass phone number if needed
            },
          );
        }
      }
      showSuccessPopup(context);

      Future.delayed(const Duration(seconds: 2), () {
        Get.offAll(() => Dashboard(initialTabIndex: 1));
        invertersController.fetchInverter();
      });
      // MessageToast.showToast(msg: 'Inverter added successfully!');
    } catch (error) {
      MessageToast.showToast(msg: 'Error adding panel: $error');
    } finally {
      isLoading.value = false;
    }
  }

  void showSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/icons/popup.svg'),
              SizedBox(height: 16.0),
              Text(
                'Posted',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: kPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'You have successfully posted your Inverter post.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.h),
              // RoundButton(
              //     onPressed: () {
              //       Navigator.of(context).pop();
              //     },
              //     text: 'Done'),
            ],
          ),
        );
      },
    );
  }
}
