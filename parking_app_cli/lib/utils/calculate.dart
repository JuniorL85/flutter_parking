void calculateDuration(startTime, endTime, pricePerHour) {
  Duration interval = endTime.difference(startTime);
  final price = interval.inMinutes / 60 * pricePerHour;
  print('\nDitt pris kommer att bli: ${price.toStringAsFixed(2)}kr\n');
}
