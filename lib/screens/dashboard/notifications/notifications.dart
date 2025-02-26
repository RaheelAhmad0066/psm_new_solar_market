import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/data_controller.dart';
import 'package:solar_market/screens/dashboard/panels/panel_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeAgo;

import '../detail_screens/user_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  DataController dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dataController
            .getNotification(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: kPrimaryColor),
            );
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'You have not any notification yet',
                textAlign: TextAlign.center,
                style: GoogleFonts.kameron(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: kPrimaryColor,
                ),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: snapshot.data?.docs.length ?? 0,
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index];
                DateTime date;
                try {
                  date = data.get('time').toDate();
                } catch (e) {
                  date = DateTime.now();
                }
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (data['isFollow'] == true) {
                          Get.to(() => UserDetailScreen(
                                userId: data['currentUserId'],
                                phoneNumber: data['phoneNumber'],
                              ));
                        } else {
                          Get.to(() => BiddingScreen(
                              phoneNumber: data['phoneNumber'],
                              userId: data['userId'],
                              itemId: data['itemId'],
                              subCollection: data['subCollection']));
                        }
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 5.h, horizontal: 12),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 15.h),
                        decoration: ShapeDecoration(
                          color: const Color(0xFFD6FFEB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.sp),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['userName'],
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    data['message'],
                                    style: GoogleFonts.inter(
                                      color: Colors.black,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    softWrap: true,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 12.w,
                            ),
                            Text(
                              timeAgo.format(date),
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                color: Color(0xFF2E5FFF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
