import 'package:flutter/material.dart';
import 'package:coffee_app/service/widget_support.dart';
import '../service/order_service.dart';
import '../model/order_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  void initState() {
    super.initState();
    // Đảm bảo dữ liệu mới nhất được tải từ Firestore
    OrderService.instance.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final coffeeBrown = const Color(0xFF6B4F35);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: coffeeBrown,
        title: const Text('Đơn hàng'),
      ),
      body: ValueListenableBuilder<List<OrderModel>>(
        valueListenable: OrderService.instance.ordersNotifier,
        builder: (context, orders, _) {
          if (orders.isEmpty) {
            return Center(
              child: Text(
                'Chưa có đơn hàng nào',
                style: AppWidget.boldTextFieldStyle(),
              ),
            );
          }

          // Sắp xếp đơn hàng mới nhất lên đầu
          final displayOrders = List<OrderModel>.from(orders)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.separated(
            padding: const EdgeInsets.all(12.0),
            itemCount: displayOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8.0),
            itemBuilder: (context, index) {
              final order = displayOrders[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  leading: order.image != null
                      ? (order.image!.startsWith('http')
                            ? Image.network(
                                order.image!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              )
                            : Image.asset(
                                order.image!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ))
                      : null,
                  title: Text(order.name ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Số lượng: ${order.quantity}'),
                      const SizedBox(height: 4.0),
                      Text(
                        'Tổng: ${order.computedTotalPrice.toStringAsFixed(0)}k',
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Trạng thái: ${order.status.label}',
                        style: TextStyle(
                          color: order.status == OrderStatus.receiving
                              ? Colors.orange.shade700
                              : order.status == OrderStatus.shipping
                              ? Colors.blue.shade700
                              : Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  trailing: order.status == OrderStatus.receiving
                      ? IconButton(
                          icon: const Icon(Icons.cancel_outlined),
                          color: Colors.redAccent,
                          tooltip: 'Hủy đơn hàng',
                          onPressed: () {
                            // Tìm index gốc trong danh sách chưa sắp xếp để xóa đúng
                            int originalIndex = orders.indexOf(order);
                            OrderService.instance.cancelOrderAt(originalIndex);
                          },
                        )
                      : Icon(
                          order.status == OrderStatus.shipping
                              ? Icons.local_shipping_outlined
                              : Icons.check_circle_outline,
                          color: order.status == OrderStatus.shipping
                              ? Colors.blue.shade700
                              : Colors.green.shade700,
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
