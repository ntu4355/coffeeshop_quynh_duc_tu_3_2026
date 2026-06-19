import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/service/widget_support.dart';
import 'package:coffee_app/service/category_data.dart';
import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  List<String> categories = [];
  String? selectedCategory;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  bool isLoading = false;

  final Color coffeeBrown = const Color(0xFF6B4F35);

  @override
  void initState() {
    super.initState();
    // Lấy danh mục từ service và lọc bỏ "Tất cả"
    categories = getCategories()
        .map((e) => e.name ?? '')
        .where((name) => name.isNotEmpty && name != "Tất cả")
        .toList();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<void> uploadItem() async {
    if (nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        imageController.text.isNotEmpty &&
        selectedCategory != null) {
      setState(() => isLoading = true);

      try {
        // Chuyển đổi giá sang số. Nếu người dùng nhập 35000 thì chia 1000 để thành 35.0
        // hoặc giữ nguyên tùy theo quy ước ví của bạn. Ở đây tôi giả định đơn vị là 'k'.
        double priceValue = double.tryParse(priceController.text.trim()) ?? 0.0;
        if (priceValue > 1000) priceValue = priceValue / 1000;

        // 2. Lưu thông tin vào Firestore với URL ảnh vừa lấy được
        Map<String, dynamic> addProduct = {
          "name": nameController.text.trim(),
          "price": priceValue,
          "description": descriptionController.text.trim(),
          "category": selectedCategory,
          "image": imageController.text.trim(),
        };

        await FirebaseFirestore.instance.collection("products").add(addProduct);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Thêm sản phẩm thành công!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
        }
      } finally {
        if (mounted) setState(() => isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn ảnh và nhập đủ thông tin!"),
        ),
      );
    }
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
          "Thêm sản phẩm mới",
          style: AppWidget.boldTextFieldStyle().copyWith(fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabel("Tên sản phẩm"),
                _buildTextField(
                  nameController,
                  "Nhập tên sản phẩm",
                  Icons.coffee,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                _buildLabel("Giá sản phẩm (vd: 35000)"),
                _buildTextField(
                  priceController,
                  "Nhập giá",
                  Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),

                _buildLabel("Đường dẫn ảnh (URL từ Imgur/PostImages)"),
                _buildTextField(
                  imageController,
                  "Dán URL ảnh tại đây",
                  Icons.link,
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Xem trước ảnh từ URL
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: imageController.text.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            imageController.text.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                  child: Text("URL ảnh không hợp lệ"),
                                ),
                          ),
                        )
                      : const Center(child: Text("Xem trước ảnh")),
                ),
                const SizedBox(height: 20),

                _buildLabel("Danh mục"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      hint: const Text("Chọn danh mục"),
                      icon: Icon(Icons.keyboard_arrow_down, color: coffeeBrown),
                      isExpanded: true,
                      items: categories.map((String item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => selectedCategory = value),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildLabel("Mô tả sản phẩm"),
                _buildTextField(
                  descriptionController,
                  "Nhập mô tả chi tiết...",
                  Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: isLoading ? null : uploadItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: coffeeBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Thêm sản phẩm",
                          style: AppWidget.whiteTextFieldStyle().copyWith(
                            fontSize: 18,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFececf8),
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.black54),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
