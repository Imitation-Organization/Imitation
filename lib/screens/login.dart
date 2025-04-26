import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imitation/screens/home.dart';
import 'package:imitation/screens/registration.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {


  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void login() async {
    if (emailController.text != '' && passwordController.text != '') {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );
        User user = credential.user!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Вы успешно вошли в аккаунт"),));
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Пользователь не найден"),));
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Пароль неверный"),));
        }
      }
    } else if (emailController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Введите логин"),));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Введите пароль"),));
    }
  }

  bool _isObscured = true;


  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF962D),
              Color(0xFF400093),
              Color(0xFFFF962D),
            ],
          )
        ),
        child: Stack(
          children: [
            Container(
              width: width,
              height: height,
              alignment: Alignment.center,
              child: SvgPicture.asset("assets/login.svg", width: width * 0.8),
            ),
            Container(
              height: height,
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: height * 0.3),
                    child: Text('Вход', style: GoogleFonts.inter(fontSize: width * 0.08, color: Colors.white),),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: width * 0.1, right: width * 0.1, top: height * 0.05),
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      cursorColor: Colors.white,
                      style: GoogleFonts.inter(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Логин',
                        hintStyle: GoogleFonts.inter(color: Colors.white),
                        filled: false,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide(color: Colors.white)
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: BorderSide(color: Colors.white)
                        )
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: width * 0.1, right: width * 0.1, top: height * 0.05),
                    child: TextField(
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _isObscured,
                      enableSuggestions: false,
                      autocorrect: false,
                      controller: passwordController,
                      cursorColor: Colors.white,
                      style: GoogleFonts.inter(color: Colors.white),
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          hintText: 'Пароль',
                          suffixIcon: IconButton(
                            icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _isObscured = !_isObscured;
                              });
                            },
                            color: Colors.white,
                          ),
                          hintStyle: GoogleFonts.inter(color: Colors.white),
                          filled: false,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(26),
                              borderSide: BorderSide(color: Colors.white)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(26),
                              borderSide: BorderSide(color: Colors.white)
                          )
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: height * 0.05, left: width * 0.02),
                        child: ElevatedButton(
                          child: Text('Зарегистрироваться', style: GoogleFonts.instrumentSans(fontSize: width * 0.05, color: Colors.white),),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegistrationScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF962D),
                              padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8)
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: height * 0.05, right: width * 0.02),
                        child: ElevatedButton(
                          child: Text('Войти', style: GoogleFonts.instrumentSans(fontSize: width * 0.05, color: Colors.white),),
                          onPressed: () {
                            login();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF962D),
                              padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8)
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}