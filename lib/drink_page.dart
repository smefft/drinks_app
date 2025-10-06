import 'package:drinks_app/drinks.dart';
import 'package:flutter/material.dart';

class DrinkPage extends StatefulWidget {
  final Drink drink;
  const DrinkPage({super.key, required this.drink});

  @override
  State<DrinkPage> createState() => _DrinkPageState();
}

class _DrinkPageState extends State<DrinkPage> {
  List<Text> ingredients() {
    List<Text> ingredients = [];
    if (widget.drink.drinkIngredients != null) {
      widget.drink.drinkIngredients!.forEach(
        (ingredient, measurement) =>
            ingredients.add(Text("\t•\t${measurement ?? ""} $ingredient")),
      );
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          spacing: 10.0,
          children: [
            Center(
              child: Text(
                widget.drink.drinkName,
                style: TextStyle(fontSize: 25, overflow: TextOverflow.ellipsis),
              ),
            ),
            widget.drink.drinkPicture != null
                ? (Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Image.network(
                        "${widget.drink.drinkPicture!}/small",
                        height: 150,
                        width: 150,
                      ),
                    ),
                  ))
                : CircleAvatar(child: Text(widget.drink.drinkName)),
            Divider(),
            Expanded(
              child: ListView(
                children:
                    ingredients() +
                    [Text("\n"), Text(widget.drink.drinkInstructions ?? "")],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
