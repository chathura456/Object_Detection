import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  //final List<CameraDescription> cameras;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isWorking = false;
  String results = '';
  late CameraController cameraController;
  CameraImage? cameraImage;

  initCamera() {
    cameraController.initialize().then((value) {
      setState(() {
        cameraController.startImageStream((image) => {
          if(!isWorking){
            isWorking = true,
            cameraImage = image,
            runModel()
          }
        });
      });
    });
  }

  loadModel() async{
    await Tflite.loadModel(
        model: 'assets/mobilenet_v1_1.0_224.tflite',
        labels: 'assets/mobilenet_v1_1.0_224.txt'
    );

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cameraController = CameraController(cameras[0],ResolutionPreset.high);
    //initCamera();
    //loadModel();

  }

  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    cameraController.stopImageStream();
    cameraController.dispose();
  }

  Future runModel() async {
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(title: const Text('Object Detection'),
        actions: [
          IconButton(onPressed: (){

            if(cameraImage != null){
              cameraController.stopImageStream();
              cameraController.pausePreview().then((value) {
                setState(() {
                  results = "";
                });
              });
              setState(() {
                cameraImage = null;
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
                      },
                      child: Container(
                        color: Colors.white,
                        // margin: const EdgeInsets.symmetric(vertical: 35),
                        height: 500,
                        width: MediaQuery.of(context).size.width,
                        child: cameraImage ==null? const SizedBox(
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

    );
  }
}