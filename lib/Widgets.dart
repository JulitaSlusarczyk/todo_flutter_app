import 'package:flutter/material.dart';

SnackBar snackBar(String message) {
  return SnackBar(
    content: Text(
      message,
      style: const TextStyle(
          color: Colors.red
      ),
    ),
  );
}