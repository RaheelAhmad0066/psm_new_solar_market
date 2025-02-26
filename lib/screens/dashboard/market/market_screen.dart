import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/bidding_controller.dart';
import 'package:solar_market/screens/dashboard/market/all_users.dart';
import 'package:solar_market/utils/auth_service.dart';
import 'package:solar_market/widgets/drawer_widget.dart';
import 'package:solar_market/widgets/tabbar_item.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  String? uploadedFileURL;
  String? localFilePath;

  @override
  void initState() {
    tabController = TabController(length: 5, vsync: this);
    super.initState();
    tabController.addListener(() {
      setState(() {});
    });
    fetchPdfUrlFromFirestore();
  }

  Future<void> fetchPdfUrlFromFirestore() async {
    try {
      var pdfDoc = await FirebaseFirestore.instance
          .collection('pdfs')
          .doc('5f0a46c1-bd04-4965-bde3-2078b65f87a9')
          .get();

      if (pdfDoc.exists) {
        setState(() {
          uploadedFileURL = pdfDoc['url'];
        });
        downloadPdfFile();
      }
    } catch (e) {
      print('Error fetching PDF URL from Firestore: $e');
    }
  }

  Future<void> downloadPdfFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/temp.pdf';

      await Dio().download(uploadedFileURL!, filePath);

      setState(() {
        localFilePath = filePath;
      });
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: AuthService.isAuthenticated() ? const DrawerWidget() : null,
        appBar: AppBar(
          automaticallyImplyLeading:
              AuthService.isAuthenticated() ? true : false,
          centerTitle: true,
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'Market',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
              height: 38.h,
              child: TabBar(
                physics: BouncingScrollPhysics(),
                dividerColor: Colors.transparent,
                labelPadding: EdgeInsets.zero,
                controller: tabController,
                indicatorColor: Colors.transparent,
                tabs: [
                  TabBarItem(
                    isProfile: true,
                    title: 'USERS',
                    unSelectedColor: Color(0xFFD9D9D9),
                    isSelected: tabController.index == 0,
                  ),
                  TabBarItem(
                    isProfile: true,
                    title: 'IMPORTER',
                    unSelectedColor: Color(0xFFD9D9D9),
                    isSelected: tabController.index == 1,
                  ),
                  TabBarItem(
                    isProfile: true,
                    title: 'EPC',
                    unSelectedColor: Color(0xFFD9D9D9),
                    isSelected: tabController.index == 2,
                  ),
                  TabBarItem(
                    isProfile: true,
                    title: 'CHINA RATES',
                    unSelectedColor: Color(0xFFD9D9D9),
                    isSelected: tabController.index == 3,
                  ),
                  TabBarItem(
                    isProfile: true,
                    title: 'MARKET',
                    unSelectedColor: Color(0xFFD9D9D9),
                    isSelected: tabController.index == 4,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 6.h,
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics:
                    NeverScrollableScrollPhysics(), // Disable swipe gesture
                children: [
                  UserListScreen(),
                  DataListScreen(collectionName: 'importers'),
                  DataListScreen(collectionName: 'Epc'),
                  DataListScreen(collectionName: 'chinese'),
                  uploadedFileURL != null
                      ? localFilePath != null
                          ? PDFView(
                              filePath: localFilePath,
                              enableSwipe: true,
                              swipeHorizontal: true,
                              autoSpacing: false,
                              pageFling: false,
                              onRender: (_pages) {},
                              onError: (error) {
                                print('PDFView Error: ${error.toString()}');
                              },
                              onPageError: (page, error) {
                                print('Page $page: ${error.toString()}');
                              },
                            )
                          : Center(
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                              ),
                            )
                      : Center(
                          child: Text(
                            'No PDF available',
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DataListScreen extends StatefulWidget {
  final String collectionName;

  DataListScreen({Key? key, required this.collectionName}) : super(key: key);

  @override
  State<DataListScreen> createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  BiddingController controller = Get.put(BiddingController());

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _dataStream = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .orderBy('number')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _dataStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
            color: kPrimaryColor,
          ));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                color: Colors.red,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No data found in ${widget.collectionName}',
              style: GoogleFonts.kameron(
                  color: kPrimaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500),
            ),
          );
        }

        final data = snapshot.data!.docs;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            if (widget.collectionName == 'chinese') {
              return Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['companyName'] ?? 'N/A',
                          style: GoogleFonts.inter(
                              fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${item['rate'] ?? 'N/A'}\$\nMQ: ${item['mq'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryColor),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sp),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Landed Cost: ${item['landedCost'] ?? 'N/A'}\nTimeframe: ${item['timeframe'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          children: [
                            Text(
                              '${item['profitMargin'] ?? 'N/A'}',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    item['profitMargin']?.contains('+') ?? false
                                        ? kPrimaryColor
                                        : Colors.red,
                              ),
                            ),
                            Icon(
                              item['profitMargin']?.contains('+') ?? false
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color:
                                  item['profitMargin']?.contains('+') ?? false
                                      ? kPrimaryColor
                                      : Colors.red,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 0.4,
                  )
                ],
              );
            } else if (widget.collectionName == 'Epc') {
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      item['companyName'] ?? 'N/A',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['directorName'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                              color: kPrimaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${item['location'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                              fontSize: 13.sp, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${item['description'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    trailing: InkWell(
                      onTap: () {
                        controller.makeCall(item['phoneNumber']);
                      },
                      child: CircleAvatar(
                        backgroundColor: kPrimaryColor,
                        child: SvgPicture.asset(
                          'assets/icons/call.svg',
                          height: 22.h,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 0.5,
                  )
                ],
              );
            } else if (widget.collectionName == 'importers') {
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      item['companyName'] ?? 'N/A',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['directorName'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                              color: kPrimaryColor,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${item['description'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    trailing: InkWell(
                      onTap: () {
                        controller.makeCall(item['phoneNumber']);
                      },
                      child: CircleAvatar(
                        backgroundColor: kPrimaryColor,
                        child: SvgPicture.asset(
                          'assets/icons/call.svg',
                          height: 22.h,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 0.4,
                  )
                ],
              );
            } else {
              return Column(
                children: [
                  ListTile(
                    title: Text(
                      item['companyName'] ?? 'N/A',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item['directorName'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                              fontSize: 14.sp, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${item['phoneNumber'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: kPrimaryColor),
                        ),
                      ],
                    ),
                    trailing: InkWell(
                      onTap: () {
                        controller.makeCall(item['phoneNumber']);
                      },
                      child: CircleAvatar(
                        backgroundColor: kPrimaryColor,
                        child: SvgPicture.asset(
                          'assets/icons/call.svg',
                          height: 22.h,
                        ),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 0.4,
                  )
                ],
              );
            }
          },
        );
      },
    );
  }
}
