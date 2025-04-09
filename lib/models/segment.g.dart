// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Segment _$SegmentFromJson(Map<String, dynamic> json) => Segment(
      json['text'] as String,
      (json['start'] as num).toDouble(),
      (json['end'] as num).toDouble(),
    );

Map<String, dynamic> _$SegmentToJson(Segment instance) => <String, dynamic>{
      'text': instance.text,
      'start': instance.start,
      'end': instance.end,
    };
