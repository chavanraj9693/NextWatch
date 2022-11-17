// initially false, since you have to sign in to get into the app.
//bool isLoggedOut = false;

bool isNewUser = false;

String uid ="";
String username = "";
String email = "";

//API Specific
Map genreMap = {
  28 : "Action", 12 : "Adventure", 16 : "Animation",
  35 : "Comedy", 80 : "Crime", 99 : "Documentary",
  18 : "Drama", 10751 : "Family", 14 : "Fantasy",
  36 : "History", 27 : "Horror", 10402 : "Music",
  9648 : "Mystery", 10749 : "Romance", 878 : "Science Fiction",
  10770 : "TV Movie", 53 : "Thriller", 10752 : "War",
  37 : "Western"
};

Map languagesMap = {
  'en': 'English', 'hi': 'Hindi', 'fr': 'French',
  'tr': 'Turkish', 'ar': 'Arabic', 'it': 'Italian',
  'jp': 'Japanese', 'ko': 'Korean', 'ru': 'Russian',
  'zh': 'Chinese',  'es':'Spanish', 'ta': 'Tamil',
  'pt': 'Portuguese', 'de': 'German', 'id': 'Indonesian'
};

String apiKey = "your-api-key";
String baseImageURL = "https://image.tmdb.org/t/p/w500";

Map<String, dynamic> genreScore = new Map();
Map<String, dynamic> peopleScore = new Map();

bool isDataLoaded = false;
bool isMoviesLoaded = false;

Map LikedMovies = new Map();
Map DislikedMovies = new Map();
Map Watchlist = new Map();

Function setLiked = (){};
Function setWatchlist = (){};

Function updateLiked = (String title, int id){};
Function updateWatchList = (String title, int id){};