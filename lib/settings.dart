import 'package:flutter/material.dart';
import 'package:nextwatch/global.dart';
import 'package:nextwatch/google_sign_in.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 1,
        centerTitle: true,
        title: Text("SETTINGS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0, 12, 0),
        child: ListView(
          children: [
            SizedBox(height: 20.0,),

            Row(children: [
              Text(
                '   LOGGED IN AS',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
              Expanded(child: Divider(color: Colors.black12,)),
            ],),

            ListTile(
              leading: CircleAvatar(
                child: Text(username.substring(0,1), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                backgroundColor: Colors.black87,
              ),
              title: Text(username),
              subtitle: Text(email),
            ),

            SizedBox(height: 20.0,),

            Row(children: [
              Text(
                '   GENERAL',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
              Expanded(child: Divider(color: Colors.black12,)),
            ],),

            SizedBox(height: 20.0,),

            ListTile(
              title: Text("Clear Cache", style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text("Clears stored cache. May lead to longer loading times"),
            ),

            SizedBox(height: 20.0,),

            ListTile(
              title: Text("About App", style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text("Show Licences and other information"),
              onTap: (){
                showAboutDialog(
                  context: context,
                  applicationName: "Nextwatch",
                  applicationVersion: "0.1.0",
                  children: [
                    Text("Powered by\n",textAlign: TextAlign.center , style: TextStyle(fontSize: 13.0),),
                    Image.asset('assets/long.png'),
                    Text("\n\nBuilt as a MiniProject for SEM 3 CSE (AIML)\n", style: TextStyle(fontSize: 13.0),),
                    Text("Project Members", style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),),
                    Text("Zohaib Hamdule", style: TextStyle(fontSize: 13.0),),
                    Text("Raj Chavan", style: TextStyle(fontSize: 13.0),),
                    Text("Raj Salvi", style: TextStyle(fontSize: 13.0),),
                    Text("Sujan Kambli", style: TextStyle(fontSize: 13.0),),
                  ]
                );
              },
            ),

            SizedBox(height: 20.0,),

            Row(children: [
              Text(
                '   ACCOUNT',
                style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                ),
              ),
              Expanded(child: Divider(color: Colors.black12,)),
            ],),

            SizedBox(height: 10.0,),

            ListTile(
              onTap: () async {
                showAlertDialog(context);
              },
              title: Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: Text("Log out of your account"),
            ),

            SizedBox(height: 20.0,),

            ListTile(
              onTap: () async {
                showRemoveAlertDialog(context);
              },
              title: Text("Remove my Account", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(204, 0, 0, 100)),),
              subtitle: Text("Completely erase all data associated with your account"),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 80,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Powered by   ", style: TextStyle(fontSize: 12.0),),
                    SizedBox(width: 100, child: Image.asset('assets/short.png'),)
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}


showAlertDialog(BuildContext context) {
   showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out from this account?"),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("CANCEL")),
          TextButton(
            onPressed: (){
              final provider =
              Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.logout();
              Navigator.pop(context);

            },
            child: Text("OK"),
          )
        ],
      );
    },
  );

}

showRemoveAlertDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Remove Account"),
        content: Text("This will permanently erase all data associated with your account!\nYou might be prompted to login again. Press OK to proceed."),
        actions: [
          TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("CANCEL")),
          TextButton(
            onPressed: (){
              final provider =
              Provider.of<GoogleSignInProvider>(context, listen: false);
              provider.deleteUser();
              Navigator.pop(context);

            },
            child: Text("OK"),
          )
        ],
      );
    },
  );

}



