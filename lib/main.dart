import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 50, 70, 231)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext(){
    current = WordPair.random();
    notifyListeners();                          //Notify other builds that State is changed
  }

  var favorites = <WordPair>[];                 //Initialise WordPair list to store favouriteWords

  void toggleFavorite(){
    if(favorites.contains(current)){
      favorites.remove(current);
    }else{
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    Widget page;
    switch(selectedIndex){
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();                 //A generic page-screen Widget that displays a view of an unfinished page
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(                         // LayoutBuilder is used when constraints change (resize app, rotate phone, 1 widget grows in size thus effecting another's size)
      builder: (context, constraints) {           // Add 'constraints' to parameters, to be used for new app view size
        return Scaffold(                          //Every build() must return a Widget (Scaffold) to be viewed. You can add widgets under this (Expanded)
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {                       //Similar to notifyListener(), whatever change happens in the function will be updated on the view
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(                   //Greedy widget function. Takes as much of the remaining room as possible
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();     //Keep track of Apps State at ALL Times
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(                                  //Place column to be centered horizontally on View
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,  //Place content vertically center
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),                       //An invisible box to create space
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({                                   // Constructor, which ALWAYS takes super.key. Pair is added by us 
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);                // Get theme from the App's context
    final style = theme.textTheme.displayMedium!.copyWith(color: theme.colorScheme.onPrimary); //displayMedium? can potentially be null, so add ! so that code knows you're aware of this

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(pair.asLowerCase, style: style,),
      ),
    );
  }
}