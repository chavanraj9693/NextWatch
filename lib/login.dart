import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nextwatch/google_sign_in.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.pink, Colors.deepOrange])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(mainAxisSize: MainAxisSize.max,),
            Text(
              "Get Movie Recommendations and Find out what to watch next!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 35.0
              ),
            ),
            SizedBox(height: 200,),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  minimumSize: Size(100,50)
              ),
              icon: FaIcon(FontAwesomeIcons.google, color: Colors.deepOrange,),
              onPressed: (){

                final provider =
                Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogin();
              },
              label: Text(
                "Continue with Google",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
