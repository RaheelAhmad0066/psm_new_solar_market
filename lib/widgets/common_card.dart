import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import '../constants.dart';
import '../screens/dashboard/panels/panel_detail_screen.dart';
import '../screens/dashboard/panels/timer.dart';
import '../screens/dashboard/profile/edit_profile_screen.dart';
import '../utils/auth_popup.dart';
import '../utils/auth_service.dart';
import '../utils/toas_message.dart';

class CommonCard extends StatefulWidget {
  final String subCollection;
  final Future<void> Function() onRefresh;
  final dynamic controller; // Add controller as a parameter

  CommonCard({
    required this.controller,
    required this.subCollection,
    required this.onRefresh, // Initialize controller in the constructor
  });

  @override
  State<CommonCard> createState() => _CommonCardState();
}

class _CommonCardState extends State<CommonCard> {
  ProfileController profileController = Get.put(ProfileController());
    final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 300) {
      setState(() {
        _showScrollToBottom = true;
      });
    } else {
      setState(() {
        _showScrollToBottom = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Expanded(
      child: Obx(() {
        if (widget.controller.errorMessage.value.isNotEmpty) {
          return Center(child: Text(widget.controller.errorMessage.value));
        }

        return Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.controller.brands.length,
                    itemBuilder: (context, index) {
                      final category = widget.controller.brands[index];
                      final isSelected =
                          widget.controller.selectedBrand.value == category;
            
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ChoiceChip(
                          side: BorderSide.none,
                          showCheckmark: false,
                          backgroundColor: const Color(0xFFD9D9D9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          selectedColor: kPrimaryColor,
                          label: Text(
                            category,
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF141316),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (isSelected) {
                            if (isSelected) {
                              widget.controller.filterByBrand(category);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (widget.controller.isLoading.value)
                  const Expanded(
                      child: Center(
                          child: CircularProgressIndicator(
                    color: kPrimaryColor,
                  )))
                else if (widget.controller.paginatedData.isEmpty)
                  Expanded(
                    child: Center(
                        child: Center(
                            child: Text(
                      'NO POST AVAILABLE FOR ${widget.controller.selectedBrand.value}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.kameron(
                          color: kPrimaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ))),
                  )
                else
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (scrollNotification) {
                        if (scrollNotification.metrics.pixels ==
                                scrollNotification.metrics.maxScrollExtent &&
                            !widget.controller.isLoadingMore.value) {
                          widget.controller.loadMoreItems();
                        }
                        return true;
                      },
                      child: RefreshIndicator(
                        backgroundColor: Colors.white,
                        color: kPrimaryColor,
                        onRefresh: () async {
                          widget.onRefresh(); // Call the original function
                          return Future
                              .value(); // Ensure a Future<void> is returned
                        },
                        child: ListView.builder(
                          physics: Platform.isIOS
                              ? ClampingScrollPhysics()
                              : AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                          itemCount: widget.controller.paginatedData.length +
                              (widget.controller.isLoadingMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == widget.controller.paginatedData.length &&
                                widget.controller.isLoadingMore.value) {
                              return Padding(
                                padding: EdgeInsets.all(8.r),
                                child: Center(
                                    child: SizedBox(
                                  child: SizedBox(
                                    height: 26.h,
                                    width: 26.w,
                                    child: CircularProgressIndicator(
                                      color: kPrimaryColor,
                                      strokeWidth: 2.w,
                                    ),
                                  ),
                                )),
                              );
                            }
            
                            final data = widget.controller.paginatedData[index];
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
                                  formattedPrice = formattedPrice.replaceAll(
                                      RegExp(r'\.?0+$'), '');
                                }
                                return formattedPrice;
                              }
                              return 'Invalid price';
                            }
            
                            final String price = NumberFormat.compactCurrency(
                              decimalDigits: 1,
                              symbol: '',
                            ).format(double.tryParse(data['price'].toString()));
            
                            bool isBought = data.toString().contains('bought')
                                ? data['bought']
                                : false;
            
                            String formattedDate =
                                '${data['availability']} ${formatDateString(data['deliveryDate'])}';
                            return InkWell(
                              onTap: () {
                                if (!AuthService.isAuthenticated()) {
                                  AuthPopup.show(context);
                                } else if (!profileController
                                    .isPhoneVerified.value) {
                                  MessageToast.showToast(
                                      msg:
                                          'Please verify your phone number before proceeding.');
                                  Get.to(() => EditProfileScreen());
                                } else {
                                  Get.to(() => BiddingScreen(
                                        phoneNumber: data['userNumber'],
                                        userId: data['userId'],
                                        itemId: data['itemId'],
                                        subCollection: widget
                                            .subCollection, // Use subCollection from data
                                      ));
                                }
                              },
                              child: Card(
                                color: data['sold'] == true || isBought == true
                                    ? Colors.white12
                                    : data['userName'] == 'PSM Official'
                                        ? Colors.amber[200]
                                        : const Color(0xFFEBEBEB),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                elevation: 2,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 10.h),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    '${data['name']} (${data['model']})',
                                                    style: GoogleFonts.inter(
                                                      color:
                                                          const Color(0xFF141316),
                                                      fontSize: isSmallScreen
                                                          ? 9.sp
                                                          : 11.sp,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    softWrap: true,
                                                  ),
                                                ),
                                                if (FirebaseAuth
                                                            .instance.currentUser !=
                                                        null &&
                                                    data['userId'] ==
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid)
                                                  Text(
                                                    '  (You)',
                                                    style: GoogleFonts.inter(
                                                      fontSize:
                                                          isSmallScreen ? 10 : 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: kPrimaryColor,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8.h,
                                            ),
                                            Wrap(
                                              spacing: 5.w,
                                              runSpacing: 5.h,
                                              children: [
                                                if (data['userId'] != null &&
                                                    (widget.controller
                                                            .userVerificationStatus
                                                            .containsKey(
                                                                data['userId']) ||
                                                        data['userName'] ==
                                                            'PSM Official'))
                                                  Icon(
                                                    Icons.verified,
                                                    color: (data['userName'] ==
                                                                'PSM Official' ||
                                                            widget.controller
                                                                        .userVerificationStatus[
                                                                    data[
                                                                        'userId']] ==
                                                                true)
                                                        ? Colors.blue
                                                        : Colors.grey,
                                                    size: isSmallScreen
                                                        ? 18.sp
                                                        : 22.sp,
                                                  ),
                                                Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: ShapeDecoration(
                                                    color: const Color(0xFF2E5FFF),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(40),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    widget.subCollection ==
                                                            'userPanels'
                                                        ? '${data['quantity']} ${data['size']}'
                                                        : '${data['quantity']} PCS',
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: isSmallScreen
                                                          ? 6.sp
                                                          : 7.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: ShapeDecoration(
                                                    color: kPrimaryColor,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(40),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    data['location'],
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: isSmallScreen
                                                          ? 6.sp
                                                          : 7.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: ShapeDecoration(
                                                    color: data['availability'] ==
                                                            'Delivery'
                                                        ? Colors.orange.shade500
                                                        : const Color(0xFFFF2E2E),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(40),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    data['availability'] ==
                                                            'Delivery'
                                                        ? formattedDate
                                                        : data['availability'],
                                                    style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: isSmallScreen
                                                          ? 6.sp
                                                          : 7.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                if (data['userName'] ==
                                                    'PSM Official')
                                                  Container(
                                                    margin:
                                                        EdgeInsets.only(left: 4.w),
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 4.w,
                                                        vertical: 5.h),
                                                    decoration: ShapeDecoration(
                                                      color: Colors.purple.shade500,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                40),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      "Today's Offer",
                                                      style: GoogleFonts.inter(
                                                        color: Colors.white,
                                                        fontSize: isSmallScreen
                                                            ? 6.sp
                                                            : 7.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                
                                                
                                                if (data['userId'] != null &&
                                                    (widget.controller.userRoles
                                                        .containsKey(
                                                            data['userId'])) &&
                                                    widget.controller.userRoles[
                                                            data['userId']] !=
                                                        'user')
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                        horizontal: 7.w,
                                                        vertical: 4.h),
                                                    decoration: BoxDecoration(
                                                      color: widget.controller
                                                                      .userRoles[
                                                                  data['userId']] ==
                                                              'Importer'
                                                          ? Colors.black
                                                          : widget.controller
                                                                          .userRoles[
                                                                      data[
                                                                          'userId']] ==
                                                                  'EPC'
                                                              ? Colors.orange
                                                              : Color(0xFF2E5FFF),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              44.r),
                                                    ),
                                                    child: Text(
                                                      widget.controller.userRoles[
                                                          data['userId']],
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
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: screenWidth * 0.01),
                                      Column(
                                        children: [
                                          Text(
                                            widget.subCollection == 'userLithium' ||
                                                    widget.subCollection ==
                                                        'userInverters'
                                                ? price
                                                : formatPrice(data['price']),
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF141316),
                                              fontSize:
                                                  isSmallScreen ? 12.sp : 14.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 9, vertical: 4),
                                            decoration: ShapeDecoration(
                                              color: data['type'] == 'Seller'
                                                  ? kPrimaryColor
                                                  : const Color(0xFFFF2E2E),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                            ),
                                            child: Text(
                                              data['type'],
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize:
                                                    isSmallScreen ? 7.sp : 8.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      isBought == true
                                          ? Icon(
                                              Icons
                                                  .production_quantity_limits_rounded,
                                              color: kPrimaryColor,
                                            )
                                          : data['sold'] == true
                                              ? Image.asset(
                                                  'assets/images/sold.png',
                                                  width:
                                                      isSmallScreen ? 25.w : 30.w,
                                                )
                                              : Column(
                                                  children: [
                                                    const Icon(
                                                      Icons.watch_later_outlined,
                                                      color: kPrimaryColor,
                                                    ),
                                                    CountdownTimer(
                                                      createdAt: data['createdAt']
                                                          .toDate(),
                                                    ),
                                                  ],
                                                ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),]),
                  if (_showScrollToBottom && widget.controller.hasMoreData.value)
  Positioned(
    bottom: MediaQuery.of(context).size.height * 0.011, 
    right: MediaQuery.of(context).size.width * 0.45,  
    child: SizedBox(
      height: 28.h,
      width: 28.w,
      child: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(66.r)
        ),
        tooltip: 'Scroll Down',
        mini: true,
        onPressed: () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: Icon(Icons.arrow_downward, color: Colors.white,size: 18.sp,),
      ),
    ),
  ),

              
            
          ],
        );
      }),
    );
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
