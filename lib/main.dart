import 'package:flutter/material.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, userSnapshot) {
          if (userSnapshot.hasData) {
            return LogOut();
          } else if (userSnapshot.hasError) {
            return CircularProgressIndicator();
          }
          return SignInScreen();
        },
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              "https://www.3nions.com/wp-content/uploads/2020/01/comp_1.gif",
              height: 200,
            ),
            InkWell(
              onTap: () {
                _login();
              },
              borderRadius: BorderRadius.circular(30),
              splashColor: Colors.blue,
              child: Container(
                height: 50,
                width: 300,
                child: Center(
                    child: Text(
                      "Sign In using twitter",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    )),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              message == null ? "" : message,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    final TwitterLoginResult result = await twitterLogin.authorize();
    String newMessage;
    if (result.status == TwitterLoginStatus.loggedIn) {
      _signInWithTwitter(result.session.token, result.session.secret);
    } else if (result.status == TwitterLoginStatus.cancelledByUser) {
      newMessage = 'Login cancelled by user.';
    } else {
      newMessage = result.errorMessage;
    }

    setState(() {
      message = newMessage;
    });
  }

  void _signInWithTwitter(String token, String secret) async {
    final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: token, authTokenSecret: secret);
    await _auth.signInWithCredential(credential);
  }
}

FirebaseAuth _auth = FirebaseAuth.instance;
final TwitterLogin twitterLogin = new TwitterLogin(
  consumerKey: '',
  consumerSecret: '',
);

void _logout() async {
  await twitterLogin.logOut();
  await _auth.signOut();
}

class LogOut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Twitter Auth Demo"),
      ),
      body: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (context, snapshot) {
          FirebaseUser firebaseUser = snapshot.data;
          return snapshot.hasData
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "SignIn Success 😊",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("UserId: ${firebaseUser.uid}"),
                SizedBox(
                  height: 20,
                ),
                Image.network(
                  firebaseUser.photoUrl,
                  height: 100,
                ),
                Text("Your name: ${firebaseUser.displayName}"),
                SizedBox(
                  height: 20,
                ),
                RaisedButton(
                  onPressed: _logout,
                  child: Text(
                    "LogOut",
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Colors.blue,
                )
              ],
            ),
          )
              : CircularProgressIndicator();
        },
      ),
    );
  }
}
