import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Anim search bar Example',
      home: App(),
    );
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  TextEditingController textController = TextEditingController();
  final items = List<SuggestionItem>.generate(
    3,
    (i) => SuggestionItem(name: 'Sender $i', type: 'Message body $i'),
  );

  final _controller = SuggestionController(count: 3);

  void updateSuggestionState() {
    if (textController.text.isNotEmpty) {
      setState(() {
        _controller
            .setItems(items.take(textController.text.length % 3 + 1).toList());
      });
    }
  }

  @override
  void initState() {
    super.initState();

    textController.addListener(updateSuggestionState);
  }

  @override
  void dispose() {
    super.dispose();

    textController.removeListener(updateSuggestionState);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        /// In AnimSearchBar widget, the width, textController, onSuffixTap are required properties.
        /// You have also control over the suffixIcon, prefixIcon, helpText and animationDurationInMilli
        child: AnimSearchBar(
          width: 400,
          textController: textController,
          onSuffixTap: () {
            setState(() {
              _controller.clear(context);
              textController.clear();
            });
          },
          suggestionController: _controller,
        ),
      ),
    );
  }
}
