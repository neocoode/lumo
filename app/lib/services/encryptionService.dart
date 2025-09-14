import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static const String _salt = 'lumo_app_salt_2024';
  
  // Criptografar senha
  static String encryptPassword(String password) {
    final bytes = utf8.encode(password + _salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Verificar senha
  static bool verifyPassword(String password, String hashedPassword) {
    final encryptedPassword = encryptPassword(password);
    return encryptedPassword == hashedPassword;
  }
  
  // Criptografar dados sensíveis (email + senha)
  static String encryptSensitiveData(String data) {
    final bytes = utf8.encode(data + _salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // Descriptografar dados (não é possível reverter SHA256, mas podemos verificar)
  static bool verifySensitiveData(String data, String encryptedData) {
    final encrypted = encryptSensitiveData(data);
    return encrypted == encryptedData;
  }
}
