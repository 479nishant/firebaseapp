import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseapp/Registration.dart';
import 'package:firebaseapp/Trainer.dart';
import 'package:firebaseapp/TrainerFormPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Home.dart';
import 'Homescreen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<void> sharedpref() async {
    final mpref=await SharedPreferences.getInstance();
    mpref.setString("session", "in");
  }
  void _login() async {
    try {
      UserCredential user= await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: name.text.trim(),
        password: password.text.trim(),
      );

      if(user!=null)
      {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login Successful")));

        if(name.text=="trainer@gmail.com"&&password.text=="45454545")
          {
            sharedpref();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Trainer()),

            );
          }
        else{
          sharedpref();
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homescreen()),
        );}
      }
      else{
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Somethimg went wrong")));
      }
    } on FirebaseException catch (e){
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }


  final TextEditingController name = TextEditingController();
  final TextEditingController password = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
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

                          _login();


                        },
                        child: const Text('Login'),
                      ),
                      ElevatedButton(
                        onPressed: ()  {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Registration(),));
                        },
                        child: const Text('REGISTER'),
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
