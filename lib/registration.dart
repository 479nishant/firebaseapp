import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseapp/Login.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'FireStoreGpt.dart';
import 'Home.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController name = TextEditingController();
  final TextEditingController password = TextEditingController();
  void _googleSignin()  async{

    try {
      GoogleSignInAccount? account = await GoogleSignIn().signIn();
      if (account == null) {
        return;
      }
      GoogleSignInAuthentication? user = await account.authentication;

      OAuthCredential credential =await GoogleAuthProvider.credential(accessToken: user.accessToken,idToken: user.idToken);

      UserCredential firebaseUser =await FirebaseAuth.instance.signInWithCredential(credential);

      if(firebaseUser!=null){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google login succeful"),));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FirestoreGpt(),));
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google login unsucceful"),));
      }

    }on FirebaseException{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("exception"),));
    }
    catch(e){

    }

  }

  void _registerUser() async {
    try {
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: name.text.trim(),
        password: password.text.trim(),
      );

      if (user != null) {
        print(user.user);
        print(user.user?.uid);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration Successful")));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FirestoreGpt()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registraion failed")));
      }
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Some error is coming from the server")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {

                          _registerUser();

                        },
                        child: const Text('Register'),
                      ),
                      ElevatedButton(
                        onPressed: ()  {
                          _googleSignin();
                        },
                        child: const Text('GOOGLE '),
                      ),
                      ElevatedButton(
                        onPressed: ()  {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),));
                        },
                        child: const Text('LOGIN'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
