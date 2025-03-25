import 'package:json_annotation/json_annotation.dart';

part 'article.g.dart';

@JsonSerializable(explicitToJson: true)
class Article {
  const Article({
    this.title = '',
    this.category = '',
    this.url = '',
    this.thumb = '',
  });

  final String title;
  final String category;
  final String url;
  final String thumb;

  String toConstructorString() {
    return '{"title": "Article Title", "category": "Category", "url": "https://example.com", "thumb": "https://example.com/image.jpg"}';
  }

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleToJson(this);
}
