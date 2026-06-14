class ProductModel {
  String? id;
  String? name;
  String? image;
  String? price;
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
    return ProductModel(
      id: id,
      name: map['name'] as String?,
      image: map['image'] as String?,
      price: map['price'] as String?,
      description: map['description'] as String?,
      category: map['category'] as String?,
    );
  }
}
