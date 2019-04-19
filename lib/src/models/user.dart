class User {
  String name, email, photoUrl;

  User(String email, {String name = "", String photoUrl = ""}) {
    this.name = name;
    this.email = email;
    this.photoUrl = photoUrl;
  }

  Map<String, dynamic> userToJson() =>
      {
        "name": this.name,
        "email": this.email,
        "photo_url": this.photoUrl
      };
}
