import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 123,
            channelKey: "call_channel",
            color: Colors.white,
            title: title,
            body: body,
            category: NotificationCategory.Call,
            wakeUpScreen: true,
            fullScreenIntent: true,
            autoDismissible: false,
            backgroundColor: Colors.orange,
          ),
          actionButtons: [
            NotificationActionButton(
              key: "ACCEPT",
              label: "Accept Call",
              color: Colors.green,
              autoDismissible: true,
            ),
            NotificationActionButton(
              key: "REJECT",
              label: "Reject Call",
              color: Colors.red,
              autoDismissible: true,
            )
          ]);
      AwesomeNotifications().actionStream.listen((event) {
        if (event.buttonKeyPressed == "REJECT") {
          print("Call Is Rejected");
        } else if (event.buttonKeyPressed == "ACCEPT") {
          print("Call Is Accepted");
        } else {
          print("Print On Notification");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page "),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontStyle: FontStyle.normal),
              ),
              onPressed: () async {
                String? token = await FirebaseMessaging.instance.getToken();
                print(token);
              },
              child: const Text('Press for Token'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.green,
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontStyle: FontStyle.normal),
              ),
              onPressed: () {
                _sendPush();
              },
              child: const Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }

  String constructFCMPayload(String? token) {
    return jsonEncode({
      'token': token,
      'data': {'via': 'FlutterFire Cloud Messaging!!!'},
      'notification': {
        'title': 'Hello FlutterFire!',
        'body': 'This notification was created via FCM!',
      },
    });
  }

  Future<void> _sendPush() async {
    var _token = await FirebaseMessaging.instance.getToken();
    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              "key=AAAAOTxa3_s:APA91bG19Dhk7WckTlXHfJieFh4jCaQyiRNF7C0U8pI53I2zocbYPvrnrVRapAuaB1nvvG_zBOhZGqVrAWl5NIfopO3hL_3-PcLXqp4-07iFbLUI0zUAniVVZPwaC0zI0Py-IdsqH3JV"
        },
        body: constructFCMPayload(_token),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }
}
