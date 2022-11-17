import "package:flutter/material.dart";
import 'package:nextwatch/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nextwatch/logincheck.dart';
import 'package:provider/provider.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(ChangeNotifierProvider(
    create: (context) => GoogleSignInProvider(),
    child: MaterialApp(
      routes: {
        '/' : (context) => LoginCheck(),
      },
    ),
  ));

}