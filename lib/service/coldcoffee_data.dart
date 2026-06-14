import 'package:coffee_app/model/coldcoffee_model.dart';

List<ColdCoffeeModel> getColdCoffee() {
  List<ColdCoffeeModel> coldCoffee = [];
  ColdCoffeeModel coldCoffeeModel = new ColdCoffeeModel();

  coldCoffeeModel.name = "Bạc Xỉu";
  coldCoffeeModel.image = "images/BacXiu.png";
  coldCoffeeModel.price = "50k";
  coldCoffeeModel.description =
      "Bạc Xỉu là một loại cà phê sữa đá phổ biến, với hương vị ngọt ngào và mát lạnh, tạo nên một trải nghiệm thưởng thức cà phê độc đáo và hấp dẫn.";
  coldCoffee.add(coldCoffeeModel);
  coldCoffeeModel = new ColdCoffeeModel();

  coldCoffeeModel.name = "Nâu đá";
  coldCoffeeModel.image = "images/NauDa.png";
  coldCoffeeModel.price = "25k";
  coldCoffeeModel.description =
      "Nâu đá là một lựa chọn phổ biến, với hương vị cà phê mát lạnh và vị ngọt nhẹ.";
  coldCoffee.add(coldCoffeeModel);
  coldCoffeeModel = new ColdCoffeeModel();

  coldCoffeeModel.name = "Đen đá";
  coldCoffeeModel.image = "images/DenDa.png";
  coldCoffeeModel.price = "25k";
  coldCoffeeModel.description =
      "Đen đá là cà phê đen nguyên chất, có hương vị mạnh mẽ và đậm đà.";
  coldCoffee.add(coldCoffeeModel);
  coldCoffeeModel = new ColdCoffeeModel();

  return coldCoffee;
}
