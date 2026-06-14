import 'package:coffee_app/model/category_model.dart';

List<CategoryModel> getCategories() {
  List<CategoryModel> category = [];
  CategoryModel categoryModel = new CategoryModel();

  categoryModel.name = "Tất cả";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.name = "Cafe nóng";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.name = "Cafe lạnh";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.name = "Trà";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  categoryModel.name = "Matcha";
  category.add(categoryModel);
  categoryModel = new CategoryModel();

  return category;
}
