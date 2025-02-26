import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:solar_market/controllers/profile/profile_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class BiddingController extends GetxController {
  var bidAmount = ''.obs;
  var bidders = <Map<String, dynamic>>[].obs;
  var userBids = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ProfileController profileController = Get.put(ProfileController());
  bool userHasBid(String userId) {
    return bidders.any((bidder) => bidder['userId'] == userId);
  }

  void fetchBidders(String itemId) async {
    isLoading.value = true;
    final snapshot = await firestore
        .collection('psmBids')
        .where('itemId', isEqualTo: itemId)
        .get();

    bidders.value = snapshot.docs
        .map((doc) => {
              'userName': doc['userName'],
              'bid': doc['bid'],
              'userId': doc['userId'],
              'itemId': doc['itemId'],
              'itemPrice': doc['itemPrice'],
              'userImage': doc['userImage'],
              'phoneNumber': doc['phoneNumber']
            })
        .toList();

    isLoading.value = false;
  }

  void fetchUserBids(String userId) async {
    isLoading.value = true;
    try {
      final snapshot = await firestore
          .collection('psmBids')
          .where('ownerId', isEqualTo: userId)
          .get();

      userBids.value = snapshot.docs
          .map((doc) => {
                'itemId': doc['itemId'],
                'itemName': doc['itemName'],
                'itemPrice': doc['itemPrice'],
                'userId': doc['userId'],
                'ownerId': doc['ownerId'],
                'userName': doc['userName'],
                'userImage': doc['userImage'],
                'phoneNumber': doc['phoneNumber'],
                'bid': doc['bid'],
                'subCollection': doc['subCollection'],
              })
          .toList();
    } catch (e) {
      print('Error fetching user bids: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitBid({
    required String itemId,
    required String itemName,
    required String userName,
    required String userId,
    required String ownerId,
    required String userImage,
    required String phoneNumber,
    required String itemPrice,
    required String ownerNumber,
    required String subCollection,
  }) async {
    if (!userHasBid(userId)) {
      isLoading.value = true;
      try {
        await firestore.collection('psmBids').add({
          'itemId': itemId,
          'itemName': itemName,
          'userId': userId,
          'ownerId': ownerId,
          'fcmToken': profileController.fcmToken.value,
          'userName': userName,
          'userImage': userImage,
          'phoneNumber': phoneNumber,
          'itemPrice': itemPrice,
          'bid': double.parse(bidAmount.value),
          'subCollection': subCollection,
        });

        QuerySnapshot subCollectionSnapshot = await firestore
            .collection('psmPosts')
            .doc(ownerNumber)
            .collection(subCollection)
            .where('itemId', isEqualTo: itemId)
            .get();

        if (subCollectionSnapshot.docs.isNotEmpty) {
          String subDocId = subCollectionSnapshot.docs.first.id;

          // Update the 'bidding' field in the specific subdocument
          await firestore
              .collection('psmPosts')
              .doc(ownerNumber)
              .collection(subCollection)
              .doc(subDocId)
              .update({'bidding': 'bidded'});
        } else {
          print('Subdocument not found for the given itemId.');
        }

        // Fetch updated bidders
        fetchBidders(itemId);
      } catch (e) {
        print('Error while submitting bid: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    await launchUrl(url);
  }

  Future<void> openWhatsApp(String phoneNumber) async {
    final sanitizedNumber = phoneNumber.replaceAll(' ', '');
    final Uri url = Uri.parse('https://wa.me/$sanitizedNumber');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
