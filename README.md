# drinks_app

Uses the Cocktail DB: https://www.thecocktaildb.com/api.php

Example endpoint showing all drinks with a spirit:
https://www.thecocktaildb.com/api/json/v1/1/search.php?s=vodka

Example endpoint showing all drinks with names containing the search term:
https://www.thecocktaildb.com/api/json/v1/1/search.php?s=margarita

Example endpoint for searching by ingredients:
https://www.thecocktaildb.com/api/json/v1/1/filter.php?i=Gin

Example endpoint for finding a drink by id:
https://www.thecocktaildb.com/api/json/v1/1/lookup.php?i=11007

## Getting Started

To run: 
Type 'flutter run' in main directory.

User action: Search by drink name or ingredient

Edge case is weird symbols in search. App handles it by returning an empty list and saying 'No search results found'.