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

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); //Keep track of Apps State at ALL TIMES
    var pair = appState.current;

    IconData icon;
    if(appState.favorites.contains(pair)){
      icon = Icons.favorite;
    }else{
      icon = Icons.favorite_border;
    }

    return Scaffold(                            //Every build() must return a Widget to be viewed
      body: Center(                                     //Place column to be centered horizontally on Scaffold view
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  //Place Content vertically center 
          children: [
            BigCard(pair: pair),
            SizedBox(height: 10),               //An invisible box to create seperation
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
                SizedBox(width: 10,),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),
              ],
            )
          ],
        ),
      ),
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