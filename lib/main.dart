import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'models/message.dart';
import 'services/service_locator.dart';
import 'view_models/message_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  setupServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: serviceLocator.allReady(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 2.0),
          );
        }

        if (snapshot.hasError) {
          showDialog(
              context: ctx,
              builder: (_) {
                return CupertinoAlertDialog(
                  content: Text(snapshot.error.toString()),
                );
              });
          return Container();
        }

        return ChangeNotifierProvider.value(
          value: serviceLocator<MessageViewModel>(),
          child: const StartMyApp(),
        );
      },
    );
  }
}

class StartMyApp extends StatelessWidget {
  const StartMyApp({Key? key}) : super(key: key);

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
  late final MessageViewModel _model;

  StreamSubscription? _backupProgressSub, _restoreProgressSub;
  bool _isUploading = false;
  bool _isDownloading = false;

  @override
  void initState() {
    _model = context.read<MessageViewModel>();
    super.initState();
  }

  @override
  void dispose() {
    if (_isUploading && _backupProgressSub != null) {
      _backupProgressSub!.cancel();
    }

    if (_isDownloading && _restoreProgressSub != null) {
      _restoreProgressSub!.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: _backupMessages,
            icon: const Icon(Icons.cloud_upload),
          ),
          IconButton(
            onPressed: _restoreMessages,
            icon: const Icon(Icons.cloud_download),
          ),
          IconButton(
            onPressed: _deleteMessages,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(
                height: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const <Widget>[
                    MessageList(),
                    MessageTextInput(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _backupMessages() async {
    Future? progressDialog = Dialog.progressDialog(
      context,
      'Backup in progress',
    );

    await _model.uploadMessages((Stream<double> stream) async {
      void Function(double) onData;
      void Function() onDone;
      Function onError;

      onData = (progress) => developer.log('UPLOAD PROGRESS: $progress');

      onDone = () {
        developer.log('UPLOAD COMPLETED');
        if (progressDialog != null) {
          Navigator.of(context).pop();
          progressDialog = null;
        }
        _isUploading = false;
      };

      onError = (err) {
        developer.log('Failed to upload file by error($err)');
        if (progressDialog != null) {
          Navigator.of(context).pop();
          progressDialog = null;
        }
        _isUploading = false;
      };

      _isUploading = true;

      _backupProgressSub = stream.listen(
        onData,
        onDone: onDone,
        onError: onError,
        cancelOnError: true,
      );
    });
  }

  Future<void> _restoreMessages() async {
    Future? progressDialog = Dialog.progressDialog(
      context,
      'Restore in progress',
    );

    await _model.downloadMessages((Stream<double> stream) async {
      void Function(double) onData;
      void Function() onDone;
      Function onError;

      onData = (progress) => developer.log('DOWNLOAD PROGRESS: $progress');

      onDone = () async {
        developer.log('DOWNLOAD COMPLETED');
        if (progressDialog != null) {
          Navigator.of(context).pop();
          progressDialog = null;
        }
        _isDownloading = false;
        await _model.reloadMessages();
      };

      onError = (err) {
        developer.log('Failed to download file by error($err)');
        if (progressDialog != null) {
          Navigator.of(context).pop();
          progressDialog = null;
        }
        _isDownloading = false;
      };

      _isDownloading = true;

      _restoreProgressSub = stream.listen(
        onData,
        onDone: onDone,
        onError: onError,
        cancelOnError: true,
      );
    });
  }

  Future<void> _deleteMessages() async {
    Dialog.progressDialog(
      context,
      'Deleting...',
    );
    await _model.deleteMessages();
    Future.delayed(
      const Duration(seconds: 1),
      () async {
        Navigator.of(context).pop();
        await _model.reloadMessages();
      },
    );
  }
}
//------------------------------------------------------------------------------
// Message List
//------------------------------------------------------------------------------

class MessageList extends StatefulWidget {
  const MessageList({Key? key}) : super(key: key);

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late Future<bool> _readMessagesFuture;

  @override
  void initState() {
    _readMessagesFuture = context.read<MessageViewModel>().readAll();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
          showDialog(
              context: ctx,
              builder: (_) {
                return CupertinoAlertDialog(
                  content: Text(snapshot.error.toString()),
                );
              });
          return Container();
        }

        return Expanded(
          child: SizedBox(
            child: ListView.builder(
                // itemCount: messages.length,
                itemCount: context.watch<MessageViewModel>().messages.length,
                itemBuilder: (_, i) {
                  return MessageListItem(
                    message:
                        context.watch<MessageViewModel>().messages[i].message,
                    date: context
                        .watch<MessageViewModel>()
                        .messages[i]
                        .createdTime
                        .toString(),
                  );
                }),
          ),
        );
      },
    );
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
//------------------------------------------------------------------------------
// Message Input
//------------------------------------------------------------------------------

class MessageTextInput extends StatefulWidget {
  const MessageTextInput({Key? key}) : super(key: key);

  @override
  State<MessageTextInput> createState() => _MessageTextInputState();
}

class _MessageTextInputState extends State<MessageTextInput> {
  final _messageController = TextEditingController();

  late final MessageViewModel _model;

  @override
  void initState() {
    _model = context.read<MessageViewModel>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
    // setState(() {});
    _messageController.text = '';
    FocusScope.of(context).unfocus();
    return;
  }
}

//------------------------------------------------------------------------------
// Dialog
//------------------------------------------------------------------------------
class Dialog {
  static Future progressDialog(BuildContext context, String message) {
    Widget dialogContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyText2!.fontSize),
        ),
      ],
    );

    Widget dialog = (Platform.isIOS)
        ? CupertinoAlertDialog(content: dialogContent)
        : AlertDialog(content: dialogContent);

    return showDialog(
      context: context,
      builder: (_) {
        return WillPopScope(child: dialog, onWillPop: () async => false);
      },
    );
  }
}
