import 'package:combovids/vm/video_vm.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Combo Vids'),
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
  late VideoVm vm;

  @override
  void initState() {
    vm = VideoVm();
    vm.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            const Text(
              'You have selected the below number of videos:',
              textAlign: TextAlign.center,
            ),
            Text(
              '${vm.videos.length}',
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
            Row(
              children: [
                ...vm.controllers.values
                    .map((controller) => Expanded(
                          child: AspectRatio(
                            aspectRatio: 0.7,
                            child: VideoPlayer(controller),
                          ),
                        ))
                    .toList()
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * .6,
              child: OutlinedButton.icon(
                onPressed: vm.combineVideo,
                icon: const Icon(Icons.video_collection_rounded),
                label: const Text('Combine videos'),
              ),
            ),
            if (vm.outputVidController != null) ...[
              const Divider(thickness: 2),
              const Text('Combined Video'),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 1,
                child: VideoPlayer(vm.outputVidController!),
              )
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.pickVideo,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
