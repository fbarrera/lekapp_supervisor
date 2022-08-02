import 'package:flutter/material.dart';

final backgroundContainer = Container(
  height: double.infinity,
  width: double.infinity,
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF5AE73),
        Color(0xFFF1A461),
        Color(0xFFE08D47),
        Color(0xFFE58A39),
      ],
      stops: [0.1, 0.4, 0.7, 0.9],
    ),
  ),
);
