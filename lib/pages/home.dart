import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:coffee_app/model/category_model.dart';
import 'package:coffee_app/model/hotcoffee_model.dart';
import 'package:coffee_app/pages/detail_page.dart';
import 'package:coffee_app/service/category_data.dart';
import 'package:coffee_app/service/hotcoffee_data.dart';
import 'package:coffee_app/model/coldcoffee_model.dart';
import 'package:coffee_app/service/coldcoffee_data.dart';
import 'package:coffee_app/pages/order.dart';
import 'package:coffee_app/pages/wallet.dart';
import 'package:coffee_app/pages/profile.dart';
import 'package:coffee_app/service/user_service.dart';
import 'package:coffee_app/model/user_model.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel> categories = [];
  List<HotCoffeeModel> hotCoffee = [];
  List<ColdCoffeeModel> coldCoffee = [];
  int currentIndex = 0;
  int selectedCategoryIndex = 0;

  @override
  void initState() {
    categories = getCategories();
    hotCoffee = getHotCoffee();
    coldCoffee = getColdCoffee();
    super.initState();
  }

  Widget _buildProductGrid(Color coffeeBrown) {
    Query query = FirebaseFirestore.instance.collection('products');

    // Nếu không phải "Tất cả", thực hiện lọc theo danh mục
    if (selectedCategoryIndex != 0) {
      query = query.where(
        'category',
        isEqualTo: categories[selectedCategoryIndex].name,
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Đã xảy ra lỗi'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        double screenWidth = MediaQuery.of(context).size.width;
        // Tự động tính số cột: Nếu màn hình > 1200px hiện 5 cột, > 800px hiện 3 cột, còn lại 2 cột.
        int crossAxisCount = screenWidth > 1200
            ? 5
            : (screenWidth > 800 ? 3 : 2);

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('Không có sản phẩm nào'));
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            mainAxisSpacing: 12.0,
            crossAxisSpacing: 12.0,
          ),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return FoodTile(
              context,
              data['name'] ?? '',
              data['image'] ?? '',
              data['price'], // Truyền dynamic (số hoặc chuỗi từ data cũ)
              data['description'] ?? '',
              coffeeBrown,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFf4eee3);
    final coffeeBrown = const Color(0xFF6B4F35);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QDT Coffee',
                        style: TextStyle(
                          color: coffeeBrown,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đặt hàng ngay',
                        style: TextStyle(
                          color: coffeeBrown.withOpacity(0.75),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  ValueListenableBuilder<UserModel?>(
                    valueListenable: UserService.instance.userNotifier,
                    builder: (context, user, _) {
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: Row(
                            children: [
                              Text(
                                user?.username ?? '',
                                style: TextStyle(
                                  color: coffeeBrown,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: coffeeBrown,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm cà phê...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF6B4F35),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final bool selected = selectedCategoryIndex == index;
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => selectedCategoryIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(left: 4.0),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? coffeeBrown : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: coffeeBrown.withOpacity(0.15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [
                                    const BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Text(
                            categories[index].name ?? '',
                            style: TextStyle(
                              color: selected ? Colors.white : coffeeBrown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildProductGrid(coffeeBrown)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 0) return;
          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, '/order');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/wallet');
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
}

Widget FoodTile(
  BuildContext context,
  String name,
  String image,
  dynamic price,
  String description,
  Color coffeeBrown,
) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(
              image: image,
              name: name,
              price: price,
              description: description,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFf4eee3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: image.startsWith('http')
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      )
                    : Image.asset(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: coffeeBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price is num
                        ? "${price.toStringAsFixed(0)}k"
                        : price.toString(),
                    style: TextStyle(
                      color: coffeeBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CategoryTitle extends StatelessWidget {
  final String name;
  const CategoryTitle({required this.name, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Color(0xFF6B4F35),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
