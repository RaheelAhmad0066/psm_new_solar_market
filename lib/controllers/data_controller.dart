import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:uuid/uuid.dart';

class DataController extends GetxController {
  ProfileController profileController = Get.put(ProfileController());
  FirebaseAuth auth = FirebaseAuth.instance;
  var isMessageSending = false.obs;
  var hasNewNotification = false.obs;

  @override
  void onInit() {
    super.onInit();
    listenForNotifications();
  }

  void listenForNotifications() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      FirebaseFirestore.instance
          .collection('psmNotifications')
          .where('toSenderId', isEqualTo: userId)
          .where('isRead', isEqualTo: false) // Only fetch unread notifications
          .snapshots()
          .listen((snapshot) {
        hasNewNotification.value = snapshot.docs.isNotEmpty;
      });
    }
  }

  // Mark all notifications as read when user opens notification screen
  void markNotificationsAsRead() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      var notifications = await FirebaseFirestore.instance
          .collection('psmNotifications')
          .where('toSenderId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notifications.docs) {
        await doc.reference.update({'isRead': true});
      }
      hasNewNotification.value = false;
    }
  }

  Stream<QuerySnapshot> getNotification(String uuidToRetrieve) {
    return FirebaseFirestore.instance
        .collection('psmNotifications')
        .where('toSenderId', isEqualTo: uuidToRetrieve)
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<void> createNotification({
    required String toSenderId,
    required String message,
    required String itemId,
    required String subCollection,
    required String userId,
    required String phoneNumber,
  }) async {
      User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    var uuid = const Uuid();
    var myId = uuid.v6();

    try {
      await FirebaseFirestore.instance
          .collection('psmNotifications')
          .doc(myId)
          .set({
        'notificationUid': myId,
        'toSenderId': toSenderId,
        'currentUserId': FirebaseAuth.instance.currentUser!.uid,
        'userImage': profileController.userImage.value,
        'message': message,
        'userName': profileController.userName.value,
        'fcmToken': profileController.fcmToken.value,
        'itemId': itemId, // Store itemId
        'subCollection': subCollection, // Store subCollection
        'userId': userId, // Store userId
        'phoneNumber': phoneNumber, // Store phone number
        'time': DateTime.now(),
        'isRead': false,
        'isFollow': false,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error: ${e.toString()}");
      }
    }}
  }

  Future<void> createfollowNotification({
    required String toSenderId,
    required String message,
    required String userId,
    required String phoneNumber,
  }) async {
      User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    var uuid = const Uuid();
    var myId = uuid.v6();

    try {
      await FirebaseFirestore.instance
          .collection('psmNotifications')
          .doc(myId)
          .set({
        'notificationUid': myId,
        'toSenderId': toSenderId,
        'currentUserId': FirebaseAuth.instance.currentUser!.uid,
        'message': message,
        'isFollow': true,
        'userName': profileController.userName.value,
        'fcmToken': profileController.fcmToken.value,
        'userId': userId, // Store userId
        'phoneNumber': phoneNumber, // Store phone number
        'time': DateTime.now(),
        'isRead': false,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error: ${e.toString()}");
      }
    }}
  }

//
  Future<void> deleteNotification(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('psmNotifications')
          .doc(id)
          .delete()
          .then((value) {});
    } catch (e) {
      Get.snackbar('Error', 'Error deleting document: $e');
    }
  }
}
