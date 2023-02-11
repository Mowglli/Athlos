import 'package:athlos/models/exercise.dart';
import 'package:athlos/models/maxes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/sets.dart';

Future<List<Max>> getSpecificMax(
    String userid, String exercise, double reps) async {
  final QuerySnapshot<Map<String, dynamic>> ref = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(userid)
      .collection('maxes')
      .where('exercise', isEqualTo: exercise)
      .where('reps', isEqualTo: reps)
      .orderBy('weight', descending: true)
      .get();
  List<Max> maxList = <Max>[];
  for (int i = 0; i < ref.docs.length; i++) {
    Max max = Max.fromJson(ref.docs[i].data());
    maxList.add(max);
  }
  return maxList;
}

void deleteMax(String userid, Exercise exercise) async {
  final QuerySnapshot<Map<String, dynamic>> ref = await FirebaseFirestore
      .instance
      .collection('users')
      .doc("5")
      .collection('maxes')
      .where('exerciseID', isEqualTo: exercise.id)
      .get();
  for (int i = 0; i < ref.docs.length; i++) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('maxes')
        .doc(ref.docs[i].id)
        .delete();
  }
}

Future<Max> getOneRepMax(String userid, String exercise) async {
  QuerySnapshot<Map<String, dynamic>>? ref;
  ref = await FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .collection('maxes')
      .where('exercise', isEqualTo: exercise)
      .orderBy('weight', descending: true)
      .get();

  //Log.info(ref.docs.first.data().toString());

  Max returnMax;
  if (ref.docs.isNotEmpty) {
    returnMax = Max.fromJson(ref.docs.first.data());
  } else {
    returnMax = Max("0", "0", 0, '');
  }
  return returnMax;
}

void saveMax(String userid, Max max) {
  Map<String, Object?> jsonMax = max.toJson();
  FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .collection('maxes')
      .add(jsonMax)
      .then((DocumentReference<Map<String, dynamic>> value) {});
}

void checkMax(String userid, Exercise exercise) async {
  // check if max already exists otherwise save
  final QuerySnapshot<Map<String, dynamic>> ref = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(userid)
      .collection('maxes')
      .where('exercise', isEqualTo: exercise.name)
      .get();

  if (ref.docs.isEmpty) {
    List<ExerciseSet> setList = <ExerciseSet>[];
    for (ExerciseSet set in exercise.sets) {
      // check which ones are maxes and which aren't
      if (setList.isNotEmpty) {
        bool shouldUpdate = true;
        for (ExerciseSet newSet in setList) {
          if (newSet.reps == set.reps && newSet.weight == set.weight) {
            shouldUpdate = false;
          }
        }
        if (shouldUpdate) {
          setList.add(set);
        }
      } else {
        setList.add(set);
      }
    }
    for (ExerciseSet set in setList) {
      Max max = Max(set.weight, set.reps, set.sets, exercise.name);
      max.exerciseID = exercise.id;
      saveMax(userid, max);
    }
  } else {
    List<ExerciseSet> setList = <ExerciseSet>[];
    for (ExerciseSet set in exercise.sets) {
      bool shouldUpdate = true;
      for (int i = 0; i < ref.docs.length; i++) {
        QueryDocumentSnapshot<Map<String, dynamic>> data = ref.docs[i];

        if (data['reps'] == set.reps && data['weight'] == set.weight) {
          shouldUpdate = false;
        }
      }
      for (ExerciseSet refSet in setList) {
        if (set.reps == refSet.reps && set.weight == refSet.weight) {
          shouldUpdate = false;
        }
      }
      if (shouldUpdate) {
        setList.add(set);
      }
    }
    for (ExerciseSet set in setList) {
      Max max = Max(set.weight, set.reps, set.sets, exercise.name);
      max.exerciseID = exercise.id;
      saveMax(userid, max);
    }
  }
}

void updateExercise(String id, Exercise exercise) {}

void printFirebase() {
  //
}
