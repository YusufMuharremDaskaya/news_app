import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app/screens/home_page.dart';
import 'package:news_app/screens/register.dart';
import 'package:news_app/screens/sign_in.dart';

void main() {
  runApp(Home());
}


class Home extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Firebase.initializeApp();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(title: Text("giriş seçeneğini belirleyiniz"),),
          body: Center(
            child: Column(
              children: [
                    RaisedButton(
                  child: Text("g-mail ile giriş yap"),
                  onPressed: () {
                    signInWithGoogle();
                  },
                ),
                    RaisedButton(
                      child: Text("E-mail ile giriş yap"),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>  SignIn()));
                      },
                    ),
                    RaisedButton(
                      child: Text(" E-mail ile kayıt ol "),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>  Register()));
                    }),
              ],
            ),
        )
    ));
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
  }
}
