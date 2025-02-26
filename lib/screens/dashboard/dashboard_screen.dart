import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solar_market/constants.dart';
import 'package:solar_market/controllers/notifications.dart';
import 'package:solar_market/screens/dashboard/inverters/inverter_screen.dart';
import 'package:solar_market/screens/dashboard/lithium_batteries/lithium_battery_screen.dart';
import 'package:solar_market/screens/dashboard/market/market_screen.dart';
import 'package:solar_market/screens/dashboard/panels/panel_screen.dart';
import 'package:solar_market/screens/dashboard/profile/profile_screen.dart';
import 'package:solar_market/utils/auth_popup.dart';
import 'package:solar_market/utils/auth_service.dart';
import 'package:solar_market/utils/get_server_key.dart';

class Dashboard extends StatefulWidget {
  final int initialTabIndex;

  const Dashboard({super.key, this.initialTabIndex = 0});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late int selectedIndex;
  LocalNotificationService notificationService = LocalNotificationService();
  // AuthController authController = Get.put(AuthController());
  final GetServerKey _getServerKey = GetServerKey();

  Future<void> getServiceToken() async {
    String serverToken = await _getServerKey.getServerKeyToken();
    print("Server Token => $serverToken");
  }

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTabIndex;
    notificationService.requestNotificationPermission();
    notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    getServiceToken();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return showExitDialog(context);
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(
              index: selectedIndex,
              children: [
                PanelScreen(),
                // Container(),
                // Container(),
                InverterScreen(),
                LithiumBatteryScreen(),

                // Container(
                //   height: Get.size.height,
                //   width: Get.size.width,
                //   color: Colors.white,
                //   child: Center(
                //     child: Text(
                //       'Coming Soon!',
                //       style: GoogleFonts.inter(
                //           color: kPrimaryColor,
                //           fontSize: 29.sp,
                //           fontWeight: FontWeight.w600),
                //     ),
                //   ),
                // ),

                // AddCompanyScreen(),
                MarketScreen(),
                const ProfileScreen()
              ],
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          showUnselectedLabels: true,
          selectedFontSize: 10,
          backgroundColor: Colors.white,
          unselectedFontSize: 8,
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 8.sp),
          selectedLabelStyle: GoogleFonts.inter(fontSize: 8.sp),
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.black,
          onTap: (index) {
            if ((index == 3 || index == 4) && !AuthService.isAuthenticated()) {
              AuthPopup.show(
                context,
              );
            } else {
              setState(() {
                selectedIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          items: [
            _bottomNavItem('assets/icons/panels.svg', 'Panels', 0),
            _bottomNavItem('assets/icons/inverters.svg', 'Inverters', 1),

            _bottomNavItem('assets/icons/lithium.svg', 'Batteries', 2),
            // _bottomNavItem('assets/icons/projects.svg', 'Projects', 3),
            _bottomNavItem('assets/icons/market.svg', 'Market', 3),
            _bottomNavItem('assets/icons/profile.svg', 'Profile', 4),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _bottomNavItem(
      String asset, String label, int index) {
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        asset,
        color: selectedIndex == index ? kPrimaryColor : null,
      ),
      label: label,
      backgroundColor: Colors.white,
    );
  }

  static Future<bool> showExitDialog(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    color: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Exit App',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Message
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Text(
                    'Do you really want to exit the app?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                      ),
                      onPressed: () => SystemNavigator.pop(),

                      // Navigator.of(context).pop(true),

                      child: Text(
                        "Exit",
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        )) ??
        false;
  }
}
