// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Article _$ArticleFromJson(Map<String, dynamic> json) => Article(
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      url: json['url'] as String? ?? '',
      thumb: json['thumb'] as String? ?? '',
    );

Map<String, dynamic> _$ArticleToJson(Article instance) => <String, dynamic>{
      'title': instance.title,
      'category': instance.category,
      'url': instance.url,
      'thumb': instance.thumb,
    };
