// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();

  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";

  late UserCredential userCredentials;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _passwordVisibility = true;

  bool _creatingAccount = false;

  _createAccount() async {
    _formKey.currentState!.save();
    if (_password.compareTo(_confirmPassword) != 0) {
      _formKey.currentState!.validate();
      setState(() {
        _creatingAccount = false;
      });
    } else {
      try {
        userCredentials = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          "firstname": _firstName,
          "lastname": _lastName,
          "createdAt": DateTime.now()
        });
        Navigator.of(context).pop();
      } catch (error) {
        showError('failed to create an new account');
      } finally {
        _formKey.currentState!.reset();

        setState(() {
          _creatingAccount = false;
        });
      }
    }
  }

  showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        action: SnackBarAction(
            label: 'Okay',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Pocket Buddy',
                style: GoogleFonts.pacifico(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                  color: Theme.of(context).colorScheme.background,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.2), // Black with 20% opacity
                      blurRadius: 9,
                      spreadRadius: 1.5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'first name',
                          prefixIcon: Icon(Icons.person),
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value.toString().isEmpty || value == null) {
                            return 'First name can\'t be empty';
                          }
                          if (value
                              .toString()
                              .contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'))) {
                            return 'Name can\'t contain numbers or special characters';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _firstName = value!;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'last name',
                          prefixIcon: Icon(Icons.person),
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value
                              .toString()
                              .contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'))) {
                            return 'Name can\'t contain numbers or special characters';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _lastName = value!;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'email',
                          prefixIcon: Icon(Icons.email),
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value.toString().isEmpty || value == null) {
                            return 'first name can\' be empty';
                          }

                          if (!value.toString().contains('@')) {
                            return 'eniter a valid email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        obscureText: _passwordVisibility,
                        decoration: InputDecoration(
                            labelText: 'password',
                            prefixIcon: const Icon(Icons.lock),
                            border: const UnderlineInputBorder(),
                            suffixIcon: !_passwordVisibility
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisibility =
                                            !_passwordVisibility;
                                      });
                                    },
                                    icon: const Icon(Icons.remove_red_eye))
                                : IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisibility =
                                            !_passwordVisibility;
                                      });
                                    },
                                    icon: const Icon(Icons.visibility_off))),
                        validator: (value) {
                          if (value.toString().isEmpty ||
                              value == null && value.toString().length > 6) {
                            return 'password should be greater then 6 characters.';
                          }

                          if (!value
                              .toString()
                              .contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'))) {
                            return 'use number like (1,2,3) or special symbols like (@, #) to create password';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        obscureText: _passwordVisibility,
                        decoration: const InputDecoration(
                          labelText: 'password',
                          prefixIcon: Icon(Icons.lock),
                          border: UnderlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value.toString().isEmpty ||
                              value == null && value.toString().length > 6) {
                            return 'password should be greater then 6 characters.';
                          }

                          if (!value
                              .toString()
                              .contains(RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]'))) {
                            return 'use number like (1,2,3) or special symbols like (@, #) to create password';
                          }

                          if (_password
                                  .toString()
                                  .compareTo(_confirmPassword.toString()) !=
                              0) {
                            return 'password and confirm password not match';
                          }

                          return null;
                        },
                        onSaved: (value) {
                          _confirmPassword = value!;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _creatingAccount = true;
                            });
                            _createAccount();
                          }
                        },
                        child: !_creatingAccount
                            ? const Text('Create Account')
                            : CircularProgressIndicator(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  const Divider(thickness: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () {
                          // Navigate to login page
                          Navigator.of(context).pop();
                        },
                        child: const Text('Login'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
