import 'package:follow/models/segment.dart';
import 'package:follow/models/word.dart';

import 'package:json_annotation/json_annotation.dart';

part 'transcribe_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TranscribleResponseModel {
  final String text;
  final String task;
  final String language;
  final double duration;
  List<Segment> segments;
  List<Word> words;
  TranscribleResponseModel(
      {this.text = '',
      this.task = '',
      this.language = '',
      this.duration = 0,
      this.segments = const [],
      this.words = const []});

  factory TranscribleResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TranscribleResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$TranscribleResponseModelToJson(this);
}
