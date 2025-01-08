extension IntToDateTime on int {
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(this);
}
