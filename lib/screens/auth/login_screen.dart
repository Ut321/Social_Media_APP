import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/constants/color.dart';
import 'package:social_media_app/services/authentaction.dart';
import 'package:social_media_app/widgets/reset_widgets.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<AutoCompleteTextFieldState<String>> key = GlobalKey();

  String selectedEmail = '';

  String email = '';
  String password = '';
  String fullname = '';
  bool login = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthServices>(context, listen: false);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: darkblueColor,
        elevation: 0,
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!login)
                    TextFormField(
                      key: const ValueKey('fullname'),
                      decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: darkblueColor),
                        ),
                        labelText: 'Full Name',
                        labelStyle:
                            TextStyle(color: darkblueColor, fontSize: 18),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Full Name';
                        } else {
                          return null;
                        }
                      },
                      onSaved: (value) {
                        setState(() {
                          fullname = value!;
                        });
                      },
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    key: const ValueKey('email'),
                    decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: darkblueColor),
                        ),
                        labelText: 'Enter Email',
                        labelStyle:
                            TextStyle(color: darkblueColor, fontSize: 18),
                        border: OutlineInputBorder()),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please Enter valid Email';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      setState(() {
                        email = value!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    key: const ValueKey('password'),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Enter Password',
                      labelStyle: TextStyle(color: darkblueColor, fontSize: 18),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: darkblueColor),
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password.';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long.';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      setState(() {
                        password = value!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          login
                              ? authProvider.signinUser(
                                  email, password, context)
                              : authProvider.signupUser(
                                  email, password, fullname, context);
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(darkblueColor),
                      ),
                      child: Text(login ? 'Login' : 'Signup',
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        login = !login;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: darkblueColor,
                    ),
                    child: Text(
                        login
                            ? "Don't have an account? Signup"
                            : "Already have an account? Login",
                        style: const TextStyle(fontSize: 15)),
                  ),
                  login
                      ? const Text(
                          "OR",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        )
                      : Container(),
                  if (login)
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Forgot Password'),
                              content: TextField(
                                onChanged: (value) {
                                  email = value;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Enter Email',
                                  labelStyle: TextStyle(
                                      color: darkblueColor, fontSize: 18),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: darkblueColor),
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    // Send password reset email using Firebase
                                    authProvider.resetPassword(
                                        email, context, scaffoldKey);
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ResetPasswordSuccessScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Reset Password',
                                      style: TextStyle(color: darkblueColor)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel',
                                      style: TextStyle(color: darkblueColor)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('Forgot Password?',
                          style: TextStyle(color: darkblueColor)),
                    ),
                  login
                      ? Container()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkblueColor,
                          ),
                          onPressed: () {
                            authProvider.signInWithGoogle(context);
                          },
                          child: const Text(
                            "Sign with Google",
                            style: TextStyle(),
                          ),
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
