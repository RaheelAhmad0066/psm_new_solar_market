
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/lithium/fetch_lithium_controller.dart';

import 'package:solar_market/utils/auth_popup.dart';
import 'package:solar_market/utils/auth_service.dart';
import 'package:solar_market/widgets/drawer_widget.dart';

import '../../../controllers/data_controller.dart';
import '../../../widgets/common_banner_widget.dart';
import '../../../widgets/common_card.dart';
import '../add_items/add_product_screen.dart';
import '../notifications/notifications.dart';

class LithiumBatteryScreen extends StatefulWidget {
  const LithiumBatteryScreen({super.key});

  @override
  State<LithiumBatteryScreen> createState() => _LithiumBatteryScreenState();
}

class _LithiumBatteryScreenState extends State<LithiumBatteryScreen> {
  final DataController dataController = Get.put(DataController());



  @override
  Widget build(BuildContext context) {
    final FetchLithiumController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AuthService.isAuthenticated() ? const DrawerWidget() : null,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: kblack,
        centerTitle: true,
        title: Text(
          'Batteries',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                if (!AuthService.isAuthenticated()) {
                  AuthPopup.show(
                    context,
                  );
                } else {
                  Get.to(() => const AddProductScreen(
                        initialTabIndex: 2,
                      ));
                }
              },
              icon: const Icon(
                Icons.add,
                size: 32,
              )),
          Obx(() => InkWell(
              onTap: () {
                if (!AuthService.isAuthenticated()) {
                  AuthPopup.show(
                    context,
                  );
                } else {
                  dataController.markNotificationsAsRead();

                  Get.to(() => NotificationScreen());
                }
              },
              child: SvgPicture.asset(
                'assets/icons/notifications.svg',
                color: dataController.hasNewNotification.value
                    ? kPrimaryColor
                    : null,
              ))),
          const SizedBox(
            width: 14,
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 12.h),
            color: kblack,
            height: 112.h,
            child:    CommonBannerWidget(collectionName: 'batteryBanners'), // Panels
    ),
          SizedBox(
            height: 14.h,
          ),
          CommonCard(
            controller: controller,
            subCollection: 'userLithium',
            onRefresh: () async {
              await controller.fetchLithium();
            },
          )
        ],
      ),
    );
  }
}
