import 'package:json_annotation/json_annotation.dart';

part 'segment.g.dart';

@JsonSerializable(explicitToJson: true)
class Segment {
  final String text;
  final double start;
  final double end;
  const Segment(this.text, this.start, this.end);

  factory Segment.fromJson(Map<String, dynamic> json) =>
      _$SegmentFromJson(json);
  Map<String, dynamic> toJson() => _$SegmentToJson(this);
}
