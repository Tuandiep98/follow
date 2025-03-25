// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResponseData _$ResponseDataFromJson(Map<String, dynamic> json) => ResponseData(
      date: json['date'] as String? ?? '',
      website: json['website'] as String? ?? '',
      featuredArticles: (json['featuredArticles'] as List<dynamic>?)
              ?.map((e) => Article.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ResponseDataToJson(ResponseData instance) =>
    <String, dynamic>{
      'date': instance.date,
      'website': instance.website,
      'featuredArticles':
          instance.featuredArticles.map((e) => e.toJson()).toList(),
    };
