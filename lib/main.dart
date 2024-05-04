import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ipix/src/rust/api/async_spawn.dart';
import 'package:ipix/src/rust/api/simple.dart';
import 'package:ipix/src/rust/frb_generated.dart';
import 'package:window_manager/window_manager.dart';

Future setupLogger() async {
  setupLogStream().listen((msg) {
    // This should use a logging framework in real applications
    // and this will not be showed on mobile devices
    // ignore: avoid_print
    print("${msg.logLevel} ${msg.lbl.padRight(8)}: ${msg.msg}");
  });
}

Future<void> main() async {
  await RustLib.init();
  await setupLogger();
  //needed to ensure binding was initialized
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS) {
    //macOS相关代码
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitle('iPix');
    });
  }
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
    // fetchIp();
    super.initState();
  }

  void fetchIp() {
    getIp().then((value) {
      setState(() => ip = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('iPix')),
        body: Column(
          children: [
            Row(children: [
              Text(
                  'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")},async function: $ip`'),
            ]),
            Row(children: [
              ElevatedButton(
                child: const Text("请求网络"),
                onPressed: () {
                  fetchIp();
                },
              )
            ])
          ],
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
