int parseInt(Object object) {
  if (object is int) {
    return object;
  } else if (object is String) {
    try {
      return int.parse(object);
    } catch (_) {}
  }
  return null;
}
