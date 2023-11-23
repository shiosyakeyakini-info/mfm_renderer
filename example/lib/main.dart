import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_highlighting/flutter_highlighting.dart';
import 'package:flutter_highlighting/themes/github-dark.dart';
import 'package:highlighting/languages/all.dart';
import 'package:mfm_renderer/mfm_renderer.dart';
import 'package:http/http.dart' as http;

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
  Map<String, String> emojiList = {};
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future(() async {
      String? host;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextFormField(
            onFieldSubmitted: (data) {
              host = data;
              Navigator.of(context).pop();
            },
            decoration: const InputDecoration(
                hintText:
                    "Please input misskey server host (such as misskey.io) to fetch emojis."),
          ),
        ),
      );
      if (host == null) return;

      final response = await http.get(
          Uri(scheme: "https", host: host, pathSegments: ["api", "emojis"]));
      setState(() {
        emojiList = Map.fromEntries(
            (jsonDecode(response.body)["emojis"] as List)
                .map((e) => MapEntry(e["name"] as String, e["url"] as String)));
        focusNode.requestFocus();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: textController,
            maxLines: null,
            expands: true,
            focusNode: focusNode,
            keyboardType: TextInputType.multiline,
            decoration:
                const InputDecoration(contentPadding: EdgeInsets.all(10)),
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(color: Theme.of(context).dividerColor))),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Mfm(
                  mfmText: textController.text,
                  emojiBuilder: (context, emoji, style) {
                    final emojiData = emojiList[emoji];
                    if (emojiData == null) {
                      return Text.rich(TextSpan(text: emoji, style: style));
                    } else {
                      // show emojis if emoji data found
                      return Image.network(
                        emojiData,
                        height: (style?.fontSize ?? 1) * 2,
                      );
                    }
                  },
                  codeBlockBuilder: (context, code, lang) {
                    final language = allLanguages[lang]?.id ?? "javascript";
                    return SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: HighlightView(
                          code,
                          languageId: language,
                          theme: githubDarkTheme,
                          padding: const EdgeInsets.all(10),
                        ),
                      ),
                    );
                  },
                  mentionTap: (username, host, acct) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("$acct tapped.")));
                  },
                  linkTap: (url) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("@$url tapped.")));
                  },
                  hashtagTap: (url) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("@$url tapped.")));
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
