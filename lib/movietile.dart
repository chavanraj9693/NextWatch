import 'package:flutter/material.dart';
import 'package:nextwatch/moviedialogue.dart';

class MovieTile extends StatelessWidget {
  String title;
  int id;
  Function removeFunction;
  MovieTile(this.title, this.id, this.removeFunction);

  @override
  Widget build(BuildContext context) {

    Future<bool> deleteDialogue() async {
      return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(10),
            title: Text("Remove movie"),
            content:  Text("Remove $title from this list?"),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context, true);
                },
                child: Text("YES"),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context, false);
                },
                child: Text("CLOSE"),
              ),
            ],
          );
        },
      );
    }

    return Card(
      child: ListTile(
        onTap: (){
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return MovieDialogue(id);
            });
        },
        subtitle: Text(" "),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold),),
        trailing: IconButton(
          onPressed: () async {
            if (await deleteDialogue()) removeFunction(title);
          },
          icon: Icon(
              Icons.delete_outline,
            color: Colors.black12,
          ),
        ),
      ),
    );
  }
}