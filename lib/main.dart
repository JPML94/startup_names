import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:english_words/english_words.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/scheduler.dart' show timeDilation;

void main() => runApp(new MyApp());

//Animation Page Start
class StaggerDemo extends StatefulWidget {
  @override
  _StaggerDemoState createState() => new _StaggerDemoState();
}

class _StaggerDemoState extends State<StaggerDemo>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // the animation go cancelled, probably because we were disposed
    }
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 1.0; //1.0 is normal animation speed
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Staggered Animation'),
      ),
      body: new GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _playAnimation();
        },
        child: new Center(
          child: new Container(
            width: 300.0,
            height: 300.0,
            decoration: new BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              border: new Border.all(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            child: new StaggerAnimation(controller: _controller.view),
          ),
        ),
      ),
    );
  }
}

class StaggerAnimation extends StatelessWidget {
  StaggerAnimation({Key key, this.controller})
      :

        // Each animation defined here transforms its value during the subset
        // of the controller's duration defined by the animation's interval.
        // For example the opacity animation transforms its value during
        // the first 10% of the controller's duration.

        opacity = new Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.0,
              0.100,
              curve: Curves.ease,
            ),
          ),
        ),
        width = new Tween<double>(
          begin: 50.0,
          end: 150.0,
        ).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.125,
              0.250,
              curve: Curves.ease,
            ),
          ),
        ),
        height = new Tween<double>(begin: 50.0, end: 150.0).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.250,
              0.375,
              curve: Curves.ease,
            ),
          ),
        ),
        padding = new EdgeInsetsTween(
          begin: const EdgeInsets.only(bottom: 16.0),
          end: const EdgeInsets.only(bottom: 75.0),
        ).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.250,
              0.375,
              curve: Curves.ease,
            ),
          ),
        ),
        borderRadius = new BorderRadiusTween(
          begin: new BorderRadius.circular(4.0),
          end: new BorderRadius.circular(75.0),
        ).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.375,
              0.500,
              curve: Curves.ease,
            ),
          ),
        ),
        color = new ColorTween(
          begin: Colors.indigo[100],
          end: Colors.teal[400],
        ).animate(
          new CurvedAnimation(
            parent: controller,
            curve: new Interval(
              0.500,
              0.750,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final Animation<double> controller;
  final Animation<double> opacity;
  final Animation<double> width;
  final Animation<double> height;
  final Animation<EdgeInsets> padding;
  final Animation<BorderRadius> borderRadius;
  final Animation<Color> color;

  // This function is called each the controller "ticks" a new frame.
  // When it runs, all of the animation's values will have been
  // updated to reflect the controller's current value.
  Widget _buildAnimation(BuildContext context, Widget child) {
    return new Container(
      padding: padding.value,
      alignment: Alignment.bottomCenter,
      child: new Opacity(
        opacity: opacity.value,
        child: new Container(
          width: width.value,
          height: height.value,
          decoration: new BoxDecoration(
            color: color.value,
            border: new Border.all(
              color: Colors.black,
              width: 3.0,
            ),
            borderRadius: borderRadius.value,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red[800],
        accentColor: Colors.cyan[600],
      ),
      home: new RandomWords(),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = new Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Startup Name Generator',
            style: new TextStyle(fontSize: 15.0)),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved),
          new IconButton(icon: new Icon(Icons.image), onPressed: _pushGallery),
          new IconButton(
              icon: new Icon(Icons.arrow_downward), onPressed: _pushRequest),
          new IconButton(
              icon: new Icon(Icons.beach_access), onPressed: _pushAnimation)
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  Widget _buildSuggestions() {
    return new ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return new Divider();
          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final alreadySaved = _saved.contains(pair);
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      leading: const Icon(Icons.fingerprint),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              return new ListTile(
                title: new Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = ListTile
              .divideTiles(
                context: context,
                tiles: tiles,
              )
              .toList();

          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }

  void _pushGallery() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new Scaffold(
          appBar: new AppBar(
            title: new Text('Image Gallery'),
          ),
          body: new Center(
              child: new ListView(children: [
            new Image.asset('images/pic.jpg'),
            new Image.asset('images/pic2.jpg'),
            new Image.asset('images/pic3.jpg'),
            new Image.asset('images/pic4.jpg'),
            new Image.asset('images/pic5.jpg'),
          ])));
    }));
  }

  var _ipAddress = 'Unkown';
  _getIPAddress() async {
    var url = 'https://httpbin.org/ip';
    var httpClient = new HttpClient();

    String result;
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == HttpStatus.OK) {
        var jsonString = await response.transform(utf8.decoder).join();
        var data = json.decode(jsonString);
        result = data['origin'];
      } else {
        result =
            'Error getting IP address:\nHttp status ${response.statusCode}';
      }
    } catch (exception) {
      result = 'Failed getting IP address';
    }
    if (!mounted) return;

    setState(() {
      _ipAddress = result;
    });
  }

  void _pushRequest() {
    Navigator.of(context).push(
      new MaterialPageRoute(builder: (context) {
        var spacer = new SizedBox(height: 32.0);

        return new Scaffold(
          appBar: new AppBar(
            title: new Text('Request Gallery'),
          ),
          body: new Center(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text('You current IP address is:'),
                new Text('$_ipAddress.'),
                spacer,
                new RaisedButton(
                  onPressed: _getIPAddress,
                  child: new Text('Get IP address'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _pushAnimation() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return new StaggerDemo();
    }));
  }
}
// unsplash application id = 23684
// unsplash callback urls = urn:ietf:wg:oauth:2.0:oob
// access key for unsplash = ded6ae126aa681e085f81e0d26dc44b93d1f378a6279a5a933a41fcc1c961f0b
// secret key for unsplash = bd52b00b643aaf97a97f6d2f58bae26ebe96b95895e7bdc4b09309a11bb7e619
// auth code for unsplash = 1939821a1147529433356916d5205d57b4db4e4f443ff874b1d473784e7023ad
