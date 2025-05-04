import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imitation/screens/login.dart';
import 'package:imitation/screens/phrases.dart';
import 'package:imitation/screens/words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';


class HomeScreen extends StatefulWidget {

  final User user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState(user: user);
}


class _HomeScreenState extends State<HomeScreen> {

  AudioPlayer player = AudioPlayer();

  final User user;

  _HomeScreenState({required this.user});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  void resetProgress() async {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Прогресс сброшен')));
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF400093),
                  Color(0xFF762A76),
                  Color(0xFF974465),
                  Color(0xFFC86B4A),
                  Color(0xFFFF962D)
                ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              child: Row(
                children: [
                  SizedBox(
                    width: width * 0.05,
                  ),
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.white, size: width * 0.1,),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) => AlertDialog(
                            title: const Text('Выйти из аккаунта?'),
                            actions: [
                              TextButton(
                                child: Text('Нет'),
                                onPressed: () {
                                  player.play(AssetSource("click.mp3"), volume: 5);
                                  Navigator.pop(dialogContext);
                                },
                              ),
                              TextButton(
                                child: Text('Да'),
                                onPressed: () {
                                  player.play(AssetSource("click.mp3"), volume: 5);
                                  FirebaseAuth.instance.signOut().then((_) => {
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginScreen()))
                                  });
                                },
                              ),
                            ],
                          )
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white, size: width * 0.1,),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) => AlertDialog(
                            title: const Text('Сбросить прогресс?'),
                            actions: [
                              TextButton(
                                child: Text('Нет'),
                                onPressed: () {
                                  player.play(AssetSource("click.mp3"), volume: 5);
                                  Navigator.pop(dialogContext);
                                },
                              ),
                              TextButton(
                                child: Text('Да'),
                                onPressed: () {
                                  player.play(AssetSource("click.mp3"), volume: 5);
                                  resetProgress();
                                  Navigator.pop(dialogContext);
                                },
                              ),
                            ],
                          )
                      );
                    },
                  ),
                ],
              )
            ),
            GestureDetector(
              child: Container(
                width: width * 0.8,
                margin: EdgeInsets.only(left: width * 0.1),
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('СЛОВА', style: TextStyle(fontFamily: "Nokia", fontSize: width * 0.08, color: Colors.white),),
                          Icon(Icons.play_arrow_outlined, size: width * 0.15, color: Colors.white,)
                        ],
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(width: 1, color: Colors.white),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Text('изучайте новые слова, переводите их на родной язык, используйте подсказки, выбирайте темы ...', style: GoogleFonts.inter(fontSize: width * 0.05),),
                      padding: EdgeInsets.only(left: width * 0.04, right: width * 0.04, bottom: height * 0.02, top: height * 0.01),
                    )
                  ],
                ),
              ),
              onTap: () {
                player.play(AssetSource("click.mp3"), volume: 5);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => WordsScreen(user: user,)));
              },
            ),
            GestureDetector(
              child: Container(
                width: width * 0.8,
                margin: EdgeInsets.only(top: height * 0.03, left: width * 0.1),
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ФРАЗЫ', style: TextStyle(fontFamily: "Nokia", fontSize: width * 0.08, color: Colors.white),),
                          Icon(Icons.play_arrow_outlined, size: width * 0.15, color: Colors.white,)
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Text('изучайте новые фразы, переводите их на родной язык, используйте подсказки, выбирайте темы ...', style: GoogleFonts.inter(fontSize: width * 0.05),),
                      padding: EdgeInsets.only(left: width * 0.04, right: width * 0.04, bottom: height * 0.02, top: height * 0.01),
                    )
                  ],
                ),
              ),
              onTap: () {
                player.play(AssetSource("click.mp3"), volume: 5);
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PhrasesScreen(user: user,)));
              },
            ),
            GestureDetector(
              child: Container(
                width: width * 0.8,
                margin: EdgeInsets.only(top: height * 0.03, left: width * 0.1),
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ИИ', style: TextStyle(fontFamily: "Nokia", fontSize: width * 0.08, color: Colors.white),),
                          Container(
                            child: Image.asset("assets/bot.png", height: width * 0.1,),
                            margin: EdgeInsets.only(left: width * 0.03, right: width * 0.01),
                          ),
                          Icon(Icons.play_arrow_outlined, size: width * 0.15, color: Colors.white,)
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(width: 1, color: Colors.white),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Text('тренируйте говорение, используйте новые слова, получайте мгновенный ответ ...', style: GoogleFonts.inter(fontSize: width * 0.05),),
                      padding: EdgeInsets.only(left: width * 0.04, right: width * 0.04, bottom: height * 0.02, top: height * 0.01),
                    )
                  ],
                ),
              ),
              onTap: () {
                player.play(AssetSource("click.mp3"), volume: 5);
              },
            ),
          ],
        ),
      ),
    );
  }
}