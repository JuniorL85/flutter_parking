final RegExp numberRegExp = RegExp(r'\d');

validateSocialSecurityNumber(String input) {
  return input.length == 12 && numberRegExp.hasMatch(input);
}

validateNumber(String input) {
  return numberRegExp.hasMatch(input);
}
