import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class HttpScreen extends StatefulWidget {
  const HttpScreen({super.key});

  @override
  State<HttpScreen> createState() => _HttpScreenState();
}

class _HttpScreenState extends State<HttpScreen> {
  static const int _port = 4041;

  String _statusText = 'Starting...';
  HttpServer? _server;
  StreamSubscription<HttpRequest>? _requestsSubscription;

  @override
  void initState() {
    HttpServer.bind(InternetAddress.anyIPv4, _port).then((server) {
      _server = server;
      _requestsSubscription = server.listen(_requestHandler);

      setState(() {
        _statusText = 'Ready';
      });
    }).catchError((error) {
      setState(() {
        _statusText = error.toString();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    Future.microtask(() async {
      await _requestsSubscription?.cancel();
      await _server?.close(force: true);
    }).catchError((e) {
      print(e);
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Http Server'),
      ),
      body: Column(
        children: [
          Text(_statusText),
          const CircularProgressIndicator(),
          Flexible(child: Container()),
        ],
      ),
    );
  }

  void _requestHandler(HttpRequest request) {
    request.response
      ..headers.contentType = ContentType('text', 'plain', charset: 'utf-8')
      ..write('Hello, world')
      ..close();
  }
}
