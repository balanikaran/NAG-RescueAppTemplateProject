import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  String name, byUid, byName, description, documentId;
  List<String> photoUrls, tags;
  GeoPoint location;
  int quantity;
  DateTime timeAdded;

  Item(
      String name,
      int quantity,
      String byUid,
      String byName,
      String documentId,
      String description,
      DateTime timeAdded,
      List<String> photoUrls,
      List<String> tags,
      GeoPoint location) {
    this.name = name;
    this.byUid = byUid;
    this.byName = byName;
    this.documentId = documentId;
    this.quantity = quantity;
    this.timeAdded = timeAdded;
    this.photoUrls = photoUrls;
    this.description = description;
    this.tags = tags;
    this.location = location;
  }

  Item.fromDocumentSnapshot(DocumentSnapshot document)
      : this.name = document.data['name'],
        this.byUid = document.data['by_uid'],
        this.byName = document.data['by_name'],
        this.documentId = document.data['document_id'],
        this.quantity = document.data['quantity'],
        this.timeAdded = DateTime.fromMillisecondsSinceEpoch(
            document.data['time_added'].millisecondsSinceEpoch),
        this.photoUrls = List.from(document.data['photo_urls']),
        this.tags = List.from(document.data['tags']),
        this.location = document.data['location'],
        this.description = document.data['description'];

  Map<String, dynamic> itemToJson() => {
        'name': this.name,
        'by_uid': this.byUid,
        'by_name': this.byName,
        'document_id': this.documentId,
        'quantity': this.quantity,
        'time_added': this.timeAdded,
        'photo_urls': this.photoUrls,
        'tags': this.tags,
        'location': this.location,
        'description': this.description,
      };
}
