// ignore_for_file: prefer_const_constructors

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication/auth.dart';
import 'package:firebase_authentication/pages/main_page.dart';
import 'package:firebase_authentication/pages/register_page.dart';
import 'package:firebase_authentication/widgets/password_text_field.dart';
import 'package:firebase_authentication/widgets/text_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../util/shared_functions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Size screenSize;
  bool _rememberMe = false;

  bool _waitingFirebaseResponse = false;
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<TextTextFieldState>();
  final _passwordKey = GlobalKey<PasswordTextFieldState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFFAF3E0),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: screenSize.height * 0.1),
              // Build welcome title
              buildWelcomeTitle(),
              SizedBox(height: screenSize.height * 0.025),
              // Build the body of the form
              Column(
                children: [
                  // Build TextFields to get input of login credentials
                  // Use %35 of the screen size
                  SizedBox(
                    height: screenSize.height * 0.35,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildEmailField(),
                          buildPasswordField(),

                          // Build remember me checkbox and password reset
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              buildRememberMe(),
                              buildForgotPassword(),
                            ],
                          ),

                          // Build login button
                          buildLoginButton(),
                        ],
                      ),
                    ),
                  ),

                  // Put some space so it'll look better
                  SizedBox(height: screenSize.height * 0.15),

                  buildOrWithSection(),

                  SizedBox(height: screenSize.height * 0.025),

                  // Build other login types
                  SizedBox(
                    height: screenSize.height * 0.18,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildLoginByDifferentKey(
                          "assets/facebook_logo.png",
                          "Login With Facebook",
                          Colors.blue,
                          Colors.white,
                          () => {},
                          false,
                        ),
                        buildLoginByDifferentKey(
                          "assets/google_logo.png",
                          "Login With Google",
                          Colors.white,
                          Colors.black,
                          () => {},
                          true,
                        ),

                        // Build SingUp
                        buildSingUpSection(),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Build functions
  Row buildWelcomeTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          "Hello, There! 🤖",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildLoginButton() {
    return SizedBox(
      width: screenSize.width * 0.9,
      height: 50,
      child: FilledButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.blue[600],
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onPressed: login,
        child: _waitingFirebaseResponse == false
            ? Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              )
            : LoadingAnimationWidget.inkDrop(color: Colors.white, size: 30),
      ),
    );
  }

  Row buildRememberMe() {
    return Row(
      children: [
        Text(
          "Remember me",
          style: TextStyle(fontSize: 16),
        ),
        Checkbox(
          value: _rememberMe,
          onChanged: updateRememberMeValue,
        )
      ],
    );
  }

  TextButton buildForgotPassword() {
    return TextButton(
      onPressed: forgotPassword,
      child: Text(
        "Forgot your password?",
        style: TextStyle(
          fontSize: 16,
          color: Colors.blue,
        ),
      ),
    );
  }

  SizedBox buildEmailField() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Email",
            style: TextStyle(fontSize: 16),
          ),
          TextTextField(
            key: _emailKey,
            controller: _emailController,
            hintText: "Enter Email",
            inputCheck: checkEmail,
          ),
          // createTextField(hint, secure),
        ],
      ),
    );
  }

  SizedBox buildPasswordField() {
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Password",
            style: TextStyle(fontSize: 16),
          ),
          PasswordTextField(
            key: _passwordKey,
            controller: _passwordController,
            hintText: "Enter password",
          ),
          // createTextField(hint, secure),
        ],
      ),
    );
  }

  RichText buildSingUpSection() {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 18),
        children: [
          TextSpan(
            text: "Don't  have an account? ",
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: "Sign up",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = openSignUpPage,
          ),
        ],
      ),
    );
  }
  // Build functions

  // Other functions
  Future<void> login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    bool error = false;
    _waitingFirebaseResponse = true;

    try {
      await Auth.signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);
    } on FirebaseAuthException catch (e) {
      error = true;
      String errorCode = e.code;
      if (errorCode == "invalid-credential") {
        showFailureSnackBar("Invalid credentials",
            "Wrong email or password, please try again!");

        setState(() {
          _emailKey.currentState!.errorText = "";
          _passwordKey.currentState!.errorText = "";
        });
      }
    }

    _waitingFirebaseResponse = false;
    if (!error) openMainPage();
  }

  void openMainPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }

  void showFailureSnackBar(String errorTitle, String errorMessage) {
    var snackBar = SnackBar(
      duration: Duration(seconds: 3),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: errorTitle,
        message: errorMessage,
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showSuccessSnackBar(String successTitle, String successMessage) {
    var snackBar = SnackBar(
      duration: Duration(seconds: 2),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: successTitle,
        message: successMessage,
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void forgotPassword() {
    String email = _emailController.text;
    if (EmailValidator.validate(email)) {
      showSuccessSnackBar("Password reset code sent",
          "We sent a link to your email to reset your password.");
    } else {
      showFailureSnackBar("Enter your mail",
          "You have to enter a mail to get a password reset code.");
    }
  }

  void updateRememberMeValue(bool? value) {
    setState(() {
      _rememberMe = !_rememberMe;
    });
  }

  void openSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(),
      ),
    );
  }
}
