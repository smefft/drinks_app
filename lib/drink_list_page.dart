import 'package:flutter/material.dart';
import 'package:drinks_app/drinks.dart';
import 'package:drinks_app/drink_page.dart';

class DrinkListPage extends StatefulWidget {
  final String spirit;
  const DrinkListPage({super.key, required this.spirit});

  @override
  State<DrinkListPage> createState() => _DrinkListPageState();
}

class _DrinkListPageState extends State<DrinkListPage> {
  late Future<DrinkList> _futureDrinkList;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _futureDrinkList = fetchDrinkListFromSpirit(widget.spirit);
  }

  void _loadSpirit() {
    setState(() {
      _loading = true;
      _futureDrinkList = fetchDrinkListFromSpirit(widget.spirit).whenComplete(
        () {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
        },
      );
    });
  }

  String getSubtitle(Drink drink) {
    List<String> ingredients = drink.drinkIngredients!.keys.toList();
    // first ingredient should be the spirit
    if (ingredients[0].toLowerCase() == widget.spirit) {
      ingredients.remove(ingredients[0]);
    }
    return ingredients.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.spirit)),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
        child: FutureBuilder<DrinkList>(
          future: _futureDrinkList,
          builder: (context, snapshot) {
            // While loading, show a spinner
            if (snapshot.connectionState == ConnectionState.waiting ||
                _loading) {
              return const CircularProgressIndicator();
            }

            // If there was an error, show it + Retry button
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _loadSpirit(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final drinklist = snapshot.data!;
            return ListView(
              children: drinklist.drinkList
                  .map(
                    (drink) => ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DrinkPage(drink: drink),
                          ),
                        );
                      },
                      minTileHeight: 100.0,
                      title: Text(drink.drinkName),
                      subtitle: Text(
                        getSubtitle(drink),
                        style: TextStyle(fontSize: 10.0),
                      ),
                      leading: drink.drinkPicture != null
                          ? Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30.0),
                                child: Image.network(drink.drinkPicture!),
                              ),
                            )
                          : CircleAvatar(),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
    );
  }
}
