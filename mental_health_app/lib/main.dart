import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;

void main() => runApp(new MyApp());

Future<String> fetchid() async {
  final response = await http.get(Uri.parse(globals.base_url + 'init'));
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print("Response session ID: " + response.body);
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print("Didn't receive a 200 code! Response code: " +
        response.statusCode.toString());
    throw Exception('Failed to load album');
  }
}

Future<String> fetchmsg(id, msg) async {
  var parsed = Uri.parse(globals.base_url + 'bot?id=' + id + '&msg=' + msg);
  print("Parsed: " + parsed.toString());
  final response = await http.get(parsed);
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    print("Received response: " + response.body);
    return response.body;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    print("Didn't receive a 200 code! Response code: " +
        response.statusCode.toString());
    throw Exception('Failed to load album');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'MLH Hacks App!',
      theme: new ThemeData(
        primarySwatch: Colors.cyan,
      ),
      debugShowCheckedModeBanner: false,
      home: new HomePage(
        title: 'Home Page!',
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  Widget getButtons(BuildContext context, int i) {
    // return <Widget>[
    if (i == 0)
      return new Text("Hi! My name is " +
          globals.bot_name +
          ", your friendly Pysch bot. Click below to get started.");
    else {
      return new ElevatedButton(
          onPressed: () {
            fetchid().then((String some_id) {
              globals.session = some_id;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(
                            title: '',
                          )));
            });
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.chat),
              Text(" Get Started!", textAlign: TextAlign.center)
            ],
          ));
      // ];
    }
  }

  Widget _buildButtonsComposer() {
    return new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new ListView.separated(
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 20,
            );
          },
          itemCount: 2,
          itemBuilder: (BuildContext ctx, int i) {
            return Card(child: getButtons(ctx, i));
          },
          shrinkWrap: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Home Page"),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            // decoration: new BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildButtonsComposer(),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  ChatPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _ChatPage createState() => new _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _textController = new TextEditingController();

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration:
                    new InputDecoration.collapsed(hintText: "Send a message"),
              ),
            ),
            new Container(
              margin: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new IconButton(
                  icon: new Icon(Icons.send),
                  onPressed: () => _handleSubmitted(_textController.text)),
            ),
          ],
        ),
      ),
    );
  }

  void Response(query) async {
    // _textController.clear();
    // AuthGoogle authGoogle =
    //     await AuthGoogle(fileJson: "assets/credentials.json")
    //         .build();
    // Dialogflow dialogflow =
    //     Dialogflow(authGoogle: authGoogle, language: Language.english);
    // AIResponse response = await dialogflow.detectIntent(query);
    fetchmsg(globals.session, globals.user_history.last).then((String result) {
      ChatMessage message = new ChatMessage(
        text: result,
        name: globals.bot_name,
        type: false,
      );
      setState(() {
        _messages.insert(0, message);
      });
    });
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    globals.user_history.add(text);
    ChatMessage message = new ChatMessage(
      text: text,
      name: "Me",
      type: true,
    );
    setState(() {
      _messages.insert(0, message);
    });
    Response(text);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: new Text("Mental Health Chat Bot"),
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
          padding: new EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (_, int index) => _messages[index],
          itemCount: _messages.length,
        )),
        new Divider(height: 1.0),
        new Container(
          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          child: _buildTextComposer(),
        ),
      ]),
    );
  }
}

class ChatMessage extends StatelessWidget {
  ChatMessage({required this.text, required this.name, required this.type});

  final String text;
  final String name;
  final bool type;

  List<Widget> otherMessage(context) {
    return <Widget>[
      new Container(
        margin: const EdgeInsets.only(right: 16.0),
        child: new CircleAvatar(child: new Text('B')),
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(this.name,
                style: new TextStyle(fontWeight: FontWeight.bold)),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(text),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> myMessage(context) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(this.name, style: Theme.of(context).textTheme.subtitle1),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: new Text(text),
            ),
          ],
        ),
      ),
      new Container(
        margin: const EdgeInsets.only(left: 16.0),
        child: new CircleAvatar(
            child: new Text(
          this.name[0],
          style: new TextStyle(fontWeight: FontWeight.bold),
        )),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: this.type ? myMessage(context) : otherMessage(context),
      ),
    );
  }
}
