import 'package:flutter/material.dart';
import 'package:nextwatch/global.dart';
import 'package:nextwatch/movietile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Liked extends StatefulWidget {
  @override
  _LikedState createState() => _LikedState();
}

class _LikedState extends State<Liked> {

  List<MovieTile> tileList = [];

  void removeFunction(String title) {
    setState(() {
      for (MovieTile tile in tileList) {
        if (tile.title == title) {
          tileList.remove(tile);
          break;
        }
      }

      FirebaseFirestore.instance.collection(uid).doc("Liked Movies").update({
        title : FieldValue.delete()
      });
    });
  }

  @override
  void initState() {

    //setLiked was called twice
    setLiked = () {
      LikedMovies.forEach((title, id) {
        tileList.insert(0,MovieTile(title, id, removeFunction));
      });
      setState(() {});
    };

    updateLiked = (String title, int id){

      // you can get the same movie more than once in one batch
      // doesnt check for liked, disliked movie after every swipe (batches of 10)
      bool isPresent()
      {
        for (MovieTile tile in tileList) {
          if(tile.id == id) {
            return true;
          }
        }
        return false;
      }

      if (!isPresent()) {
        setState(() {
          tileList.insert(0, MovieTile(title, id, removeFunction));
        });
      }
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 1,
        centerTitle: true,
        title: Text("LIKED MOVIES", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
      body: (isDataLoaded)? Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0, 12, 0),
        child: (tileList.isNotEmpty) ? ListView(
          children: <Widget>[
            SizedBox(height: 12.0,),
          ] +  tileList,
        ) : Center(child: Text("\nNo Movies Rated", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),)),
      ): Center(child: CircularProgressIndicator(color: Colors.deepOrange,)),
    );
  }
}



