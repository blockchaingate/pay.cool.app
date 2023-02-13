import 'package:decimal/decimal.dart';

class ClubProject {
  Name? name;
  Name? description;
  String? sId;
  String? owner;
  String? id;
  int? status;
  String? dateCreated;
  String? address;
  String? image;
  List<String>? coins;
  String? projectId;
  Decimal? joiningFee;

  ClubProject(
      {this.name,
      this.description,
      this.sId,
      this.owner,
      this.id,
      this.status,
      this.dateCreated,
      this.address,
      this.image,
      this.projectId,
      this.coins,
      this.joiningFee});

  ClubProject.fromJson(Map<String, dynamic> json) {
    if (json['coins'] != null) {
      var c = json['coins'] as List;
      if (c != null) {
        coins = [];
        for (var v in c) {
          coins!.add(v);
        }
      }
    }
    if (json['value'] != null) {
      joiningFee = Decimal.parse(json["value"].toString());
    }
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    description =
        json['description'] != null ? Name.fromJson(json['description']) : null;
    sId = json['_id'];
    owner = json['owner'];
    id = json['id'];
    status = json['status'];
    dateCreated = json['dateCreated'];
    address = json['address'];
    image = json['image'];
    projectId = json["project"];
    // coins = json["coins"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (name != null) {
      data['name'] = name!.toJson();
    }
    if (description != null) {
      data['description'] = description!.toJson();
    }
    data['_id'] = sId;
    data['owner'] = owner;
    data['id'] = id;
    data['status'] = status;
    data['dateCreated'] = dateCreated;
    data['address'] = address;
    data['image'] = image;
    data['project'] = projectId;
    data['coins'] = coins;
    data['value'] = joiningFee;
    return data;
  }
}

class Name {
  String? en;
  String? sc;

  Name({this.en, this.sc});

  Name.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    sc = json['sc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    data['sc'] = sc;
    return data;
  }
}

class ClubProjectList {
  final List<ClubProject>? clubProjects;
  ClubProjectList({this.clubProjects});

  factory ClubProjectList.fromJson(List<dynamic> parsedJson) {
    List<ClubProject> clubProjects = [];
    clubProjects = parsedJson.map((i) => ClubProject.fromJson(i)).toList();
    return ClubProjectList(clubProjects: clubProjects);
  }
}
