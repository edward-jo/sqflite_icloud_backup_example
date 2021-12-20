import 'package:json_annotation/json_annotation.dart';
import '../constants.dart';
part 'message.g.dart';

@JsonSerializable()
class Message {
  @JsonKey(name: MessagesDbCols.id)
  final int? id;
  @JsonKey(name: MessagesDbCols.message)
  final String message;
  @JsonKey(name: MessagesDbCols.createdTime)
  final DateTime createdTime;

  Message({
    this.id,
    required this.message,
    required this.createdTime,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
