class ValueException implements Exception {
  ValueException(this.message);
  final String message;

  @override
  String toString() {
    return message;
  }
}
