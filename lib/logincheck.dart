import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nextwatch/genre.dart';
import 'package:nextwatch/global.dart';
import 'package:nextwatch/home.dart';
import 'package:nextwatch/login.dart';

class LoginCheck extends StatefulWidget {
  @override
  _LoginCheckState createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        //Streams if user is authenticated and if yes the user details are stored in snapshot
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.deepOrange,));
          } else if (snapshot.hasError) {
            return Center(child: Text("Something went wrong!"),);
          } else if (snapshot.hasData) {
            //snapshot has data for a few seconds even after log out

            return CheckNewUser();

          }
          //else
          return Login();
        },
      ),
    );
  }
}


class CheckNewUser extends StatefulWidget {
  @override
  _CheckNewUserState createState() => _CheckNewUserState();
}

class _CheckNewUserState extends State<CheckNewUser> {

  Future<bool> checkNewUser() async
  {
    return !(await FirebaseFirestore.instance.collection(uid).doc("People Score").get()).exists;
  }

  @override
  void initState() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    uid = user!.uid;
    username = user.displayName!;
    email = user.email!;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkNewUser(),
      initialData: CircularProgressIndicator(color: Colors.deepOrange,),
      builder: (context, snapshot) {
        if (snapshot.hasData)
        {
          if(snapshot.data == true)
          {
            return Genre(
                    (){
                  setState(() {
                    isNewUser = false;
                    isDataLoaded = false;
                    //just for safety (for some reason Home is also returned)
                  });
                }
            );
          }
          else
          {
            return Home();
            // Home is also returned for a few seconds,
            //if navigates to Home impossible to pop
          }
        }
        else return CircularProgressIndicator(color: Colors.deepOrange,);
      },
    );
  }
}


