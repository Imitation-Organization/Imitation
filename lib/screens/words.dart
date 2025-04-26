import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';



class WordsScreen extends StatefulWidget {

  final User user;

  WordsScreen({required this.user});

  @override
  _WordsScreenState createState() => _WordsScreenState(user: user);
}


class _WordsScreenState extends State<WordsScreen> {

  final User user;

  _WordsScreenState({required this.user});

  String? currentTheme;
  List<Phrase> themeWords = [];
  Map<String, List<Phrase>> allWords = {};
  int wordIndex = 0;
  bool isTranslate = false;
  Map<String, int> rightWords = {};
  Map<String, int> firstIndex = {}; // the first index of phrase where the phrase is not done or not correct

  bool themeOpen = false;
  bool wordsOpen = false;

  bool isRecording = false;

  bool ready = false;

  @override
  void initState() {
    super.initState();
    getPhrases();
  }

  void getPhrases() async {
    final phrasesSnapshot = await FirebaseFirestore.instance.collection('phrases').get();
    for (int i = 0; i < phrasesSnapshot.size; i++) {
      var phrase = phrasesSnapshot.docs[i];
      String theme = phrase['theme'];
      if (!allWords.containsKey(theme)) {
        allWords[theme] = [];
        firstIndex[theme] = -1;
      }
      if (!rightWords.containsKey(phrase.id)) {
        rightWords[theme] = 0;
      }
      String translate = phrase['translate'];
      List<dynamic> variationsD = phrase['variations'] as List<dynamic>;
      bool isComplete = false;
      final userPhraseSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection("phrases").doc(phrase.id).get();
      if (userPhraseSnapshot.exists) {
        isComplete = true;
        rightWords[theme] = rightWords[theme]! + 1;
      } else if (firstIndex[theme] == -1) {
        firstIndex[theme] = allWords[theme]!.length;
      }
      List<String> variations = [];
      for (int j = 0; j < variationsD.length; j++) {
        variations.add(variationsD[j].toString());
      }
      Phrase ph = Phrase(text: phrase.id, theme: theme, translate: translate, variations: variations, isComplete: isComplete);
      allWords[theme]!.add(ph);
    }
    currentTheme = allWords.keys.first;
    themeWords = allWords[currentTheme]!;
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
                    Color(0xFF591486),
                    Color(0xFF230052),
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
                                Text('СЛОВА', style: TextStyle(fontFamily: "Nokia", fontSize: width * 0.08, color: Colors.white),),
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
                            icon: Icon(Icons.arrow_back_ios, color: wordIndex > 0 ? Colors.white : Colors.transparent, size: width * 0.1,),
                            onPressed: () {
                              if (wordIndex > 0) {
                                setState(() {
                                  wordIndex--;
                                });
                              }
                            },
                          ),
                          Container(
                            width: width * 0.65,
                            height: height * 0.15,
                            padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.02, bottom: height * 0.02),
                            child: Center(
                              child: Text(isTranslate ? themeWords[wordIndex].translate : themeWords[wordIndex].text, style: GoogleFonts.roboto(color: Colors.white, fontSize: width * 0.06, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(14)
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, color: wordIndex < themeWords.length - 1 ? Colors.white : Colors.transparent, size: width * 0.1),
                            onPressed: () {
                              if (wordIndex < themeWords.length - 1) {
                                setState(() {
                                  wordIndex++;
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
                                    wordsOpen = true;
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
                              icon: Icon(isRecording ? Icons.mic_off_outlined : Icons.mic_none, color: Colors.white, size: width * 0.2,),
                              onPressed: () {},
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
                            width: width * 0.8 * (rightWords[currentTheme]!.toDouble() / themeWords.length.toDouble()),
                            height: height * 0.05,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                color: Color(0xFFFF962D),
                                borderRadius: BorderRadius.circular(16)
                            ),
                          ),
                          Container(
                            child: Text('${(rightWords[currentTheme]!.toDouble() / themeWords.length.toDouble()).toInt()}%', style: TextStyle(fontFamily: "nokia", fontSize: width * 0.06, color: Color(0xFF400093)),),
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(right: width * 0.05),
                          )
                        ],
                      ),
                    ),
                    themeWords[wordIndex].isComplete ? Container(
                      child: Icon(Icons.done, color: Colors.white, size: width * 0.18,),
                    ) : Container(),
                    themeWords[wordIndex].isComplete ? Text("Верно!", style: TextStyle(fontFamily: "nokia", fontSize: width * 0.07, color: Colors.white,))
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
                    itemCount: allWords.keys.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Container(
                          child: Text(allWords.keys.elementAt(index), style: GoogleFonts.roboto(fontSize: width * 0.06, color: Colors.black),),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1, color: Colors.grey))
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            currentTheme = allWords.keys.elementAt(index);
                            themeWords = allWords[currentTheme]!;
                            wordIndex = firstIndex[currentTheme]!;
                            themeOpen = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              ) : Container(),
              wordsOpen ? Container(
                height: height * 0.6,
                width: width * 0.8,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(26),
                    color: Colors.white
                ),
                child: Container(
                  padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.02),
                  child: ListView.builder(
                    itemCount: themeWords.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Container(
                          height: height * 0.08,
                          child: Center(
                            child: Text(themeWords[index].text, style: GoogleFonts.roboto(fontSize: width * 0.04, color: Colors.black), textAlign: TextAlign.center,),
                          ),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1, color: Colors.grey))
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            wordIndex = index;
                            wordsOpen = false;
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