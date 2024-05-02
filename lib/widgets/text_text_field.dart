import 'package:flutter/material.dart';

class TextTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? inputCheck;
  const TextTextField({
    required this.controller,
    required this.hintText,
    this.inputCheck,
    super.key,
  });

  @override
  State<TextTextField> createState() => TextTextFieldState();
}

class TextTextFieldState extends State<TextTextField> {
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        controller: widget.controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
        ),
        validator: (updatedText) => validateInput(updatedText),
      ),
    );
  }

  // Return the string
  String? validateInput(String? updatedText) {
    // If the updated text is null
    // make it empty so function will be able to scan it
    errorText = null;
    updatedText ??= "";

    String error = "";
    if (widget.inputCheck != null) {
      error = widget.inputCheck!(updatedText);
    }

    if (error.isEmpty) return null;

    return error;
  }
}
