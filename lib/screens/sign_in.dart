import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:news_app/screens/home_page.dart';

class SignIn extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haberler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Page(),
    );
  }
}

class Page extends StatefulWidget {

  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailController;
  TextEditingController passwordController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(

          children: [
            Container(
              height: 10,
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
              controller: emailController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "emailinizi girin"
              ),
            ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
              obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "şifrenizi girin"
              ),
            ),
            ),
            SignInButton(
                Buttons.Email,
                onPressed: (){
              signIn();
            })
            
            
          ],
        ),
      )
    );
  }

  signIn() async {
    var email = emailController.text;
    var password = passwordController.text;
    print(email);
    print(password);
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: email,
          password: password
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print("Bu emaile sahip kullanıcı bulunamadı");
      } else if (e.code == 'wrong-password') {
        print('Bu email ve şifre birbirleriyle uyuşmuyor');
      }
    }
  }
}