import 'package:http/http.dart' as http;
import 'dart:convert';

class Drink {
  final int drinkId;
  final String drinkName;
  final String? drinkPicture;
  final Map<String, String?>? drinkIngredients;
  final String? drinkInstructions;
  const Drink({
    required this.drinkId,
    required this.drinkName,
    this.drinkPicture,
    this.drinkIngredients,
    this.drinkInstructions,
  });

  factory Drink.fromJson(Map<String, dynamic> json) {
    int drinkId = int.parse(json['idDrink']);
    String drinkName = json['strDrink'];
    String? drinkPicture = json['strDrinkThumb'];
    if (drinkPicture != null && !drinkPicture.startsWith('http')) {
      drinkPicture = 'https://$drinkPicture';
    }
    String? drinkInstructions = json['strInstructions'];

    // In the API, ingredients are in fields named strIngredient1, 2, etc.
    // The same with measurements being strMeasurement1, 2, etc.
    // Each drink has up to 15 ingredients but mostly they start just being
    // null at some point
    Map<String, String?> drinkIngredients = {};
    int ingredientCount = 1;
    while (json["strIngredient$ingredientCount"] != null) {
      String ingredient = json["strIngredient$ingredientCount"];
      String? measurement = json["strMeasure$ingredientCount"];
      drinkIngredients[ingredient] = measurement;
      ingredientCount += 1;
    }

    return Drink(
      drinkId: drinkId,
      drinkName: drinkName,
      drinkPicture: drinkPicture,
      drinkInstructions: drinkInstructions,
      drinkIngredients: drinkIngredients,
    );
  }
}

class DrinkList {
  final List<Drink> drinkList;
  const DrinkList({required this.drinkList});

  factory DrinkList.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'drinks': null} => DrinkList(drinkList: []),
      {'drinks': 'no data found'} => DrinkList(drinkList: []),
      {'drinks': List listOfDrinks} => DrinkList(
        drinkList: listOfDrinks.map((drink) => Drink.fromJson(drink)).toList(),
      ),
      _ => throw const FormatException('Failed to load drink list'),
    };
  }
}

Future<DrinkList> fetchDrinkListFromSpirit(String spirit) async {
  final uri = Uri.parse(
    'https://www.thecocktaildb.com/api/json/v1/1/search.php?s=$spirit',
  );

  final result = await http.get(uri).timeout(const Duration(seconds: 10));
  if (result.statusCode == 200) {
    return DrinkList.fromJson(jsonDecode(result.body) as Map<String, dynamic>);
  } else {
    throw Exception(
      'Failed to load drinks with spirit $spirit (HTTP ${result.statusCode})',
    );
  }
}

Future<Drink> searchId(String id) async {
  final uri = Uri.parse(
    'https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=$id',
  );
  final result = await http
      .get(uri)
      .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw Exception("Request timed out");
        },
      );
  if (result.statusCode == 200) {
    final resultBody = jsonDecode(result.body);
    Map<String, dynamic> drink = resultBody['drinks']![0];
    return Drink.fromJson(drink);
  } else {
    throw FormatException("Couldn't load drink with id $id");
  }
}

Future<DrinkList> search(String searchTerm) async {
  final duration = Duration(seconds: 10);
  // first see if search term is contained in drink names
  final nameUri = Uri.parse(
    'https://www.thecocktaildb.com/api/json/v1/1/search.php?s=${searchTerm.toLowerCase()}',
  );
  final drinkResult = await http
      .get(nameUri)
      .timeout(
        duration,
        onTimeout: () {
          throw Exception("Request timed out");
        },
      );
  if (drinkResult.statusCode == 200 &&
      jsonDecode(drinkResult.body)['drinks'] != null) {
    // normal drink list
    return DrinkList.fromJson(
      jsonDecode(drinkResult.body) as Map<String, dynamic>,
    );
  } else {
    // if no drink names contain the search term, look for drinks with that ingredient
    final ingredientUri = Uri.parse(
      'https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=${searchTerm.toLowerCase()}',
    );

    final ingredientResult = await http
        .get(ingredientUri)
        .timeout(
          duration,
          onTimeout: () {
            throw Exception("Request timed out");
          },
        );
    if (ingredientResult.statusCode == 200) {
      final body = jsonDecode(ingredientResult.body);
      final drinks = body['drinks'];
      // no matching drinks, return empty list
      if (drinks == null || drinks == 'no data found' || drinks == []) {
        return DrinkList(drinkList: []);
      }
      // this search only returns the id, name, and picture.
      // Need whole drink for drinklist
      List<Drink> listOfDrinks = [];
      for (int i = 0; i < drinks.length; i++) {
        final drink = drinks[i];
        final drinkId = drink['idDrink'];
        // fetch each drink
        final Drink drinkObj = await searchId(drinkId);
        listOfDrinks.add(drinkObj);
      }
      // return populated drink list
      return DrinkList(drinkList: listOfDrinks);
    } else {
      throw Exception('Error code ${ingredientResult.statusCode}');
    }
  }
}
