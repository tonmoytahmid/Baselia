class versemodel {
  int? total;
  String? name;
  String? language;
  int? chapters;
  int? currentChapter;
  int? remainingChapters;
  String? abbrev;
  List<Data>? data;

  versemodel(
      {this.total,
      this.name,
      this.language,
      this.chapters,
      this.currentChapter,
      this.remainingChapters,
      this.abbrev,
      this.data});

  versemodel.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    name = json['name'];
    language = json['language'];
    chapters = json['chapters'];
    currentChapter = json['currentChapter'];
    remainingChapters = json['remainingChapters'];
    abbrev = json['abbrev'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['name'] = name;
    data['language'] = language;
    data['chapters'] = chapters;
    data['currentChapter'] = currentChapter;
    data['remainingChapters'] = remainingChapters;
    data['abbrev'] = abbrev;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  String? abbrev;
  int? id;
  int? chapter;
  String? lang;
  String? verse;
  int? iV;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.sId,
      this.name,
      this.abbrev,
      this.id,
      this.chapter,
      this.lang,
      this.verse,
      this.iV,
      this.createdAt,
      this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    abbrev = json['abbrev'];
    id = json['id'];
    chapter = json['chapter'];
    lang = json['lang'];
    verse = json['verse'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['abbrev'] = abbrev;
    data['id'] = id;
    data['chapter'] = chapter;
    data['lang'] = lang;
    data['verse'] = verse;
    data['__v'] = iV;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}
