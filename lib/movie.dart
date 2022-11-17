class Movie
{
  int id;
  String title;
  String imageURL;
  dynamic rating;
  String language;
  List<dynamic> genreIDs;
  List<String> creditIDs;
  String details;

  Movie({this.id = 0, this.title = "", this.imageURL = "", this.rating = 0.0, this.language = "", this.genreIDs = const [], this.creditIDs = const [], this.details=""});
}