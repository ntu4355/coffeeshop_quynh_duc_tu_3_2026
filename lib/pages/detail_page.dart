import 'package:flutter/material.dart';
import 'package:coffee_app/service/widget_support.dart';
import '../model/order_model.dart';
import '../service/order_service.dart';
import '../service/wallet_service.dart';
import 'order.dart';

class DetailPage extends StatefulWidget {
  final String image;
  final String name;
  final dynamic price; // Để tương thích cả dữ liệu cũ (String) và mới (num)
  final String description;

  const DetailPage({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.description,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;

  double get priceValue {
    if (widget.price is num) return (widget.price as num).toDouble();
    // Xử lý dữ liệu cũ dạng "50k"
    final numericString =
        RegExp(r'\d+').stringMatch(widget.price.toString()) ?? '0';
    return double.tryParse(numericString) ?? 0.0;
  }

  String formatDisplay(double val) {
    return "${val.toStringAsFixed(0)}k";
  }

  double get totalAmount => priceValue * quantity;

  @override
  Widget build(BuildContext context) {
    final coffeeBrown = const Color(0xFF6B4F35);
    return Scaffold(
      backgroundColor: const Color(0xFFf4eee3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 26.0,
                        color: coffeeBrown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Text(
                      'Chi tiết sản phẩm',
                      style: AppWidget.boldTextFieldStyle().copyWith(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Hero(
                      tag: widget.image,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28.0),
                          child: widget.image.startsWith('http')
                              ? Image.network(
                                  widget.image,
                                  width: double.infinity,
                                  height: 320,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 50),
                                )
                              : Image.asset(
                                  widget.image,
                                  width: double.infinity,
                                  height: 320,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18.0),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.name,
                                  style: AppWidget.boldTextFieldStyle()
                                      .copyWith(fontSize: 24.0),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.0,
                                  vertical: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: coffeeBrown.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: Text(
                                  widget.price is num
                                      ? "${(widget.price as num).toStringAsFixed(0)}k"
                                      : widget.price.toString(),
                                  style: AppWidget.boldTextFieldStyle()
                                      .copyWith(
                                        color: coffeeBrown,
                                        fontSize: 18.0,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Mô tả sản phẩm',
                            style: AppWidget.boldTextFieldStyle().copyWith(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            widget.description,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15.0,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Text(
                            'Số lượng',
                            style: AppWidget.boldTextFieldStyle().copyWith(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18.0),
                                  border: Border.all(
                                    color: coffeeBrown.withOpacity(0.25),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (quantity > 1) quantity--;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.remove,
                                        color: coffeeBrown,
                                      ),
                                    ),
                                    Text(
                                      '$quantity',
                                      style: AppWidget.boldTextFieldStyle()
                                          .copyWith(fontSize: 20.0),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          quantity++;
                                        });
                                      },
                                      icon: Icon(Icons.add, color: coffeeBrown),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Tổng thanh toán',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    formatDisplay(totalAmount),
                                    style: AppWidget.priceTextFieldStyle()
                                        .copyWith(color: coffeeBrown),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 28.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                final walletBalance =
                                    WalletService.instance.balance;

                                if (walletBalance < totalAmount) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Số dư không đủ! Cần: ${formatDisplay(totalAmount)}, Hiện có: ${WalletService.instance.formatCurrency(walletBalance)}',
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                  return;
                                }

                                final order = OrderModel(
                                  name: widget.name,
                                  image: widget.image,
                                  price: priceValue,
                                  quantity: quantity,
                                  totalPrice: totalAmount,
                                  status: OrderStatus.receiving,
                                );
                                await OrderService.instance.addOrder(order);
                                await WalletService.instance.deductBalance(
                                  totalAmount,
                                  description:
                                      'Thanh toán đơn hàng: ${widget.name}',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã đặt hàng')),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OrderPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: coffeeBrown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                              ),
                              child: Text(
                                'Đặt hàng',
                                style: AppWidget.whiteTextFieldStyle().copyWith(
                                  fontSize: 18.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
