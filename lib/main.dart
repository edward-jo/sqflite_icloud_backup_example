import 'dart:developer' as developer;
import 'package:flutter/material.dart';

import 'models/message.dart';

void main() {
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
  final _messageController = TextEditingController();
  List<Message> _messages = [];

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
                child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      return MessageListItem(
                        message: _messages[i].message,
                        date: _messages[i].createdTime.toString(),
                      );
                    }),
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
    setState(() {
      _messages.add(
        Message(
          id: null,
          message: _messageController.text.trim(),
          createdTime: DateTime.now(),
        ),
      );
    });
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
              Text(message ?? 'Empty message'),
              Text(date ?? 'Empty date'),
            ],
          ),
        )
      ],
    );
  }
}
