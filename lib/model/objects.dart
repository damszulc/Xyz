class ObjectResponse {
  int id;
  String name;
  String type;
  String location;

  ObjectResponse({
    this.id,
    this.name,
    this.type,
    this.location
  });

  static ObjectResponse fromJson(Map<String, dynamic> json) {
    return ObjectResponse(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      location: json['location'],
    );
  }
}
