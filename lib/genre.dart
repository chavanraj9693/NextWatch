//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nextwatch/global.dart';

class Genre extends StatefulWidget {

  Function setStateFunction;
  Genre(this.setStateFunction);

  @override
  _GenreState createState() => _GenreState();
}

class _GenreState extends State<Genre> {

  bool isLangSelected = false;
  Map languagesSelected = new Map();
  Map genreSelected = new Map();
  int genreCount = 0;
  int langCount = 0;

  Map getMap() => isLangSelected?genreMap:languagesMap;
  Map getSelected() => isLangSelected?genreSelected:languagesSelected;
  Map<String, dynamic> getScore() => isLangSelected?genreScore:peopleScore;


  void selectFunction(dynamic id)
  {
    getSelected()[id] = !getSelected()[id];
  }


  @override
  Widget build(BuildContext context) {

    getMap().keys.forEach((key) { getSelected()[key] = false; });

    List<Widget> genreWidgetList()
    {
      int length = getMap().length;
      int columnLength = (length/2).round();
      int k = 0;
      bool isEven = (length%2==0);
      List<Widget> widgetList = [];

      for (int i=0; i<columnLength-1; i++)
      {
        widgetList.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GenreTile(getMap().values.elementAt(k), getSelected().keys.elementAt(k++),selectFunction),
            GenreTile(getMap().values.elementAt(k), getSelected().keys.elementAt(k++), selectFunction),
          ],
        ));
      }

      if (isEven)
      {
        widgetList.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GenreTile(getMap().values.elementAt(k), getSelected().keys.elementAt(k++), selectFunction),
            GenreTile(getMap().values.elementAt(k), getSelected().keys.elementAt(k++), selectFunction),
          ],
        ));
      }
      else
      {
        widgetList.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GenreTile(getMap().values.elementAt(k), getSelected().keys.elementAt(k++), selectFunction),
            GenreTile(" ", 0, (){}),
          ],
        ));
      }

      return widgetList;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          isLangSelected? "SELECT GENRES" : "PREFERRED LANGUAGES",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            SizedBox(height: 8.0,),
          ] + genreWidgetList()
        ),
      ),
      floatingActionButton: Container(
        height: 50,
        width: 100,
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: FloatingActionButton(
                backgroundColor: Colors.deepOrange,
                onPressed: (){

                  getSelected().forEach((key, value) {
                    if (value == true) {
                      getScore()[key.toString()] = 1;
                      isLangSelected?genreCount++:langCount++;
                    }
                    else if (isLangSelected) {
                      genreScore[key.toString()] = 0;
                    }
                  });

                  if (!isLangSelected)
                    {
                      if (langCount < 1) {
                        Fluttertoast.showToast(
                            msg: "Please select a language",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.deepOrange,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      } else {
                        setState(() {
                          isLangSelected = true;
                        });
                      }
                    }
                  else
                    {
                      if (genreCount < 3) {
                        Fluttertoast.showToast(
                            msg: "Please select atleast 3 genres",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.deepOrange,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                      }
                      else {
                        FirebaseFirestore.instance.collection(uid).doc("People Score").set(peopleScore);
                        FirebaseFirestore.instance.collection(uid).doc("Genre Score").set(genreScore);
                        FirebaseFirestore.instance.collection(uid).doc("Liked Movies").set({});
                        FirebaseFirestore.instance.collection(uid).doc("Disliked Movies").set({'tid': []});
                        FirebaseFirestore.instance.collection(uid).doc("Watchlists").set({});

                        widget.setStateFunction();
                      }
                    }
                },
                child: Text(
                  "NEXT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}

class GenreTile extends StatefulWidget {

  String text = " ";
  dynamic selectedID = 0;
  Function selectFunction;
  bool isSelected = false;
  GenreTile(this.text, this.selectedID, this.selectFunction);

  @override
  _GenreTileState createState() => _GenreTileState();
}

class _GenreTileState extends State<GenreTile> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: (){
            setState(() {
              if (widget.text != " ")
              {
                 widget.isSelected = !widget.isSelected;
                 widget.selectFunction(widget.selectedID);
              }
            });
          },
          child: Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(3.0),
            color: (widget.text !=" ")? Colors.black: Colors.white,
            child: Container(
              alignment: AlignmentDirectional.center,
              color: (widget.isSelected)? Colors.black : Colors.white,
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: (widget.isSelected)? Colors.white : Colors.black,
                    fontSize: 20.0,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold
                ),
              ),
            )
          ),
        ),
      ),
    );
  }
}


