import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pocket_buddy_new/widgets/create_account.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

final firebaseAuth = FirebaseAuth.instance;

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isHiding = true;

  late UserCredential userCredentials;

  // login variables
  late String _email;
  late String _password;

  _loginWithEmailAndPasswrod() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    try {
      userCredentials = await firebaseAuth.signInWithEmailAndPassword(
          email: _email, password: _password);
    } catch (error) {
      _showError(error.toString());
    } finally {
      _formKey.currentState!.reset();
      _email = '';
      _password = '';
    }
  }

  Future<UserCredential?> _withGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      return await firebaseAuth.signInWithCredential(credential);
    } catch (error) {
      return null;
    }
  }

  Future<UserCredential?> _withFacebook() async {
    // Implement Facebook login here
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 56),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 100,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  const SizedBox(height: 42),
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Welcome back you\'ve been missed'),
                        const SizedBox(height: 15),
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty || !value.contains('@')) {
                                    return 'please enter a valid email id';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _email = value!;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  prefixIcon: Icon(Icons.email),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                validator: (value) {
                                  if (value!.isEmpty || value.length <= 6) {
                                    return 'password must be greater than 6 characters';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _password = value!;
                                },
                                obscureText: isHiding,
                                decoration: InputDecoration(
                                  labelText: 'password',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  prefixIcon: const Icon(Icons.lock_person),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isHiding = !isHiding;
                                      });
                                    },
                                    icon: isHiding
                                        ? const Icon(Icons.visibility)
                                        : const Icon(Icons.visibility_off),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('forgot password?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _loginWithEmailAndPasswrod,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20), // Adjust the button height
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Login',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .copyWith(color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Or continue with'),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _withGoogle,
                              child: const Image(
                                image: AssetImage('assets/logo/google.png'),
                                width: 64,
                              ),
                            ),
                            const SizedBox(width: 36),
                            GestureDetector(
                              onTap: _withFacebook,
                              child: const Image(
                                image: AssetImage('assets/logo/facebook.png'),
                                width: 64,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member ?'),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CreateAccount(),
                            ),
                          );
                        },
                        child: const Text('Register new'))
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _showError(String errorMessage) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        action: SnackBarAction(
            label: 'Okay',
            textColor: Theme.of(context).colorScheme.background,
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
            }),
      ),
    );
  }
}
