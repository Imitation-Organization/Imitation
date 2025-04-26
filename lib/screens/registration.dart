import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:imitation/screens/home.dart';
import 'package:imitation/screens/login.dart';


class RegistrationScreen extends StatefulWidget {


  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}


class _RegistrationScreenState extends State<RegistrationScreen> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void registration() async {
    if (emailController.text != '' && passwordController.text != '') {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text
        );
        User user = credential.user!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Вы успешно вошли в аккаунт"),));
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Пароль слишком слабый"),));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Аккаунт уже зарегистрирован"),));
        }
      } catch (e) {
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
                    child: Text('Регистрация', style: GoogleFonts.inter(fontSize: width * 0.08, color: Colors.white),),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: height * 0.05, right: width * 0.02),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: Colors.white,
                          style: IconButton.styleFrom(
                            backgroundColor: Color(0xFFFF962D)
                          )
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: height * 0.05),
                        child: ElevatedButton(
                          child: Text('Зарегистрироваться', style: GoogleFonts.instrumentSans(fontSize: width * 0.05, color: Colors.white),),
                          onPressed: () {
                            registration();
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