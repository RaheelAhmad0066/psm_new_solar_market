import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/screens/dashboard/add_items/components/dropdown.dart';
import 'package:solar_market/widgets/round_button.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../controllers/notifications.dart';
import '../utils/toas_message.dart';
import '../controllers/profile/profile_controller.dart';
import '../controllers/user_controller/user_controller.dart';

class ReportButton extends StatefulWidget {
  final String itemId;
  final String userId;
  final String phoneNumber;
  final String ownerName;

  ReportButton({
    Key? key,
    required this.itemId,
    required this.userId,
    required this.phoneNumber,
    required this.ownerName,
  }) : super(key: key);

  @override
  State<ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  final UserController userController = Get.put(UserController());

  final ProfileController profileController = Get.put(ProfileController());

  final List<String> reportSubjects = [
    'Fraud',
    'Incorrect Data',
    'Fake Profile',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showReportBottomSheet(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(4.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 6.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, color: Colors.white, size: 20.h),
            SizedBox(width: 4.h),
            Text(
              'Report',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showReportBottomSheet(BuildContext context) {
    TextEditingController reportController = TextEditingController();
    String? selectedSubject;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.w,
                right: 16.w,
                top: 16.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Report Post',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Dropdown.buildDropdownFieldAlt(
                      label: 'Reason',
                      hint: 'Select reason',
                      value: selectedSubject,
                      items: reportSubjects,
                      onChanged: (value) {
                        setModalState(() {
                          selectedSubject = value;
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: reportController,
                      maxLength: 250,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: Colors.black,
                      ),
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describe the issue...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black38)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.black26)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: RoundButton(
                          onPressed: () {
                            if (selectedSubject != null &&
                                reportController.text.trim().isNotEmpty) {
                              submitReport(
                                reportController.text.trim(),
                                widget.itemId,
                                widget.userId,
                                selectedSubject!,
                              );
                              Navigator.pop(context);
                            } else {
                              MessageToast.showToast(
                                  msg:
                                      'Please fill all fields before submitting.');
                            }
                          },
                          text: 'Submit'),
                    ),
                    SizedBox(height: 22.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void submitReport(String reportText, String postId, String reportedUserId,
      String subject) async {
    try {
      var uuid = const Uuid();
      var myId = uuid.v4();
      String reporterId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('reports').doc(myId).set({
        'postId': postId,
        'reportedUserId': reportedUserId,
        'reporterId': reporterId,
        'subject': subject,
        'reportText': reportText,
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('adminDetail')
          .doc('9jQGdhx4zQfEgWfmLjHHlx6Xq0r2')
          .get();

      if (adminSnapshot.exists) {
        String? fcmToken = adminSnapshot.data()?['fcmToken'];

        if (fcmToken != null && fcmToken.isNotEmpty) {
          LocalNotificationService.sendNotificationUsingApi(
            token: fcmToken,
            title: 'Report alert!',
            body:
                '${profileController.userName.value} has reported against ${widget.ownerName}',
            data: {
              'screen': 'userDetail',
              'phoneNumber': widget.phoneNumber,
              'userId': widget.userId,
            },
          );
        }
      }

      MessageToast.showToast(msg: 'Report submitted successfully');
    } catch (e) {
      MessageToast.showToast(msg: 'Failed to submit report');
    }
  }
}
