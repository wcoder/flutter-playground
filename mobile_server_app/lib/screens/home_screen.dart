import 'package:flutter/material.dart';
import 'package:mobile_server_app/screens/http_screen.dart';
import 'package:mobile_server_app/screens/tcp_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Mobile Server Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const TcpScreen(),
                  ),
                );
              },
              child: const Text('Tcp Server'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const HttpScreen(),
                  ),
                );
              },
              child: const Text('Http Server'),
            ),
          ],
        ),
      ),
    );
  }
}
