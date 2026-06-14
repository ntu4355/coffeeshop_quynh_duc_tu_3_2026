import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/model/order_model.dart';
import 'package:coffee_app/service/widget_support.dart';
import 'package:flutter/material.dart';

class DeliveryHistory extends StatefulWidget {
  const DeliveryHistory({super.key});

  @override
  State<DeliveryHistory> createState() => _DeliveryHistoryState();
}

class _DeliveryHistoryState extends State<DeliveryHistory> {
  final Color coffeeBrown = const Color(0xFF6B4F35);

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

  void _confirmDelete(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn xóa lịch sử đơn hàng này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderId)
                  .delete();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
        title: Text(
          "Lịch sử giao hàng",
          style: AppWidget.boldTextFieldStyle().copyWith(fontSize: 22),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "Lỗi: ${snapshot.error.toString()}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Lọc dữ liệu thủ công để tránh yêu cầu Composite Index từ Firestore
          final allDocs = snapshot.data!.docs;
          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == OrderStatus.delivered.name;
          }).toList();

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "Chưa có lịch sử giao hàng",
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: const Text(
                                "Đã hoàn thành",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _confirmDelete(docs[index].id),
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
}
