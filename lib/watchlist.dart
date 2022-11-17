import 'package:flutter/material.dart';
import 'package:nextwatch/movietile.dart';
import 'package:nextwatch/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';

class WatchList extends StatefulWidget {
  @override
  _WatchListState createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> {

  List<MovieTile> tileList = [];

  void removeFunction(String title) {
    setState(() {
      for (MovieTile tile in tileList) {
        if (tile.title == title) {
          tileList.remove(tile);
          break;
        }
      }

      FirebaseFirestore.instance.collection(uid).doc("Watchlists").update({
        title : FieldValue.delete()
      });
    });
  }


  @override
  void initState() {

    setWatchlist = (){
      Watchlist.forEach((title, id) {
        tileList.insert(0,MovieTile(title, id, removeFunction));
      });
      setState(() {});
    };

    updateWatchList = (String title, int id){

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
        title: Text("WATCH LIST", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
      ),
      body: (isDataLoaded)? Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0, 12, 0),
        child: (tileList.isNotEmpty) ? ListView(
          children: <Widget>[
            SizedBox(height: 12.0,),
          ] + tileList,
        ) : Center(child: Text("\nWatchlist is Empty", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),)),
      ) :  Center(child: CircularProgressIndicator(color: Colors.deepOrange,)),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          String shareString = "";
          Watchlist.keys.forEach((title) {
            shareString += "\n$title";
          });
          Share.share('Hey, Checkout My Watchlist:$shareString', subject: 'NextWatch Watchlist');
        },
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.share),
      ),
    );
  }
}



