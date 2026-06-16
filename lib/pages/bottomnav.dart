import 'package:flutter/material.dart';
import 'package:coffee_app/pages/home.dart';
import 'package:coffee_app/pages/order.dart';
import 'package:coffee_app/pages/wallet.dart';
import 'package:coffee_app/pages/profile.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;

  // Danh sách các trang để giữ trạng thái
  late List<Widget> pages;
  late Home homepage;
  late OrderPage order;
  late WalletPage wallet;
  late ProfilePage profile;

  @override
  void initState() {
    homepage = const Home();
    order = const OrderPage();
    wallet = const WalletPage();
    profile = const ProfilePage();
    pages = [homepage, order, wallet, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF6B4F35);

    return Scaffold(
      // IndexedStack giúp giữ trạng thái các trang khi chuyển đổi
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
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
}
