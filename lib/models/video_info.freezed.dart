// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

VideoInfo _$VideoInfoFromJson(Map<String, dynamic> json) {
  return _VideoInfo.fromJson(json);
}

/// @nodoc
mixin _$VideoInfo {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get channel => throw _privateConstructorUsedError;
  String get channelId => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError; // Duration in seconds
  String get thumbnailUrl => throw _privateConstructorUsedError;
  String get uploadDate => throw _privateConstructorUsedError;
  int get viewCount => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String>? get availableFormats => throw _privateConstructorUsedError;
  bool? get hasSubtitles => throw _privateConstructorUsedError;

  /// Serializes this VideoInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VideoInfoCopyWith<VideoInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VideoInfoCopyWith<$Res> {
  factory $VideoInfoCopyWith(VideoInfo value, $Res Function(VideoInfo) then) =
      _$VideoInfoCopyWithImpl<$Res, VideoInfo>;
  @useResult
  $Res call({
    String id,
    String title,
    String channel,
    String channelId,
    int duration,
    String thumbnailUrl,
    String uploadDate,
    int viewCount,
    String description,
    List<String>? availableFormats,
    bool? hasSubtitles,
  });
}

/// @nodoc
class _$VideoInfoCopyWithImpl<$Res, $Val extends VideoInfo>
    implements $VideoInfoCopyWith<$Res> {
  _$VideoInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? channel = null,
    Object? channelId = null,
    Object? duration = null,
    Object? thumbnailUrl = null,
    Object? uploadDate = null,
    Object? viewCount = null,
    Object? description = null,
    Object? availableFormats = freezed,
    Object? hasSubtitles = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            channel: null == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as String,
            channelId: null == channelId
                ? _value.channelId
                : channelId // ignore: cast_nullable_to_non_nullable
                      as String,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            thumbnailUrl: null == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            uploadDate: null == uploadDate
                ? _value.uploadDate
                : uploadDate // ignore: cast_nullable_to_non_nullable
                      as String,
            viewCount: null == viewCount
                ? _value.viewCount
                : viewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            availableFormats: freezed == availableFormats
                ? _value.availableFormats
                : availableFormats // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            hasSubtitles: freezed == hasSubtitles
                ? _value.hasSubtitles
                : hasSubtitles // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$VideoInfoImplCopyWith<$Res>
    implements $VideoInfoCopyWith<$Res> {
  factory _$$VideoInfoImplCopyWith(
    _$VideoInfoImpl value,
    $Res Function(_$VideoInfoImpl) then,
  ) = __$$VideoInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String channel,
    String channelId,
    int duration,
    String thumbnailUrl,
    String uploadDate,
    int viewCount,
    String description,
    List<String>? availableFormats,
    bool? hasSubtitles,
  });
}

/// @nodoc
class __$$VideoInfoImplCopyWithImpl<$Res>
    extends _$VideoInfoCopyWithImpl<$Res, _$VideoInfoImpl>
    implements _$$VideoInfoImplCopyWith<$Res> {
  __$$VideoInfoImplCopyWithImpl(
    _$VideoInfoImpl _value,
    $Res Function(_$VideoInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? channel = null,
    Object? channelId = null,
    Object? duration = null,
    Object? thumbnailUrl = null,
    Object? uploadDate = null,
    Object? viewCount = null,
    Object? description = null,
    Object? availableFormats = freezed,
    Object? hasSubtitles = freezed,
  }) {
    return _then(
      _$VideoInfoImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        channel: null == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as String,
        channelId: null == channelId
            ? _value.channelId
            : channelId // ignore: cast_nullable_to_non_nullable
                  as String,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        thumbnailUrl: null == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        uploadDate: null == uploadDate
            ? _value.uploadDate
            : uploadDate // ignore: cast_nullable_to_non_nullable
                  as String,
        viewCount: null == viewCount
            ? _value.viewCount
            : viewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        availableFormats: freezed == availableFormats
            ? _value._availableFormats
            : availableFormats // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        hasSubtitles: freezed == hasSubtitles
            ? _value.hasSubtitles
            : hasSubtitles // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$VideoInfoImpl implements _VideoInfo {
  const _$VideoInfoImpl({
    required this.id,
    required this.title,
    required this.channel,
    required this.channelId,
    required this.duration,
    required this.thumbnailUrl,
    required this.uploadDate,
    required this.viewCount,
    required this.description,
    final List<String>? availableFormats,
    this.hasSubtitles,
  }) : _availableFormats = availableFormats;

  factory _$VideoInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$VideoInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String channel;
  @override
  final String channelId;
  @override
  final int duration;
  // Duration in seconds
  @override
  final String thumbnailUrl;
  @override
  final String uploadDate;
  @override
  final int viewCount;
  @override
  final String description;
  final List<String>? _availableFormats;
  @override
  List<String>? get availableFormats {
    final value = _availableFormats;
    if (value == null) return null;
    if (_availableFormats is EqualUnmodifiableListView)
      return _availableFormats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final bool? hasSubtitles;

  @override
  String toString() {
    return 'VideoInfo(id: $id, title: $title, channel: $channel, channelId: $channelId, duration: $duration, thumbnailUrl: $thumbnailUrl, uploadDate: $uploadDate, viewCount: $viewCount, description: $description, availableFormats: $availableFormats, hasSubtitles: $hasSubtitles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.channelId, channelId) ||
                other.channelId == channelId) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.uploadDate, uploadDate) ||
                other.uploadDate == uploadDate) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(
              other._availableFormats,
              _availableFormats,
            ) &&
            (identical(other.hasSubtitles, hasSubtitles) ||
                other.hasSubtitles == hasSubtitles));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    channel,
    channelId,
    duration,
    thumbnailUrl,
    uploadDate,
    viewCount,
    description,
    const DeepCollectionEquality().hash(_availableFormats),
    hasSubtitles,
  );

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoInfoImplCopyWith<_$VideoInfoImpl> get copyWith =>
      __$$VideoInfoImplCopyWithImpl<_$VideoInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VideoInfoImplToJson(this);
  }
}

abstract class _VideoInfo implements VideoInfo {
  const factory _VideoInfo({
    required final String id,
    required final String title,
    required final String channel,
    required final String channelId,
    required final int duration,
    required final String thumbnailUrl,
    required final String uploadDate,
    required final int viewCount,
    required final String description,
    final List<String>? availableFormats,
    final bool? hasSubtitles,
  }) = _$VideoInfoImpl;

  factory _VideoInfo.fromJson(Map<String, dynamic> json) =
      _$VideoInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get channel;
  @override
  String get channelId;
  @override
  int get duration; // Duration in seconds
  @override
  String get thumbnailUrl;
  @override
  String get uploadDate;
  @override
  int get viewCount;
  @override
  String get description;
  @override
  List<String>? get availableFormats;
  @override
  bool? get hasSubtitles;

  /// Create a copy of VideoInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoInfoImplCopyWith<_$VideoInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DownloadProgress _$DownloadProgressFromJson(Map<String, dynamic> json) {
  return _DownloadProgress.fromJson(json);
}

/// @nodoc
mixin _$DownloadProgress {
  double get percentage => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get speed => throw _privateConstructorUsedError;
  String? get eta => throw _privateConstructorUsedError;
  String? get fileSize => throw _privateConstructorUsedError;

  /// Serializes this DownloadProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DownloadProgressCopyWith<DownloadProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadProgressCopyWith<$Res> {
  factory $DownloadProgressCopyWith(
    DownloadProgress value,
    $Res Function(DownloadProgress) then,
  ) = _$DownloadProgressCopyWithImpl<$Res, DownloadProgress>;
  @useResult
  $Res call({
    double percentage,
    String status,
    String? speed,
    String? eta,
    String? fileSize,
  });
}

/// @nodoc
class _$DownloadProgressCopyWithImpl<$Res, $Val extends DownloadProgress>
    implements $DownloadProgressCopyWith<$Res> {
  _$DownloadProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percentage = null,
    Object? status = null,
    Object? speed = freezed,
    Object? eta = freezed,
    Object? fileSize = freezed,
  }) {
    return _then(
      _value.copyWith(
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            speed: freezed == speed
                ? _value.speed
                : speed // ignore: cast_nullable_to_non_nullable
                      as String?,
            eta: freezed == eta
                ? _value.eta
                : eta // ignore: cast_nullable_to_non_nullable
                      as String?,
            fileSize: freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DownloadProgressImplCopyWith<$Res>
    implements $DownloadProgressCopyWith<$Res> {
  factory _$$DownloadProgressImplCopyWith(
    _$DownloadProgressImpl value,
    $Res Function(_$DownloadProgressImpl) then,
  ) = __$$DownloadProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double percentage,
    String status,
    String? speed,
    String? eta,
    String? fileSize,
  });
}

/// @nodoc
class __$$DownloadProgressImplCopyWithImpl<$Res>
    extends _$DownloadProgressCopyWithImpl<$Res, _$DownloadProgressImpl>
    implements _$$DownloadProgressImplCopyWith<$Res> {
  __$$DownloadProgressImplCopyWithImpl(
    _$DownloadProgressImpl _value,
    $Res Function(_$DownloadProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percentage = null,
    Object? status = null,
    Object? speed = freezed,
    Object? eta = freezed,
    Object? fileSize = freezed,
  }) {
    return _then(
      _$DownloadProgressImpl(
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        speed: freezed == speed
            ? _value.speed
            : speed // ignore: cast_nullable_to_non_nullable
                  as String?,
        eta: freezed == eta
            ? _value.eta
            : eta // ignore: cast_nullable_to_non_nullable
                  as String?,
        fileSize: freezed == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DownloadProgressImpl implements _DownloadProgress {
  const _$DownloadProgressImpl({
    required this.percentage,
    required this.status,
    this.speed,
    this.eta,
    this.fileSize,
  });

  factory _$DownloadProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$DownloadProgressImplFromJson(json);

  @override
  final double percentage;
  @override
  final String status;
  @override
  final String? speed;
  @override
  final String? eta;
  @override
  final String? fileSize;

  @override
  String toString() {
    return 'DownloadProgress(percentage: $percentage, status: $status, speed: $speed, eta: $eta, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadProgressImpl &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.eta, eta) || other.eta == eta) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, percentage, status, speed, eta, fileSize);

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadProgressImplCopyWith<_$DownloadProgressImpl> get copyWith =>
      __$$DownloadProgressImplCopyWithImpl<_$DownloadProgressImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DownloadProgressImplToJson(this);
  }
}

abstract class _DownloadProgress implements DownloadProgress {
  const factory _DownloadProgress({
    required final double percentage,
    required final String status,
    final String? speed,
    final String? eta,
    final String? fileSize,
  }) = _$DownloadProgressImpl;

  factory _DownloadProgress.fromJson(Map<String, dynamic> json) =
      _$DownloadProgressImpl.fromJson;

  @override
  double get percentage;
  @override
  String get status;
  @override
  String? get speed;
  @override
  String? get eta;
  @override
  String? get fileSize;

  /// Create a copy of DownloadProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadProgressImplCopyWith<_$DownloadProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DownloadResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath, String fileName, int fileSize)
    success,
    required TResult Function(String message, String? details) error,
    required TResult Function() cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath, String fileName, int fileSize)? success,
    TResult? Function(String message, String? details)? error,
    TResult? Function()? cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath, String fileName, int fileSize)? success,
    TResult Function(String message, String? details)? error,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DownloadSuccess value) success,
    required TResult Function(DownloadError value) error,
    required TResult Function(DownloadCancelled value) cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DownloadSuccess value)? success,
    TResult? Function(DownloadError value)? error,
    TResult? Function(DownloadCancelled value)? cancelled,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DownloadSuccess value)? success,
    TResult Function(DownloadError value)? error,
    TResult Function(DownloadCancelled value)? cancelled,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DownloadResultCopyWith<$Res> {
  factory $DownloadResultCopyWith(
    DownloadResult value,
    $Res Function(DownloadResult) then,
  ) = _$DownloadResultCopyWithImpl<$Res, DownloadResult>;
}

/// @nodoc
class _$DownloadResultCopyWithImpl<$Res, $Val extends DownloadResult>
    implements $DownloadResultCopyWith<$Res> {
  _$DownloadResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DownloadResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$DownloadSuccessImplCopyWith<$Res> {
  factory _$$DownloadSuccessImplCopyWith(
    _$DownloadSuccessImpl value,
    $Res Function(_$DownloadSuccessImpl) then,
  ) = __$$DownloadSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String filePath, String fileName, int fileSize});
}

/// @nodoc
class __$$DownloadSuccessImplCopyWithImpl<$Res>
    extends _$DownloadResultCopyWithImpl<$Res, _$DownloadSuccessImpl>
    implements _$$DownloadSuccessImplCopyWith<$Res> {
  __$$DownloadSuccessImplCopyWithImpl(
    _$DownloadSuccessImpl _value,
    $Res Function(_$DownloadSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
    Object? fileName = null,
    Object? fileSize = null,
  }) {
    return _then(
      _$DownloadSuccessImpl(
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        fileSize: null == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$DownloadSuccessImpl implements DownloadSuccess {
  const _$DownloadSuccessImpl({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
  });

  @override
  final String filePath;
  @override
  final String fileName;
  @override
  final int fileSize;

  @override
  String toString() {
    return 'DownloadResult.success(filePath: $filePath, fileName: $fileName, fileSize: $fileSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadSuccessImpl &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filePath, fileName, fileSize);

  /// Create a copy of DownloadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadSuccessImplCopyWith<_$DownloadSuccessImpl> get copyWith =>
      __$$DownloadSuccessImplCopyWithImpl<_$DownloadSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath, String fileName, int fileSize)
    success,
    required TResult Function(String message, String? details) error,
    required TResult Function() cancelled,
  }) {
    return success(filePath, fileName, fileSize);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath, String fileName, int fileSize)? success,
    TResult? Function(String message, String? details)? error,
    TResult? Function()? cancelled,
  }) {
    return success?.call(filePath, fileName, fileSize);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath, String fileName, int fileSize)? success,
    TResult Function(String message, String? details)? error,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(filePath, fileName, fileSize);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DownloadSuccess value) success,
    required TResult Function(DownloadError value) error,
    required TResult Function(DownloadCancelled value) cancelled,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DownloadSuccess value)? success,
    TResult? Function(DownloadError value)? error,
    TResult? Function(DownloadCancelled value)? cancelled,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DownloadSuccess value)? success,
    TResult Function(DownloadError value)? error,
    TResult Function(DownloadCancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class DownloadSuccess implements DownloadResult {
  const factory DownloadSuccess({
    required final String filePath,
    required final String fileName,
    required final int fileSize,
  }) = _$DownloadSuccessImpl;

  String get filePath;
  String get fileName;
  int get fileSize;

  /// Create a copy of DownloadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadSuccessImplCopyWith<_$DownloadSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DownloadErrorImplCopyWith<$Res> {
  factory _$$DownloadErrorImplCopyWith(
    _$DownloadErrorImpl value,
    $Res Function(_$DownloadErrorImpl) then,
  ) = __$$DownloadErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String? details});
}

/// @nodoc
class __$$DownloadErrorImplCopyWithImpl<$Res>
    extends _$DownloadResultCopyWithImpl<$Res, _$DownloadErrorImpl>
    implements _$$DownloadErrorImplCopyWith<$Res> {
  __$$DownloadErrorImplCopyWithImpl(
    _$DownloadErrorImpl _value,
    $Res Function(_$DownloadErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? details = freezed}) {
    return _then(
      _$DownloadErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        details: freezed == details
            ? _value.details
            : details // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$DownloadErrorImpl implements DownloadError {
  const _$DownloadErrorImpl({required this.message, this.details});

  @override
  final String message;
  @override
  final String? details;

  @override
  String toString() {
    return 'DownloadResult.error(message: $message, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DownloadErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.details, details) || other.details == details));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, details);

  /// Create a copy of DownloadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DownloadErrorImplCopyWith<_$DownloadErrorImpl> get copyWith =>
      __$$DownloadErrorImplCopyWithImpl<_$DownloadErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath, String fileName, int fileSize)
    success,
    required TResult Function(String message, String? details) error,
    required TResult Function() cancelled,
  }) {
    return error(message, details);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath, String fileName, int fileSize)? success,
    TResult? Function(String message, String? details)? error,
    TResult? Function()? cancelled,
  }) {
    return error?.call(message, details);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath, String fileName, int fileSize)? success,
    TResult Function(String message, String? details)? error,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, details);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DownloadSuccess value) success,
    required TResult Function(DownloadError value) error,
    required TResult Function(DownloadCancelled value) cancelled,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DownloadSuccess value)? success,
    TResult? Function(DownloadError value)? error,
    TResult? Function(DownloadCancelled value)? cancelled,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DownloadSuccess value)? success,
    TResult Function(DownloadError value)? error,
    TResult Function(DownloadCancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class DownloadError implements DownloadResult {
  const factory DownloadError({
    required final String message,
    final String? details,
  }) = _$DownloadErrorImpl;

  String get message;
  String? get details;

  /// Create a copy of DownloadResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DownloadErrorImplCopyWith<_$DownloadErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DownloadCancelledImplCopyWith<$Res> {
  factory _$$DownloadCancelledImplCopyWith(
    _$DownloadCancelledImpl value,
    $Res Function(_$DownloadCancelledImpl) then,
  ) = __$$DownloadCancelledImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DownloadCancelledImplCopyWithImpl<$Res>
    extends _$DownloadResultCopyWithImpl<$Res, _$DownloadCancelledImpl>
    implements _$$DownloadCancelledImplCopyWith<$Res> {
  __$$DownloadCancelledImplCopyWithImpl(
    _$DownloadCancelledImpl _value,
    $Res Function(_$DownloadCancelledImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DownloadResult
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DownloadCancelledImpl implements DownloadCancelled {
  const _$DownloadCancelledImpl();

  @override
  String toString() {
    return 'DownloadResult.cancelled()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DownloadCancelledImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String filePath, String fileName, int fileSize)
    success,
    required TResult Function(String message, String? details) error,
    required TResult Function() cancelled,
  }) {
    return cancelled();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String filePath, String fileName, int fileSize)? success,
    TResult? Function(String message, String? details)? error,
    TResult? Function()? cancelled,
  }) {
    return cancelled?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String filePath, String fileName, int fileSize)? success,
    TResult Function(String message, String? details)? error,
    TResult Function()? cancelled,
    required TResult orElse(),
  }) {
    if (cancelled != null) {
      return cancelled();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(DownloadSuccess value) success,
    required TResult Function(DownloadError value) error,
    required TResult Function(DownloadCancelled value) cancelled,
  }) {
    return cancelled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(DownloadSuccess value)? success,
    TResult? Function(DownloadError value)? error,
    TResult? Function(DownloadCancelled value)? cancelled,
  }) {
    return cancelled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(DownloadSuccess value)? success,
    TResult Function(DownloadError value)? error,
    TResult Function(DownloadCancelled value)? cancelled,
    required TResult orElse(),
  }) {
    if (cancelled != null) {
      return cancelled(this);
    }
    return orElse();
  }
}

abstract class DownloadCancelled implements DownloadResult {
  const factory DownloadCancelled() = _$DownloadCancelledImpl;
}
