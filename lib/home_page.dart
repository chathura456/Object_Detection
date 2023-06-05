import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.cameras});
  final List<CameraDescription> cameras;

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
            //runModel()
          }
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cameraController = CameraController(widget.cameras[0],ResolutionPreset.high);
    initCamera();

  }

  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    super.dispose();
    //await Tflite.close();
    cameraController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Object Detection'),),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/jarvis.jpg')
            )
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    color: Colors.black,
                    width: 360,
                    height: 320,
                    child: Image.asset('assets/images/camera.jpg'),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      initCamera();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 35),
                      height: 270,
                      width: 360,
                      child: cameraImage ==null? const SizedBox(
                        height: 50,
                        width: 50,
                        child: Icon(Icons.photo_camera_front,color: Colors.blueAccent,size: 40,),
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
                margin: const EdgeInsets.only(top: 55),
                child: SingleChildScrollView(
                  child: Text(
                    results,
                    style: const TextStyle(backgroundColor: Colors.black87,fontSize: 30,color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
