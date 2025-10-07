// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoInfoImpl _$$VideoInfoImplFromJson(Map<String, dynamic> json) =>
    _$VideoInfoImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      channel: json['channel'] as String,
      channelId: json['channelId'] as String,
      duration: (json['duration'] as num).toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String,
      uploadDate: json['uploadDate'] as String,
      viewCount: (json['viewCount'] as num).toInt(),
      description: json['description'] as String,
      availableFormats: (json['availableFormats'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      hasSubtitles: json['hasSubtitles'] as bool?,
    );

Map<String, dynamic> _$$VideoInfoImplToJson(_$VideoInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'channel': instance.channel,
      'channelId': instance.channelId,
      'duration': instance.duration,
      'thumbnailUrl': instance.thumbnailUrl,
      'uploadDate': instance.uploadDate,
      'viewCount': instance.viewCount,
      'description': instance.description,
      'availableFormats': instance.availableFormats,
      'hasSubtitles': instance.hasSubtitles,
    };

_$DownloadProgressImpl _$$DownloadProgressImplFromJson(
  Map<String, dynamic> json,
) => _$DownloadProgressImpl(
  percentage: (json['percentage'] as num).toDouble(),
  status: json['status'] as String,
  speed: json['speed'] as String?,
  eta: json['eta'] as String?,
  fileSize: json['fileSize'] as String?,
);

Map<String, dynamic> _$$DownloadProgressImplToJson(
  _$DownloadProgressImpl instance,
) => <String, dynamic>{
  'percentage': instance.percentage,
  'status': instance.status,
  'speed': instance.speed,
  'eta': instance.eta,
  'fileSize': instance.fileSize,
};
