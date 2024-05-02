import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? extraInputCheck;
  const PasswordTextField({
    required this.controller,
    required this.hintText,
    this.extraInputCheck,
    super.key,
  });

  @override
  State<PasswordTextField> createState() => PasswordTextFieldState();
}

class PasswordTextFieldState extends State<PasswordTextField> {
  bool _passwordVisible = false;
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: !_passwordVisible,
      decoration: InputDecoration(
        hintText: widget.hintText,
        errorText: errorText,
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.only(left: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        suffixIcon: IconButton(
          icon:
              Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
        ),
      ),
      validator: (updatedText) => validateInput(updatedText),
    );
  }

  // Returns the error (if there's any)
  String? validateInput(String? updatedText) {
    String errorText = "";

    // If the updated text is null
    // make it empty so function will be able to scan it
    updatedText ??= "";

    // If there's any extra input check
    if (widget.extraInputCheck != null) {
      errorText = widget.extraInputCheck!(updatedText);
    }

    // Check if the pass is long enough
    if (updatedText.length < 8) {
      errorText = "Password must contain more than 8 characters";
    }

    if (errorText.isEmpty) return null;

    return errorText;
  }
}
