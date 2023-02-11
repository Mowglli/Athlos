import 'package:athlos/features/database/exercise_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:athlos/features/database/max_bloc.dart';
import 'package:athlos/models/exercise.dart';
import 'package:athlos/models/workout.dart';

Future<Workout> getSpecificWorkout(String userid, String id) async {
  final DocumentReference<Workout> data = FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .collection('workouts')
      .doc(id)
      .withConverter<Workout>(
        fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
            Workout.fromJson(snapshot.data()!),
        toFirestore: (Workout workout, _) => workout.toJson(),
      );
  Workout workout =
      await data.get().then((DocumentSnapshot<Workout> value) => value.data()!);
  workout.id = id;
  return workout;
}

Future<List<Workout>> getWorkoutsWithinDates(
    String userid, DateTime startDate, DateTime endDate) async {
  final QuerySnapshot<Map<String, dynamic>> ref = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(userid)
      .collection('workouts')
      .where('date', isGreaterThanOrEqualTo: startDate)
      .where('date', isLessThanOrEqualTo: endDate)
      .get();

  List<Workout> workoutList = <Workout>[];
  for (int i = 0; i < ref.docs.length; i++) {
    Workout workout = Workout.fromJsonQuery(ref.docs[i]);
    workout.id = ref.docs[i].id;
    workoutList.add(workout);
  }
  return workoutList;
}

Stream<QuerySnapshot<Map<String, dynamic>>> getWorkoutOnDate(
    String userid, DateTime after, DateTime before) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .collection('workouts')
      .where('date', isLessThan: after)
      .where('date', isGreaterThan: before)
      .snapshots();
}

Future<Workout> loadWorkout(String userid, Workout workout) async {
  List<Exercise> exerciseList = <Exercise>[];
  for (int i = 0; i < workout.exercises.length; i++) {
    Exercise exercise = await loadExercise(userid, workout.exercises[i]);
    exerciseList.add(exercise);
  }
  workout.exercises = exerciseList;
  return workout;
}

Future<List<Workout>> getWorkoutTemplates(String userid) async {
  final QuerySnapshot<Map<String, dynamic>> ref = await FirebaseFirestore
      .instance
      .collection('users')
      .doc(userid)
      .collection('workouts')
      .where('template', isEqualTo: true)
      .get();
  List<Workout> workoutTemplates = <Workout>[];

  for (int i = 0; i < ref.docs.length; i++) {
    final DocumentReference<Workout> data = FirebaseFirestore.instance
        .collection('users')
        .doc(userid)
        .collection('workouts')
        .doc(ref.docs[i].id)
        .withConverter<Workout>(
          fromFirestore: (DocumentSnapshot<Map<String, dynamic>> snapshot, _) =>
              Workout.fromJson(snapshot.data()!),
          toFirestore: (Workout max, _) => max.toJson(),
        );
    Workout workout = await data
        .get()
        .then((DocumentSnapshot<Workout> value) => value.data()!);
    workout.id = data.id;
    if (!workoutTemplates.contains(workout)) {
      workoutTemplates.add(workout);
    }
  }
  return workoutTemplates;
}

void saveWorkout(String userid, Workout workout) async {
  List<String> exerciseList = <String>[];
  for (Exercise exercise in workout.exercises) {
    exercise.setExerciseTotals();
    exerciseList.add(await saveExercise(userid, exercise));
  }
  workout.setWorkoutTotals();
  workout.exercises = exerciseList;
  Map<String, Object?> jsonWorkout = workout.toJson();
  FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .collection('workouts')
      .add(jsonWorkout)
      .then((DocumentReference<Map<String, dynamic>> value) {});

  //databaseRef.push().set(workout.toJson());
}

void deleteWorkout(String userid, Workout workout) async {
  for (Exercise exercise in workout.exercises) {
    deleteExercise(userid, exercise);
  }
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .collection('workouts')
      .doc(workout.id)
      .delete();
}

void printFirebase() {
  //
}
