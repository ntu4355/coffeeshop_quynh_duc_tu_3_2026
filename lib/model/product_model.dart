class ProductModel {
  String? id;
  String? name;
  String? image;
  double? price;
  String? description;
  String? category;

  ProductModel({
    this.id,
    this.name,
    this.image,
    this.price,
    this.description,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'price': price,
      'description': description,
      'category': category,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? id}) {
    // Hàm helper để xử lý giá từ Firestore (có thể là int hoặc double)
    double? parsePrice(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) {
        return double.tryParse(val.replaceAll(RegExp(r'[^0-9.]'), ''));
      }
      return null;
    }

    return ProductModel(
      id: id,
      name: map['name'] as String?,
      image: map['image'] as String?,
      price: parsePrice(map['price']),
      description: map['description'] as String?,
      category: map['category'] as String?,
    );
  }
}
