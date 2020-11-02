// Copyright (c) 2019 Souvik Biswas

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'package:flutter/material.dart';
import 'sign_in.dart';

class GoogleSignInOutWidget extends StatefulWidget {
  @override
  _GoogleSignInOutState createState() => _GoogleSignInOutState();
}

class _GoogleSignInOutState extends State<GoogleSignInOutWidget> {
  @override
  Widget build(BuildContext context) {
    //print("_GoogleSignInOutState: u=$googleUser");
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: ((googleUser == null) ? _signInButton(context) : _signOutButton(context))
      );
  }

  Widget _signOutButton(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SizedBox(height: 20),
            CircleAvatar(
              backgroundImage: NetworkImage(
                googleUser.photoURL,
              ),
              radius: 30,
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 20),
            Text(
              'EMAIL',
              style: TextStyle(
                //fontSize: 15,
                  fontWeight: FontWeight.bold,
//                  color: Colors.black54
              ),
            ),
            Text(
              googleUser.email,
              style: TextStyle(
                //fontSize: 25,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(height: 20),
            RaisedButton(
              onPressed: () {
                signOutGoogle();
                setState(() { }); // refresh stateful widget
              },
              //color: Colors.deepPurple,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Odhlásit se',
                  style: TextStyle(
                    //fontSize: 25,
                    //color: Colors.white
                  ),
                ),
              ),
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            )
          ],
        ),
      ),
    );

  }

  Widget _signInButton(BuildContext context) {
    return OutlineButton(
      //splashColor: Colors.grey,
      onPressed: () {
        signInWithGoogle(context, false).then((result) {
          print("result of sign in: $result");
          setState(() { }); // refresh stateful widget
        });
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(image: AssetImage("assets/google_logo.png"), height: 35.0),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Přihlásit se pomocí Google',
                style: TextStyle(
                  fontSize: 20,
                  //color: Colors.grey,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
