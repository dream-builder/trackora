import 'package:firebase_database/firebase_database.dart';

class FirebaseUserService {
  final DatabaseReference _dbRef =
  FirebaseDatabase.instance.ref().child('users');

  /// 🔹 Create or Update user data
  Future<void> updateUser({
    required String userId,
    required String name,
    required double lat,
    required double lng,
    String status = 'online',
  }) async {
    await _dbRef.child(userId).update({
      'name': name,
      'lat': lat,
      'lng': lng,
      'status': status,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 🔹 Get single user data once
  Future<Map<String, dynamic>?> getUser(String userId) async {
    final snapshot = await _dbRef.child(userId).get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  /// 🔹 Listen real-time updates for single user
  Stream<DatabaseEvent> listenUser(String userId) {
    return _dbRef.child(userId).onValue;
  }

  /// 🔹 Listen real-time updates for all users
  Stream<DatabaseEvent> listenAllUsers() {
    return _dbRef.onValue;
  }

  /// 🔹 Remove user
  Future<void> deleteUser(String userId) async {
    await _dbRef.child(userId).remove();
  }
}
