import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../model/user_model.dart';
import 'order_service.dart';
import 'wallet_service.dart';

class UserService {
  UserService._privateConstructor();
  static final UserService instance = UserService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ValueNotifier<UserModel?> userNotifier = ValueNotifier(null);

  UserModel? get currentUser => userNotifier.value;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<void> loadUserData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        userNotifier.value = UserModel.fromMap(doc.data() ?? {}, uid: uid);
      } else {
        // Nếu không có doc trong Firestore, tạo UserModel tối thiểu từ Auth
        userNotifier.value = UserModel(
          uid: uid,
          email: _auth.currentUser?.email,
          fullName: _auth.currentUser?.displayName,
        );
      }

      // Tải dữ liệu liên quan ngay khi user được xác định
      await WalletService.instance.loadWalletData();
      OrderService.instance.loadOrders();
    } catch (e) {
      if (kDebugMode) print('Failed to load user data: $e');
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? email,
    String? address,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final updates = <String, dynamic>{};
      if (fullName != null) updates['fullName'] = fullName;
      if (username != null) updates['username'] = username;
      if (email != null) updates['email'] = email;
      if (address != null) updates['address'] = address;

      await _firestore.collection('users').doc(uid).update(updates);

      final user = currentUser;
      if (user != null) {
        // Tạo object MỚI để ValueNotifier trigger rebuild
        userNotifier.value = UserModel(
          uid: user.uid,
          email: email ?? user.email,
          createdAt: user.createdAt,
          fullName: fullName ?? user.fullName,
          username: username ?? user.username,
          address: address ?? user.address,
        );
      }
    } catch (e) {
      if (kDebugMode) print('Failed to update profile: $e');
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } catch (e) {
      if (kDebugMode) print('Failed to change password: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      userNotifier.value = null;
      // Dọn dẹp dữ liệu của tài khoản cũ
      OrderService.instance.clear();
      // Xóa dữ liệu ví trong bộ nhớ
      WalletService.instance.clear();
    } catch (e) {
      if (kDebugMode) print('Failed to logout: $e');
      rethrow;
    }
  }
}
