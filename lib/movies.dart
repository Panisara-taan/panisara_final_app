import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panisara_final_app/api/post.dart';

class MoviesPage extends StatefulWidget {
  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final PanisaraMoviesService service = PanisaraMoviesService();
  late Future<List<PanisaraMovies>> moviesFuture;

  @override
  void initState() {
    super.initState();
    moviesFuture = service.fetchMovies();
  }

  Future<void> refreshMovies() async {
    setState(() {
      moviesFuture = service.fetchMovies();
    });
  }

  final List<Map<String, dynamic>> staticMovies = [
    {
      'title': 'The Parent Trap',
      'genre': 'Romantic Comedy',
      'poster':
          'https://lumiere-a.akamaihd.net/v1/images/p_theparenttrap1998_19873_be8ce25c.jpeg?region=0%2C0%2C540%2C810',
      'description':
          'A heartwarming story about twin sisters who reunite their divorced parents.',
      'duration': '2h 5m',
      'source': 'Disney+',
    },
    {
      'title': "Miss Peregrine's Home for Peculiar Children",
      'genre': 'Fantasy Adventure',
      'poster':
          'https://m.media-amazon.com/images/M/MV5BMTU0Nzc5NzI5NV5BMl5BanBnXkFtZTgwNTk1MDE4MDI@._V1_.jpg',
      'description':
          'A mysterious orphanage, home to children with peculiar abilities, is protected by Miss Peregrine, who must defend it from dark forces.',
      'duration': '2h 7m',
      'source': 'Netflix',
    },
    {
      'title': "Home Alone",
      'genre': 'Comedy',
      'poster':
          'https://m.media-amazon.com/images/S/pv-target-images/6cf8e71c230bdb27575ad916aa81adaf9a0ba2922f4066a7d5d1b9b023ce84c1.jpg',
      'description':
          'An eight-year-old troublemaker must protect his house from a pair of burglars when he is accidentally left home alone by his family during Christmas vacation.',
      'duration': '1h 43m',
      'source': 'Disney+',
    },
    {
      'title': 'Flight Plan',
      'genre': 'Thriller',
      'poster':
          'https://i.namu.wiki/i/-L3XXekHVmnNselpLys4Jf9BlPv5M3au5sTS5lxrRJBK24McoTADNC2R-gK2suCrH7tfrtX-DBIpnx0VEi2o4Q.webp',
      'description':
          'A gripping thriller that will keep you on the edge of your seat.',
      'duration': '1h 38m',
      'source': 'Netflix',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshMovies,
          )
        ],
      ),
      body: FutureBuilder<List<PanisaraMovies>>(
        future: moviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final firebaseMovies = snapshot.data ?? [];
          final combinedMovies = [
            ...staticMovies,
          ];

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2 / 3,
            ),
            padding: const EdgeInsets.all(10),
            itemCount: combinedMovies.length,
            itemBuilder: (context, index) {
              final movie = combinedMovies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailPage(
                        movie: movie,
                        onConfirm: refreshMovies,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          movie['poster'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            movie['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MovieDetailPage extends StatefulWidget {
  final Map<String, dynamic> movie;
  final VoidCallback onConfirm;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.onConfirm,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  String? selectedShowDate;

  List<String> generateDateRange(int days) {
    final today = DateTime.now();
    return List.generate(days, (index) {
      final date = today.add(Duration(days: index));
      return DateFormat('yyyy-MM-dd').format(date);
    });
  }

  Future<void> saveConfirmedMovieToFirebase(
      Map<String, dynamic> movie, String? date) async {
    if (date != '') {
      try {
        await FirebaseFirestore.instance.collection('panisara_movies').add({
          'title': movie['title'],
          'genre': movie['genre'],
          'duration': movie['duration'],
          'source': movie['source'],
          'description': movie['description'],
          'date': date,
        });
        print('Confirmed movie saved successfully');
      } catch (e) {
        print('Error saving confirmed movie: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;
    final availableDates = generateDateRange(6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          movie['title'],
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                movie['poster'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Text(
                movie['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Genre: ${movie['genre']}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
             
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Duration: ${movie['duration']}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Source: ${movie['source']}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
           
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Description:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
       
              Text(
                movie['description'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
           
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Select Date:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.5,
                ),
                itemCount: availableDates.length,
                itemBuilder: (context, index) {
                  final date = availableDates[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedShowDate = date;
                      });
                    },
                    child: Card(
                      color: selectedShowDate == date
                          ? Colors.blueAccent
                          : Colors.white,
                      child: Center(
                        child: Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: selectedShowDate == date
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            
              if (selectedShowDate != null)
                Center(
                  child: ElevatedButton(
                    onPressed: selectedShowDate != null
                        ? () async {
                            await saveConfirmedMovieToFirebase(
                                movie, selectedShowDate);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConfirmedMoviesPage(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConfirmedMoviesPage extends StatelessWidget {
  const ConfirmedMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmed Movies'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('panisara_movies')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No confirmed movies.'));
          }

          final confirmedMovies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: confirmedMovies.length,
            itemBuilder: (context, index) {
              final movie = confirmedMovies[index];
              final data = movie.data() as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(
                  data['poster'] ?? '',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Text(data['date'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => deleteConfirmedMovie(movie.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<void> deleteConfirmedMovie(String id) async {
  try {
    await FirebaseFirestore.instance
        .collection('panisara_movies')
        .doc(id)
        .delete();
    print('Movie deleted successfully');
  } catch (e) {
    print('Error deleting movie: $e');
  }
}

class PanisaraMovies {
  final String title;
  final String genre;
  final String duration;
  final String source;
  final String description;
  String dbId;

  PanisaraMovies({
    required this.title,
    required this.genre,
    required this.duration,
    required this.source,
    required this.description,
    this.dbId = '',
  });

  // Create a model from Firestore document
  factory PanisaraMovies.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PanisaraMovies(
      title: data['title'] ?? '',
      genre: data['genre'] ?? '',
      duration: data['duration'] ?? '',
      source: data['source'] ?? '',
      description: data['description'] ?? '',
      dbId: snapshot.id,
    );
  }

  // Convert the model to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'genre': genre,
      'duration': duration,
      'source': source,
      'description': description,
    };
  }
}

class PanisaraMoviesService {
  final CollectionReference moviesCollection =
      FirebaseFirestore.instance.collection('panisara_movies');

  Future<void> addMovie(PanisaraMovies movie) async {
    try {
      await moviesCollection.add(movie.toMap());
    } catch (e) {
      print('Error adding movie: $e');
      throw Exception('Failed to add movie');
    }
  }

  Future<List<PanisaraMovies>> fetchMovies() async {
    try {
      final snapshot = await moviesCollection.get();
      return snapshot.docs
          .map((doc) => PanisaraMovies.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching movies: $e');
      throw Exception('Failed to fetch movies');
    }
  }

  Future<void> updateMovie(String id, PanisaraMovies movie) async {
    try {
      await moviesCollection.doc(id).update(movie.toMap());
    } catch (e) {
      print('Error updating movie: $e');
      throw Exception('Failed to update movie');
    }
  }

  Future<void> deleteMovie(String id) async {
    try {
      await moviesCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting movie: $e');
      throw Exception('Failed to delete movie');
    }
  }
}
