import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/screens/dashboard/add_items/components/add_inverter.dart';
import 'package:solar_market/screens/dashboard/add_items/components/add_panel.dart';
import 'package:solar_market/widgets/backbutton.dart';
import 'package:solar_market/widgets/tabbar_item.dart';

import 'components/add_lithium.dart';

class AddProductScreen extends StatefulWidget {
  final int initialTabIndex;

  const AddProductScreen({super.key, this.initialTabIndex = 0});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    // Initialize the TabController with the initial index passed from the previous screen
    tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    // Listen for tab changes
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Get.height * .05),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                BackNavigatingButton(color: kblack),
                SizedBox(width: Get.width * .05),
                Text(
                  'New Listing',
                  style: GoogleFonts.inter(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: Get.height * .06,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(35),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.zero,
              controller: tabController,
              indicatorColor: Colors.transparent,
              tabs: [
                TabBarItem(
                  isProfile: false,
                  title: '+ Panel',
                  isSelected: tabController.index == 0,
                ),
                TabBarItem(
                  isProfile: false,
                  title: '+ Inverter',
                  isSelected: tabController.index == 1,
                ),
                TabBarItem(
                  isProfile: false,
                  title: '+ Battery',
                  isSelected: tabController.index == 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                AddPanel(),
                AddInverter(),
                AddLithium(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
