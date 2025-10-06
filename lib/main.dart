import 'package:drinks_app/search_result_page.dart';
import 'package:flutter/material.dart';
import 'package:drinks_app/drink_list_page.dart';

void main() {
  runApp(MaterialApp(home: CocktailApp()));
}

class CocktailApp extends StatefulWidget {
  const CocktailApp({super.key});

  @override
  State<CocktailApp> createState() => _CocktailAppState();
}

class _CocktailAppState extends State<CocktailApp> {
  final List<String> spirits = [
    'gin',
    'tequila',
    'vodka',
    'rum',
    'whiskey',
    'brandy',
    'bourbon',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("cocktail explorer"),
        backgroundColor: Colors.grey,
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
        child: Column(
          children: [
            SearchBar(
              hintText: "Search by drink or ingredient",
              padding: WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
              leading: const Icon(Icons.search),
              onSubmitted: (value) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchResultsPage(searchTerm: value),
                  ),
                );
              },
            ),
            SizedBox(height: 15.0),
            Divider(),
            ListView(
              shrinkWrap: true,
              children: spirits
                  .map(
                    (spirit) => ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DrinkListPage(spirit: spirit),
                          ),
                        );
                      },
                      title: Text(spirit),
                    ),
                  )
                  .toList(),
            ),
            ElevatedButton(onPressed: () {}, child: Text("Random")),
          ],
        ),
      ),
    );
  }
}
