class Singleton {
  Singleton._();
  static final Singleton instance = Singleton._();

  String pubKey;
  String privateKey;
  String userName;
  String userID;
  String friendID;
  String firestoreID;

  void setPubKey(String key) => pubKey = key;

  String getPubKey() => pubKey;
}
