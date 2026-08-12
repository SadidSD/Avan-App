import 'package:flutter/material.dart';
import '../say_after_me/say_after_me_tab.dart';

class MyVoiceTab extends StatelessWidget {
  const MyVoiceTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SayAfterMeTab(initialModeIndex: 1);
  }
}
