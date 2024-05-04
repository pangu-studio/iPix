import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:ipix/src/rust/api/async_spawn.dart';
import 'package:ipix/src/rust/api/simple.dart';
import 'package:ipix/src/rust/frb_generated.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  await RustLib.init();
  //needed to ensure binding was initialized
  WidgetsFlutterBinding.ensureInitialized();

  await WindowManager.instance.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle('iPix');
  });
  runApp(const HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // const MyApp({super.key});
  var ip = '';

  @override
  void initState() {
    getIp().then((value) {
      setState(() => ip = value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('iPix')),
        body: Center(
          child: Text(
              'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")},async function: $ip`'),
        ),
      ),
    );
  }
}

Future<String> getIp() async {
  try {
    var ip = await simpleUseAsyncSpawn(arg: "tom");
    return ip;
  } catch (e) {
    print(e);
  }
  return '';
}
