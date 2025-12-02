import 'package:flutter/material.dart';

ValueNotifier<int> selectedPageNotifier = ValueNotifier(0);
ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);

ValueNotifier<int> publicModeSelectedNotifier = ValueNotifier(0);

ValueNotifier<String> subtreeSelector = ValueNotifier("firstLaunch");
ValueNotifier<bool> hasNewFeedbackNotifier = ValueNotifier(false);
