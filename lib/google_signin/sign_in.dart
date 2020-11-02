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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/classroom/v1.dart';
import 'package:toast/toast.dart';
//import 'package:http/http.dart' as http;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    // Google classroom:
    //'https://www.googleapis.com/auth/classroom.courses',
    ClassroomApi.ClassroomCoursesReadonlyScope,
    ClassroomApi.ClassroomTopicsReadonlyScope,
    ClassroomApi.ClassroomCourseworkMeReadonlyScope,
    ClassroomApi.ClassroomCourseworkmaterialsReadonlyScope,
    ClassroomApi.ClassroomAnnouncementsReadonlyScope,
  ],
);

//String name;
//String email;
//String imageUrl;
User googleUser;
GoogleSignInAuthentication googleTokens;

Future<String> signInWithGoogle(BuildContext context, bool silently) async {
  //print("signInWithGoogle(silently=$silently) starting...");
  googleUser = null;
  googleTokens = null;

  await Firebase.initializeApp();
  //print("firebase OK");

  GoogleSignInAccount googleSignInAccount;
  try {
    googleSignInAccount = await (silently ? googleSignIn.signInSilently() : googleSignIn.signIn());
    //print("googleSignInAccount=$googleSignInAccount");
  } catch (error) {
    print(error);
    if (context != null) {
      // shows a short notification about error
      Toast.show("Error: $error", context, duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM);
    }

    return '';  // must not be null
  }

  if (googleSignInAccount == null) {    // happens eg. when user cancels login dialogue (that one when he/she can choose Google identity)
    return '';  // must not be null
  }
  final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final UserCredential authResult = await _auth.signInWithCredential(credential);
  final User user = authResult.user;

  //print("user=$user");
  if (user != null) {
    // Checking if email and name is null
    assert(user.email != null);
    assert(user.displayName != null);
    assert(user.photoURL != null);

    // name = user.displayName;
    // email = user.email;
    // imageUrl = user.photoURL;
    //
    // // Only taking the first part of the name, i.e., First Name
    // if (name.contains(" ")) {
    //   name = name.substring(0, name.indexOf(" "));
    // }

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);

    print('signInWithGoogle succeeded, email=${user.email}');

    googleUser = user;
    googleTokens = googleSignInAuthentication;
    //print("at=${googleSignInAuthentication.accessToken}, it=${googleSignInAuthentication.idToken}");

    // idtoken: urcuje mou identitu
    // accesstoken: upresnuje scope, tzn. k cemu se smim prihlasit

    // // kontrola tokenu:
    // final client = new http.Client();
    // var response = await client.get(
    //     'https://oauth2.googleapis.com/tokeninfo?id_token=${googleSignInAuthentication.idToken}'
    // );
    // print('idToken verify result: ${response.body}');
    // response = await client.get(
    //     'https://oauth2.googleapis.com/tokeninfo?access_token=${googleSignInAuthentication.accessToken}'
    // );
    // print('accessToken verify result: ${response.body}');

    return '$user';
  }

  return '';  // must not be null
}

Future<void> signOutGoogle() async {
  await googleSignIn.signOut();
  googleUser = null;
  googleTokens = null;

  print("User Signed Out");
}
