import 'package:coffee_app/service/widget_support.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn thoát khỏi quyền quản trị?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Chuyển hướng về trang login người dùng và xóa lịch sử chuyển trang
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coffeeBrown = const Color(0xFF6B4F35);

    return Scaffold(
      backgroundColor: const Color(0xFFf4eee3),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Trang Quản Trị",
                            style: AppWidget.boldTextFieldStyle().copyWith(
                              fontSize: 28.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            "Chào mừng trở lại, Admin!",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _showLogoutDialog,
                        icon: Icon(Icons.logout, color: coffeeBrown, size: 28),
                        tooltip: 'Đăng xuất',
                      ),
                    ],
                  ),
                  const SizedBox(height: 40.0),

                  // Box 1: Quản lý sản phẩm
                  _buildAdminBox(
                    context,
                    title: "Quản lý sản phẩm",
                    icon: Icons.coffee_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, '/manage_products');
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Box 2: Quản lý người
                  _buildAdminBox(
                    context,
                    title: "Quản lý người dùng",
                    icon: Icons.people_alt_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, '/manage_users');
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Box 3: Quản lý đơn hàng
                  _buildAdminBox(
                    context,
                    title: "Quản lý đơn hàng",
                    icon: Icons.shopping_bag_rounded,
                    onTap: () {
                      Navigator.pushNamed(context, '/all_orders');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBox(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final coffeeBrown = const Color(0xFF6B4F35);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: coffeeBrown, size: 36.0),
              const SizedBox(width: 20.0),
              Text(
                title,
                style: AppWidget.boldTextFieldStyle().copyWith(fontSize: 18.0),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: coffeeBrown.withOpacity(0.5),
                size: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
