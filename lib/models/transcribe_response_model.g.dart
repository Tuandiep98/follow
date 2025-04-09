// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transcribe_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranscribleResponseModel _$TranscribleResponseModelFromJson(
        Map<String, dynamic> json) =>
    TranscribleResponseModel(
      text: json['text'] as String? ?? '',
      task: json['task'] as String? ?? '',
      language: json['language'] as String? ?? '',
      duration: (json['duration'] as num?)?.toDouble() ?? 0,
      segments: (json['segments'] as List<dynamic>?)
              ?.map((e) => Segment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      words: (json['words'] as List<dynamic>?)
              ?.map((e) => Word.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$TranscribleResponseModelToJson(
        TranscribleResponseModel instance) =>
    <String, dynamic>{
      'text': instance.text,
      'task': instance.task,
      'language': instance.language,
      'duration': instance.duration,
      'segments': instance.segments.map((e) => e.toJson()).toList(),
      'words': instance.words.map((e) => e.toJson()).toList(),
    };
