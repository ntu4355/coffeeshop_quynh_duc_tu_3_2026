import 'package:coffee_app/model/hotcoffee_model.dart';

List<HotCoffeeModel> getHotCoffee() {
  List<HotCoffeeModel> hotCoffee = [];
  HotCoffeeModel hotCoffeeModel = new HotCoffeeModel();

  hotCoffeeModel.name = "Caramel Cappuccino";
  hotCoffeeModel.image = "images/CaramelCappuccino.png";
  hotCoffeeModel.price = "50k";
  hotCoffeeModel.description =
      "Caramel Cappuccino là sự kết hợp hoàn hảo giữa cà phê espresso đậm đà, sữa tươi mịn màng và lớp caramel ngọt ngào. Hương vị cân bằng giữa đắng và ngọt, tạo nên một trải nghiệm thưởng thức cà phê độc đáo và hấp dẫn.";
  hotCoffee.add(hotCoffeeModel);
  hotCoffeeModel = new HotCoffeeModel();

  hotCoffeeModel.name = "Nâu nóng";
  hotCoffeeModel.image = "images/NauNong.png";
  hotCoffeeModel.price = "25k";
  hotCoffeeModel.description =
      "Nâu nóng là một lựa chọn phổ biến, với hương vị cà phê đậm đà và vị ngọt nhẹ.";
  hotCoffee.add(hotCoffeeModel);
  hotCoffeeModel = new HotCoffeeModel();

  hotCoffeeModel.name = "Đen nóng";
  hotCoffeeModel.image = "images/DenNong.png";
  hotCoffeeModel.price = "25k";
  hotCoffeeModel.description =
      "Đen nóng là cà phê đen nguyên chất, có hương vị mạnh mẽ và đậm đà.";
  hotCoffee.add(hotCoffeeModel);
  hotCoffeeModel = new HotCoffeeModel();

  return hotCoffee;
}
