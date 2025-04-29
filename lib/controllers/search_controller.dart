import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:square_up_fresh/constants.dart';
import 'package:square_up_fresh/models/user.dart';  // Import AppUser model

class SearchController extends GetxController {
  final Rx<List<AppUser>> _searchedUsers = Rx<List<AppUser>>([]);  // Use AppUser here

  List<AppUser> get searchedUsers => _searchedUsers.value;

  searchUser(String typedUser) async {
    _searchedUsers.bindStream(firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: typedUser)
        .snapshots()
        .map((QuerySnapshot query) {
      List<AppUser> retVal = [];  // Use AppUser here
      for (var elem in query.docs) {
        retVal.add(AppUser.fromSnap(elem));  // Convert to AppUser
      }
      return retVal;
    }));
  }
}
