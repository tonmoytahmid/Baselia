class singelbook {
  String? sId;
  String? name;
  String? abbrev;
  String? language;
  List<Chapters>? chapters;
  String? createdAt;
  String? updatedAt;
  int? iV;

  singelbook(
      {this.sId,
      this.name,
      this.abbrev,
      this.language,
      this.chapters,
      this.createdAt,
      this.updatedAt,
      this.iV});

  singelbook.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    abbrev = json['abbrev'];
    language = json['language'];
    if (json['chapters'] != null) {
      chapters = <Chapters>[];
      json['chapters'].forEach((v) {
        chapters!.add(Chapters.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['abbrev'] = abbrev;
    data['language'] = language;
    if (chapters != null) {
      data['chapters'] = chapters!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Chapters {
  String? abbrev;
  String? name;
  int? chapters;
  String? sId;

  Chapters({this.abbrev, this.name, this.chapters, this.sId});

  Chapters.fromJson(Map<String, dynamic> json) {
    abbrev = json['abbrev'];
    name = json['name'];
    chapters = json['chapters'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['abbrev'] = abbrev;
    data['name'] = name;
    data['chapters'] = chapters;
    data['_id'] = sId;
    return data;
  }
}
