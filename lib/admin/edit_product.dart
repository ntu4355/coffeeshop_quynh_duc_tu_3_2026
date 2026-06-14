import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_app/service/widget_support.dart';
import 'package:flutter/material.dart';

class EditProduct extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const EditProduct({super.key, required this.id, required this.data});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final List<String> categories = ['Cafe nóng', 'Cafe lạnh', 'Trà', 'Matcha'];
  String? selectedCategory;

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController imageController;

  bool isLoading = false;
  final Color coffeeBrown = const Color(0xFF6B4F35);

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller với dữ liệu cũ
    nameController = TextEditingController(text: widget.data['name']);

    // Xử lý giá tiền (chuyển về dạng chuỗi để nhập liệu)
    dynamic price = widget.data['price'];
    priceController = TextEditingController(text: price?.toString() ?? '');

    descriptionController = TextEditingController(
      text: widget.data['description'],
    );
    imageController = TextEditingController(text: widget.data['image']);
    selectedCategory = widget.data['category'];
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imageController.dispose();
    super.dispose();
  }

  Future<void> updateItem() async {
    if (nameController.text.isNotEmpty &&
        priceController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        imageController.text.isNotEmpty &&
        selectedCategory != null) {
      setState(() => isLoading = true);

      try {
        double priceValue = double.tryParse(priceController.text.trim()) ?? 0.0;
        // Giữ logic chuẩn hóa giá 'k' như khi thêm
        if (priceValue > 1000) priceValue = priceValue / 1000;

        Map<String, dynamic> updateData = {
          "name": nameController.text.trim(),
          "price": priceValue,
          "description": descriptionController.text.trim(),
          "category": selectedCategory,
          "image": imageController.text.trim(),
        };

        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.id)
            .update(updateData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cập nhật sản phẩm thành công!"),
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
        const SnackBar(content: Text("Vui lòng nhập đủ thông tin!")),
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
          "Sửa sản phẩm",
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLabel("Tên sản phẩm"),
                _buildTextField(nameController, "Tên sản phẩm", Icons.coffee),
                const SizedBox(height: 20),
                _buildLabel("Giá sản phẩm"),
                _buildTextField(
                  priceController,
                  "Giá",
                  Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildLabel("URL Ảnh"),
                _buildTextField(
                  imageController,
                  "Dán URL ảnh",
                  Icons.link,
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Preview ảnh
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
                                const Center(child: Icon(Icons.broken_image)),
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
                _buildLabel("Mô tả"),
                _buildTextField(
                  descriptionController,
                  "Mô tả...",
                  Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(color: coffeeBrown),
                        ),
                        child: Text(
                          "Hủy",
                          style: TextStyle(
                            color: coffeeBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : updateItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: coffeeBrown,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Cập nhật",
                                style: AppWidget.whiteTextFieldStyle(),
                              ),
                      ),
                    ),
                  ],
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
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
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
