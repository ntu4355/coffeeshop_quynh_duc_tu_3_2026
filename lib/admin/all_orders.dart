import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/model/order_model.dart';
import 'package:coffee_app/service/widget_support.dart';
import 'package:flutter/material.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders> {
  final Color coffeeBrown = const Color(0xFF6B4F35);

  // Hàm lấy tên người dùng từ Firestore
  Future<String> getUserName(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc.data()?['fullName'] ?? "Khách hàng";
    } catch (e) {
      return "Ẩn danh";
    }
  }

  // Hàm cập nhật trạng thái đơn hàng
  Future<void> updateStatus(String orderId, OrderStatus currentStatus) async {
    OrderStatus nextStatus;
    if (currentStatus == OrderStatus.receiving) {
      nextStatus = OrderStatus.shipping;
    } else if (currentStatus == OrderStatus.shipping) {
      nextStatus = OrderStatus.delivered;
    } else {
      return; // Đã giao xong không đổi nữa
    }

    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': nextStatus.name,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf4eee3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf4eee3),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: coffeeBrown),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: coffeeBrown),
            onPressed: () => Navigator.pushNamed(context, '/delivery_history'),
            tooltip: "Lịch sử giao hàng",
          ),
        ],
        title: Text(
          "Tất cả đơn hàng",
          style: AppWidget.boldTextFieldStyle().copyWith(fontSize: 22),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Lọc bỏ các đơn hàng đã giao
          final allDocs = snapshot.data!.docs;
          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] != OrderStatus.delivered.name;
          }).toList();

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "Chưa có đơn hàng nào",
                style: AppWidget.boldTextFieldStyle(),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final order = OrderModel.fromMap(data, id: docs[index].id);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: order.image != null
                            ? (order.image!.startsWith('http')
                                  ? Image.network(
                                      order.image!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image),
                                    )
                                  : Image.asset(
                                      order.image!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ))
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[200],
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.name ?? '',
                              style: AppWidget.boldTextFieldStyle().copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Người đặt: ${order.userName ?? 'Khách hàng'}",
                              style: TextStyle(
                                color: coffeeBrown,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Số lượng: ${order.quantity} | Tổng: ${order.computedTotalPrice.toStringAsFixed(0)}k",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildStatusBadge(order.status),
                          ],
                        ),
                      ),
                      // Nút chuyển trạng thái
                      if (order.status != OrderStatus.delivered)
                        IconButton(
                          icon: const Icon(Icons.sync_alt, color: Colors.blue),
                          onPressed: () =>
                              updateStatus(docs[index].id, order.status),
                          tooltip: "Chuyển trạng thái",
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String label;

    switch (status) {
      case OrderStatus.receiving:
        color = Colors.orange;
        label = "Đang chuẩn bị";
        break;
      case OrderStatus.shipping:
        color = Colors.blue;
        label = "Đang giao";
        break;
      case OrderStatus.delivered:
        color = Colors.green;
        label = "Đã giao";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
