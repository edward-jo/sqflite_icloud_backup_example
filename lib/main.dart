import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'models/message.dart';
import 'services/service_locator.dart';
import 'view_models/message_viewmodel.dart';

Future<void> main() async {
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Main Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MessageViewModel _model = serviceLocator<MessageViewModel>();
  final _messageController = TextEditingController();
  late Future<bool> _readMessagesFuture;

  @override
  void initState() {
    _readMessagesFuture = _model.readAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // MESSAGE LIST
              Expanded(
                child: FutureBuilder(
                  future: _readMessagesFuture,
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      );
                    }

                    if (snapshot.hasError) {
                      CupertinoAlertDialog(
                        content: Text(snapshot.error.toString()),
                      );
                      return Container();
                    }

                    return ListView.builder(
                        itemCount: _model.messages.length,
                        itemBuilder: (_, i) {
                          return MessageListItem(
                            message: _model.messages[i].message,
                            date: _model.messages[i].createdTime.toString(),
                          );
                        });
                  },
                ),
              ),
              // TEXT INPUT & SAVE
              Container(
                color: const Color(0xFFEBECED),
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      maxLines: 1,
                      controller: _messageController,
                      decoration: const InputDecoration(
                        // labelText: 'New message',
                        hintText: 'New message',
                        hintStyle: TextStyle(fontSize: 12),
                      ),
                      onSubmitted: null,
                    ),
                    TextButton(
                      onPressed: () => _save(context),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _save(BuildContext context) async {
    developer.log('Save message( ${_messageController.text.trim()} )');
    await _model.save(
      Message(
        id: null,
        message: _messageController.text.trim(),
        createdTime: DateTime.now(),
      ),
    );
    setState(() {});
    _messageController.text = '';
    FocusScope.of(context).unfocus();
    return;
  }
}

class MessageListItem extends StatelessWidget {
  final String? message, date;
  const MessageListItem({
    Key? key,
    @required this.message,
    @required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(bottom: 2.0),
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color(0xFFFAEBDD),
              borderRadius: BorderRadius.all(Radius.circular(5))),
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                message ?? 'Empty message',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 3.0),
              Text(
                date ?? 'Empty date',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9B9A97)),
              ),
            ],
          ),
        )
      ],
    );
  }
}
