import 'package:flutter/material.dart';
import 'constants.dart';

final theme = ThemeData(
  colorScheme: kColorScheme,
  appBarTheme: AppBarTheme().copyWith(
    backgroundColor: kColorScheme.onPrimaryContainer,
    foregroundColor: kColorScheme.primaryContainer,
  ),
  cardTheme: CardThemeData().copyWith(color: kColorScheme.secondaryContainer),
  textTheme: TextTheme().copyWith(
    headlineLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: kColorScheme.secondaryContainer,
      fontSize: 16,
    ),
  ),
);
