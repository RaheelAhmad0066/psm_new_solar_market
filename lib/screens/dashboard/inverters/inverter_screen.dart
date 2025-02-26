import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/invereters/fetch_inverters_controller.dart';

import 'package:solar_market/utils/auth_popup.dart';
import 'package:solar_market/utils/auth_service.dart';
import 'package:solar_market/widgets/common_card.dart';
import 'package:solar_market/widgets/drawer_widget.dart';

import '../../../controllers/data_controller.dart';
import '../../../widgets/common_banner_widget.dart';
import '../add_items/add_product_screen.dart';
import '../notifications/notifications.dart';

class InverterScreen extends StatefulWidget {
  const InverterScreen({super.key});

  @override
  State<InverterScreen> createState() => _InverterScreenState();
}

class _InverterScreenState extends State<InverterScreen> {
  final DataController dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    final FetchInvertersController controller = Get.find();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AuthService.isAuthenticated() ? const DrawerWidget() : null,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: kblack,
        centerTitle: true,
        title: Text(
          'Inverters',
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
                        initialTabIndex: 1,
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
            child:
                CommonBannerWidget(collectionName: 'inverterBanners'), // Panels
          ),
          SizedBox(
            height: 14.h,
          ),
          CommonCard(
            controller: controller,
            subCollection: 'userInverters',
            onRefresh: () async {
              await controller.fetchInverter();
            },
          )
        ],
      ),
    );
  }
}
