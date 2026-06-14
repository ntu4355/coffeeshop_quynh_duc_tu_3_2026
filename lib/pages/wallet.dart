import 'package:flutter/material.dart';
import '../service/wallet_service.dart';
import '../model/transaction_model.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WalletService.instance.loadWalletData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _showTopupDialog() {
    _amountController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nạp tiền'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Nhập số tiền',
            suffixText: 'đ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              double? amount = double.tryParse(_amountController.text.trim());
              if (amount != null && amount > 0) {
                // Chuẩn hóa: Nếu người dùng nhập 50000 thì hiểu là 50k
                if (amount >= 1000) {
                  amount = amount / 1000;
                }
                await WalletService.instance.topupBalance(amount);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B4F35),
            ),
            child: const Text('Nạp tiền'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coffeeBrown = const Color(0xFF6B4F35);
    return Scaffold(
      appBar: AppBar(title: const Text('Số dư'), backgroundColor: coffeeBrown),
      body: ValueListenableBuilder<double>(
        valueListenable: WalletService.instance.balanceNotifier,
        builder: (context, balance, _) {
          return Column(
            children: [
              // Balance Card
              Container(
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Số dư hiện tại',
                      style: TextStyle(color: Colors.grey, fontSize: 14.0),
                    ),
                    const SizedBox(height: 12.0),
                    Text(
                      WalletService.instance.formatCurrency(balance),
                      style: TextStyle(
                        color: coffeeBrown,
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Top-up Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showTopupDialog,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Nạp tiền'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: coffeeBrown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28.0),

              // Transaction History Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      'Lịch sử giao dịch',
                      style: TextStyle(
                        color: coffeeBrown,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12.0),

              // Transaction List
              Expanded(
                child: ValueListenableBuilder<List<TransactionModel>>(
                  valueListenable: WalletService.instance.transactionsNotifier,
                  builder: (context, transactions, _) {
                    if (transactions.isEmpty) {
                      return Center(
                        child: Text(
                          'Chưa có giao dịch nào',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14.0,
                          ),
                        ),
                      );
                    }

                    // Sắp xếp giao dịch mới nhất lên đầu
                    final displayTransactions = List<TransactionModel>.from(
                      transactions,
                    )..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: displayTransactions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                      itemBuilder: (context, index) {
                        final transaction = displayTransactions[index];
                        final isIncome =
                            transaction.type == TransactionType.topup ||
                            transaction.type == TransactionType.refund;

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 48.0,
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: isIncome
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: Text(
                                  transaction.type.icon,
                                  style: const TextStyle(fontSize: 24.0),
                                ),
                              ),
                            ),
                            title: Text(transaction.type.label),
                            subtitle: Text(
                              transaction.description ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.0),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isIncome ? '+' : '-'}${WalletService.instance.formatCurrency(transaction.amount)}',
                                  style: TextStyle(
                                    color: isIncome ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                ),
                                Text(
                                  _formatDate(transaction.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/order');
              break;
            case 2:
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        selectedItemColor: coffeeBrown,
        unselectedItemColor: coffeeBrown.withOpacity(0.45),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            label: 'Số dư',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Hôm nay ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (date == yesterday) {
      return 'Hôm qua ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
