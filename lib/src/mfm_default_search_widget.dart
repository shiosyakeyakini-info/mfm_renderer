import 'package:flutter/material.dart';
import 'package:mfm/mfm.dart';

class MfmDefaultSearch extends StatefulWidget {
  final String query;
  final SearchTapCallback? callback;

  const MfmDefaultSearch({super.key, required this.query, this.callback});

  @override
  State<StatefulWidget> createState() => MfmDefaultSearchState();
}

class MfmDefaultSearchState extends State<MfmDefaultSearch> {
  late final controller = TextEditingController(text: widget.query);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextField(
          controller: controller,
        )),
        ElevatedButton(
            onPressed: () async {
              await widget.callback?.call(controller.text);
            },
            child: const Text("検索")), //TODO: add localize support
      ],
    );
  }
}
