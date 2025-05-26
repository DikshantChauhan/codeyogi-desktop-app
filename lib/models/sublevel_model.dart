class AssetIdObj<T> {
  final T staging;
  final T prod;

  AssetIdObj({required this.staging, required this.prod});

  factory AssetIdObj.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return AssetIdObj<T>(
      staging: fromJsonT(json['staging']),
      prod: fromJsonT(json['prod']),
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    return {'staging': toJsonT(staging), 'prod': toJsonT(prod)};
  }
}

abstract class Sublevel {
  final String id;
  final String type;

  Sublevel({required this.id, required this.type});

  factory Sublevel.fromJson(Map<String, dynamic> json, String id) {
    switch (json['type'] as String?) {
      case 'video':
        return Video.fromJson(json, id);
      case 'quiz':
        return Quiz.fromJson(json, id);
      case 'assignment':
        return Assignment.fromJson(json, id);
      case 'notes':
        return Notes.fromJson(json, id);
      default:
        throw ArgumentError('Unknown step type: ${json['type']}');
    }
  }

  Map<String, dynamic> toJson();
}

class Video extends Sublevel {
  final AssetIdObj<String>? telegramId;
  final String? videoId;
  final AssetIdObj<String>? thumbnailId;
  final String title;

  Video({
    required super.id,
    required this.title,
    this.telegramId,
    this.videoId,
    this.thumbnailId,
  }) : super(type: 'video');

  factory Video.fromJson(Map<String, dynamic> json, String id) {
    return Video(
      id: id,
      title: json['title'] as String,
      telegramId:
          json['telegramId'] != null
              ? AssetIdObj<String>.fromJson(
                json['telegramId'] as Map<String, dynamic>,
                (o) => o as String,
              )
              : null,
      videoId: json['videoId'] as String?,
      thumbnailId:
          json['thumbnailId'] != null
              ? AssetIdObj<String>.fromJson(
                json['thumbnailId'] as Map<String, dynamic>,
                (o) => o as String,
              )
              : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'type': type, 'title': title};
    if (telegramId != null) {
      data['telegramId'] = telegramId!.toJson((value) => value);
    } else if (videoId != null && thumbnailId != null) {
      data['videoId'] = videoId;
      data['thumbnailId'] = thumbnailId!.toJson((value) => value);
    }
    return data;
  }
}

class QuizOption {
  final String value;
  final String? reason;
  final bool? correct; // In Dart, bool? for optional true

  QuizOption({required this.value, this.reason, this.correct});

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      value: json['value'] as String,
      reason: json['reason'] as String?,
      correct: json['correct'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      if (reason != null) 'reason': reason,
      if (correct != null) 'correct': correct,
    };
  }
}

class Quiz extends Sublevel {
  final List<QuizOption> options;
  final String? reason;
  final AssetIdObj<String>? image;
  final String title;

  Quiz({
    required super.id,
    required this.title,
    required this.options,
    this.reason,
    this.image,
  }) : super(type: 'quiz');

  factory Quiz.fromJson(Map<String, dynamic> json, String id) {
    return Quiz(
      id: id,
      title: json['title'] as String,
      options:
          (json['options'] as List<dynamic>)
              .map((e) => QuizOption.fromJson(e as Map<String, dynamic>))
              .toList(),
      reason: json['reason'] as String?,
      image:
          json['image'] != null
              ? AssetIdObj<String>.fromJson(
                json['image'] as Map<String, dynamic>,
                (o) => o as String,
              )
              : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'options': options.map((e) => e.toJson()).toList(),
      if (reason != null) 'reason': reason,
      if (image != null) 'image': image!.toJson((value) => value),
    };
  }
}

enum LangName { html, css, js }

String langNameToString(LangName lang) {
  return lang.toString().split('.').last;
}

LangName langNameFromString(String langStr) {
  switch (langStr.toLowerCase()) {
    case 'html':
      return LangName.html;
    case 'css':
      return LangName.css;
    case 'js':
      return LangName.js;
    default:
      throw ArgumentError('Unknown language name: $langStr');
  }
}

class LangNameMap<T> {
  final T? html;
  final T? css;
  final T? js;

  LangNameMap({this.html, this.css, this.js}) {
    assert(
      html != null || css != null || js != null,
      'LangNameMap must have at least one language value.',
    );
  }

  factory LangNameMap.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return LangNameMap<T>(
      html: json.containsKey('html') ? fromJsonT(json['html']) : null,
      css: json.containsKey('css') ? fromJsonT(json['css']) : null,
      js: json.containsKey('js') ? fromJsonT(json['js']) : null,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) {
    final Map<String, dynamic> data = {};
    if (html != null) data['html'] = toJsonT(html as T);
    if (css != null) data['css'] = toJsonT(css as T);
    if (js != null) data['js'] = toJsonT(js as T);
    return data;
  }

  bool get isEmpty => html == null && css == null && js == null;
}

class GlitchProject {
  final String id;
  final String domain;

  GlitchProject({required this.id, required this.domain});

  factory GlitchProject.fromJson(Map<String, dynamic> json) {
    return GlitchProject(
      id: json['id'] as String,
      domain: json['domain'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'domain': domain};
  }
}

class Assignment extends Sublevel {
  final List<String>? hints;
  final AssetIdObj<String>? solutionVid;
  final String? descriptionForGPT;

  final LangNameMap<String>? initCode;
  final LangNameMap<String>? solutionCode;

  final GlitchProject? glitchInit;
  final GlitchProject? glitchSolution;

  Assignment({
    required super.id,
    this.hints,
    this.solutionVid,
    this.descriptionForGPT,
    this.initCode,
    this.solutionCode,
    this.glitchInit,
    this.glitchSolution,
  }) : super(type: 'assignment') {
    assert(
      (initCode != null && glitchInit == null) ||
          (initCode == null && glitchInit != null),
      'Assignment must have either initCode or glitchInit, but not both.',
    );
  }

  factory Assignment.fromJson(Map<String, dynamic> json, String id) {
    return Assignment(
      id: id,
      hints:
          (json['hints'] as List<dynamic>?)?.map((e) => e as String).toList(),
      solutionVid:
          json['solutionVid'] != null
              ? AssetIdObj<String>.fromJson(
                json['solutionVid'] as Map<String, dynamic>,
                (o) => o as String,
              )
              : null,
      descriptionForGPT: json['descriptionForGPT'] as String?,
      initCode:
          json['initCode'] != null
              ? LangNameMap<String>.fromJson(
                json['initCode'] as Map<String, dynamic>,
                (o) => o as String,
              )
              : null,
      solutionCode:
          json['solutionCode'] != null
              ? LangNameMap<String>.fromJson(
                json['solutionCode'] as Map<String, dynamic>,
                (o) => o as String,
              )
              : null,
      glitchInit:
          json['glitchInit'] != null
              ? GlitchProject.fromJson(
                json['glitchInit'] as Map<String, dynamic>,
              )
              : null,
      glitchSolution:
          json['glitchSolution'] != null
              ? GlitchProject.fromJson(
                json['glitchSolution'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'type': type};
    if (hints != null) data['hints'] = hints;
    if (solutionVid != null) {
      data['solutionVid'] = solutionVid!.toJson((value) => value);
    }
    if (descriptionForGPT != null) {
      data['descriptionForGPT'] = descriptionForGPT;
    }

    if (initCode != null) {
      data['initCode'] = initCode!.toJson((value) => value);
      if (solutionCode != null) {
        data['solutionCode'] = solutionCode!.toJson((value) => value);
      }
    } else if (glitchInit != null) {
      data['glitchInit'] = glitchInit!.toJson();
      if (glitchSolution != null) {
        data['glitchSolution'] = glitchSolution!.toJson();
      }
    }
    return data;
  }
}

class Notes extends Sublevel {
  final AssetIdObj<String> fileId;

  Notes({required this.fileId, required super.id}) : super(type: 'notes');

  factory Notes.fromJson(Map<String, dynamic> json, String id) {
    return Notes(
      fileId: AssetIdObj<String>.fromJson(
        json['fileId'] as Map<String, dynamic>,
        (o) => o as String,
      ),
      id: id,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'type': type,
      'fileId': fileId.toJson((value) => value),
    };
    return data;
  }
}
