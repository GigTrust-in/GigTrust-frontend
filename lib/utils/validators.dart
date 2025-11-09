bool isValidEmail(String email) {
  final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+');
  return regex.hasMatch(email);
}

bool isValidPassword(String password) {
  if (password.length < 8) return false;
  final hasNumber = RegExp(r"\d").hasMatch(password);
  // consider any non-alphanumeric as a special character
  final hasSpecial = RegExp(r"[^A-Za-z0-9]").hasMatch(password);
  return hasNumber && hasSpecial;
}
bool isValidMobile(String phone) {
  final regex = RegExp(r'^[0-9]{10}$');
  return regex.hasMatch(phone);
}


bool isValidOtp(String otp) {
  final regex = RegExp(r'^[0-9]{4}$');
  return regex.hasMatch(otp);
}