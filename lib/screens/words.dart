import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';


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
  List<Word> themewords = [];
  Map<String, List<Word>> allwords = {};
  int wordIndex = 0;
  bool isTranslate = false;
  Map<String, int> rightwords = {};
  Map<String, int> firstIndex = {}; // the first index of word where the word is not done or not correct

  bool themeOpen = false;
  bool wordsOpen = false;

  bool isRecording = false;

  bool ready = false;

  String recognize = "";

  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  final player = AudioPlayer();

  int kSAMPLERATE = 16000;
  int kNUMBEROFCHANNELS = 1;

  Codec codec = Codec.pcm16;
  String recorderPath = "";

  List<int> toIntList(Uint8List source) {
    return List.from(source);
  }


  List<(String, bool)>? words;

  var recordingDataControllerUint8 = StreamController<Uint8List>();
  StreamSubscription? streamSubscription;
  StreamSubscription? socketSubscription;

  void checkWord() async {
    String recognizeCopy = recognize.toLowerCase();
    recognizeCopy = recognizeCopy.replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}\s]+', unicode: true), '');
    String reference = themewords[wordIndex].text.toLowerCase();
    reference = reference.replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}\s]+', unicode: true), '');
    List<String> referenceWords = [];
    List<String> recognizeWords = [];
    String word = '';
    for (int i = 0; i < recognizeCopy.length; i++) {
      if (recognizeCopy[i] != ' ') {
        word += recognizeCopy[i];
      } else {
        recognizeWords.add(word.replaceAll(' ', ''));
        word = '';
      }
    }
    if (word != '') {
      recognizeWords.add(word.replaceAll(' ', ''));
    }
    word = ' ';
    for (int i = 0; i < reference.length; i++) {
      if (reference[i] != ' ') {
        word += reference[i];
      } else {
        referenceWords.add(word.replaceAll(' ', ''));
        word = '';
      }
    }
    if (word != '') {
      referenceWords.add(word.replaceAll(' ', ''));
    }
    int rightCount = 0;
    List<(String, bool)> wordsCopy = List.filled(recognizeWords.length, ('', false));
    bool isVariation = false;
    for (String variation in themewords[wordIndex].variations) {
      if (recognizeCopy.contains(reference)) {
        isVariation = true;
        break;
      }
    }
    for (int i = 0; i < recognizeWords.length; i++) {
      wordsCopy[i] = (recognizeWords[i], isVariation ? true : false);
    }
    for (String word in referenceWords) {
      if (recognizeWords.contains(word)) {
        rightCount++;
        wordsCopy[recognizeWords.indexOf(word)] = (word, true);
      }
    }
    setState(() {
      words = wordsCopy;
    });
    if (rightCount == referenceWords.length) {
      correctAnswer();
    }
  }

  void correctAnswer() async {
    allwords[currentTheme]![wordIndex].isComplete = true;
    themewords[wordIndex].isComplete = true;
    rightwords[currentTheme!] = rightwords[currentTheme!]! + 1;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection("words").doc(themewords[wordIndex].text).set({
      'isComplete': true
    });
    await player.play(AssetSource("correct.mp3"), volume: 100.0);
  }

  Socket? socket;

  bool isMic = false;

  Future<void> openTheRecoreder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await recorder.openRecorder();
    await recorder.setSubscriptionDuration(Duration(milliseconds: 40));
  }

  void record() async {

    socket = await Socket.connect('37.252.21.214', 80);

    recordingDataControllerUint8 = StreamController<Uint8List>();

    streamSubscription = recordingDataControllerUint8.stream.listen((data) {
      socket!.add(data);
      setState(() {

      });
    });

    recorder.startRecorder(
        codec: codec,
        toStream: recordingDataControllerUint8.sink,
        audioSource: AudioSource.defaultSource,
        sampleRate: kSAMPLERATE,
        numChannels: kNUMBEROFCHANNELS,
        bufferSize: 1024
    );
  }

  void stopRecorder() async {
    try {
      await streamSubscription!.cancel();
      streamSubscription = null;
      await recorder.stopRecorder();
      socketSubscription = socket!.listen((data) async {
        setState(() {
          recognize = utf8.decode(data);
        });
        checkWord();
      });
    } catch (e) {

    } finally {
      await socket!.close();
      socket = null;
    }
  }

  void micOn() async {
    await player.play(AssetSource("mic_on.mp3"), volume: 100.0);
  }

  void micOff() async {
    await player.play(AssetSource("mic_off.mp3"), volume: 100.0);
  }

  void playReference() async {
    await player.play(BytesSource(themewords[wordIndex].audioBytes!));
  }

  @override
  void initState() {
    super.initState();
    getwords();
    openTheRecoreder();
  }

  void getwords() async {
    final wordsSnapshot = await FirebaseFirestore.instance.collection('words').get();
    for (int i = 0; i < wordsSnapshot.size; i++) {
      var word = wordsSnapshot.docs[i];
      String theme = word['theme'];
      if (!allwords.containsKey(theme)) {
        allwords[theme] = [];
        firstIndex[theme] = -1;
      }
      if (!rightwords.containsKey(word.id)) {
        rightwords[theme] = 0;
      }
      String translate = word['translate'];
      List<dynamic> variationsD = word['variations'] as List<dynamic>;
      bool isComplete = false;
      final userwordSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).collection("words").doc(word.id).get();
      if (userwordSnapshot.exists) {
        isComplete = true;
        rightwords[theme] = rightwords[theme]! + 1;
      } else if (firstIndex[theme] == -1) {
        firstIndex[theme] = allwords[theme]!.length;
      }
      List<String> variations = [];
      for (int j = 0; j < variationsD.length; j++) {
        variations.add(variationsD[j].toString());
      }
      Word wd = Word(text: word.id, theme: theme, translate: translate, variations: variations, isComplete: isComplete);
      try {
        final audioData = word.data()['audio']['data'] as String?;
        final bytes = base64Decode(audioData!);
        wd.audioBytes = bytes;
      } catch (e) {

      }
      allwords[theme]!.add(wd);
    }
    for (int i = 0; i < allwords.length; i++) {
      if (firstIndex[allwords.keys.elementAt(i)] == -1) {
        firstIndex[allwords.keys.elementAt(i)] = 0;
      }
    }
    currentTheme = allwords.keys.first;
    themewords = allwords[currentTheme]!;
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
                                  recognize = '';
                                  words = [];
                                });
                              }
                            },
                          ),
                          Container(
                            width: width * 0.65,
                            height: height * 0.15,
                            padding: EdgeInsets.only(left: width * 0.04, right: width * 0.04, top: height * 0.01, bottom: height * 0.02),
                            child: Center(
                              child: Text(isTranslate ? themewords[wordIndex].translate : themewords[wordIndex].text, style: GoogleFonts.roboto(color: Colors.white, fontSize: width * 0.05, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(14)
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, color: wordIndex < themewords.length - 1 ? Colors.white : Colors.transparent, size: width * 0.1),
                            onPressed: () {
                              if (wordIndex < themewords.length - 1) {
                                setState(() {
                                  wordIndex++;
                                  recognize = '';
                                  words = [];
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
                                  playReference();
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
                              width: width * 0.8,
                              height: height * 0.2,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(26)
                              ),
                              padding: EdgeInsets.only(left: width * 0.05, right: width * 0.05, top: height * 0.02),
                              child: recognize != '' ? RichText(
                                text: TextSpan(
                                    children: List.generate(words!.length, (index) => TextSpan(
                                        text: words![index].$1 + (index < words!.length - 1 ? ' ' : ''),
                                        style: GoogleFonts.roboto(color: words![index].$2 ? Colors.green : Colors.red, fontSize: width * 0.06, fontWeight: FontWeight.w400)
                                    ))
                                ),
                              ) : Container()
                          ),
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
                            width: width * 0.8 * (rightwords[currentTheme]!.toDouble() / themewords.length.toDouble()),
                            height: height * 0.05,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                color: Color(0xFFFF962D),
                                borderRadius: BorderRadius.circular(16)
                            ),
                          ),
                          Container(
                            child: Text('${(rightwords[currentTheme]!.toDouble() / themewords.length.toDouble()).toInt() * 100}%', style: TextStyle(fontFamily: "nokia", fontSize: width * 0.06, color: Color(0xFF400093)),),
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(right: width * 0.05),
                          )
                        ],
                      ),
                    ),
                    themewords[wordIndex].isComplete ? Container(
                      child: Icon(Icons.done, color: Colors.white, size: width * 0.18,),
                    ) : Container(),
                    themewords[wordIndex].isComplete ? Text("Верно!", style: TextStyle(fontFamily: "nokia", fontSize: width * 0.07, color: Colors.white,))
                        : Container(),
                    !themewords[wordIndex].isComplete ? GestureDetector(
                      child: Container(
                        margin: EdgeInsets.only(top: height * 0.02),
                        child: Icon(isMic ? Icons.mic_off_outlined : Icons.mic_none, color: isMic ? Color(0xFFE26196) : Colors.white, size: width * 0.2,),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isMic ? Colors.white : Colors.transparent
                        ),
                      ),
                      onLongPress: () {
                        micOn();
                        setState(() {
                          isMic = true;
                        });
                        record();
                      },
                      onLongPressEnd: (_) {
                        micOff();
                        setState(() {
                          isMic = false;
                        });
                        stopRecorder();
                      },
                    ) : Container()
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
                    itemCount: allwords.keys.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Container(
                          child: Text(allwords.keys.elementAt(index), style: GoogleFonts.roboto(fontSize: width * 0.06, color: Colors.black),),
                          decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1, color: Colors.grey))
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            currentTheme = allwords.keys.elementAt(index);
                            themewords = allwords[currentTheme]!;
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
                    itemCount: themewords.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Container(
                          height: height * 0.08,
                          child: Center(
                            child: Text(themewords[index].text, style: GoogleFonts.roboto(fontSize: width * 0.04, color: themewords[index].isComplete ? Colors.green : Colors.red), textAlign: TextAlign.center,),
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







class Word {
  String text;
  String theme;
  String translate;
  List<String> variations;
  bool isComplete;
  Uint8List? audioBytes;
  Word({required this.text, required this.theme, required this.translate, required this.variations, required this.isComplete});
}