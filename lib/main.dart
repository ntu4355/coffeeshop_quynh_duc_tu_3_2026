import 'package:coffee_app/admin/admin_home.dart';
import 'package:coffee_app/admin/add_product.dart';
import 'package:coffee_app/admin/all_orders.dart';
import 'package:coffee_app/admin/delivery_history.dart';
import 'package:coffee_app/admin/manage_products.dart';
import 'package:coffee_app/admin/manage_users.dart';
import 'package:coffee_app/pages/admin_login.dart';
import 'package:coffee_app/pages/home.dart';
import 'package:coffee_app/pages/login.dart';
import 'package:coffee_app/pages/order.dart';
import 'package:coffee_app/pages/profile.dart';
import 'package:coffee_app/pages/signup.dart';
import 'package:coffee_app/pages/wallet.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffee_app/service/user_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    // If initialization fails, show a helpful error UI instead of crashing.
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final message =
        '''Firebase failed to initialize.

Reason: $error

Ensure you generated and registered Firebase
options (firebase_options.dart) using the FlutterFire CLI, or provide
FirebaseOptions to Firebase.initializeApp().

Docs: https://firebase.flutter.dev/docs/overview#initializing-flutterfire''';

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Initialization error')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(child: Text(message)),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QDT Coffee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        scaffoldBackgroundColor: const Color(0xFFf4eee3),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            // Người dùng đã đăng nhập. Đảm bảo dữ liệu người dùng được tải.
            // Sử dụng FutureBuilder để đợi loadUserData hoàn tất trước khi hiển thị Home.
            return FutureBuilder<void>(
              future: UserService.instance
                  .loadUserData(), // Tải hoặc tải lại dữ liệu người dùng
              builder: (context, userLoadSnapshot) {
                if (userLoadSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                // Sau khi dữ liệu người dùng đã được tải (hoặc cố gắng tải), hiển thị Home.
                return const Home();
              },
            );
          }
          // Nếu chưa đăng nhập, vào trang Login
          return const LogIn();
        },
      ),
      routes: {
        '/login': (_) => const LogIn(),
        '/signup': (_) => const SignUp(),
        '/home': (_) => const Home(),
        '/order': (_) => const OrderPage(),
        '/wallet': (_) => const WalletPage(),
        '/profile': (_) => const ProfilePage(),
        '/adminlogin': (_) => const AdminLogin(),
        '/adminhome': (_) => const AdminHome(),
        '/manage_users': (_) => const ManageUsers(),
        '/all_orders': (_) => const AllOrders(),
        '/delivery_history': (_) => const DeliveryHistory(),
        '/manage_products': (_) => const ManageProducts(),
        '/add_product': (_) => const AddProduct(),
      },
    );
  }
}
