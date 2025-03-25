import 'package:follow/models/article.dart';
import 'package:json_annotation/json_annotation.dart';

part 'response_data.g.dart';

@JsonSerializable(explicitToJson: true)
class ResponseData {
  const ResponseData({
    this.date = '',
    this.website = '',
    this.featuredArticles = const [],
  });

  final String date;
  final String website;
  final List<Article> featuredArticles;

  String toConstructorString() {
    return '{"date": "dd/mm/yyyy", "website": "https://example.com", "featuredArticles": [${Article().toConstructorString()}]}';
  }

  factory ResponseData.fromJson(Map<String, dynamic> json) =>
      _$ResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$ResponseDataToJson(this);
}
