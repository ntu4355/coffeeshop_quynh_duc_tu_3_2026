import 'package:coffee_app/service/widget_support.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginAdmin() async {
    setState(() => isLoading = true);
    String username = usernameController.text.trim();
    String password = passwordController.text; // Không dùng trim cho mật khẩu

    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('admin')
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .get();

      if (snapshot.docs.isNotEmpty) {
        if (mounted) {
          // Đăng nhập thành công, chuyển đến trang chủ Admin
          Navigator.pushReplacementNamed(context, '/adminhome');
        }
      } else {
        // Không tìm thấy bản ghi nào khớp
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Tài khoản hoặc mật khẩu Quản trị không chính xác!",
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi kết nối Firebase: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coffeeBrown = const Color(0xFF6B4F35);

    return Scaffold(
      backgroundColor: const Color(0xFFf4eee3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
          child: Column(
            children: [
              Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: coffeeBrown,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    'Admin Portal',
                    style: AppWidget.boldTextFieldStyle().copyWith(
                      fontSize: 24.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 24.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 18,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Đăng nhập Quản trị',
                          style: AppWidget.boldTextFieldStyle().copyWith(
                            fontSize: 22.0,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Vui lòng nhập tài khoản quản trị viên để tiếp tục.',
                          style: TextStyle(
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                        const Text(
                          'Tên đăng nhập',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        _buildTextField(
                          controller: usernameController,
                          hintText: 'Nhập tên đăng nhập',
                          prefixIcon: Icons.admin_panel_settings_outlined,
                        ),
                        const SizedBox(height: 16.0),
                        const Text(
                          'Mật khẩu',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        _buildPasswordField(
                          controller: passwordController,
                          hintText: 'Nhập mật khẩu',
                          obscureText: obscurePassword,
                          onToggle: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 32.0),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (usernameController.text.isEmpty ||
                                      passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Vui lòng nhập đủ thông tin",
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  await loginAdmin();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: coffeeBrown,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Đăng nhập Admin',
                                  style: AppWidget.whiteTextFieldStyle()
                                      .copyWith(fontSize: 18.0),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFececf8),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          prefixIcon: Icon(prefixIcon, color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFececf8),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
