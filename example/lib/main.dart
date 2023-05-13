import 'package:flutter/material.dart';
import 'package:mfm_renderer/mfm_renderer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("MFM Rendering Example")),
        body: const MfmRenderingExample(),
      ),
    );
  }
}

class MfmRenderingExample extends StatefulWidget {
  const MfmRenderingExample({super.key});

  @override
  State<StatefulWidget> createState() => MfmRenderingExampleState();
}

class MfmRenderingExampleState extends State<MfmRenderingExample> {
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(contentPadding: EdgeInsets.all(10)),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Mfm(
                textController.text,
                mentionTap: (username, host, acct) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("$acct tapped.")));
                },
                linkTap: (url) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text("@$url tapped.")));
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
