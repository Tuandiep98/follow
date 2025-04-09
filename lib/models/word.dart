import 'package:json_annotation/json_annotation.dart';

part 'word.g.dart';

@JsonSerializable(explicitToJson: true)

class Word {
  final String word;
  final double start;
  final double end;
  const Word(this.word, this.start, this.end);

  factory Word.fromJson(Map<String, dynamic> json) =>
      _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}
