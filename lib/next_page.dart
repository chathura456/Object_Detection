import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'main.dart';

enum ExerciseState { handDown, handRaising, handUp, handLowering }

class PoseDetector extends StatefulWidget {
  const PoseDetector({super.key});

  @override
  State<PoseDetector> createState() => _PoseDetectorState();
}

class _PoseDetectorState extends State<PoseDetector> {

  bool isWorking = false;
  String results = '';
  late CameraController cameraController;
  //CameraImage? cameraImage;
  late List _recognitions;
  late double _imageHeight;
  late double _imageWidth;
  CameraImage? img;
  bool isBusy = false;
  bool handWasUp = false;
  int repCount = 0;
  int roundCount = 0;
  double previousWristY = 0.0;
  FlutterTts flutterTts1 = FlutterTts();
  var rounds = [1,2,3,4,5];
  var reps = [5,6,7,8,9,10,11,12,13,14,15];
  var exercises = ['Jumping jacks','Overhead presses','Bicep curls'];
  var currentRound = 3;
  var currentRep = 5;
  var selectedExercise = 'Jumping jacks';
  AudioPlayer player = AudioPlayer();
  Random random = Random();
  var randomNumber = 3;


  ExerciseState exerciseState = ExerciseState.handDown;

  initCamera() {
    cameraController.initialize().then((value) {
      setState(() {
        cameraController.startImageStream((image) => {
          if(!isWorking){
            isWorking = true,
            img = image,
            //runModel()
            runModelOnFrame()
          }
        });
      });
    });
  }

  loadModel() async{
    try{
      await Tflite.loadModel(
          model: 'assets/posenet_mv1_075_float_from_checkpoints.tflite',
          //model: 'assets/posenet.tflite'
         // labels: 'assets/mobilenet_v1_1.0_224.txt'
      );
    }on PlatformException {
      print('Failed to load model.');
    }

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
    cameraController = CameraController(cameras[0],ResolutionPreset.max);
   // initCamera();

  }



  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    cameraController.stopImageStream();
    cameraController.dispose();
    player.dispose();
  }

  runModelOnFrame() async {
    _imageWidth = (img!.width + 0.0)!;
    _imageHeight = (img!.height + 0.0)!;
    _recognitions = (await Tflite.runPoseNetOnFrame(
      bytesList: img!.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: img!.height,
      imageWidth: img!.width,
      numResults: 1,
      threshold: 0.7,
    ))!;
    print(_recognitions.length);
    isWorking = false;
    setState(() {
      img;
    });
  }

  //TODO draw points
  List<Widget> renderKeyPoints(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight;

    var lists = <Widget>[];
    for (var re in _recognitions) {
      var keypointsList = re["keypoints"].values.toList();
      //var keypoints = { for (var k in keypointsList) k["part"] : k };
      var keypoints = Map.fromIterable(keypointsList, key: (k) => k['part'], value: (k) => k);
      // Apply smoothing
      double wristY = 0.5 * previousWristY + 0.5 * keypoints["rightWrist"]["y"];
      previousWristY = wristY;

      // Determine the state of the exercise
      switch (exerciseState) {
        case ExerciseState.handDown:
          if (wristY < keypoints["rightShoulder"]["y"]) {
            exerciseState = ExerciseState.handRaising;
          }
          break;
        case ExerciseState.handRaising:
          if (wristY < keypoints["rightElbow"]["y"]) {
            exerciseState = ExerciseState.handUp;
          }
          break;
        case ExerciseState.handUp:
          if (wristY > keypoints["rightElbow"]["y"]) {
            exerciseState = ExerciseState.handLowering;
          }
          break;
        case ExerciseState.handLowering:
          if (wristY > keypoints["rightShoulder"]["y"]) {
            exerciseState = ExerciseState.handDown;
            repCount++;
            if(repCount==randomNumber){
                 playRandomMessage();
            }
            //flutterTts1.speak(repCount.toString());
            if(repCount>currentRep){
              var rng = Random();

              setState(() {
                roundCount++;
                repCount = 1;
                randomNumber = rng.nextInt(currentRep) + 1;
              });
            }
          }
          break;
      }

      var list = keypoints.values.map<Widget>((k) {
        if (k["score"] > 0.2) {
          return Positioned(
            left: k["x"] * factorX,
            top: k["y"] * factorY,
            width: 100,
            height: 40,
            child: const Text(
             // "● ${k["part"]}",
              "● ",
              style: TextStyle(
                color: Colors.red,
                fontSize: 12.0,
              ),
            ),
          );
        }
        else {
          return Container();
        }
      }
      ).toList();

      lists.addAll(list);

      // Define the skeleton
     var skeleton = [
        ["leftShoulder", "rightShoulder"],
        ["leftShoulder", "leftElbow"],
        ["rightShoulder", "rightElbow"],
        ["leftElbow", "leftWrist"],
        ["rightElbow", "rightWrist"],
        ["leftShoulder", "leftHip"],
        ["rightShoulder", "rightHip"],
        ["leftHip", "rightHip"],
        ["leftHip", "leftKnee"],
        ["rightHip", "rightKnee"],
        ["leftKnee", "leftAnkle"],
        ["rightKnee", "rightAnkle"],
      ];

      // Draw the skeleton
      for (var joints in skeleton) {
        var firstJoint = joints[0];
        var secondJoint = joints[1];
        if (keypoints.containsKey(firstJoint) && keypoints.containsKey(secondJoint)) {
          if (keypoints[firstJoint]["score"] > 0.2 && keypoints[secondJoint]["score"] > 0.2) {
            lists.add(
                Container(
                  width: factorX,
                  height: factorY,
                  child: CustomPaint(
                    painter: LinePainter(
                      start: Offset(keypoints[firstJoint]["x"] * factorX,
                          keypoints[firstJoint]["y"] * factorY),
                      end: Offset(keypoints[secondJoint]["x"] * factorX,
                          keypoints[secondJoint]["y"] * factorY),
                      color: Colors.red,
                    ),
                  ),
                ));
          }
        }
      }
    }

    return lists;
  }

  List<String> messages = [
    "voices/v1.mp3",
    "voices/v2.mp3",
    "voices/v3.mp3",
    "voices/v4.mp3",
    "voices/v5.mp3",
    "voices/v6.mp3",
    "voices/v7.mp3",
    "voices/v8.mp3",
  ];

  Future playRandomMessage() async {
    String message = messages[random.nextInt(messages.length)];
    await player.play(AssetSource(message));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(
        Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height*1,
        child: Container(
          child: (img==null)
              ? Column(
                children: [
                  const SizedBox(height: 85,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        const Flexible(child: Text('Exercise : ',style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.bold
                        ),),),
                        const SizedBox(width: 30,),
                        Flexible(
                          flex: 2,
                          child: FittedBox(
                            child: DropdownButton(
                                icon: const Icon(Icons.arrow_drop_down_sharp,color: Colors.black),
                                items: List<DropdownMenuItem<String>>.generate(
                                    exercises.length,
                                        (index) => DropdownMenuItem(
                                        value: exercises[index].toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15),
                                          child: Text(exercises[index].toString(),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ))),
                                value: selectedExercise,
                                onChanged: (value){
                                  setState(() {
                                    selectedExercise = value.toString();
                                  });
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        const Flexible(child: Text('No of Rounds : ',style: TextStyle(
                            fontSize: 16,fontWeight: FontWeight.bold
                        ),),),
                        const SizedBox(width: 30,),
                        Flexible(
                          flex: 2,
                          child: FittedBox(
                            child: DropdownButton(
                                icon: const Icon(Icons.arrow_drop_down_sharp,color: Colors.black),
                                items: List<DropdownMenuItem<String>>.generate(
                                    5,
                                        (index) => DropdownMenuItem(
                                        value: rounds[index].toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15),
                                          child: Text(rounds[index].toString(),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ))),
                                value: currentRound.toString(),
                                onChanged: (value){
                                  setState(() {
                                    currentRound = int.parse(value.toString());
                                  });
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  [
                        const Flexible(child: Text('No of Reps : ',
                          style: TextStyle(
                              fontSize: 16,fontWeight: FontWeight.bold
                          ),)),
                        const SizedBox(width: 30,),
                        Flexible(
                          flex: 2,
                          child: FittedBox(
                            child: DropdownButton(
                                icon: const Icon(Icons.arrow_drop_down_sharp,color: Colors.black),
                                items: List<DropdownMenuItem<String>>.generate(
                                    11,
                                        (index) => DropdownMenuItem(
                                        value: reps[index].toString(),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 15),
                                          child: Text(reps[index].toString(),
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ))),
                                value: currentRep.toString(),
                                onChanged: (value){
                                  setState(() {
                                    currentRep = int.parse(value.toString());
                                  });
                                }),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 15,),
                  ElevatedButton(
            onPressed: (){
                  setState(() {
                    repCount = 0;
                  });
                  initCamera();
            },
            child: Container(
                  child: const Text("Let's start"),
            ),
          ),
                ],
              )
              : AspectRatio(
            aspectRatio: cameraController.value.aspectRatio,
            child: CameraPreview(cameraController),
          ),
        )));

    if (img != null && _recognitions.isNotEmpty) {
      stackChildren.addAll(renderKeyPoints(size));

    }



    return SafeArea(

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: Text('',
            style: TextStyle(
                color: Colors.white,
                fontSize: 25
            ),),
          elevation: 2.0,
          actions: [
            Center(
              child: Text('Round : ${roundCount.toString()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
            const SizedBox(width: 20,),
            Center(
              child: Text('Reps : ${repCount.toString()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
            const SizedBox(width: 20,),
            IconButton(onPressed: () async {
              if(img != null){
                cameraController.stopImageStream();
                cameraController.pausePreview().then((value) {
                });
                setState(() {
                  img = null;
                  repCount = 0;

                });
              }
            }, icon: img==null?const Icon(Icons.flip_camera_ios,color: Colors.white,):
            const Icon(Icons.stop,color: Colors.white,)),
            const SizedBox(width: 10,),

          ],
        ),
        body: Container(
            color: Colors.white,
            child: Stack(
              children: stackChildren,
            )),
      ),
    );
  }

/*Future runModel() async {
    if(cameraImage != null){
      await loadModel();
      //print('--------checked----------------');
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90,
          numResults: 2,
          threshold: 0.1,
          asynch: true
      );
      results = "";
      recognitions?.forEach((response) {
        results += response["label"] + " " + (response["confidence"] as double).toStringAsFixed(2) + "\n\n";
        print(results);
      });
      setState(() {
        results;
      });
      isWorking = false;
    }else{
      setState(() {
        results = '';
      });
    }
  }*/
/*runModelOnFrame() async {
    _imageWidth = (img!.width + 0.0)!;
    _imageHeight = (img!.height + 0.0)!;
    _recognitions = (await Tflite.runPoseNetOnFrame(
      bytesList: img!.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      imageHeight: img!.height,
      imageWidth: img!.width,
      numResults: 1,
      threshold: 0.7,
    ))!;
    print(_recognitions.length);
    isWorking = false;
    setState(() {
      img;
    });
  }*/
}


class LinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final Color color;

  LinePainter({required this.start, required this.end, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
