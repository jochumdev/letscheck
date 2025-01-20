// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CommentsState extends CommentsState {
  @override
  final BuiltMap<String, BuiltMap<num, cmk_api.TableCommentsDto>> comments;

  factory _$CommentsState([void Function(CommentsStateBuilder)? updates]) =>
      (new CommentsStateBuilder()..update(updates))._build();

  _$CommentsState._({required this.comments}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        comments, r'CommentsState', 'comments');
  }

  @override
  CommentsState rebuild(void Function(CommentsStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CommentsStateBuilder toBuilder() => new CommentsStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CommentsState && comments == other.comments;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, comments.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CommentsState')
          ..add('comments', comments))
        .toString();
  }
}

class CommentsStateBuilder
    implements Builder<CommentsState, CommentsStateBuilder> {
  _$CommentsState? _$v;

  MapBuilder<String, BuiltMap<num, cmk_api.TableCommentsDto>>? _comments;
  MapBuilder<String, BuiltMap<num, cmk_api.TableCommentsDto>> get comments =>
      _$this._comments ??=
          new MapBuilder<String, BuiltMap<num, cmk_api.TableCommentsDto>>();
  set comments(
          MapBuilder<String, BuiltMap<num, cmk_api.TableCommentsDto>>?
              comments) =>
      _$this._comments = comments;

  CommentsStateBuilder();

  CommentsStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _comments = $v.comments.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CommentsState other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$CommentsState;
  }

  @override
  void update(void Function(CommentsStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CommentsState build() => _build();

  _$CommentsState _build() {
    _$CommentsState _$result;
    try {
      _$result = _$v ??
          new _$CommentsState._(
            comments: comments.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'comments';
        comments.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'CommentsState', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
