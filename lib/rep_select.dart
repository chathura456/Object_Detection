import 'package:flutter/material.dart';
import 'package:object_detection2/feature_box.dart';
import 'package:object_detection2/next_page.dart';

class RepSelect extends StatefulWidget {
  const RepSelect({super.key});

  @override
  State<RepSelect> createState() => _RepSelectState();
}

class _RepSelectState extends State<RepSelect> {
  var rounds = [1,2,3,4,5];
  var reps = [5,6,7,8,9,10,11,12,13,14,15];
  var exercises = ['Jumping jacks','Overhead presses','Bicep curls'];
  var currentRound = 3;
  var currentRep = 5;
  var selectedExercise = 'Jumping jacks';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('AI Rep Counter',
          style: TextStyle(
              color: Colors.white,
              fontSize: 25
          ),),
        elevation: 2.0,
      ),
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15,),
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
            ElevatedButton(onPressed: (){
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context){
                    return const PoseDetector();
                  })
              );
            }, child: const Text('Confirm'))
          ],
        ),

    );
  }
}
