import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ipix/src/rust/api/async_spawn.dart';
import 'package:ipix/src/rust/api/simple.dart';
import 'package:ipix/src/rust/frb_generated.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:logger/logger.dart';

var logger = Logger();

Future<void> main() async {
  // Initialize the Rust library
  RustLib.init();

  // Desktop platform brige flutter logger for debugging
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await setupLogger();
  }
  // Ensure that the WidgetsBinding is initialized before calling flutter api
  WidgetsFlutterBinding.ensureInitialized();
  // init database
  await setupDatabase();

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
    var ip = await simpleUseAsyncSpawn(arg: "test");
    logger.d("ip: $ip");
    return ip;
  } catch (e) {
    logger.e("error: $e");
  }
  return '';
}

// setup logger for desktop platform
Future setupLogger() async {
  setupLogStream().listen((msg) {
    var level = msg.logLevel.toString().replaceAll("Level.", "");
    var dt = DateTime.now();
    var fdt = DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
    // This should use a logging framework in real applications
    // and this will not be showed on mobile devices
    // ignore: avoid_print
    print("$fdt [${level.padRight(5)}] [${msg.lbl.padRight(12)}]: ${msg.msg}");
  });
}

Future<void> setupDatabase() async {
  try {
    // init database
    // db_path refering sqflite getDatabasesPath
    String dbPath;
    if (Platform.isAndroid) {
      // for Android /data/user/0/**/databases/data.db
      // getApplicationDocumentsDirectory() return /data/user/0/**/app_flutter
      // replace /app_flutter with /databases
      var docDir = await getApplicationDocumentsDirectory();
      var dbDirPath = join(docDir.parent.path, "databases");
      Directory dbDir = Directory(dbDirPath);

      // create database directory if not exists
      if (!dbDir.existsSync()) {
        dbDir.createSync(recursive: true);
      }
      dbPath = dbDir.path;
    } else {
      // for iOS /var/mobile/Containers/Data/Application/**/Documents/data.db
      var dir = await getApplicationDocumentsDirectory();
      dbPath = dir.path;
    }
    logger.d("init Lib for sqlite: $dbPath");
    if (dbPath.isEmpty) {
      logger.e("dbPath is null");
      return;
    }
    await initLib(path: dbPath);
    Directory db = Directory(dbPath);
    db.listSync().forEach((element) {
      logger.d("list -> files: ${element.path}");
    });
    logger.d('path: $dbPath\n');
  } catch (e) {
    logger.e("error: $e");
  }
}
