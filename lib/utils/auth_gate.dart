// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:solar_market/screens/auth/login_screen.dart';
// import 'package:solar_market/screens/dashboard/contact_us/contact_us_screen.dart';
// import 'package:solar_market/screens/dashboard/dashboard_screen.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// class AuthGate extends StatelessWidget {
//   const AuthGate({super.key});

//   Future<bool> isUserBanned(String userId) async {
//     final userDoc = await FirebaseFirestore.instance
//         .collection('pmsUsers')
//         .doc(userId)
//         .get();
//     if (userDoc.exists) {
//       return userDoc.data()?['isBanned'] ?? false;
//     }
//     return false;
//   }

//   Future<bool> isRequestSubmitted() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('contactSubmitted') ?? false;
//   }

//   Future<void> updateFCMToken(String userId, String fcmToken) async {
//     await FirebaseFirestore.instance
//         .collection('pmsUsers')
//         .doc(userId)
//         .update({'fcmToken': fcmToken});
//   }

//   Future<void> checkAndLogoutPreviousDevice(String userId, String currentFCMToken) async {
//     final userDoc = await FirebaseFirestore.instance
//         .collection('pmsUsers')
//         .doc(userId)
//         .get();

//     if (userDoc.exists) {
//       final storedFCMToken = userDoc.data()?['fcmToken'];
//       if (storedFCMToken != null && storedFCMToken != currentFCMToken) {
//         await FirebaseAuth.instance.signOut();
//       }
//     }
//   }

//   Future<void> handleLogin(User user) async {
//     final currentFCMToken = await FirebaseMessaging.instance.getToken();
//     if (currentFCMToken != null) {
//       await checkAndLogoutPreviousDevice(user.uid, currentFCMToken);
//       await updateFCMToken(user.uid, currentFCMToken);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final User user = FirebaseAuth.instance.currentUser!;
//             handleLogin(user);

//             return FutureBuilder<bool>(
//               future: isUserBanned(user.uid),
//               builder: (context, bannedSnapshot) {
//                 if (bannedSnapshot.data == true) {
//                   return FutureBuilder<bool>(
//                     future: isRequestSubmitted(),
//                     builder: (context, requestSnapshot) {
//                       return requestSnapshot.data == true
//                           ? RequestReceivedScreen()
//                           : ContactUsScreen();
//                     },
//                   );
//                 } else {
//                   return const Dashboard();
//                 }
//               },
//             );
//           } else {
//             return const LoginScreen();
//           }
//         },
//       ),
//     );
//   }
// }

// class RequestReceivedScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(16.r),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Lottie.asset('assets/animations/success.json',
//                   width: 244.w, height: 200.h),
//               Text(
//                 "We have received your request!",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.inter(
//                     fontSize: 22.sp, fontWeight: FontWeight.w600),
//               ),
//               SizedBox(height: 10.h),
//               Text(
//                 "Please wait while we review your request. You will be notified soon.",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(fontSize: 15.sp),
//               ),
//             ],
//           )),)
//     );
//   }
// }



import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_market/screens/auth/login_screen.dart';
import 'package:solar_market/screens/dashboard/contact_us/contact_us_screen.dart';
import 'package:solar_market/screens/dashboard/dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> isUserBanned(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('pmsUsers')
        .doc(userId)
        .get();
    if (userDoc.exists) {
      return userDoc.data()?['isBanned'] ?? false;
    }
    return false;
  }

  Future<bool> isRequestSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('contactSubmitted') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final User user = FirebaseAuth.instance.currentUser!;
            return FutureBuilder<bool>(
              future: isUserBanned(user.uid),
              builder: (context, bannedSnapshot) {
                // if (bannedSnapshot.connectionState == ConnectionState.waiting) {
                //   return const Center(child: CircularProgressIndicator());
                // }
                if (bannedSnapshot.data == true) {
                  return FutureBuilder<bool>(
                    future: isRequestSubmitted(),
                    builder: (context, requestSnapshot) {
                      // if (requestSnapshot.connectionState == ConnectionState.waiting) {
                      //   return const Center(child: CircularProgressIndicator());
                      // }
                      return requestSnapshot.data == true
                          ? RequestReceivedScreen()
                          : ContactUsScreen();
                    },
                  );
                } else {
                  return const Dashboard();
                }
              },
            );
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}

class RequestReceivedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/animations/success.json',
                  width: 244.w, height: 200.h),
              Text(
                "We have received your request!",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 22.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 10.h),
              Text(
                "Please wait while we review your request. You will be notified soon.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
