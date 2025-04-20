import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../barrel.dart';

class CustomUser {
  String userId;
  String userName;
  String password;
  String email;
  String imagePath;
  CustomUser(
    this.userId,
    this.userName,
    this.password,
    this.email,
    this.imagePath,
  );
}
