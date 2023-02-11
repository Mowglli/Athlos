import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:athlos/models/sets.dart';
//import 'package:athlos/UI/exercise/totals_widget.dart';

class Exercise {
  Exercise(
    this.name,
    this.sets,
    this.bodyParts,
    this.totalSets,
    this.totalReps,
    this.totalWeight,
  );

  Exercise.fromJson(Map<String, Object?> exercise)
      : this.name = exercise['name']! as String,
        this.sets = exercise['sets']! as List<dynamic>,
        this.bodyParts = exercise['body_parts']! as List<dynamic>,
        this.totalReps = exercise['total_reps']! as int,
        this.totalWeight = exercise['total_weight']! as double,
        this.totalSets = exercise['total_sets']! as int;

  String name;
  List<dynamic> sets;
  List<dynamic> bodyParts;
  String? id;
  int totalReps;
  double totalWeight;
  int totalSets;

  //ExerciseTotalsWidget totalWidget =
  //  ExerciseTotalsWidget(totals: TotalsData(0, 0, 0.0, 0.0), index: 0);

  void setExerciseTotals() {
    totalReps = 0;
    totalSets = 0;
    totalWeight = 0.0;
    for (ExerciseSet set in sets) {
      totalSets += 1;
      final weightInt = set.weight == null ? 0 : double.tryParse(set.weight!);
      final repsInt = set.reps == null ? 0 : int.tryParse(set.reps!);

      totalReps += repsInt!;
      totalWeight += (repsInt * weightInt!);
    }
    //totalWidget.totals.totalReps = totalReps;
    //totalWidget.totals.totalSets = totalSets;
    //totalWidget.totals.totalWeight = totalWeight;
    //totalWidget.totals.avgWeight = totalWeight / totalReps;
  }

  Map<String, dynamic> toJson() {
    List<dynamic> theSets = <dynamic>[];
    for (ExerciseSet set in sets) {
      theSets.add(set.toJson());
    }
    return <String, dynamic>{
      'name': name,
      'sets': theSets,
      'body_parts': bodyParts,
      'total_reps': totalReps,
      'total_weight': totalWeight,
      'total_sets': totalSets,
      'created': FieldValue.serverTimestamp()
    };
  }
}
