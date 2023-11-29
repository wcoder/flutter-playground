import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

class TcpScreen extends StatefulWidget {
  const TcpScreen({super.key});

  @override
  State<TcpScreen> createState() => _TcpScreenState();
}

class _TcpScreenState extends State<TcpScreen> {
  static const int _port = 4041;

  final Map<ClientAddress, TcpClient> _clients = {};

  String _statusText = 'Starting server on port $_port...';
  StreamSubscription<Socket>? _serverSocketSubscription;

  @override
  void initState() {
    ServerSocket.bind(InternetAddress.anyIPv4, _port).then((serverSocket) {
      _serverSocketSubscription = serverSocket.listen(
        _onClientConnected,
        onError: (error) {
          setState(() {
            _statusText = error.toString();
          });
        },
        cancelOnError: true,
      );

      setState(() {
        _statusText = 'Ready on port $_port';
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
      for (var x in _clients.entries) {
        await x.value.disconnect();
      }
    }).catchError((_) {
      print('XXX: Clients disposed');
    });

    _serverSocketSubscription?.cancel();
    _serverSocketSubscription = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text('Tcp Server'),
      ),
      body: Column(
        children: [
          Text(_statusText),
          const CircularProgressIndicator(),
          Text('Connected clients: ${_clients.length}'),
          Flexible(
            child: ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients.entries.elementAt(index);
                return Text('${client.key}');
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onClientConnected(Socket clientSocket) {
    final clientSocketSubscription = utf8.decoder.bind(clientSocket).listen(
      (event) {
        print('XXX: ${clientSocket.remoteAddress}: $event');

        clientSocket.write('response: $event\n');
      },
      onDone: () {
        print('XXX: ${clientSocket.remoteAddress}: disconnected');

        setState(() {
          final clientAddress = ClientAddress(clientSocket);
          _clients.remove(clientAddress);
        });
      },
      onError: (error) {
        print('XXX: $clientSocket: $error');
      },
      cancelOnError: true,
    );

    final client = TcpClient(
      socket: clientSocket,
      subscription: clientSocketSubscription,
    );

    if (_clients.containsKey(client.address)) {
      throw 'Duplicated client socket';
    }
    setState(() {
      _clients[client.address] = client;
    });
  }
}

class TcpClient {
  final Socket socket;
  final StreamSubscription<Object> subscription;

  late ClientAddress address;

  TcpClient({required this.socket, required this.subscription}) {
    address = ClientAddress(socket);
  }

  Future<void> disconnect() async {
    await subscription.cancel();
    socket.destroy();
  }
}

class ClientAddress {
  late String _address;

  ClientAddress(Socket socket) {
    _address = '${socket.remoteAddress.address}:${socket.remotePort}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClientAddress && other._address == _address;
  }

  @override
  int get hashCode => _address.hashCode;

  @override
  String toString() => _address;
}
