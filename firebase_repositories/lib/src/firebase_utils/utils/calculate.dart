double calculateDuration(startTime, endTime, pricePerHour) {
  Duration interval = endTime.difference(startTime);
  final price = interval.inMinutes / 60 * pricePerHour;
  return price;
}
