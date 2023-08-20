import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:comic_reader_app/models/comic.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //  final FirebaseApp app = await Firebase.initializeApp();
  // ignore: unused_local_variable
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'comic_reader_flutter',
    options: Platform.isMacOS || Platform.isIOS
        ? const FirebaseOptions(
            appId: 'IOS KEY',
            apiKey: 'AIzaSyAqGh2VBRc3k0TNUTqDhmvnioFXpIoW_mw',
            projectId: 'comic-app-reader',
            messagingSenderId: '901165900383',
          )
        : const FirebaseOptions(
            appId: '1:901165900383:android:06993f629a7c660aa1b1ea',
            apiKey: 'AIzaSyAqGh2VBRc3k0TNUTqDhmvnioFXpIoW_mw',
            projectId: 'comic-app-reader',
            messagingSenderId: '901165900383',
          ),
  );
  // ignore: prefer_const_constructors
  runApp(ProviderScope(child: MyApp(app: app)));
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  final FirebaseApp? app;
  const MyApp({this.app, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      home: MyHomePage(title: "Comic Reader", app: app!),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final FirebaseApp app;
  const MyHomePage({required this.app, required this.title, super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ignore: unused_field
  DatabaseReference? _bannerRef, _comicRef;

  @override
  void initState() {
    // ignore: deprecated_member_use, no_leading_underscores_for_local_identifiers
    final FirebaseDatabase _database = FirebaseDatabase(app: widget.app);
    // ignore: deprecated_member_use
    _bannerRef = _database.reference().child("Banners");
    _comicRef = _database.reference().child("Comic");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[500],
        title: Text(widget.title),
      ),
      //
      body: FutureBuilder<List<String>>(
        future: getBanners(_bannerRef!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("${snapshot.hasError}"),
            );
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No available"),
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CarouselSlider(
                items: snapshot.data!
                    .map((e) => Builder(
                          builder: (context) {
                            return Image.network(
                              e,
                              fit: BoxFit.cover,
                            );
                          },
                        ))
                    .toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  viewportFraction: 1,
                  initialPage: 0,
                  height: MediaQuery.of(context).size.height / 3,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "New Comic".toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "".toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              //
              FutureBuilder(
                future: getComic(_comicRef!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.hasError}"),
                    );
                  } else if (snapshot.data!.isEmpty || snapshot.data == null) {
                    return const Center(
                      child: Text("No available"),
                    );
                  } else if (snapshot.hasData) {
                    List<Comic> comics = [];
                    // ignore: avoid_function_literals_in_foreach_calls
                    snapshot.data!.forEach((item) {
                      var comic =
                          Comic.fromJson(json.decode(json.encode(item)));
                      comics.add(comic);
                    });
                    //
                    return Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        mainAxisSpacing: 5.0,
                        crossAxisSpacing: 5.0,
                        children: comics.map((comic) {
                          return GestureDetector(
                            onTap: () {},
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  comic.image!,
                                  fit: BoxFit.cover,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      color: Colors.red,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                "${comic.name}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                  // Add the following return statement
                  return Container(); // Or any other fallback widget
                },
              )
            ],
          );
        },
      ),
    );
  }

  Future<List<String>> getBanners(DatabaseReference bannerRef) async {
    final snapshot = await bannerRef.once();
    final value = snapshot.snapshot.value;
    if (value is List) {
      final List<String> banners = [];
      for (var item in value) {
        if (item != null) {
          banners.add(item.toString());
        }
      }
      return banners;
    } else {
      return [];
    }
  }

  //
  Future<List<dynamic>> getComic(DatabaseReference comicRef) async {
    final snapshot = await comicRef.once();
    final value = snapshot.snapshot.value;
    if (value is List) {
      return value;
    } else {
      return [];
    }
  }
}
