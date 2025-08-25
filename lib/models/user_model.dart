class UserModel {
  String name, email, address, phone;

  UserModel({
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json["name"] ?? "User",
      address: json["address"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
    );
  }
}
