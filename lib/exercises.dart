import 'dart:math';

enum ExerciseState { handDown, handRaising, handUp, handLowering, upPosition, goingDown, downPosition, goingUp  }

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
  double previousElbowY = 0;
  double previousTime = 0;
  ExerciseState exerciseState = ExerciseState.handDown;

  JumpingJacks(Function updateUI, int currentRep) : super(updateUI, currentRep);

  @override
  void processKeyPoints(Map<String, dynamic> keypoints) {
    double elbowY = 0.5 * previousElbowY + 0.5 * keypoints["rightElbow"]["y"];
    double time = DateTime.now().millisecondsSinceEpoch / 1000.0;  // Current time in seconds

    // Calculate direction of movement
    String direction = elbowY > previousElbowY ? "down" : "up";

    previousElbowY = elbowY;
    previousTime = time;

    // Determine the state of the exercise
    switch (exerciseState) {
      case ExerciseState.handDown:
        if (direction == "up") {
          exerciseState = ExerciseState.handRaising;
        }
        break;
      case ExerciseState.handRaising:
        if (direction == "down") {
          exerciseState = ExerciseState.handLowering;
        }
        break;
      case ExerciseState.handLowering:
        if (direction == "down") {
          exerciseState = ExerciseState.handDown;
          repCount++;

          // Update the UI
          updateUI();
        }
        break;
    }
  }
}

// class JumpingJacks extends Exercise {
//   double previousWristY = 0;
//   ExerciseState exerciseState = ExerciseState.handDown;
//
//   JumpingJacks(Function updateUI, int currentRep) : super(updateUI, currentRep);
//
//   @override
//   void processKeyPoints(Map<String, dynamic> keypoints) {
//     double elbowY = 0.5 * previousElbowY + 0.5 * keypoints["rightElbow"]["y"];
//     previousElbowY = elbowY;
//
//     // Determine the state of the exercise
//     switch (exerciseState) {
//       case ExerciseState.handDown:
//         if (elbowY < keypoints["rightShoulder"]["y"]) {
//           exerciseState = ExerciseState.handRaising;
//         }
//         break;
//       case ExerciseState.handRaising:
//         if (elbowY < keypoints["rightShoulder"]["y"]) {
//           exerciseState = ExerciseState.handUp;
//         }
//         break;
//       case ExerciseState.handUp:
//         if (elbowY > keypoints["rightShoulder"]["y"]) {
//           exerciseState = ExerciseState.handLowering;
//         }
//         break;
//       case ExerciseState.handLowering:
//         if (elbowY > keypoints["rightShoulder"]["y"]) {
//           exerciseState = ExerciseState.handDown;
//           repCount++;
//           // Update the UI
//           updateUI();
//         }
//         break;
//     }
//   }
// }

class OverheadPresses extends Exercise {
  double previousElbowY = 0;
  ExerciseState exerciseState = ExerciseState.handDown;

  OverheadPresses(Function updateUI, int currentRep) : super(updateUI, currentRep);

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
        if (elbowY >= keypoints["rightShoulder"]["y"]) {
          exerciseState = ExerciseState.handLowering;
        }
        break;
      case ExerciseState.handLowering:
        if (elbowY >= keypoints["rightShoulder"]["y"]) {
          exerciseState = ExerciseState.handDown;
          repCount++;

          // Update the UI
          updateUI();
        }
        break;
    }
  }
}

class BicepCurls extends Exercise {
  double previousElbowY = 0;
  double previousWristY = 0;
  double previousTime = 0;
  ExerciseState exerciseState = ExerciseState.handDown;

  BicepCurls(Function updateUI, int currentRep) : super(updateUI, currentRep);

  @override
  void processKeyPoints(Map<String, dynamic> keypoints) {
    double elbowY = keypoints["rightElbow"]["y"];
    double wristY = keypoints["rightWrist"]["y"];
    double time = DateTime.now().millisecondsSinceEpoch / 1000.0;  // Current time in seconds

    // Calculate direction of movement
    String elbowDirection = elbowY > previousElbowY ? "up" : "down";
    String wristDirection = wristY > previousWristY ? "up" : "down";

    // Calculate speed of movement (in pixels per second)
    double elbowSpeed = (elbowY - previousElbowY) / (time - previousTime);
    double wristSpeed = (wristY - previousWristY) / (time - previousTime);

    previousElbowY = elbowY;
    previousWristY = wristY;
    previousTime = time;

    // Determine the state of the exercise
    switch (exerciseState) {
      case ExerciseState.handDown:
        if (elbowDirection == "up" && wristDirection == "up" && elbowSpeed > 0.1 && wristSpeed > 0.1) {
          exerciseState = ExerciseState.handRaising;
        }
        break;
      case ExerciseState.handRaising:
        if (elbowDirection == "down" && wristDirection == "down") {
          exerciseState = ExerciseState.handLowering;
        }
        break;
      case ExerciseState.handLowering:
        if (elbowDirection == "up" && wristDirection == "up") {
          exerciseState = ExerciseState.handDown;
          repCount++;

          // Update the UI
          updateUI();
        }
        break;
    }
  }
}

class Squat extends Exercise {
  double previousHipY = 0;
  double previousTime = 0;
  ExerciseState exerciseState = ExerciseState.upPosition;

  Squat(Function updateUI, int currentRep) : super(updateUI, currentRep);

  @override
  void processKeyPoints(Map<String, dynamic> keypoints) {
    double hipY = 0.5 * previousHipY + 0.5 * keypoints["rightHip"]["y"];
    double time = DateTime.now().millisecondsSinceEpoch / 1000.0;  // Current time in seconds

    // Calculate direction of movement
    String direction = hipY > previousHipY ? "down" : "up";

    previousHipY = hipY;
    previousTime = time;

    // Determine the state of the exercise
    switch (exerciseState) {
      case ExerciseState.upPosition:
        if (direction == "down") {
          exerciseState = ExerciseState.goingDown;
        }
        break;
      case ExerciseState.goingDown:
        if (direction == "up") {
          exerciseState = ExerciseState.goingUp;
        }
        break;
      case ExerciseState.goingUp:
        if (direction == "up") {
          exerciseState = ExerciseState.upPosition;
          repCount++;

          // Update the UI
          updateUI();
        }
        break;
    }
  }
}

class PushUp extends Exercise {
  double previousElbowY = 0;
  double previousTime = 0;
  ExerciseState exerciseState = ExerciseState.upPosition;

  PushUp(Function updateUI, int currentRep) : super(updateUI, currentRep);

  @override
  void processKeyPoints(Map<String, dynamic> keypoints) {
    double elbowY = 0.5 * previousElbowY + 0.5 * keypoints["rightElbow"]["y"];
    double time = DateTime.now().millisecondsSinceEpoch / 1000.0;  // Current time in seconds

    // Calculate direction of movement
    String direction = elbowY > previousElbowY ? "down" : "up";

    previousElbowY = elbowY;
    previousTime = time;

    // Determine the state of the exercise
    switch (exerciseState) {
      case ExerciseState.upPosition:
        if (direction == "down") {
          exerciseState = ExerciseState.goingDown;
        }
        break;
      case ExerciseState.goingDown:
        if (direction == "up") {
          exerciseState = ExerciseState.goingUp;
        }
        break;
      case ExerciseState.goingUp:
        if (direction == "up") {
          exerciseState = ExerciseState.upPosition;
          repCount++;

          // Update the UI
          updateUI();
        }
        break;
    }
  }
}

class DeadLift extends Exercise {
  double previousHipY = 0;
  double previousTime = 0;
  ExerciseState exerciseState = ExerciseState.upPosition;

  DeadLift(Function updateUI, int currentRep) : super(updateUI, currentRep);

  @override
  void processKeyPoints(Map<String, dynamic> keypoints) {
    double hipY = 0.5 * previousHipY + 0.5 * keypoints["rightHip"]["y"];
    double time = DateTime.now().millisecondsSinceEpoch / 1000.0;  // Current time in seconds

    // Calculate direction of movement
    String direction = hipY > previousHipY ? "down" : "up";

    previousHipY = hipY;
    previousTime = time;

    // Determine the state of the exercise
    switch (exerciseState) {
      case ExerciseState.upPosition:
        if (direction == "down") {
          exerciseState = ExerciseState.goingDown;
        }
        break;
      case ExerciseState.goingDown:
        if (direction == "up") {
          exerciseState = ExerciseState.goingUp;
        }
        break;
      case ExerciseState.goingUp:
        if (direction == "up") {
          exerciseState = ExerciseState.upPosition;
          repCount++;

          // Update the UI
          updateUI();
        }
        break;
    }
  }
}




