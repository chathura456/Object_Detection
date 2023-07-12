import 'dart:math';

enum ExerciseState { handDown, handRaising, handUp, handLowering }

abstract class Exercise {
  int repCount = 0;
  int roundCount = 0;
  int currentRep; // This will be set by the dropdown
  double previousElbowY = 0;// Random number between 1 and 10

  final Function updateUI;

  Exercise(this.updateUI, this.currentRep);

  void processKeyPoints(Map<String, dynamic> keypoints);
}

class JumpingJacks extends Exercise {
  double previousWristY = 0;
  ExerciseState exerciseState = ExerciseState.handDown;

  JumpingJacks(Function updateUI, int currentRep) : super(updateUI, currentRep);

  @override
  void processKeyPoints(Map<String, dynamic> keypoints) {
    double elbowY = 0.5 * previousElbowY + 0.5 * keypoints["rightElbow"]["y"];
    previousElbowY = elbowY;

    // Determine the state of the exercise
    switch (exerciseState) {
      case ExerciseState.handDown:
        if (elbowY < keypoints["rightShoulder"]["y"]) {
          exerciseState = ExerciseState.handRaising;
        }
        break;
      case ExerciseState.handRaising:
        if (elbowY < keypoints["rightShoulder"]["y"]) {
          exerciseState = ExerciseState.handUp;
        }
        break;
      case ExerciseState.handUp:
        if (elbowY > keypoints["rightShoulder"]["y"]) {
          exerciseState = ExerciseState.handLowering;
        }
        break;
      case ExerciseState.handLowering:
        if (elbowY > keypoints["rightShoulder"]["y"]) {
          exerciseState = ExerciseState.handDown;
          repCount++;
          // Update the UI
          updateUI();
        }
        break;
    }
  }
}


