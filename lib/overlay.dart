import 'dart:ui';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginDisplay.dart';

OverlayEntry? overlayEntry;
void showOverlay(BuildContext context, bool a) {
  if (a) {
    overlayEntry?.remove();
    overlayEntry = null;
    return;
  }
  OverlayState? overlayState = Overlay.of(context);
  overlayEntry = OverlayEntry(
    builder:
        (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  overlayEntry?.remove();
                  overlayEntry = null;
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: 50,
              left: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  child: Container(
                    width: 300,
                    height: 300,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          child: InkWell(
                            onTap: () {
                              overlayEntry?.remove();
                              overlayEntry = null;
                            },
                            child: Icon(Icons.close, color: Colors.white),
                          ),
                          alignment: Alignment.centerRight,
                        ),
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage("images/genseki.png"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
  );
  overlayState.insert(overlayEntry!);
}
