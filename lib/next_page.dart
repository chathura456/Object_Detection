import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite/tflite.dart';
import 'main.dart';

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
    cameraController = CameraController(cameras[0],ResolutionPreset.high);
   // initCamera();
  }

  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    cameraController.stopImageStream();
    cameraController.dispose();
  }

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

  //TODO draw points
  List<Widget> renderKeyPoints(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight;

    var lists = <Widget>[];
    for (var re in _recognitions) {
      var keypointsList = re["keypoints"].values.toList();
      var keypoints = { for (var k in keypointsList) k["part"] : k };

      var list = keypoints.values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX,
          top: k["y"] * factorY,
          width: 100,
          height: 40,
          child: Text(
            "● ${k["part"]}",
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();

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
          lists.add(
              Container(
                width: factorX,
                height: factorY,
                child: CustomPaint(
            painter: LinePainter(
                start: Offset(keypoints[firstJoint]["x"] * factorX, keypoints[firstJoint]["y"] * factorY),
                end: Offset(keypoints[secondJoint]["x"] * factorX, keypoints[secondJoint]["y"] * factorY),
                color: Colors.red,
            ),
          ),
              ));
        }
      }
    }

    return lists;
  }





  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        height: size.height*0.9,
        child: Container(
          child: (img==null)
              ? ElevatedButton(
            onPressed: (){
              initCamera();
            },
            child: Container(
              color: Colors.white,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Icon(Icons.camera_alt,color: Colors.deepPurple,size: 80,),
                  ),
                  SizedBox(height: 10,),
                  Text('Tap on Camera Icon to start Rep Counter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
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
          title: const Text('AI Rep Counter',
            style: TextStyle(
                color: Colors.white,
                fontSize: 25
            ),),
          elevation: 2.0,
          actions: [
            IconButton(onPressed: () async {
              if(img != null){
                cameraController.stopImageStream();
                cameraController.pausePreview().then((value) {
                });
                setState(() {
                  img = null;
                });
              }
            }, icon: img==null?const Icon(Icons.flip_camera_ios,color: Colors.white,):
            const Icon(Icons.stop,color: Colors.white,))
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