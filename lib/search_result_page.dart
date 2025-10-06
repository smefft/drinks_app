import 'package:flutter/material.dart';
import 'package:drinks_app/drinks.dart';
import 'package:drinks_app/drink_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchTerm;
  const SearchResultsPage({super.key, required this.searchTerm});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late Future<DrinkList> _searchResults;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _searchResults = search(widget.searchTerm);
  }

  void _loadSearchResult() {
    setState(() {
      _loading = true;
      _searchResults = fetchDrinkListFromSpirit(widget.searchTerm).whenComplete(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text("Search Results: '${widget.searchTerm}'"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
        child: FutureBuilder<DrinkList>(
          future: _searchResults,
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
                      onPressed: () => _loadSearchResult(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final drinklist = snapshot.data!;

            if (drinklist.drinkList.isEmpty) {
              return Center(child: Text('No results found'));
            } else {
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
            }
          },
        ),
      ),
    );
  }
}
