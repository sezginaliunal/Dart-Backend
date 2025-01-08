extension StringToInt on String {
  int? toInt() => int.tryParse(this);
}
