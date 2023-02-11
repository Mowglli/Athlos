class ExerciseSet {
  final String? rest;
  final String? weight;
  final String? reps;
  final int sets;

  ExerciseSet(this.rest, this.weight, this.reps, this.sets);

  Map<dynamic, dynamic> toJson() {
    return {
      "rest": rest,
      "weight": weight,
      "reps": reps,
      "sets": sets,
    };
  }

  static ExerciseSet fromString(Map set) {
    return ExerciseSet(set['rest'], set['weight'], set['reps'], set['sets']);
  }
}
