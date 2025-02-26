import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/post/my_post_controller.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:solar_market/screens/dashboard/my_posts/edit_post.dart';
import 'package:solar_market/widgets/tabbar_item.dart';

import '../panels/panel_detail_screen.dart';

class UsersPostScreen extends StatefulWidget {
  final String postType;
  final String appBarText;
  final String categoryType;

  UsersPostScreen({
    Key? key,
    required this.postType,
    required this.categoryType,
    required this.appBarText,
  }) : super(key: key);

  @override
  State<UsersPostScreen> createState() => _UsersPostScreenState();
}

class _UsersPostScreenState extends State<UsersPostScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late TextEditingController searchController;

  final MyPostsController controller = Get.put(MyPostsController());
  final ProfileController profileController = Get.put(ProfileController());

  String sortOrder = 'asc'; // Default sort order: ascending

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    searchController = TextEditingController();
    tabController.addListener(() {
      setState(() {});
    });
    _fetchPosts();
  }

  @override
  void dispose() {
    searchController.dispose();
    tabController.dispose();
    super.dispose();
  }

  void _fetchPosts() {
    controller.fetchUserPosts(
      profileController.userPhone.value,
      widget.postType,
    );
  }

  void _sortPosts(List<Map<String, dynamic>> posts) {
    if (sortOrder == 'asc') {
      posts.sort((a, b) {
        return (num.tryParse(a['price'].toString()) ?? 0)
            .compareTo(num.tryParse(b['price'].toString()) ?? 0);
      });
    } else {
      posts.sort((a, b) {
        return (num.tryParse(b['price'].toString()) ?? 0)
            .compareTo(num.tryParse(a['price'].toString()) ?? 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.fetchUserPosts(
      profileController.userPhone.value,
      widget.postType,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.appBarText,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 19.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 42.h,
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {});
                    },
                    style: GoogleFonts.inter(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search posts...',
                      hintStyle: GoogleFonts.inter(
                          color: Colors.grey.shade500, fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: kPrimaryColor),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.cancel,
                                  color: Colors.grey.shade500),
                              onPressed: () {
                                searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      isDense: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: kPrimaryColor, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1.0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort by price:',
                      style: GoogleFonts.inter(fontSize: 13.sp),
                    ),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          value: sortOrder,
                          items: [
                            DropdownMenuItem(
                              value: 'asc',
                              child: Text(
                                'Low to High',
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'desc',
                              child: Text(
                                'High to Low',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                sortOrder = value;
                              });
                            }
                          },
                          style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            height: 40,
            child: TabBar(
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.zero,
              controller: tabController,
              indicatorColor: Colors.transparent,
              tabs: [
                TabBarItem(
                  isProfile: false,
                  title: 'Active Posts',
                  unSelectedColor: Color(0xFFD9D9D9),
                  isSelected: tabController.index == 0,
                ),
                TabBarItem(
                  isProfile: false,
                  title: 'Inactive Posts',
                  unSelectedColor: Color(0xFFD9D9D9),
                  isSelected: tabController.index == 1,
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }

              return TabBarView(
                controller: tabController,
                children: [
                  _buildPostsList(
                    context,
                    controller.activePosts,
                    true,
                    widget.postType,
                  ),
                  _buildPostsList(
                    context,
                    controller.oldPosts,
                    false,
                    widget.postType,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, List<Map<String, dynamic>> posts,
      bool isActive, String postType) {
    final Map<String, dynamic> soldData = {
      'sold': true,
      'bidding': 'done',
    };
    final Map<String, dynamic> unSoldData = {
      'sold': false,
      // 'bidding': 'done',
    };

    if (posts.isEmpty) {
      return Center(
          child: Text(
        isActive ? 'No active posts found.' : 'No old posts found.',
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ));
    }

    String query = searchController.text.toLowerCase();
    List<Map<String, dynamic>> filteredPosts = posts
        .where((post) =>
            post['name'].toLowerCase().contains(query) ||
            post['brand'].toLowerCase().contains(query) ||
            // post['price'].toLowerCase().contains(query) ||
            post['model'].toLowerCase().contains(query) ||
            post['location'].toLowerCase().contains(query))
        .toList();

    // Sort posts by price
    _sortPosts(filteredPosts);

    if (filteredPosts.isEmpty) {
      return Center(
        child: Text(
          isActive ? 'No active posts found.' : 'No old posts found.',
          style:
              GoogleFonts.kameron(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
      );
    }
    return ListView.builder(
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        var data = filteredPosts[index];
        String formatDateString(String deliveryDate) {
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

        final String price =
            '${double.tryParse(data['price'].toString())?.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}k';

        String formattedDate =
            '${data['availability']} ${formatDateString(data['deliveryDate'])}';
        return GestureDetector(
          onTap: () {
            isActive
                ? Get.to(() => BiddingScreen(
                      phoneNumber: profileController.userPhone.value,
                      userId: data['userId'],
                      itemId: data['itemId'],
                      subCollection: postType,
                      myPost: true,
                    ))
                : null;
          },
          child: Card(
            color: data['sold'] == true || data['bought'] == true
                ? Colors.white12
                : const Color(0xFFEBEBEB),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data['name']}(${data['model']})',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF141316),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: ShapeDecoration(
                                color: const Color(0xFF2E5FFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: Text(
                                postType == 'userLithium' ||
                                        postType == 'userInverters'
                                    ? '${data['quantity']} PCS'
                                    : '${data['quantity']} ${data['size']}',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 6.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: ShapeDecoration(
                                color: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: Text(
                                data['location'],
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 6.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: ShapeDecoration(
                                color: data['availability'] == 'Delivery'
                                    ? Colors.orange.shade500
                                    : const Color(0xFFFF2E2E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                              ),
                              child: data['availability'] == 'Delivery'
                                  ? Text(
                                      formattedDate,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 6.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : Text(
                                      data['availability'],
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 6.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                            

                          ],
                        )
                      ],
                    ),
                  ),

                  // const SizedBox(
                  //   width: 6,
                  // ),
                  Column(
                    children: [
                      Text(
                        postType == 'userLithium' || postType == 'userInverters'
                            ? price
                            : formatPrice(data['price']),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF141316),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: ShapeDecoration(
                          color: data['type'] == 'Seller'
                              ? kPrimaryColor
                              : const Color(0xFFFF2E2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          data['type'],
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  data['sold'] == true
                      ? Image.asset(
                          'assets/images/sold.png',
                          width: 32.w,
                        )
                      : SizedBox.shrink(),
                  data['bought'] == true
                      ? Icon(
                          Icons.production_quantity_limits_rounded,
                          color: kPrimaryColor,
                        )
                      : SizedBox.shrink(),

                  PopupMenuButton<String>(
                    color: Colors.white,
                    iconColor: kPrimaryColor,
                    onSelected: (value) {
                      if (value == 'Repost') {
                        controller.repostPost(profileController.userPhone.value,
                            data, widget.postType);
                      } else if (value == 'Delete') {
                        controller.deletePost(profileController.userPhone.value,
                            data['itemId'], widget.postType);
                      } else if (value == 'Sold') {
                        controller.updaetToSold(
                            profileController.userPhone.value,
                            data['itemId'],
                            soldData,
                            widget.postType);
                      } else if (value == 'Unsold') {
                        controller.updaetToUnSold(
                            profileController.userPhone.value,
                            data['itemId'],
                            unSoldData,
                            widget.postType);
                      } else if (value == 'Bought') {
                        controller.updaetToBought(
                            profileController.userPhone.value,
                            data['itemId'],
                            widget.postType);
                      } else if (value == 'Unbought') {
                        controller.updaetTounBought(
                            profileController.userPhone.value,
                            data['itemId'],
                            widget.postType);
                      }
                      _fetchPosts();
                    },
                    itemBuilder: (context) {
                      return [
                        if (!data['sold'] && !data['bought'])
                          PopupMenuItem(
                              value: 'Edit',
                              child: EditPostPage(
                                post: data,
                                postType: widget.postType,
                                categoryType: widget.categoryType,
                              )),
                        if (!data['sold'] &&
                            data['type'] ==
                                'Seller') // Show 'Sold' option for seller
                          PopupMenuItem(
                            value: 'Sold',
                            child: Text(
                              'Mark as Sold',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                        if (data['sold'] &&
                            data['type'] ==
                                'Seller') // Show 'Unsold' option for seller
                          PopupMenuItem(
                            value: 'Unsold',
                            child: Text(
                              'Mark as Unsold',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                        if (!data['bought'] &&
                            data['type'] ==
                                'Buyer') // Show 'Bought' option for buyer
                          PopupMenuItem(
                            value: 'Bought',
                            child: Text(
                              'Mark as Bought',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                        if (data['bought'] &&
                            data['type'] ==
                                'Buyer') // Show 'Unbought' option for buyer
                          PopupMenuItem(
                            value: 'Unbought',
                            child: Text(
                              'Mark as Unbought',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                        // if (data['type'] == 'Seller' &&
                        //     !data[
                        //         'sold']) // Show 'Repost' option for seller if not sold
                        if (!isActive)
                          PopupMenuItem(
                            value: 'Repost',
                            child: Text(
                              'Repost',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp, fontWeight: FontWeight.w500),
                            ),
                          ),
                        PopupMenuItem(
                          value: 'Delete',
                          child: Text(
                            'Delete',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ];
                    },
                  )

                  // PopupMenuButton<String>(
                  //   color: Colors.white,
                  //   iconColor: kPrimaryColor,
                  //   onSelected: (value) {
                  //     // Navigator.pop(context);
                  //     // if (value == 'Edit') {
                  //     //   // _showEditBottomSheet(context, data);
                  //     //    EditPostPage(post: data, postType: widget.postType);
                  //     // } else
                  //     if (value == 'Repost') {
                  //       controller.repostPost(profileController.userPhone.value,
                  //           data, widget.postType);
                  //     } else if (value == 'Delete') {
                  //       controller.deletePost(profileController.userPhone.value,
                  //           data['itemId'], widget.postType);
                  //     } else if (value == 'Sold') {
                  //       controller.updaetToSold(
                  //         profileController.userPhone.value,
                  //         data['itemId'],
                  //         soldData,
                  //         widget.postType,
                  //       );
                  //     } else if (value == 'Unsold') {
                  //       // Handle the unsold status update here
                  //       controller.updaetToUnSold(
                  //         profileController.userPhone.value,
                  //         data['itemId'],
                  //         unSoldData,
                  //         widget.postType,
                  //       );
                  //     }
                  //     _fetchPosts();
                  //   },
                  //   itemBuilder: (context) {
                  //     return [
                  //       if (!data['sold'])
                  //         PopupMenuItem(
                  //             value: 'Edit',
                  //             child: EditPostPage(
                  //               post: data,
                  //               postType: widget.postType,
                  //               categoryType: widget.categoryType,
                  //             )),
                  //       if (!isActive)
                  //         PopupMenuItem(
                  //             value: 'Repost',
                  //             child: Text(
                  //               'Repost',
                  //               style: GoogleFonts.inter(
                  //                   fontSize: 14.sp,
                  //                   fontWeight: FontWeight.w500),
                  //             )),
                  //       if (isActive && !data['sold'])
                  //         PopupMenuItem(
                  //           value: 'Sold',
                  //           child: Text(
                  //             'Mark as Sold',
                  //             style: GoogleFonts.inter(
                  //                 fontSize: 14.sp, fontWeight: FontWeight.w500),
                  //           ),
                  //         ),
                  //       if (data['sold'])
                  //         PopupMenuItem(
                  //           value: 'Unsold',
                  //           child: Text(
                  //             'Mark as Unsold',
                  //             style: GoogleFonts.inter(
                  //                 fontSize: 14.sp, fontWeight: FontWeight.w500),
                  //           ),
                  //         ),
                  //       PopupMenuItem(
                  //           value: 'Delete',
                  //           child: Text(
                  //             'Delete',
                  //             style: GoogleFonts.inter(
                  //                 fontSize: 14.sp, fontWeight: FontWeight.w500),
                  //           )),
                  //     ];
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
