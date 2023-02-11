import 'package:athlos/features/database/max_bloc.dart';
import 'package:athlos/models/exercise.dart';
import 'package:athlos/models/sets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<Exercise> getSpecificExercise(String userid, String id) async {
  final DocumentReference<Exercise> data = FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .collection('exercises')
      .doc(id)
      .withConverter<Exercise>(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
            Exercise.fromJson(snapshot.data()!),
        toFirestore: (Exercise exercise, _) => exercise.toJson(),
      );
  Exercise exercise = await data
      .get()
      .then((DocumentSnapshot<Exercise> value) => value.data()!);
  exercise.id = data.id;
  return exercise;
}

Future<List<String>> getExerciseNames(String userid) async {
  final QuerySnapshot<Map<String, dynamic>> ref = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(userid)
      .collection('exercises')
      .get();

  List<String> exerciseNames = <String>[];

  for (int i = 0; i < ref.docs.length; i++) {
    String name = ref.docs[i].get('name');
    if (!exerciseNames.contains(name)) {
      exerciseNames.add(name);
    }
  }
  return exerciseNames;
}

Future<Exercise> loadExercise(String userid, String id) async {
  final DocumentReference<Exercise> data = FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .collection('exercises')
      .doc(id)
      .withConverter<Exercise>(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
            Exercise.fromJson(snapshot.data()!),
        toFirestore: (Exercise exercise, _) => exercise.toJson(),
      );
  Exercise exercise = await data
      .get()
      .then((DocumentSnapshot<Exercise> value) => value.data()!);
  exercise.id = data.id;
  List<ExerciseSet> setList = <ExerciseSet>[];
  for (int i = 0; i < exercise.sets.length; i++) {
    ExerciseSet set_ = ExerciseSet.fromString(exercise.sets[i]);
    setList.add(set_);
  }
  exercise.sets = setList;
  return exercise;
}

Future<Exercise> getExerciseByName(String userid, String exercise) async {
  final QuerySnapshot<Map<String, dynamic>> ref = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(userid)
      .collection('exercises')
      .where('name', isEqualTo: exercise)
      .orderBy('created', descending: false)
      .get();

  Exercise theExercise = Exercise.fromJson(ref.docs.last.data());
  List<ExerciseSet> setList = <ExerciseSet>[];
  for (int i = 0; i < theExercise.sets.length; i++) {
    ExerciseSet set_ = ExerciseSet.fromString(theExercise.sets[i]);
    setList.add(set_);
  }
  theExercise.sets = setList;
  return theExercise;
}

Future<String> saveExercise(String userid, Exercise exercise) async {
  Map<String, Object?> jsonExercise = exercise.toJson();
  final DocumentReference<Map<String, dynamic>> ref = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(userid)
      .collection('exercises')
      .doc();
  await ref.set(jsonExercise);
  exercise.id = ref.id;
  checkMax(userid, exercise);
  return ref.id;
}

void deleteExercise(String userid, Exercise exercise) async {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .collection('exercises')
      .doc(exercise.id)
      .delete();
  deleteMax(userid, exercise);
}

void updateExercise(String id, Exercise exercise) {}

void printFirebase() {
  //
}
