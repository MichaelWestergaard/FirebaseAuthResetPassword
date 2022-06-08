import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_test/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _sendResetPasswordMail() async {
    try {
      String dynamicLinkDomain = ''; //TODO: Set dynamic link domain here
      String email = "your_email@mail.com"; //TODO: Set your email here
      ActionCodeSettings actionCodeSettings = ActionCodeSettings(
        url: 'https://$dynamicLinkDomain/?email=$email',
        dynamicLinkDomain: dynamicLinkDomain,
        androidPackageName: 'com.example.firebase_auth_text',
        androidInstallApp: true,
        androidMinimumVersion: '12',
        iOSBundleId: 'com.example.firebase_auth_text',
        handleCodeInApp: true,
      );
      await _firebaseAuth.sendPasswordResetEmail(email: email, actionCodeSettings: actionCodeSettings);
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    FirebaseDynamicLinks.instance.onLink.listen((event) async {
      final Uri deepLink = event.link;
      String? actionCode = deepLink.queryParameters['oobCode'];
      String? mode = deepLink.queryParameters['mode'];
      switch (mode) {
        case 'resetPassword':
          if (actionCode != null) {
            try {
              ActionCodeInfo actionCodeInfo = await _firebaseAuth.checkActionCode(actionCode);
              await _firebaseAuth.applyActionCode(actionCode);

              _firebaseAuth.currentUser?.reload();
            } on FirebaseAuthException catch (e) {
              print(e);
              if (e.code == 'invalid-action-code') {
                print('The code is invalid.');
              }
            }
          }
          break;
        default:
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '0',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendResetPasswordMail,
        tooltip: 'Increment',
        child: const Icon(Icons.mail),
      ),
    );
  }
}
