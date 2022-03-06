import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const SpanielApp());
}

class SpanielApp extends StatelessWidget {
  const SpanielApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Spaniel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeView(),
    );
  }
}

class CounterController extends GetxController {
  var count = 0.obs;
  void increment() => count++;
}

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Some weird GetX magic that injects the controller inside this context
    final counterController = Get.put(CounterController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("GetX counter test"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            // How the fuck does GetX know to rebuild only when the counter changes
            // and not just any observable? Does it even manage that? It should...
            Obx(() => Text(
                "${counterController.count}",
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counterController.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}