import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_gallery/screens/album_screen.dart';
import 'package:awesome_gallery/services/photo_loader.dart';
import 'package:awesome_gallery/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  static final String id = "loading_screen";
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _haveDataLoaded = false;

  Future<bool> _getBoolFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final haveLoaded = prefs.getBool('haveLoaded');
    if (haveLoaded == null) {
      return false;
    }
    return haveLoaded;
  }

  Future<void> _dataHaveLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('haveLoaded', true);
  }

  @override
  void initState() {
    _getAll();
    super.initState();
  }

  Future<void> _getAlbums() async {
    if (_haveDataLoaded == false) {
      PhotoLoader photoLoader = PhotoLoader();
      var fetchedData = await photoLoader.getAlbumData();
      try {
        await DBProvider.instance.insert(DBProvider.albumTableName,
            {DBProvider.colName: jsonEncode(fetchedData)});
      } catch (e) {
        print("Database Error");
      }
    }
  }

  Future _getPhotos() async {
    if (_haveDataLoaded == false) {
      PhotoLoader photoLoader = PhotoLoader();
      var fetchedData = await photoLoader.getPhotoData();
      try {
        await DBProvider.instance.insert(DBProvider.photoTableName,
            {DBProvider.colName: jsonEncode(fetchedData)});
      } catch (e) {
        print("Database Error");
      }
    }
  }

  Future<void> _getAll() async {
    try {
      _haveDataLoaded = await _getBoolFromSharedPrefs();
    } catch (e) {
      print("Shared Prefs Error");
    } finally {
      await _getAlbums();
      try {
        await _getPhotos();
      } catch (e) {
        print(e);
      } finally {
        if (_haveDataLoaded == false) {
          await _dataHaveLoaded();
          Navigator.pushNamedAndRemoveUntil(
              context, AlbumScreen.id, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
              context, AlbumScreen.id, (route) => false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SpinKitCubeGrid(
            color: Colors.black,
            size: 120,
            duration: Duration(milliseconds: 1000),
          ),
          SizedBox(
            height: 40,
          ),
          DefaultTextStyle(
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24.0,
              color: Colors.black,
              fontWeight: FontWeight.w300,
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText("Please Wait"),
                WavyAnimatedText("Fetching API Data"),
              ],
              isRepeatingAnimation: true,
            ),
          ),
        ],
      ),
    );
  }
}
