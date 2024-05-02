import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_authentication/auth.dart';
import 'package:firebase_authentication/pages/login_page.dart';
import 'package:firebase_authentication/util/shared_functions.dart';
import 'package:firebase_authentication/widgets/password_text_field.dart';
import 'package:firebase_authentication/widgets/text_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late Size screenSize;

  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<TextTextFieldState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordVerifyController =
      TextEditingController();

  bool _waitingFirebaseResponse = false;

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(0xFFFAF3E0),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.height * 0.05),
              // Build welcome title
              const Text(
                "Create an Account",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const Text(
                "Enter Your Details Here!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: screenSize.height * 0.025),
              // Build the body of the form
              Column(
                children: [
                  // Build TextFields to get input of login credentials
                  // Use the %30 of the screen size
                  SizedBox(
                    height: screenSize.height * 0.4,
                    width: screenSize.width * 0.9,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextTextField(
                            controller: usernameController,
                            hintText: "Enter Your Username",
                            inputCheck: checkUserName,
                          ),
                          TextTextField(
                            controller: emailController,
                            hintText: "Enter Your Email",
                            inputCheck: checkEmail,
                            key: _emailKey,
                          ),
                          PasswordTextField(
                            controller: passwordController,
                            hintText: "Enter Your password",
                          ),
                          PasswordTextField(
                            controller: passwordVerifyController,
                            hintText: "Verify Your password",
                            extraInputCheck: verifyPassword,
                          ),
                          buildSignUpButton(),
                        ],
                      ),
                    ),
                  ),

                  // Put some space so it'll look better
                  SizedBox(height: screenSize.height * 0.1),

                  buildOrWithSection(),

                  SizedBox(height: screenSize.height * 0.025),

                  // Build "Or With" section
                  SizedBox(
                    height: screenSize.height * 0.2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Build different login op
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

                        // Build SignUp text
                        buildLoginSection(),
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
  RichText buildLoginSection() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 18),
        children: [
          const TextSpan(
            text: "Have an account? ",
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: "Sign in",
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold),
            recognizer: TapGestureRecognizer()..onTap = openSignInPage,
          ),
        ],
      ),
    );
  }

  SizedBox buildSignUpButton() {
    return SizedBox(
      width: screenSize.width * 0.9,
      height: 50,
      child: ElevatedButton(
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
        onPressed: _waitingFirebaseResponse == false ? signUp : null,
        // If app is not waiting for a response from firebase
        // build the "Sign Up" text
        // If app is waiting for a response from firebase
        // make an animation
        child: _waitingFirebaseResponse == false
            ? const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              )
            : LoadingAnimationWidget.inkDrop(color: Colors.white, size: 30),
      ),
    );
  }
  // Build functions

  // Other functions
  Future<void> signUp() async {
    setState(() {
      _waitingFirebaseResponse = true;
    });

    // If there's any invalid field, return
    if (!_formKey.currentState!.validate()) return;

    // If all fields are valid
    // Try to sign up
    bool emailError = false;
    try {
      // Wait for a small loading animation
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      Auth.signUpWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );
    } on FirebaseAuthException {
      emailError = true;
      showEmailErrorSnackBar();
    }

    setState(() {
      _waitingFirebaseResponse = false;
    });

    // If there's no error, return
    if (emailError == false) {
      await showSuccessSnackBar();
      openSignInPage();
      return;
    }

    // If there's an error, display it to the user
    _emailKey.currentState!.setState(() {
      _emailKey.currentState!.errorText = "Email already in use!";
    });
  }

  void showEmailErrorSnackBar() {
    var snackBar = SnackBar(
      duration: const Duration(seconds: 1),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Email already in use!',
        message:
            'This email has been used by a different user. Please use a different mail!',
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> showSuccessSnackBar() async {
    var snackBar = SnackBar(
      duration: const Duration(milliseconds: 900),
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Signed up successfully!',
        message:
            'Your account is created, you will be directed to login screen!',
        contentType: ContentType.success,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await Future.delayed(const Duration(seconds: 1));
  }

  String checkUserName(String updatedText) {
    if (updatedText.length < 2) {
      return "Username must contain more than 2 characters!";
    }
    return "";
  }

  String verifyPassword(String updatedText) {
    if (updatedText != passwordController.text) {
      return "Passwords must match!";
    }
    return "";
  }

  void openSignInPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ));
  }
}
