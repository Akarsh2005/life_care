// video_call_page.dart
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const int appID = 23; // Add ZEGOCLOUD appID
const String appSign =
    "Add ZEGOCLOUD appSign"; 

class VideoCallPage extends StatelessWidget {
  final String callID;

  const VideoCallPage({super.key, required this.callID});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltCall(
        appID: appID,
        appSign: appSign,
        callID: callID,
        userID:
            "user_${DateTime.now().millisecondsSinceEpoch}", // Use a unique user ID
        userName: "User", // Replace with the actual user name
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
      ),
    );
  }
}