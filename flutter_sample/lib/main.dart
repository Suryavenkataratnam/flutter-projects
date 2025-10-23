import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CounterProvider()),
        ChangeNotifierProvider(create: (_) => TheamProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theamProvider = context.watch<TheamProvider>();

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.dark(),
      themeMode: theamProvider.currentTheam,

      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: MysampleHomePageWithProvider(),
    );
  }
}

class MysampleHomePage1 extends StatefulWidget {
  const MysampleHomePage1({super.key});

  @override
  State<MysampleHomePage1> createState() {
    return _MysampleHomePage1();
  }
}

class _MysampleHomePage1 extends State<MysampleHomePage1> {
  int number = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lord Siva")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(number.toString()),
            TextButton(
              onPressed: increaseNumber, // ✅ fixed
              style: TextButton.styleFrom(
                backgroundColor: Colors.deepPurple, // ✅ simplified
              ),
              child: const Text(
                "Click me",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  increaseNumber() {
    setState(() {
      number++;
    });
  }
}

class MysampleHomePageWithProvider extends StatelessWidget {
  const MysampleHomePageWithProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text("with Provider")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: Provider.of<TheamProvider>(
                context,
                listen: false,
              ).toggleTheam,
              child: Text("Change Theme"),
            ),
            SizedBox(height: 15),

            // Selector<CounterProvider, bool>(
            //   selector: (_, provider) => provider.count == 0,
            //   builder: (_, isFive, __) {
            //     return isFive
            //         ? Text('Count reached 0 🎉')
            //         : Text('Keep going...');
            //   },
            // ),
            Consumer<CounterProvider>(
              builder: (context, value, child) {
                if (value.count == 0) {
                  return Text("Count is zero");
                } else if (value.count > 10) {
                  return Text(
                    "High value!",
                    style: TextStyle(color: Colors.red),
                  );
                } else
                  return Text("Normal value");
              },
            ),
            SizedBox(height: 15),

            Consumer<CounterProvider>(
              builder: (context, value, child) {
                return Text(value.count.toString());
              },
            ),
            SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: Provider.of<CounterProvider>(
                    context,
                    listen: false,
                  ).decrement,
                  child: Text("decrement"),
                ),
                ElevatedButton(
                  onPressed: Provider.of<CounterProvider>(
                    context,
                    listen: false,
                  ).increment,
                  child: Text("increment"),
                ),
              ],
            ),
            SizedBox(height: 15),

            ElevatedButton(
              onPressed: Provider.of<CounterProvider>(
                context,
                listen: false,
              ).reset,
              child: Text("reset", style: TextStyle(color: Colors.black26)),
            ),
          ],
        ),
      ),
    );
  }
}

class CounterProvider with ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void decrement() {
    _count--;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }
}

class TheamProvider with ChangeNotifier {
  bool _darkMode = false;
  bool get darkMode => _darkMode;
  ThemeMode get currentTheam => _darkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheam() {
    _darkMode = !_darkMode;
    notifyListeners();
  }

  void resetTheam() {
    _darkMode = false;
    notifyListeners();
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // TRY THIS: Try changing the color here to a specific color (to
//         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//         // change color while the other colors stay the same.
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           //
//           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//           // action in the IDE, or press "p" in the console), to see the
//           // wireframe for each widget.
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text('You have pushed the button this many times:'),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
