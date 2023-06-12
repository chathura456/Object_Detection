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
    initCamera();
  }

  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    cameraController.stopImageStream();
    cameraController.dispose();
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
    //double factorY = _imageHeight/_imageWidth*screen.width;

    var lists = <Widget>[];
    for (var re in _recognitions) {
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          left: k["x"] * factorX ,
          top: k["y"] * factorY ,
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
    }
    print('The list : $lists');

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
        height: size.height,
        child: Container(
          child: (!cameraController.value.isInitialized)
              ? Container()
              : AspectRatio(
            aspectRatio: cameraController.value.aspectRatio,
            child: CameraPreview(cameraController),
          ),
        )));

    if (img != null) {
      stackChildren.addAll(renderKeyPoints(size));
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            color: Colors.grey,
            child: Stack(
              children: stackChildren,
            )),
      ),
    );
   /* return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(title: const Text('Object Detection'),
        actions: [
          IconButton(onPressed: (){

            if(img != null){
              cameraController.stopImageStream();
              cameraController.pausePreview().then((value) {
                setState(() {
                  results = "";
                });
              });
              setState(() {
                img = null;
              });

            }

          }, icon: const Icon(Icons.flip_camera_ios))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(

            /* image: DecorationImage(
                    image: AssetImage('assets/images/jarvis.jpg'),
                  fit: BoxFit.fitWidth,
                  repeat: ImageRepeat.repeatX
                ),*/
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 500,
                      child: const SizedBox(),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        //cameraController.stopImageStream();
                        initCamera();
                        //await runModel();
                        await runModelOnFrame();
                      },
                      child: Container(
                        color: Colors.white,
                        // margin: const EdgeInsets.symmetric(vertical: 35),
                        height: 500,
                        width: MediaQuery.of(context).size.width,
                        child: img ==null? const SizedBox(
                          height: 100,
                          width: 100,
                          child: Icon(Icons.camera_alt,color: Colors.deepPurple,size: 80,),
                        ):AspectRatio(
                          aspectRatio: cameraController.value.aspectRatio,
                          child: CameraPreview(cameraController),
                        ),
                      ),
                    ),
                  )
                ],
              ),

              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 25),
                  child: SingleChildScrollView(
                    child: Text(
                      results,
                      style: const TextStyle(fontSize: 25,color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),

    );*/
  }
}
