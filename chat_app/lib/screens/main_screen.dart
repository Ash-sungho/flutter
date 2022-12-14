import 'dart:io';

import 'package:chat_app/add_image/add_image.dart';
import 'package:chat_app/config/palette.dart';
import 'package:chat_app/screens/chatScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final _authentication = FirebaseAuth.instance;

  bool isSignupScreen = true;
  final _formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  String userName = '';
  String userEmail = '';
  String userPassword = '';
  File? userPickedImage;

  void pickedImage(File image) {
    userPickedImage = image;
  }

  void _tryValidation() {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      _formKey.currentState!.save();
    }
  }

  void showAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            backgroundColor: Colors.white, child: AddImage(pickedImage));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Scaffold(
          backgroundColor: Palette.backgroundColor,
          body: Stack(
            children: <Widget>[
              //배경
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('images/red.jpg'), fit: BoxFit.fill),
                  ),
                  child: Container(
                      padding: const EdgeInsets.only(top: 90, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RichText(
                            text: TextSpan(
                                text: 'welcome',
                                style: const TextStyle(
                                    letterSpacing: 1.0,
                                    fontSize: 25,
                                    color: Colors.white),
                                children: [
                                  TextSpan(
                                      text: isSignupScreen
                                          ? ' to Yummy chat'
                                          : ' Back',
                                      style: const TextStyle(
                                          letterSpacing: 1.0,
                                          fontSize: 25,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ]),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            isSignupScreen
                                ? 'Signup to continue'
                                : 'SignIn to continue',
                            style: const TextStyle(
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          )
                        ],
                      )),
                ),
              ),
              //텍스트 폼 필드
              //TODO:텍스트 폼 필드 리팩토링하기
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear,
                top: 180,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear,
                  padding: const EdgeInsets.all(20),
                  height: isSignupScreen ? 280 : 250,
                  width: MediaQuery.of(context).size.width - 40,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 5,
                        )
                      ]),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = false;
                                });
                              },
                              child: Column(
                                children: <Widget>[
                                  Text('LOGIN',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isSignupScreen
                                              ? Palette.textColor1
                                              : Palette.activeColor)),
                                  if (!isSignupScreen)
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      width: 55,
                                      height: 2,
                                      color: Colors.orange,
                                    )
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignupScreen = true;
                                });
                              },
                              child: Column(
                                children: <Widget>[
                                  Row(children: [
                                    Text(
                                      'SignUp',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: !isSignupScreen
                                              ? Palette.textColor1
                                              : Palette.activeColor),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    if (isSignupScreen)
                                      GestureDetector(
                                          onTap: isSignupScreen
                                              ? () {
                                                  showAlert(context);
                                                }
                                              : null,
                                          child: Icon(
                                            Icons.image,
                                            color: isSignupScreen
                                                ? Colors.cyan
                                                : Colors.grey[300],
                                          ))
                                  ]),
                                  if (isSignupScreen)
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0, 3, 35, 0),
                                      width: 55,
                                      height: 2,
                                      color: Colors.orange,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (isSignupScreen)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    key: const ValueKey(1),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 4) {
                                        return 'Please enter at least 4 characters';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onChanged: (value) {
                                      userName = value;
                                    },
                                    onSaved: (value) {
                                      userName = value!;
                                    },
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.account_circle,
                                            color: Palette.iconColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'User name',
                                        hintStyle: TextStyle(
                                            color: Palette.textColor1,
                                            fontSize: 14),
                                        contentPadding: EdgeInsets.all(10)),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    key: const ValueKey(2),
                                    validator: (value) {
                                      if (value!.isEmpty ||
                                          !value.contains('@')) {
                                        return 'Please enter a valid email address';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.mail,
                                            color: Palette.iconColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'Mail',
                                        hintStyle: TextStyle(
                                            color: Palette.textColor1,
                                            fontSize: 14),
                                        contentPadding: EdgeInsets.all(10)),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    key: const ValueKey(3),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return 'Password must be at least 7 characters long.';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.lock,
                                            color: Palette.iconColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'Password',
                                        hintStyle: TextStyle(
                                            color: Palette.textColor1,
                                            fontSize: 14),
                                        contentPadding: EdgeInsets.all(10)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        if (!isSignupScreen)
                          Container(
                            margin: const EdgeInsets.only(top: 20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    key: const ValueKey(4),
                                    validator: (value) {
                                      if (value!.isEmpty ||
                                          !value.contains('@')) {
                                        return 'Please enter a valid email address';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      userEmail = value!;
                                    },
                                    onChanged: (value) {
                                      userEmail = value;
                                    },
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.mail,
                                            color: Palette.iconColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'Mail',
                                        hintStyle: TextStyle(
                                            color: Palette.textColor1,
                                            fontSize: 14),
                                        contentPadding: EdgeInsets.all(10)),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    key: const ValueKey(5),
                                    validator: (value) {
                                      if (value!.isEmpty || value.length < 6) {
                                        return 'Password must be at least 7 characters long.';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onSaved: (value) {
                                      userPassword = value!;
                                    },
                                    onChanged: (value) {
                                      userPassword = value;
                                    },
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(Icons.lock,
                                            color: Palette.iconColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Palette.textColor1),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        hintText: 'Password',
                                        hintStyle: TextStyle(
                                            color: Palette.textColor1,
                                            fontSize: 14),
                                        contentPadding: EdgeInsets.all(10)),
                                  )
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ),
              //버튼
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear,
                top: isSignupScreen ? 430 : 390,
                right: 0,
                left: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () async {
                      setState(() {
                        showSpinner = true;
                      });
                      if (isSignupScreen) {
                        if (userPickedImage == null) {
                          setState(() {
                            showSpinner = false;
                          });
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Please pick your image'),
                            backgroundColor: Colors.blue,
                          ));
                          return;
                        }
                        _tryValidation();
                        try {
                          print(userEmail);
                          print(userPassword);

                          final newUser = await _authentication
                              .createUserWithEmailAndPassword(
                                  email: userEmail, password: userPassword);

                          final refImage = FirebaseStorage.instance
                              .ref()
                              .child('picked_image')
                              .child(newUser.user!.uid + '.png');

                          await refImage.putFile(userPickedImage!);
                          final url = await refImage.getDownloadURL();

                          await FirebaseFirestore.instance
                              .collection('user')
                              .doc(newUser.user!.uid)
                              .set({
                            'userName': userName,
                            'email': userEmail,
                            'pickedImage' : url,
                          });

                          if (newUser.user != null) {
                            if (!mounted) {
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatScreen(),
                              ),
                            );
                            setState(() {
                              showSpinner = false;
                            });
                          }
                        } catch (e) {
                          debugPrint(e.toString());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                              'Please check your email and password2',
                              style: TextStyle(backgroundColor: Colors.blue),
                            )),
                          );
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      }
                      if (!isSignupScreen) {
                        _tryValidation();
                        try {
                          print(userEmail);
                          print(userPassword);

                          final newUser =
                              await _authentication.signInWithEmailAndPassword(
                                  email: userEmail, password: userPassword);

                          if (newUser.user != null) {
                            if (!mounted) {
                              return;
                            }
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const ChatScreen(),
                            //   ),
                            // );
                          }
                        } catch (e) {
                          debugPrint(e.toString());
                          if (!mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                              'Please check your email and password',
                              style: TextStyle(backgroundColor: Colors.blue),
                            )),
                          );
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              colors: [Colors.orange, Colors.red],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1))
                            ]),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              //하단(구글 로그인버튼)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear,
                top: isSignupScreen
                    ? MediaQuery.of(context).size.height - 125
                    : MediaQuery.of(context).size.height - 165,
                left: 0,
                right: 0,
                child: Column(
                  children: <Widget>[
                    Text(isSignupScreen ? 'or SignUp With' : 'or SignIn With'),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      label: const Text(
                        'Google',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      style: TextButton.styleFrom(
                          backgroundColor: Palette.googleColor,
                          minimumSize: const Size(155, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
