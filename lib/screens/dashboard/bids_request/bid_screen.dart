import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/bidding_controller.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/panels/panel_detail_screen.dart';

class UserBidsScreen extends StatefulWidget {
  UserBidsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UserBidsScreen> createState() => _UserBidsScreenState();
}

class _UserBidsScreenState extends State<UserBidsScreen> {
  final BiddingController controller = Get.put(BiddingController());
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    controller.fetchUserBids(FirebaseAuth.instance.currentUser!.uid);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bid Requests',
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(
                color: kPrimaryColor,
              ))
            : controller.userBids.isEmpty
                ? Center(
                    child: Text(
                    'No bid request found.',
                    style: GoogleFonts.kameron(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryColor),
                  ))
                : ListView.builder(
                    itemCount: controller.userBids.length,
                    itemBuilder: (context, index) {
                      final bid = controller.userBids[index];
                      return InkWell(
                        child: Card(
                          color: Colors.grey.shade100,
                          margin: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          child: ListTile(
                            leading: Container(
                              height: 52.h,
                              width: 52.w,
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  shape: BoxShape.circle),
                              child: bid['userImage'] != null &&
                                      bid['userImage'].isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(66),
                                      child: Image.network(
                                        bid['userImage'],
                                        fit: BoxFit.cover,
                                      ))
                                  : Icon(Icons.person_2_outlined),
                            ),
                            title: Text(
                              bid['userName'],
                              style: GoogleFonts.inter(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bids: ${bid['bid']}',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Item name: ${bid['itemName']}',
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Phone: ${bid['phoneNumber']}',
                                  style: GoogleFonts.inter(
                                      color: kPrimaryColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => BiddingScreen(
                                  phoneNumber:
                                      profileController.userPhone.value,
                                  userId: bid['ownerId'],
                                  itemId: bid['itemId'],
                                  subCollection: bid['subCollection']));
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
