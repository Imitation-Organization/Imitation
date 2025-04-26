import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';



class PhrasesScreen extends StatefulWidget {

  final User user;
  
  PhrasesScreen({required this.user});
  
  @override
  _PhrasesScreenState createState() => _PhrasesScreenState(user: user);
}


class _PhrasesScreenState extends State<PhrasesScreen> {

  final User user;

  _PhrasesScreenState({required this.user});

  String? currentTheme;
  List<Phrase> themePhrases = [];
  Map<String, List<Phrase>> allPhrases = {};
  int phraseIndex = 0;
  bool isTranslate = false;
  Map<String, int> rightPhrases = {};
  Map<String, int> firstIndex = {}; // the first index of phrase where the phrase is not done or not correct

  bool themeOpen = false;
  bool phrasesOpen = false;

  bool isRecording = false;

  bool ready = false;

  FlutterSoundRecorder recorder = FlutterSoundRecorder();

  Future<void> openTheRecoreder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await recorder.openRecorder();
  }

  Codec codec = Codec.mp3;
  String recorderPath = "record.mp3";

  void record() {
    recorder.startRecorder(
      toFile: recorderPath,
      codec: codec,
      audioSource: AudioSource.microphone
    ).then((value) {
      setState(() {
        
      });
    });
  }
  
  void stopRecorder() async {
    await recorder.startRecorder().then((value) {
      setState(() {

      });
    });
  }

  @override
  void initState() {
    super.initState();
    getPhrases();
    openTheRecoreder();
  }

  void getPhrases() async {
    final phrasesSnapshot = await FirebaseFirestore.instance.collection('phrases').get();
    for (int i = 0; i < phrasesSnapshot.size; i++) {
      var phrase = phrasesSnapshot.docs[i];
      String theme = phrase['theme'];
      if (!allPhrases.containsKey(theme)) {
        allPhrases[theme] = [];
        firstIndex[theme] = -1;
      }
      if (!rightPhrases.containsKey(phrase.id)) {
        rightPhrases[theme] = 0;
      }
      String translate = phrase['translate'];
      List<dynamic> variationsD = phrase['variations'] as List<dynamic>;
      bool isComplete = false;
      final userPhraseSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection("phrases").doc(phrase.id).get();
      if (userPhraseSnapshot.exists) {
        isComplete = true;
        rightPhrases[theme] = rightPhrases[theme]! + 1;
      } else if (firstIndex[theme] == -1) {
        firstIndex[theme] = allPhrases[theme]!.length;
      }
      List<String> variations = [];
      for (int j = 0; j < variationsD.length; j++) {
        variations.add(variationsD[j].toString());
      }
      Phrase ph = Phrase(text: phrase.id, theme: theme, translate: translate, variations: variations, isComplete: isComplete);
      allPhrases[theme]!.add(ph);
    }
    currentTheme = allPhrases.keys.first;
    themePhrases = allPhrases[currentTheme]!;
    setState(() {
      ready = true;
    });
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFE26196),
              Color(0xFF8D0F43),
            ]
          )
        ),
        child: ready ? Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: width,
              height: height,
              child: Column(
                children: [
                  Container(
                    width: width * 0.8,
                    margin: EdgeInsets.only(top: height * 0.05),
                    child: Column(
                      children: [
                        Container(
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white, size: width * 0.1,),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          alignment: Alignment.topLeft,
                        ),
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
                              borderRadius: BorderRadius.circular(16)
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Icon(Icons.list, color: Colors.white, size: width * 0.15,),
                        ),
                        Container(
                          width: width * 0.6,
                          child: ElevatedButton(
                            child: Text(currentTheme!, style: GoogleFonts.instrumentSans(fontSize: width * 0.05, color: Colors.black),),
                            onPressed: () {
                              setState(() {
                                themeOpen = !themeOpen;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 8)
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: phraseIndex > 0 ? Colors.white : Colors.transparent, size: width * 0.1,),
                          onPressed: () {
                            if (phraseIndex > 0) {
                              setState(() {
                                phraseIndex--;
                              });
                            }
                          },
                        ),
                        Container(
                          width: width * 0.65,
                          height: height * 0.15,
                          padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.02, bottom: height * 0.02),
                          child: Center(
                            child: Text(isTranslate ? themePhrases[phraseIndex].translate : themePhrases[phraseIndex].text, style: GoogleFonts.roboto(color: Colors.white, fontSize: width * 0.06, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(14)
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios, color: phraseIndex < themePhrases.length - 1 ? Colors.white : Colors.transparent, size: width * 0.1),
                          onPressed: () {
                            if (phraseIndex < themePhrases.length - 1) {
                              setState(() {
                                phraseIndex++;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: height * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: IconButton(
                            icon: Icon(isTranslate ? Icons.visibility_off : Icons.visibility, color: Colors.white, size: width * 0.1,),
                            onPressed: () {
                              setState(() {
                                isTranslate = !isTranslate;
                              });
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: width * 0.05, right: width * 0.05),
                          child: IconButton(
                            icon: Icon(Icons.list_alt, color: Colors.white, size: width * 0.1,),
                            onPressed: () {
                              setState(() {
                                phrasesOpen = true;
                              });
                            },
                          ),
                        ),
                        Container(
                          child: IconButton(
                            icon: Icon(Icons.volume_up, color: Colors.white, size: width * 0.1,),
                            onPressed: () {
                              setState(() {
                              });
                            },
                          ),
                        ),
                      ],
                    )
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: width * 0.6,
                          height: height * 0.2,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26)
                          ),
                        ),
                        Container(
                          child: IconButton(
                            icon: Icon(recorder.isRecording ? Icons.mic_off_outlined : Icons.mic_none, color: Colors.white, size: width * 0.2,),
                            onPressed: () {
                              recorder.isRecording ? stopRecorder() : record();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: width * 0.8,
                    height: height * 0.05,
                    margin: EdgeInsets.only(top: height * 0.04),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Stack(
                      children: [
                        Container(
                          width: width * 0.8 * (rightPhrases[currentTheme]!.toDouble() / themePhrases.length.toDouble()),
                          height: height * 0.05,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF962D),
                            borderRadius: BorderRadius.circular(16)
                          ),
                        ),
                        Container(
                          child: Text('${(rightPhrases[currentTheme]!.toDouble() / themePhrases.length.toDouble()).toInt()}%', style: TextStyle(fontFamily: "nokia", fontSize: width * 0.06, color: Color(0xFF400093)),),
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(right: width * 0.05),
                        )
                      ],
                    ),
                  ),
                  themePhrases[phraseIndex].isComplete ? Container(
                    child: Icon(Icons.done, color: Colors.white, size: width * 0.18,),
                  ) : Container(),
                  themePhrases[phraseIndex].isComplete ? Text("Верно!", style: TextStyle(fontFamily: "nokia", fontSize: width * 0.07, color: Colors.white,))
                      : Container(),
                ],
              ),
            ),
            themeOpen ? Container(
              height: height * 0.6,
              width: width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: Colors.white
              ),
              child: Container(
                padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.02),
                child: ListView.builder(
                  itemCount: allPhrases.keys.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Container(
                        child: Text(allPhrases.keys.elementAt(index), style: GoogleFonts.roboto(fontSize: width * 0.06, color: Colors.black),),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1, color: Colors.grey))
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          currentTheme = allPhrases.keys.elementAt(index);
                          themePhrases = allPhrases[currentTheme]!;
                          phraseIndex = firstIndex[currentTheme]!;
                          themeOpen = false;
                        });
                      },
                    );
                  },
                ),
              ),
            ) : Container(),
            phrasesOpen ? Container(
              height: height * 0.6,
              width: width * 0.8,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: Colors.white
              ),
              child: Container(
                padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.02),
                child: ListView.builder(
                  itemCount: themePhrases.length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Container(
                        height: height * 0.08,
                        child: Center(
                          child: Text(themePhrases[index].text, style: GoogleFonts.roboto(fontSize: width * 0.04, color: Colors.black), textAlign: TextAlign.center,),
                        ),
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(width: 1, color: Colors.grey))
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          phraseIndex = index;
                          phrasesOpen = false;
                        });
                      },
                    );
                  },
                ),
              ),
            ) : Container(),
          ],
        ) : Center(
          child: Container(
            height: width * 0.1,
            width: width * 0.1,
            child: CircularProgressIndicator(color: Colors.white,),
          )
        )
      ),
    );
  }
}







class Phrase {
  String text;
  String theme;
  String translate;
  List<String> variations;
  bool isComplete;
  Phrase({required this.text, required this.theme, required this.translate, required this.variations, required this.isComplete});
}