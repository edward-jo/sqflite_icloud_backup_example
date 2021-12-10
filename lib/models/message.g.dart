// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as int?,
      message: json['message'] as String,
      createdTime: DateTime.parse(json['createdTime'] as String),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'createdTime': instance.createdTime.toIso8601String(),
    };
