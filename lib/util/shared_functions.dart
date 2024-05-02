import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

Row buildOrWithSection() {
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Divider(
            color: Colors.black,
            thickness: 2,
          ),
        ),
      ),
      const Text(
        "Or with",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: const Divider(
            color: Colors.black,
            thickness: 2,
          ),
        ),
      ),
    ],
  );
}

Widget buildLoginByDifferentKey(String logoPath, String label, Color fillColor,
    Color textColor, Function onTap, bool haveBorder) {
  return SizedBox(
    height: 50,
    child: FilledButton.icon(
      icon: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            logoPath,
            fit: BoxFit.cover,
          ),
        ],
      ),
      label: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 20, color: textColor),
          ),
        ],
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(fillColor),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            side: haveBorder == true
                ? const BorderSide(color: Colors.black)
                : const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      onPressed: () => onTap,
    ),
  );
}

String checkEmail(String updatedText) {
  if (!EmailValidator.validate(updatedText)) return "Invalid E-mail";
  return "";
}
