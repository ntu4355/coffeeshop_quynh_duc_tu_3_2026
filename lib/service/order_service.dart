import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../model/order_model.dart';
import 'user_service.dart';

class OrderService {
  OrderService._privateConstructor();
  static final OrderService instance = OrderService._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ValueNotifier<List<OrderModel>> ordersNotifier = ValueNotifier([]);
  StreamSubscription? _ordersSubscription;

  List<OrderModel> get orders => ordersNotifier.value;

  void loadOrders() {
    _ordersSubscription?.cancel();
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      _ordersSubscription = _firestore
          .collection('orders')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
            ordersNotifier.value = snapshot.docs
                .map(
                  (doc) => OrderModel.fromMap(
                    doc.data() as Map<String, dynamic>,
                    id: doc.id,
                  ),
                )
                .toList();
          });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load orders: $e');
      }
    }
  }

  Future<void> addOrder(OrderModel order) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final list = List<OrderModel>.from(ordersNotifier.value);
    list.insert(0, order);
    ordersNotifier.value = list;

    try {
      final Map<String, dynamic> data = order.toMap();
      data['userId'] = uid; // Lưu ID người dùng vào đơn hàng
      // Denormalization: Lưu tên người dùng trực tiếp vào đơn hàng
      data['userName'] =
          UserService.instance.currentUser?.fullName ?? "Khách hàng";
      data['createdAt'] = FieldValue.serverTimestamp();

      final reference = await _firestore.collection('orders').add(data);
      order.id = reference.id;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save order: $e');
      }
    }
  }

  Future<void> updateOrderStatus(int index, OrderStatus status) async {
    final list = List<OrderModel>.from(ordersNotifier.value);
    if (index < 0 || index >= list.length) return;

    final order = list[index];
    order.status = status;
    ordersNotifier.value = list;

    if (order.id != null) {
      await _firestore.collection('orders').doc(order.id).update({
        'status': status.name,
      });
    }
  }

  Future<void> cancelOrderAt(int index) async {
    final list = List<OrderModel>.from(ordersNotifier.value);
    if (index < 0 || index >= list.length) return;

    final order = list[index];
    if (order.status != OrderStatus.receiving) return;

    list.removeAt(index);
    ordersNotifier.value = list;

    if (order.id != null) {
      await _firestore.collection('orders').doc(order.id).delete();
    }
  }

  Future<void> removeOrderAt(int index) async {
    final list = List<OrderModel>.from(ordersNotifier.value);
    if (index < 0 || index >= list.length) return;

    final order = list.removeAt(index);
    ordersNotifier.value = list;

    if (order.id != null) {
      await _firestore.collection('orders').doc(order.id).delete();
    }
  }

  void clear() {
    _ordersSubscription?.cancel();
    ordersNotifier.value = [];
  }
}
