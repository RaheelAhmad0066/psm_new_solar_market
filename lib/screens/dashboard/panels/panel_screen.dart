import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/data_controller.dart';
import 'package:solar_market/controllers/panels/fetch_panels_controller.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/add_items/add_product_screen.dart';
import 'package:solar_market/screens/dashboard/notifications/notifications.dart';
import 'package:solar_market/utils/auth_popup.dart';
import 'package:solar_market/utils/auth_service.dart';
import 'package:solar_market/widgets/common_card.dart';
import 'package:solar_market/widgets/drawer_widget.dart';

import 'package:http/http.dart' as http;

import '../../../widgets/common_banner_widget.dart';

class PanelScreen extends StatefulWidget {
  const PanelScreen({super.key});

  @override
  State<PanelScreen> createState() => _PanelScreenState();
}

class _PanelScreenState extends State<PanelScreen> {
  final FetchPanelsController controller = Get.put(FetchPanelsController());
  final ProfileController profileController = Get.put(ProfileController());
  final DataController dataController = Get.put(DataController());
  Future<double>? _dollarPriceFuture;

  @override
  void initState() {
    super.initState();
    _dollarPriceFuture = fetchDollarPrice();
  }

  Future<double> fetchDollarPrice() async {
    const url = 'https://api.exchangerate-api.com/v4/latest/USD';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['rates']['PKR'];
      } else {
        throw Exception('Failed to load dollar price');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final FetchPanelsController controller = Get.find();

    return Scaffold(
        backgroundColor: Colors.white,
        drawer: AuthService.isAuthenticated() ? const DrawerWidget() : null,
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: kblack,
          centerTitle: true,
          title: Image.asset(
            'assets/images/logo.png',
            height: 46,
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  if (!AuthService.isAuthenticated()) {
                    AuthPopup.show(
                      context,
                    );
                  } else {
                    Get.to(() => const AddProductScreen());
                  }
                },
                icon: const Icon(
                  Icons.add,
                  size: 32,
                )),
            Obx(() => InkWell(
                onTap: () {
                  if (!AuthService.isAuthenticated()) {
                    print("User is not authenticated");
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
        body: Column(children: [
          Container(
            decoration: const BoxDecoration(color: kblack),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<double>(
                        future: _dollarPriceFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              'Loading...',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return Text(
                              '${snapshot.data!.toStringAsFixed(2)} \$',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          } else {
                            return Text(
                              'Loading...',
                              style: GoogleFonts.inter(
                                color: Colors.red,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 9),
                        child: Image.asset(
                          'assets/images/bismillah.png',
                          height: 26,
                        ),
                      ),
                      Text(
                        DateFormat.MMMd().format(DateTime.now()),
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Container(
                  height: 100.h,
                  child: CommonBannerWidget(
                      collectionName: 'panelBanners'), // Panels
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          CommonCard(
            controller: controller,
            subCollection: 'userPanels',
            onRefresh: () async {
              await controller.fetchPanels();
            },
          )
        ]));
  }
}
