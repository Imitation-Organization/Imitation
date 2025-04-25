import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imitation/screens/home.dart';


class SplashScreen extends StatefulWidget {


  @override
  _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF400093),
              Color(0xFF2A0060)
            ]
          )
        ),
        child: Stack(
          children: [
            Container(
              height: height,
              width: width,
              child: SvgPicture.asset("assets/splash_background.svg", fit: BoxFit.contain,),
            ),
            Container(
              height: height,
              width: width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: SvgPicture.asset("assets/logo.svg", fit: BoxFit.fitHeight,),
                    height: height * 0.3,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.05),
                    child: ElevatedButton(
                      child: Text('Начать', style: GoogleFonts.instrumentSans(fontSize: width * 0.05, color: Colors.white),),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF962D),
                        padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8)
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}