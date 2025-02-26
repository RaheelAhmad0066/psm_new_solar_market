import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:solar_market/controllers/data_controller.dart';
import 'package:solar_market/utils/toas_message.dart';
import '../notifications.dart';
import '../profile/profile_controller.dart';
import 'package:uuid/uuid.dart';

class UserController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables
  final RxBool isFollowing = false.obs;
  final RxInt followersCount = 0.obs;
  final RxInt followingCount = 0.obs;
  final RxInt myfollowersCount = 0.obs;
  final RxInt myfollowingCount = 0.obs;
  final RxBool isLoading = false.obs;
  var followingLoading = <String, bool>{}.obs;
  var userFollowLoading = <String, bool>{}.obs; // Map to track each user

  // Set loading state for a specific user
  void setUserLoading(String userId, bool isLoading) {
    followingLoading[userId] = isLoading;
  }

  void setUserFollowLoading(String userId, bool isLoading) {
    userFollowLoading[userId] = isLoading;
  }

  ProfileController profileController = Get.put(ProfileController());
  DataController dataController = Get.put(DataController());

  @override
  void onInit() {
    super.onInit();
        User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;
    // String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    fetchRealTimecurentData(userId);}
  }
  Stream<List<String>> fetchUserList(String userId, bool isFollowers) {
    return _firestore.collection('pmsUsers').doc(userId).snapshots().map(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          if (isFollowers && data.containsKey('followers')) {
            return List<String>.from(data['followers'].map((f) => f['userId']));
          } else if (data.containsKey('following')) {
            return List<String>.from(data['following']);
          }
        }
        return [];
      },
    );
  }

  void fetchRealTimeData(String currentUserId) {
    _firestore.collection('pmsUsers').doc(currentUserId).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          var data = snapshot.data() as Map<String, dynamic>;
          followersCount.value = (data['followers'] as List? ?? []).length;
          followingCount.value = (data['following'] as List? ?? []).length;
        }
      },
    );
  }

  void fetchRealTimecurentData(String currentUserId) {
    _firestore.collection('pmsUsers').doc(currentUserId).snapshots().listen(
      (snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          var data = snapshot.data() as Map<String, dynamic>;
          myfollowersCount.value = (data['followers'] as List? ?? []).length;
          myfollowingCount.value = (data['following'] as List? ?? []).length;
        }
      },
    );
  }
 
  // Check if the current user is following the given user
  Future<void> fetchUserProfile(String userId, String currentUserId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('pmsUsers').doc(userId).get();

    List followers = snapshot['followers'];
    isFollowing.value = followers.any((f) => f['userId'] == currentUserId);
  }

  // Follow a user
  Future<void> followUser(
    String userId,
    String currentUserId,
    String currentUserName,
    String currentUserPhone,
  ) async {
    isLoading.value = true;
    setUserFollowLoading(userId, true);

    try {
      // Update the target user's followers list
      await _firestore.collection('pmsUsers').doc(userId).update({
        'followers': FieldValue.arrayUnion([
          {
            'userId': currentUserId,
            'fullName': currentUserName,
            'phoneNumber': currentUserPhone,
            'fcmToken': profileController.fcmToken.value,
          }
        ]),
      });

      // Update the current user's following list
      await _firestore.collection('pmsUsers').doc(currentUserId).update({
        'following': FieldValue.arrayUnion([userId]),
      });

      // Update both counts
      await _firestore.collection('pmsUsers').doc(userId).update({
        'followersCount': FieldValue.increment(1),
      });
      await _firestore.collection('pmsUsers').doc(currentUserId).update({
        'followingCount': FieldValue.increment(1),
      });

      // Set the isFollowing flag to true
      isFollowing.value = true;
      followersCount.value++; // Update the current user's followers count

      DocumentSnapshot userSnapshot =
          await _firestore.collection('pmsUsers').doc(userId).get();
      String? fcmToken = userSnapshot['fcmToken'];

      // Send notification if the target user has an FCM token
      if (fcmToken != null) {
        LocalNotificationService.sendNotificationUsingApi(
          token: fcmToken,
          title: 'New Follower',
          body: '${profileController.userName.value} started following you!',
          data: {
            'screen': 'userDetail',
            'phoneNumber': currentUserPhone,
            'userId': currentUserId,
          },
        );
      }
      dataController.createfollowNotification(
          toSenderId: userId,
          message: '${profileController.userName.value} started following you!',
          userId: userId,
          phoneNumber: currentUserPhone);
      fetchRealTimecurentData(currentUserId);
    } catch (e) {
      print('Error following user: $e');
    } finally {
      setUserFollowLoading(userId, false);

      isLoading.value = false;
    }
  }

  // Unfollow a user
  Future<void> unfollowUser(String userId, String currentUserId) async {
    isLoading.value = true;
    setUserFollowLoading(userId, true);

    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('pmsUsers').doc(userId).get();
      List followers = snapshot['followers'];

      var followerToRemove = followers
          .firstWhere((f) => f['userId'] == currentUserId, orElse: () => null);

      if (followerToRemove != null) {
        await _firestore.collection('pmsUsers').doc(userId).update({
          'followers': FieldValue.arrayRemove([followerToRemove]),
        });
      }

      await _firestore.collection('pmsUsers').doc(currentUserId).update({
        'following': FieldValue.arrayRemove([userId]),
      });

      isFollowing.value = false;
      followersCount.value--;

      // Re-fetch the user profile data to reflect updated follower/following counts
      fetchRealTimecurentData(currentUserId);
    } catch (e) {
      print('Error unfollowing user: $e');
    } finally {
      isLoading.value = false;
      setUserFollowLoading(userId, false);
    }
  }

  //
  //

  void submitReport(
      String reportText, String postId, String reportedUserId) async {
    try {
      var uuid = const Uuid();
      var myId = uuid.v6();
      String reporterId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('reports').doc(myId).set({
        'postId': postId,
        'reportedUserId': reportedUserId,
        'reporterId': reporterId,
        'reportText': reportText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      MessageToast.showToast(msg: 'Report submitted successfully');
    } catch (e) {
      MessageToast.showToast(msg: 'Failed to submit report');
    }
  }
}
