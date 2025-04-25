import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {


  @override
  void initState() {
    super.initState();
    func();
  }

  void func() async {
    Socket socket;
    Socket.connect("192.168.31.159", 80).then((Socket sock) {
      sock.add(utf8.encode("Hello"));
    });
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
          children: [
            GestureDetector(
              child: Container(
                width: width * 0.8,
                margin: EdgeInsets.only(top: height * 0.06),
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
              onTap: () {},
            ),
            GestureDetector(
              child: Container(
                width: width * 0.8,
                margin: EdgeInsets.only(top: height * 0.05),
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
              onTap: () {},
            ),
            GestureDetector(
              child: Container(
                width: width * 0.8,
                margin: EdgeInsets.only(top: height * 0.05),
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
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}