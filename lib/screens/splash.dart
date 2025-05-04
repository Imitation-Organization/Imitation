import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imitation/screens/home.dart';
import 'package:imitation/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audioplayers.dart';



class SplashScreen extends StatefulWidget {

  User? user;

  SplashScreen({required this.user});

  @override
  _SplashScreenState createState() => _SplashScreenState(user: user);
}


class _SplashScreenState extends State<SplashScreen> {

  AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    startPlayer();
  }

  void startPlayer() async {
    await player.play(AssetSource("background.mp3"), volume: 5);
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  User? user;

  _SplashScreenState({required this.user});

  bool isInfo = false;

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
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isInfo = !isInfo;
                      });
                    },
                    icon: Icon(Icons.info, size: width * 0.15, color: Colors.white,),
                    color: Color(0xFFFF962D),
                  ),
                  Container(
                    child: SvgPicture.asset("assets/logo.svg", fit: BoxFit.fitHeight,),
                    height: height * 0.3,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.05),
                    child: ElevatedButton(
                      child: Text('Начать', style: GoogleFonts.instrumentSans(fontSize: width * 0.05, color: Colors.white),),
                      onPressed: () {
                        player.stop();
                        player.play(AssetSource("click.mp3"), volume: 5);
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => user != null ? HomeScreen(user: user!) : LoginScreen()));
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
            isInfo ? GestureDetector(
              child: Container(
                margin: EdgeInsets.only(left: width * 0.05, top: height * 0.2),
                height: height * 0.6,
                width: width * 0.9,
                color: Colors.white,
                padding: EdgeInsets.only(left: width * 0.03, right: width * 0.03, top: height * 0.01, bottom: height * 0.01),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    Text("О приложении", style: GoogleFonts.roboto(fontSize: width * 0.05, fontWeight: FontWeight.w500),),
                    SizedBox(height: height * 0.05,),
                    Text("Данное мобильное приложение «Имитация - Үтүктүү» предназначено для обучения и коррекции говорения на якутском языке с использованием искусственного интеллекта, а также для расширения словарного запаса в игровой форме.", style: GoogleFonts.roboto(fontSize: width * 0.04),),
                    Text("Принцип работы: пользователю предлагается услышать эталонное слово или фразу на якутском языке и правильно повторить в микрофон, приложение с помощью искусственного интеллекта оценивает и показывает ошибку, пользователь ещё раз повторяет с учётом корректировки, и так до тех пор, пока не достигнет нужного результата. Таким образом, пользователи получают полноценный тренажер для обучения и корректировки говорения на якутском языке. ", style: GoogleFonts.roboto(fontSize: width * 0.04),),
                    Text("Приложение охватывает десять наиболее распространённых разговорных тем повседневной жизни, включая бытовые ситуации, работу и другие сферы деятельности. Каждая тема сопровождается аудиоматериалами и заданиями по изучению лексики.  ", style: GoogleFonts.roboto(fontSize: width * 0.04),),
                    Text("Приложение рассчитано на широкий круг лиц, желающих улучшить навыки устной речи на якутском языке. ", style: GoogleFonts.roboto(fontSize: width * 0.04),),
                    SizedBox(height: height * 0.02,),
                    Text("Желаем успехов! ", style: GoogleFonts.roboto(fontSize: width * 0.04),),
                    SizedBox(height: height * 0.02,),
                    Text("По всем вопросам обращаться", style: GoogleFonts.roboto(fontSize: width * 0.04),),
                    Text("ytyktyy@mail.ru", style: GoogleFonts.roboto(fontSize: width * 0.04),)
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  isInfo = !isInfo;
                });
              },
            ) : Container()
          ],
        ),
      )
    );
  }
}