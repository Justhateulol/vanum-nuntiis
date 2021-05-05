// import 'package:biometric_storage/biometric_storage.dart';
// import 'package:flutter_string_encryption/flutter_string_encryption.dart';
// import 'package:pointycastle/api.dart';
// import 'package:rsa_encrypt/rsa_encrypt.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// abstract class KeyRepository {
//   Future<AsymmetricKeyPair> generateKeys();
//
//   Future<void> storePasswordEncryptedKeys(String password, AsymmetricKeyPair keyPair);
//   Future<AsymmetricKeyPair> retrievePasswordEncryptedKeys(String password);
//
//   Future<void> storeBiometricEncryptedKeys(AsymmetricKeyPair keyPair);
//   Future<AsymmetricKeyPair> retrieveBiometricEncryptedKeys();
//
//   Future<void> clearKeys();
//
// }
//
// class RsaKeysRepository extends KeyRepository {
//   static const _salt = "LKRzZxj+7No1vDoIgehCza0N3QbQNKPiUvFJtVYd4JNfmA+xQJE2c5xc88YU13hIhzBgUdOV6EEqWm6Aa7bVJOeoPBXMEL"
//       "eBP5ILffDTbkrXZ5+zb/5ZVCOo+0/Weo1bJfLQDHa72CY8XV1mAQytHHLDomtPw4p7RIIh8GTgMIA=";
//   static const _encryptedPublicKeyPrefsKey = "encrypted_public_key";
//   static const _encryptedPrivateKeyPrefsKey = "encrypted_private_key";
//
//   static const _biometricFileName = "FwgZQLaodB";
//   static const _biometricKeysJoinPattern = "\n";
//
//   static const _beginPublicKey = "-----BEGIN PUBLIC KEY-----";
//   static const _endPublicKey = "-----END PUBLIC KEY-----";
//   static const _beginPrivateKey = "-----BEGIN PRIVATE KEY-----";
//   static const _endPrivateKey = "-----END PRIVATE KEY-----";
//
//   final _rsaHelper = RsaKeyHelper();
//   final _cryptor = PlatformStringCryptor();
//   final _storage = BiometricStorage();
//
//   @override
//   Future<AsymmetricKeyPair> generateKeys() {
//     return _rsaHelper.computeRSAKeyPair(_rsaHelper.getSecureRandom());
//   }
//
//   @override
//   Future<void> storePasswordEncryptedKeys(String password, AsymmetricKeyPair keyPair) async {
//     final key = await _cryptor.generateKeyFromPassword(password, _salt);
//     final publicKeyPem = _rsaHelper.encodePublicKeyToPemPKCS1(keyPair.publicKey);
//     final privateKeyPem = _rsaHelper.encodePrivateKeyToPemPKCS1(keyPair.privateKey);
//     final encryptedPublicKey = await _cryptor.encrypt(publicKeyPem, key);
//     final encryptedPrivateKey = await _cryptor.encrypt(privateKeyPem, key);
//
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_encryptedPublicKeyPrefsKey, encryptedPublicKey);
//     await prefs.setString(_encryptedPrivateKeyPrefsKey, encryptedPrivateKey);
//   }
//
//   @override
//   Future<AsymmetricKeyPair> retrievePasswordEncryptedKeys(String password) async {
//     final prefs = await SharedPreferences.getInstance();
//     final encryptedPublicKey = prefs.getString(_encryptedPublicKeyPrefsKey);
//     final encryptedPrivateKey = prefs.getString(_encryptedPrivateKeyPrefsKey);
//
//     final key = await _cryptor.generateKeyFromPassword(password, _salt);
//     final publicKeyPem = await _cryptor.decrypt(encryptedPublicKey, key);
//     final privateKeyPem = await _cryptor.decrypt(encryptedPrivateKey, key);
//     final publicKey = _rsaHelper.parsePublicKeyFromPem(publicKeyPem);
//     final privateKey = _rsaHelper.parsePrivateKeyFromPem(privateKeyPem);
//
//     final keyPair = AsymmetricKeyPair(publicKey, privateKey);
//
//     return keyPair;
//   }
//
//   @override
//   Future<void> storeBiometricEncryptedKeys(AsymmetricKeyPair keyPair) async {
//     final publicKeyPem = _rsaHelper.encodePublicKeyToPemPKCS1(keyPair.publicKey);
//     final privateKeyPem = _rsaHelper.encodePrivateKeyToPemPKCS1(keyPair.privateKey);
//     return (await _storage.getStorage(
//       _biometricFileName,
//       androidPromptInfo: AndroidPromptInfo(title: "Authenticate to prepare secure storage"),
//     )).write(publicKeyPem + _biometricKeysJoinPattern + privateKeyPem);
//   }
//
//   @override
//   Future<AsymmetricKeyPair> retrieveBiometricEncryptedKeys() async {
//     final storedKeys = (await (await _storage.getStorage(_biometricFileName)).read());
//
//     final publicKeyStartIndex = storedKeys.indexOf(_beginPublicKey);
//     final publicKeyEndIndex = storedKeys.indexOf(_endPublicKey) + _endPublicKey.length;
//
//     final privateKeyStartIndex = storedKeys.indexOf(_beginPrivateKey);
//     final privateKeyEndIndex = storedKeys.indexOf(_endPrivateKey) + _endPrivateKey.length;
//
//     final publicKeyPem = storedKeys.substring(publicKeyStartIndex, publicKeyEndIndex);
//     final privateKeyPem = storedKeys.substring(privateKeyStartIndex, privateKeyEndIndex);
//     final publicKey = _rsaHelper.parsePublicKeyFromPem(publicKeyPem);
//     final privateKey = _rsaHelper.parsePrivateKeyFromPem(privateKeyPem);
//
//     final keyPair = AsymmetricKeyPair(publicKey, privateKey);
//
//     return keyPair;
//   }
//
//   @override
//   Future<void> clearKeys() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_encryptedPublicKeyPrefsKey, null);
//     await prefs.setString(_encryptedPrivateKeyPrefsKey, null);
//   }
//
// }