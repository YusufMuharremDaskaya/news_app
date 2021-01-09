import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_app/Data/HtmlService.dart';
import 'package:news_app/Models/Articles.dart';
import 'package:news_app/Models/News.dart';
import 'package:url_launcher/url_launcher.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haberler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Haberler'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  TabController _tabController;


  String uid = FirebaseAuth.instance.currentUser.uid;
  News news = News();
  CollectionReference favorite = FirebaseFirestore.instance.collection('favorites');
  List<Articles> article = [];
  List<Articles> savedNews = [];
  initState() {
    super.initState();
    getUser();
    _tabController = new TabController(length: 2, vsync: this);

      setState(() {
        HtmlService.getNews().then((value) {
          setState(() {
            article = value;

          });
        });
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          labelColor: Colors.amber,
          tabs: [
            new Tab(icon: new Icon(Icons.library_books_outlined)),
            new Tab(
              icon: new Icon(Icons.favorite_border_outlined),
            ),
          ],
          controller: _tabController,
        ),
      ),
      body: TabBarView(
        children: [
          newsList(),
        StreamBuilder<QuerySnapshot>(
          stream: favorite.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }

            return streamList();
          },
        )
        ],
        controller: _tabController,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          print(savedNews);
          addUser();
        },
      ),
    );
  }

  Widget newsList(){
    return Center(
      child: ListView.builder(
        itemCount: article.length,
        itemBuilder: (context, index) {
          bool isSaved = false;
          savedNews.forEach((element) {
            if(element.title == article[index].title){
              isSaved = true;
            }
          });
          return Card(
            child: Column(
              children: [
                Image.network(urlToImage(article[index].urlToImage)),
                ListTile(
                  leading: Icon(Icons.arrow_drop_down_circle_outlined),
                  title: Text(title(article[index].title)),
                  trailing: Icon(
                    isSaved ? Icons.star : Icons.star_border,
                    color: isSaved ? Colors.blue : null,
                  ),
                  onTap: () {
                    setState(() {
                      if (isSaved) {
                        deleteField(savedNews[index]);
                        savedNews.removeWhere((e) => e.title == article[index].title);
                        isSaved = false;
                      } else {
                          savedNews.add(article[index]);
                        isSaved = true;
                      }
                    });
                  },
                ),

                Text(description(article[index].description)),
                ButtonBar(
                  alignment: MainAxisAlignment.start,
                  children: [
                    FlatButton(
                        onPressed: () {
                          _launchURL(article[index].url);
                        },
                        child: Text("Habere Git"))
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget streamList(){
    return ListView.builder(
      itemCount: savedNews.length,
      itemBuilder: (context, index) {
        return Card(
          child: Column(
            children: [
              Image.network(urlToImage(savedNews[index].urlToImage)),
              ListTile(
                leading: Icon(Icons.arrow_drop_down_circle_outlined),
                title: Text(title(savedNews[index].title)),
                trailing: Icon(
                    Icons.star,
                    color: Colors.blue
                ),
                onTap: () {
                  deleteField(savedNews[index]);
                  setState(() {
                    savedNews.remove(savedNews[index]);
                  });


                },
              ),

              Text(description(savedNews[index].description)),
              ButtonBar(
                alignment: MainAxisAlignment.start,
                children: [
                  FlatButton(
                      onPressed: () {
                        _launchURL(savedNews[index].url);
                      },
                      child: Text("Habere Git"))
                ],
              )
            ],
          ),
        );
      },
    );
  }


  //api kaynaklı hataların çözümü.
  //eğer api bir bilgiyi null olarak döndürürse aşağıdaki fonksiyonlar sayesinde durum farkedilecek ve çözülecek
  String title(String title) {
    if (title == null) {
      print("hata");
      return "";
    } else {
      return title;
    }
  }
  String description(description){
    if(description == null){
      return "";
    }else{
      return description;
    }
  }
  String urlToImage(urlToImage){
    if(urlToImage == null){
      return "https://cdn.pixabay.com/photo/2017/04/09/12/45/error-2215702_1280.png";
    }else{
      return urlToImage;
    }
  }




  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  addUser() {
    savedNews.forEach((element) {
        favorite
            .doc()
            .set({
            "author": element.author,
            "title": element.title,
            "description": element.description,
            "url": element.url,
            "urlToImage": element.urlToImage,
            "user" : FirebaseAuth.instance.currentUser.uid
        }

        )
            .then((value) => print("User Added"))
            .catchError((error) {print(error);
        print(error);
        });
    });
  }
  getUser() {
    favorite
        .where("user", isEqualTo : uid).get().then((value) {
          value.docs.forEach((element) {
            savedNews.add(Articles.withNullValues(
                author: element.data()["author"],
                urlToImage: element.data()["urlToImage"],
                description: element.data()["description"],
                title: element.data()["title"],
                url: element.data()["url"]
            ));
           });
          });



  }
  deleteField(Articles article) {

    FirebaseFirestore.instance.collection("favorites")
          .where("user", isEqualTo : uid).where("title", isEqualTo: article.title).get().then((value) {
      value.docs.forEach((element) {
        favorite.doc(element.id).delete().then((value) => print("User Deleted"))
            .catchError((error) => print("Failed to delete user: $error"));
        print(element.id);
      });
    });

  
  }

}