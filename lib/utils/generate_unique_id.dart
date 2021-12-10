int generateUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
}
