// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MoviesTable extends Movies with TableInfo<$MoviesTable, Movie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MoviesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
    'tmdb_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalTitleMeta = const VerificationMeta(
    'originalTitle',
  );
  @override
  late final GeneratedColumn<String> originalTitle = GeneratedColumn<String>(
    'original_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posterPathMeta = const VerificationMeta(
    'posterPath',
  );
  @override
  late final GeneratedColumn<String> posterPath = GeneratedColumn<String>(
    'poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backdropPathMeta = const VerificationMeta(
    'backdropPath',
  );
  @override
  late final GeneratedColumn<String> backdropPath = GeneratedColumn<String>(
    'backdrop_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseYearMeta = const VerificationMeta(
    'releaseYear',
  );
  @override
  late final GeneratedColumn<int> releaseYear = GeneratedColumn<int>(
    'release_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runtimeMeta = const VerificationMeta(
    'runtime',
  );
  @override
  late final GeneratedColumn<int> runtime = GeneratedColumn<int>(
    'runtime',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directorMeta = const VerificationMeta(
    'director',
  );
  @override
  late final GeneratedColumn<String> director = GeneratedColumn<String>(
    'director',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorsMeta = const VerificationMeta('actors');
  @override
  late final GeneratedColumn<String> actors = GeneratedColumn<String>(
    'actors',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overviewMeta = const VerificationMeta(
    'overview',
  );
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
    'overview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTvMeta = const VerificationMeta('isTv');
  @override
  late final GeneratedColumn<bool> isTv = GeneratedColumn<bool>(
    'is_tv',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tv" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _totalEpisodesMeta = const VerificationMeta(
    'totalEpisodes',
  );
  @override
  late final GeneratedColumn<int> totalEpisodes = GeneratedColumn<int>(
    'total_episodes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    tmdbId,
    title,
    originalTitle,
    posterPath,
    backdropPath,
    releaseYear,
    runtime,
    genres,
    director,
    actors,
    overview,
    country,
    language,
    isTv,
    createdAt,
    totalEpisodes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'movies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Movie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tmdb_id')) {
      context.handle(
        _tmdbIdMeta,
        tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('original_title')) {
      context.handle(
        _originalTitleMeta,
        originalTitle.isAcceptableOrUnknown(
          data['original_title']!,
          _originalTitleMeta,
        ),
      );
    }
    if (data.containsKey('poster_path')) {
      context.handle(
        _posterPathMeta,
        posterPath.isAcceptableOrUnknown(data['poster_path']!, _posterPathMeta),
      );
    }
    if (data.containsKey('backdrop_path')) {
      context.handle(
        _backdropPathMeta,
        backdropPath.isAcceptableOrUnknown(
          data['backdrop_path']!,
          _backdropPathMeta,
        ),
      );
    }
    if (data.containsKey('release_year')) {
      context.handle(
        _releaseYearMeta,
        releaseYear.isAcceptableOrUnknown(
          data['release_year']!,
          _releaseYearMeta,
        ),
      );
    }
    if (data.containsKey('runtime')) {
      context.handle(
        _runtimeMeta,
        runtime.isAcceptableOrUnknown(data['runtime']!, _runtimeMeta),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('director')) {
      context.handle(
        _directorMeta,
        director.isAcceptableOrUnknown(data['director']!, _directorMeta),
      );
    }
    if (data.containsKey('actors')) {
      context.handle(
        _actorsMeta,
        actors.isAcceptableOrUnknown(data['actors']!, _actorsMeta),
      );
    }
    if (data.containsKey('overview')) {
      context.handle(
        _overviewMeta,
        overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('is_tv')) {
      context.handle(
        _isTvMeta,
        isTv.isAcceptableOrUnknown(data['is_tv']!, _isTvMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('total_episodes')) {
      context.handle(
        _totalEpisodesMeta,
        totalEpisodes.isAcceptableOrUnknown(
          data['total_episodes']!,
          _totalEpisodesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tmdbId, isTv};
  @override
  Movie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Movie(
      tmdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tmdb_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      originalTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_title'],
      ),
      posterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_path'],
      ),
      backdropPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backdrop_path'],
      ),
      releaseYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}release_year'],
      ),
      runtime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runtime'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      director: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}director'],
      ),
      actors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actors'],
      ),
      overview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overview'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      ),
      isTv: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tv'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      totalEpisodes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_episodes'],
      ),
    );
  }

  @override
  $MoviesTable createAlias(String alias) {
    return $MoviesTable(attachedDatabase, alias);
  }
}

class Movie extends DataClass implements Insertable<Movie> {
  final int tmdbId;
  final String title;
  final String? originalTitle;
  final String? posterPath;
  final String? backdropPath;
  final int? releaseYear;
  final int? runtime;
  final String? genres;
  final String? director;
  final String? actors;
  final String? overview;
  final String? country;
  final String? language;
  final bool isTv;
  final DateTime createdAt;
  final int? totalEpisodes;
  const Movie({
    required this.tmdbId,
    required this.title,
    this.originalTitle,
    this.posterPath,
    this.backdropPath,
    this.releaseYear,
    this.runtime,
    this.genres,
    this.director,
    this.actors,
    this.overview,
    this.country,
    this.language,
    required this.isTv,
    required this.createdAt,
    this.totalEpisodes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || originalTitle != null) {
      map['original_title'] = Variable<String>(originalTitle);
    }
    if (!nullToAbsent || posterPath != null) {
      map['poster_path'] = Variable<String>(posterPath);
    }
    if (!nullToAbsent || backdropPath != null) {
      map['backdrop_path'] = Variable<String>(backdropPath);
    }
    if (!nullToAbsent || releaseYear != null) {
      map['release_year'] = Variable<int>(releaseYear);
    }
    if (!nullToAbsent || runtime != null) {
      map['runtime'] = Variable<int>(runtime);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || director != null) {
      map['director'] = Variable<String>(director);
    }
    if (!nullToAbsent || actors != null) {
      map['actors'] = Variable<String>(actors);
    }
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || language != null) {
      map['language'] = Variable<String>(language);
    }
    map['is_tv'] = Variable<bool>(isTv);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || totalEpisodes != null) {
      map['total_episodes'] = Variable<int>(totalEpisodes);
    }
    return map;
  }

  MoviesCompanion toCompanion(bool nullToAbsent) {
    return MoviesCompanion(
      tmdbId: Value(tmdbId),
      title: Value(title),
      originalTitle: originalTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(originalTitle),
      posterPath: posterPath == null && nullToAbsent
          ? const Value.absent()
          : Value(posterPath),
      backdropPath: backdropPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backdropPath),
      releaseYear: releaseYear == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseYear),
      runtime: runtime == null && nullToAbsent
          ? const Value.absent()
          : Value(runtime),
      genres: genres == null && nullToAbsent
          ? const Value.absent()
          : Value(genres),
      director: director == null && nullToAbsent
          ? const Value.absent()
          : Value(director),
      actors: actors == null && nullToAbsent
          ? const Value.absent()
          : Value(actors),
      overview: overview == null && nullToAbsent
          ? const Value.absent()
          : Value(overview),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      language: language == null && nullToAbsent
          ? const Value.absent()
          : Value(language),
      isTv: Value(isTv),
      createdAt: Value(createdAt),
      totalEpisodes: totalEpisodes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalEpisodes),
    );
  }

  factory Movie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Movie(
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      title: serializer.fromJson<String>(json['title']),
      originalTitle: serializer.fromJson<String?>(json['originalTitle']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      backdropPath: serializer.fromJson<String?>(json['backdropPath']),
      releaseYear: serializer.fromJson<int?>(json['releaseYear']),
      runtime: serializer.fromJson<int?>(json['runtime']),
      genres: serializer.fromJson<String?>(json['genres']),
      director: serializer.fromJson<String?>(json['director']),
      actors: serializer.fromJson<String?>(json['actors']),
      overview: serializer.fromJson<String?>(json['overview']),
      country: serializer.fromJson<String?>(json['country']),
      language: serializer.fromJson<String?>(json['language']),
      isTv: serializer.fromJson<bool>(json['isTv']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      totalEpisodes: serializer.fromJson<int?>(json['totalEpisodes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tmdbId': serializer.toJson<int>(tmdbId),
      'title': serializer.toJson<String>(title),
      'originalTitle': serializer.toJson<String?>(originalTitle),
      'posterPath': serializer.toJson<String?>(posterPath),
      'backdropPath': serializer.toJson<String?>(backdropPath),
      'releaseYear': serializer.toJson<int?>(releaseYear),
      'runtime': serializer.toJson<int?>(runtime),
      'genres': serializer.toJson<String?>(genres),
      'director': serializer.toJson<String?>(director),
      'actors': serializer.toJson<String?>(actors),
      'overview': serializer.toJson<String?>(overview),
      'country': serializer.toJson<String?>(country),
      'language': serializer.toJson<String?>(language),
      'isTv': serializer.toJson<bool>(isTv),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'totalEpisodes': serializer.toJson<int?>(totalEpisodes),
    };
  }

  Movie copyWith({
    int? tmdbId,
    String? title,
    Value<String?> originalTitle = const Value.absent(),
    Value<String?> posterPath = const Value.absent(),
    Value<String?> backdropPath = const Value.absent(),
    Value<int?> releaseYear = const Value.absent(),
    Value<int?> runtime = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    Value<String?> director = const Value.absent(),
    Value<String?> actors = const Value.absent(),
    Value<String?> overview = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<String?> language = const Value.absent(),
    bool? isTv,
    DateTime? createdAt,
    Value<int?> totalEpisodes = const Value.absent(),
  }) => Movie(
    tmdbId: tmdbId ?? this.tmdbId,
    title: title ?? this.title,
    originalTitle: originalTitle.present
        ? originalTitle.value
        : this.originalTitle,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    backdropPath: backdropPath.present ? backdropPath.value : this.backdropPath,
    releaseYear: releaseYear.present ? releaseYear.value : this.releaseYear,
    runtime: runtime.present ? runtime.value : this.runtime,
    genres: genres.present ? genres.value : this.genres,
    director: director.present ? director.value : this.director,
    actors: actors.present ? actors.value : this.actors,
    overview: overview.present ? overview.value : this.overview,
    country: country.present ? country.value : this.country,
    language: language.present ? language.value : this.language,
    isTv: isTv ?? this.isTv,
    createdAt: createdAt ?? this.createdAt,
    totalEpisodes: totalEpisodes.present
        ? totalEpisodes.value
        : this.totalEpisodes,
  );
  Movie copyWithCompanion(MoviesCompanion data) {
    return Movie(
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      title: data.title.present ? data.title.value : this.title,
      originalTitle: data.originalTitle.present
          ? data.originalTitle.value
          : this.originalTitle,
      posterPath: data.posterPath.present
          ? data.posterPath.value
          : this.posterPath,
      backdropPath: data.backdropPath.present
          ? data.backdropPath.value
          : this.backdropPath,
      releaseYear: data.releaseYear.present
          ? data.releaseYear.value
          : this.releaseYear,
      runtime: data.runtime.present ? data.runtime.value : this.runtime,
      genres: data.genres.present ? data.genres.value : this.genres,
      director: data.director.present ? data.director.value : this.director,
      actors: data.actors.present ? data.actors.value : this.actors,
      overview: data.overview.present ? data.overview.value : this.overview,
      country: data.country.present ? data.country.value : this.country,
      language: data.language.present ? data.language.value : this.language,
      isTv: data.isTv.present ? data.isTv.value : this.isTv,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      totalEpisodes: data.totalEpisodes.present
          ? data.totalEpisodes.value
          : this.totalEpisodes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Movie(')
          ..write('tmdbId: $tmdbId, ')
          ..write('title: $title, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('runtime: $runtime, ')
          ..write('genres: $genres, ')
          ..write('director: $director, ')
          ..write('actors: $actors, ')
          ..write('overview: $overview, ')
          ..write('country: $country, ')
          ..write('language: $language, ')
          ..write('isTv: $isTv, ')
          ..write('createdAt: $createdAt, ')
          ..write('totalEpisodes: $totalEpisodes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    tmdbId,
    title,
    originalTitle,
    posterPath,
    backdropPath,
    releaseYear,
    runtime,
    genres,
    director,
    actors,
    overview,
    country,
    language,
    isTv,
    createdAt,
    totalEpisodes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Movie &&
          other.tmdbId == this.tmdbId &&
          other.title == this.title &&
          other.originalTitle == this.originalTitle &&
          other.posterPath == this.posterPath &&
          other.backdropPath == this.backdropPath &&
          other.releaseYear == this.releaseYear &&
          other.runtime == this.runtime &&
          other.genres == this.genres &&
          other.director == this.director &&
          other.actors == this.actors &&
          other.overview == this.overview &&
          other.country == this.country &&
          other.language == this.language &&
          other.isTv == this.isTv &&
          other.createdAt == this.createdAt &&
          other.totalEpisodes == this.totalEpisodes);
}

class MoviesCompanion extends UpdateCompanion<Movie> {
  final Value<int> tmdbId;
  final Value<String> title;
  final Value<String?> originalTitle;
  final Value<String?> posterPath;
  final Value<String?> backdropPath;
  final Value<int?> releaseYear;
  final Value<int?> runtime;
  final Value<String?> genres;
  final Value<String?> director;
  final Value<String?> actors;
  final Value<String?> overview;
  final Value<String?> country;
  final Value<String?> language;
  final Value<bool> isTv;
  final Value<DateTime> createdAt;
  final Value<int?> totalEpisodes;
  final Value<int> rowid;
  const MoviesCompanion({
    this.tmdbId = const Value.absent(),
    this.title = const Value.absent(),
    this.originalTitle = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.runtime = const Value.absent(),
    this.genres = const Value.absent(),
    this.director = const Value.absent(),
    this.actors = const Value.absent(),
    this.overview = const Value.absent(),
    this.country = const Value.absent(),
    this.language = const Value.absent(),
    this.isTv = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.totalEpisodes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoviesCompanion.insert({
    required int tmdbId,
    required String title,
    this.originalTitle = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.releaseYear = const Value.absent(),
    this.runtime = const Value.absent(),
    this.genres = const Value.absent(),
    this.director = const Value.absent(),
    this.actors = const Value.absent(),
    this.overview = const Value.absent(),
    this.country = const Value.absent(),
    this.language = const Value.absent(),
    this.isTv = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.totalEpisodes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tmdbId = Value(tmdbId),
       title = Value(title);
  static Insertable<Movie> custom({
    Expression<int>? tmdbId,
    Expression<String>? title,
    Expression<String>? originalTitle,
    Expression<String>? posterPath,
    Expression<String>? backdropPath,
    Expression<int>? releaseYear,
    Expression<int>? runtime,
    Expression<String>? genres,
    Expression<String>? director,
    Expression<String>? actors,
    Expression<String>? overview,
    Expression<String>? country,
    Expression<String>? language,
    Expression<bool>? isTv,
    Expression<DateTime>? createdAt,
    Expression<int>? totalEpisodes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (title != null) 'title': title,
      if (originalTitle != null) 'original_title': originalTitle,
      if (posterPath != null) 'poster_path': posterPath,
      if (backdropPath != null) 'backdrop_path': backdropPath,
      if (releaseYear != null) 'release_year': releaseYear,
      if (runtime != null) 'runtime': runtime,
      if (genres != null) 'genres': genres,
      if (director != null) 'director': director,
      if (actors != null) 'actors': actors,
      if (overview != null) 'overview': overview,
      if (country != null) 'country': country,
      if (language != null) 'language': language,
      if (isTv != null) 'is_tv': isTv,
      if (createdAt != null) 'created_at': createdAt,
      if (totalEpisodes != null) 'total_episodes': totalEpisodes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoviesCompanion copyWith({
    Value<int>? tmdbId,
    Value<String>? title,
    Value<String?>? originalTitle,
    Value<String?>? posterPath,
    Value<String?>? backdropPath,
    Value<int?>? releaseYear,
    Value<int?>? runtime,
    Value<String?>? genres,
    Value<String?>? director,
    Value<String?>? actors,
    Value<String?>? overview,
    Value<String?>? country,
    Value<String?>? language,
    Value<bool>? isTv,
    Value<DateTime>? createdAt,
    Value<int?>? totalEpisodes,
    Value<int>? rowid,
  }) {
    return MoviesCompanion(
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      originalTitle: originalTitle ?? this.originalTitle,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      releaseYear: releaseYear ?? this.releaseYear,
      runtime: runtime ?? this.runtime,
      genres: genres ?? this.genres,
      director: director ?? this.director,
      actors: actors ?? this.actors,
      overview: overview ?? this.overview,
      country: country ?? this.country,
      language: language ?? this.language,
      isTv: isTv ?? this.isTv,
      createdAt: createdAt ?? this.createdAt,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (originalTitle.present) {
      map['original_title'] = Variable<String>(originalTitle.value);
    }
    if (posterPath.present) {
      map['poster_path'] = Variable<String>(posterPath.value);
    }
    if (backdropPath.present) {
      map['backdrop_path'] = Variable<String>(backdropPath.value);
    }
    if (releaseYear.present) {
      map['release_year'] = Variable<int>(releaseYear.value);
    }
    if (runtime.present) {
      map['runtime'] = Variable<int>(runtime.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (director.present) {
      map['director'] = Variable<String>(director.value);
    }
    if (actors.present) {
      map['actors'] = Variable<String>(actors.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (isTv.present) {
      map['is_tv'] = Variable<bool>(isTv.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (totalEpisodes.present) {
      map['total_episodes'] = Variable<int>(totalEpisodes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoviesCompanion(')
          ..write('tmdbId: $tmdbId, ')
          ..write('title: $title, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('releaseYear: $releaseYear, ')
          ..write('runtime: $runtime, ')
          ..write('genres: $genres, ')
          ..write('director: $director, ')
          ..write('actors: $actors, ')
          ..write('overview: $overview, ')
          ..write('country: $country, ')
          ..write('language: $language, ')
          ..write('isTv: $isTv, ')
          ..write('createdAt: $createdAt, ')
          ..write('totalEpisodes: $totalEpisodes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchRecordsTable extends WatchRecords
    with TableInfo<$WatchRecordsTable, WatchRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _movieIdMeta = const VerificationMeta(
    'movieId',
  );
  @override
  late final GeneratedColumn<int> movieId = GeneratedColumn<int>(
    'movie_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTvMeta = const VerificationMeta('isTv');
  @override
  late final GeneratedColumn<bool> isTv = GeneratedColumn<bool>(
    'is_tv',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tv" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _watchDateMeta = const VerificationMeta(
    'watchDate',
  );
  @override
  late final GeneratedColumn<DateTime> watchDate = GeneratedColumn<DateTime>(
    'watch_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watchPlaceMeta = const VerificationMeta(
    'watchPlace',
  );
  @override
  late final GeneratedColumn<String> watchPlace = GeneratedColumn<String>(
    'watch_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _watchCompanionMeta = const VerificationMeta(
    'watchCompanion',
  );
  @override
  late final GeneratedColumn<String> watchCompanion = GeneratedColumn<String>(
    'watch_companion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _watchNumberMeta = const VerificationMeta(
    'watchNumber',
  );
  @override
  late final GeneratedColumn<int> watchNumber = GeneratedColumn<int>(
    'watch_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeCountMeta = const VerificationMeta(
    'episodeCount',
  );
  @override
  late final GeneratedColumn<int> episodeCount = GeneratedColumn<int>(
    'episode_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    movieId,
    isTv,
    watchDate,
    watchPlace,
    watchCompanion,
    rating,
    mood,
    notes,
    watchNumber,
    tags,
    episodeCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('movie_id')) {
      context.handle(
        _movieIdMeta,
        movieId.isAcceptableOrUnknown(data['movie_id']!, _movieIdMeta),
      );
    } else if (isInserting) {
      context.missing(_movieIdMeta);
    }
    if (data.containsKey('is_tv')) {
      context.handle(
        _isTvMeta,
        isTv.isAcceptableOrUnknown(data['is_tv']!, _isTvMeta),
      );
    }
    if (data.containsKey('watch_date')) {
      context.handle(
        _watchDateMeta,
        watchDate.isAcceptableOrUnknown(data['watch_date']!, _watchDateMeta),
      );
    } else if (isInserting) {
      context.missing(_watchDateMeta);
    }
    if (data.containsKey('watch_place')) {
      context.handle(
        _watchPlaceMeta,
        watchPlace.isAcceptableOrUnknown(data['watch_place']!, _watchPlaceMeta),
      );
    }
    if (data.containsKey('watch_companion')) {
      context.handle(
        _watchCompanionMeta,
        watchCompanion.isAcceptableOrUnknown(
          data['watch_companion']!,
          _watchCompanionMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('watch_number')) {
      context.handle(
        _watchNumberMeta,
        watchNumber.isAcceptableOrUnknown(
          data['watch_number']!,
          _watchNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_watchNumberMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('episode_count')) {
      context.handle(
        _episodeCountMeta,
        episodeCount.isAcceptableOrUnknown(
          data['episode_count']!,
          _episodeCountMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      movieId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}movie_id'],
      )!,
      isTv: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tv'],
      )!,
      watchDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watch_date'],
      )!,
      watchPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watch_place'],
      ),
      watchCompanion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watch_companion'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      watchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}watch_number'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      episodeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WatchRecordsTable createAlias(String alias) {
    return $WatchRecordsTable(attachedDatabase, alias);
  }
}

class WatchRecord extends DataClass implements Insertable<WatchRecord> {
  final int id;
  final int movieId;
  final bool isTv;
  final DateTime watchDate;
  final String? watchPlace;
  final String? watchCompanion;
  final double rating;
  final String? mood;
  final String? notes;
  final int watchNumber;
  final String? tags;
  final int episodeCount;
  final DateTime createdAt;
  const WatchRecord({
    required this.id,
    required this.movieId,
    required this.isTv,
    required this.watchDate,
    this.watchPlace,
    this.watchCompanion,
    required this.rating,
    this.mood,
    this.notes,
    required this.watchNumber,
    this.tags,
    required this.episodeCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['movie_id'] = Variable<int>(movieId);
    map['is_tv'] = Variable<bool>(isTv);
    map['watch_date'] = Variable<DateTime>(watchDate);
    if (!nullToAbsent || watchPlace != null) {
      map['watch_place'] = Variable<String>(watchPlace);
    }
    if (!nullToAbsent || watchCompanion != null) {
      map['watch_companion'] = Variable<String>(watchCompanion);
    }
    map['rating'] = Variable<double>(rating);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['watch_number'] = Variable<int>(watchNumber);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['episode_count'] = Variable<int>(episodeCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WatchRecordsCompanion toCompanion(bool nullToAbsent) {
    return WatchRecordsCompanion(
      id: Value(id),
      movieId: Value(movieId),
      isTv: Value(isTv),
      watchDate: Value(watchDate),
      watchPlace: watchPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(watchPlace),
      watchCompanion: watchCompanion == null && nullToAbsent
          ? const Value.absent()
          : Value(watchCompanion),
      rating: Value(rating),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      watchNumber: Value(watchNumber),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      episodeCount: Value(episodeCount),
      createdAt: Value(createdAt),
    );
  }

  factory WatchRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchRecord(
      id: serializer.fromJson<int>(json['id']),
      movieId: serializer.fromJson<int>(json['movieId']),
      isTv: serializer.fromJson<bool>(json['isTv']),
      watchDate: serializer.fromJson<DateTime>(json['watchDate']),
      watchPlace: serializer.fromJson<String?>(json['watchPlace']),
      watchCompanion: serializer.fromJson<String?>(json['watchCompanion']),
      rating: serializer.fromJson<double>(json['rating']),
      mood: serializer.fromJson<String?>(json['mood']),
      notes: serializer.fromJson<String?>(json['notes']),
      watchNumber: serializer.fromJson<int>(json['watchNumber']),
      tags: serializer.fromJson<String?>(json['tags']),
      episodeCount: serializer.fromJson<int>(json['episodeCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'movieId': serializer.toJson<int>(movieId),
      'isTv': serializer.toJson<bool>(isTv),
      'watchDate': serializer.toJson<DateTime>(watchDate),
      'watchPlace': serializer.toJson<String?>(watchPlace),
      'watchCompanion': serializer.toJson<String?>(watchCompanion),
      'rating': serializer.toJson<double>(rating),
      'mood': serializer.toJson<String?>(mood),
      'notes': serializer.toJson<String?>(notes),
      'watchNumber': serializer.toJson<int>(watchNumber),
      'tags': serializer.toJson<String?>(tags),
      'episodeCount': serializer.toJson<int>(episodeCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WatchRecord copyWith({
    int? id,
    int? movieId,
    bool? isTv,
    DateTime? watchDate,
    Value<String?> watchPlace = const Value.absent(),
    Value<String?> watchCompanion = const Value.absent(),
    double? rating,
    Value<String?> mood = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? watchNumber,
    Value<String?> tags = const Value.absent(),
    int? episodeCount,
    DateTime? createdAt,
  }) => WatchRecord(
    id: id ?? this.id,
    movieId: movieId ?? this.movieId,
    isTv: isTv ?? this.isTv,
    watchDate: watchDate ?? this.watchDate,
    watchPlace: watchPlace.present ? watchPlace.value : this.watchPlace,
    watchCompanion: watchCompanion.present
        ? watchCompanion.value
        : this.watchCompanion,
    rating: rating ?? this.rating,
    mood: mood.present ? mood.value : this.mood,
    notes: notes.present ? notes.value : this.notes,
    watchNumber: watchNumber ?? this.watchNumber,
    tags: tags.present ? tags.value : this.tags,
    episodeCount: episodeCount ?? this.episodeCount,
    createdAt: createdAt ?? this.createdAt,
  );
  WatchRecord copyWithCompanion(WatchRecordsCompanion data) {
    return WatchRecord(
      id: data.id.present ? data.id.value : this.id,
      movieId: data.movieId.present ? data.movieId.value : this.movieId,
      isTv: data.isTv.present ? data.isTv.value : this.isTv,
      watchDate: data.watchDate.present ? data.watchDate.value : this.watchDate,
      watchPlace: data.watchPlace.present
          ? data.watchPlace.value
          : this.watchPlace,
      watchCompanion: data.watchCompanion.present
          ? data.watchCompanion.value
          : this.watchCompanion,
      rating: data.rating.present ? data.rating.value : this.rating,
      mood: data.mood.present ? data.mood.value : this.mood,
      notes: data.notes.present ? data.notes.value : this.notes,
      watchNumber: data.watchNumber.present
          ? data.watchNumber.value
          : this.watchNumber,
      tags: data.tags.present ? data.tags.value : this.tags,
      episodeCount: data.episodeCount.present
          ? data.episodeCount.value
          : this.episodeCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchRecord(')
          ..write('id: $id, ')
          ..write('movieId: $movieId, ')
          ..write('isTv: $isTv, ')
          ..write('watchDate: $watchDate, ')
          ..write('watchPlace: $watchPlace, ')
          ..write('watchCompanion: $watchCompanion, ')
          ..write('rating: $rating, ')
          ..write('mood: $mood, ')
          ..write('notes: $notes, ')
          ..write('watchNumber: $watchNumber, ')
          ..write('tags: $tags, ')
          ..write('episodeCount: $episodeCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    movieId,
    isTv,
    watchDate,
    watchPlace,
    watchCompanion,
    rating,
    mood,
    notes,
    watchNumber,
    tags,
    episodeCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchRecord &&
          other.id == this.id &&
          other.movieId == this.movieId &&
          other.isTv == this.isTv &&
          other.watchDate == this.watchDate &&
          other.watchPlace == this.watchPlace &&
          other.watchCompanion == this.watchCompanion &&
          other.rating == this.rating &&
          other.mood == this.mood &&
          other.notes == this.notes &&
          other.watchNumber == this.watchNumber &&
          other.tags == this.tags &&
          other.episodeCount == this.episodeCount &&
          other.createdAt == this.createdAt);
}

class WatchRecordsCompanion extends UpdateCompanion<WatchRecord> {
  final Value<int> id;
  final Value<int> movieId;
  final Value<bool> isTv;
  final Value<DateTime> watchDate;
  final Value<String?> watchPlace;
  final Value<String?> watchCompanion;
  final Value<double> rating;
  final Value<String?> mood;
  final Value<String?> notes;
  final Value<int> watchNumber;
  final Value<String?> tags;
  final Value<int> episodeCount;
  final Value<DateTime> createdAt;
  const WatchRecordsCompanion({
    this.id = const Value.absent(),
    this.movieId = const Value.absent(),
    this.isTv = const Value.absent(),
    this.watchDate = const Value.absent(),
    this.watchPlace = const Value.absent(),
    this.watchCompanion = const Value.absent(),
    this.rating = const Value.absent(),
    this.mood = const Value.absent(),
    this.notes = const Value.absent(),
    this.watchNumber = const Value.absent(),
    this.tags = const Value.absent(),
    this.episodeCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WatchRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int movieId,
    this.isTv = const Value.absent(),
    required DateTime watchDate,
    this.watchPlace = const Value.absent(),
    this.watchCompanion = const Value.absent(),
    required double rating,
    this.mood = const Value.absent(),
    this.notes = const Value.absent(),
    required int watchNumber,
    this.tags = const Value.absent(),
    this.episodeCount = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : movieId = Value(movieId),
       watchDate = Value(watchDate),
       rating = Value(rating),
       watchNumber = Value(watchNumber);
  static Insertable<WatchRecord> custom({
    Expression<int>? id,
    Expression<int>? movieId,
    Expression<bool>? isTv,
    Expression<DateTime>? watchDate,
    Expression<String>? watchPlace,
    Expression<String>? watchCompanion,
    Expression<double>? rating,
    Expression<String>? mood,
    Expression<String>? notes,
    Expression<int>? watchNumber,
    Expression<String>? tags,
    Expression<int>? episodeCount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (movieId != null) 'movie_id': movieId,
      if (isTv != null) 'is_tv': isTv,
      if (watchDate != null) 'watch_date': watchDate,
      if (watchPlace != null) 'watch_place': watchPlace,
      if (watchCompanion != null) 'watch_companion': watchCompanion,
      if (rating != null) 'rating': rating,
      if (mood != null) 'mood': mood,
      if (notes != null) 'notes': notes,
      if (watchNumber != null) 'watch_number': watchNumber,
      if (tags != null) 'tags': tags,
      if (episodeCount != null) 'episode_count': episodeCount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WatchRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? movieId,
    Value<bool>? isTv,
    Value<DateTime>? watchDate,
    Value<String?>? watchPlace,
    Value<String?>? watchCompanion,
    Value<double>? rating,
    Value<String?>? mood,
    Value<String?>? notes,
    Value<int>? watchNumber,
    Value<String?>? tags,
    Value<int>? episodeCount,
    Value<DateTime>? createdAt,
  }) {
    return WatchRecordsCompanion(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      isTv: isTv ?? this.isTv,
      watchDate: watchDate ?? this.watchDate,
      watchPlace: watchPlace ?? this.watchPlace,
      watchCompanion: watchCompanion ?? this.watchCompanion,
      rating: rating ?? this.rating,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      watchNumber: watchNumber ?? this.watchNumber,
      tags: tags ?? this.tags,
      episodeCount: episodeCount ?? this.episodeCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (movieId.present) {
      map['movie_id'] = Variable<int>(movieId.value);
    }
    if (isTv.present) {
      map['is_tv'] = Variable<bool>(isTv.value);
    }
    if (watchDate.present) {
      map['watch_date'] = Variable<DateTime>(watchDate.value);
    }
    if (watchPlace.present) {
      map['watch_place'] = Variable<String>(watchPlace.value);
    }
    if (watchCompanion.present) {
      map['watch_companion'] = Variable<String>(watchCompanion.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (watchNumber.present) {
      map['watch_number'] = Variable<int>(watchNumber.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (episodeCount.present) {
      map['episode_count'] = Variable<int>(episodeCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchRecordsCompanion(')
          ..write('id: $id, ')
          ..write('movieId: $movieId, ')
          ..write('isTv: $isTv, ')
          ..write('watchDate: $watchDate, ')
          ..write('watchPlace: $watchPlace, ')
          ..write('watchCompanion: $watchCompanion, ')
          ..write('rating: $rating, ')
          ..write('mood: $mood, ')
          ..write('notes: $notes, ')
          ..write('watchNumber: $watchNumber, ')
          ..write('tags: $tags, ')
          ..write('episodeCount: $episodeCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $UserMovieSettingsTable extends UserMovieSettings
    with TableInfo<$UserMovieSettingsTable, UserMovieSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserMovieSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
    'tmdb_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTvMeta = const VerificationMeta('isTv');
  @override
  late final GeneratedColumn<bool> isTv = GeneratedColumn<bool>(
    'is_tv',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tv" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isReWatchListMeta = const VerificationMeta(
    'isReWatchList',
  );
  @override
  late final GeneratedColumn<bool> isReWatchList = GeneratedColumn<bool>(
    'is_re_watch_list',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_re_watch_list" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _personalRankingMeta = const VerificationMeta(
    'personalRanking',
  );
  @override
  late final GeneratedColumn<int> personalRanking = GeneratedColumn<int>(
    'personal_ranking',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personalNotesMeta = const VerificationMeta(
    'personalNotes',
  );
  @override
  late final GeneratedColumn<String> personalNotes = GeneratedColumn<String>(
    'personal_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personalTagsMeta = const VerificationMeta(
    'personalTags',
  );
  @override
  late final GeneratedColumn<String> personalTags = GeneratedColumn<String>(
    'personal_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isActivelyWatchingMeta =
      const VerificationMeta('isActivelyWatching');
  @override
  late final GeneratedColumn<bool> isActivelyWatching = GeneratedColumn<bool>(
    'is_actively_watching',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_actively_watching" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastWatchedEpisodeMeta =
      const VerificationMeta('lastWatchedEpisode');
  @override
  late final GeneratedColumn<int> lastWatchedEpisode = GeneratedColumn<int>(
    'last_watched_episode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    tmdbId,
    isTv,
    isFavorite,
    isReWatchList,
    personalRanking,
    personalNotes,
    personalTags,
    updatedAt,
    isActivelyWatching,
    lastWatchedEpisode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_movie_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserMovieSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tmdb_id')) {
      context.handle(
        _tmdbIdMeta,
        tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('is_tv')) {
      context.handle(
        _isTvMeta,
        isTv.isAcceptableOrUnknown(data['is_tv']!, _isTvMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_re_watch_list')) {
      context.handle(
        _isReWatchListMeta,
        isReWatchList.isAcceptableOrUnknown(
          data['is_re_watch_list']!,
          _isReWatchListMeta,
        ),
      );
    }
    if (data.containsKey('personal_ranking')) {
      context.handle(
        _personalRankingMeta,
        personalRanking.isAcceptableOrUnknown(
          data['personal_ranking']!,
          _personalRankingMeta,
        ),
      );
    }
    if (data.containsKey('personal_notes')) {
      context.handle(
        _personalNotesMeta,
        personalNotes.isAcceptableOrUnknown(
          data['personal_notes']!,
          _personalNotesMeta,
        ),
      );
    }
    if (data.containsKey('personal_tags')) {
      context.handle(
        _personalTagsMeta,
        personalTags.isAcceptableOrUnknown(
          data['personal_tags']!,
          _personalTagsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_actively_watching')) {
      context.handle(
        _isActivelyWatchingMeta,
        isActivelyWatching.isAcceptableOrUnknown(
          data['is_actively_watching']!,
          _isActivelyWatchingMeta,
        ),
      );
    }
    if (data.containsKey('last_watched_episode')) {
      context.handle(
        _lastWatchedEpisodeMeta,
        lastWatchedEpisode.isAcceptableOrUnknown(
          data['last_watched_episode']!,
          _lastWatchedEpisodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tmdbId, isTv};
  @override
  UserMovieSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserMovieSetting(
      tmdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tmdb_id'],
      )!,
      isTv: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tv'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isReWatchList: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_re_watch_list'],
      )!,
      personalRanking: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}personal_ranking'],
      ),
      personalNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personal_notes'],
      ),
      personalTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}personal_tags'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isActivelyWatching: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_actively_watching'],
      )!,
      lastWatchedEpisode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_watched_episode'],
      ),
    );
  }

  @override
  $UserMovieSettingsTable createAlias(String alias) {
    return $UserMovieSettingsTable(attachedDatabase, alias);
  }
}

class UserMovieSetting extends DataClass
    implements Insertable<UserMovieSetting> {
  final int tmdbId;
  final bool isTv;
  final bool isFavorite;
  final bool isReWatchList;
  final int? personalRanking;
  final String? personalNotes;
  final String? personalTags;
  final DateTime updatedAt;
  final bool isActivelyWatching;
  final int? lastWatchedEpisode;
  const UserMovieSetting({
    required this.tmdbId,
    required this.isTv,
    required this.isFavorite,
    required this.isReWatchList,
    this.personalRanking,
    this.personalNotes,
    this.personalTags,
    required this.updatedAt,
    required this.isActivelyWatching,
    this.lastWatchedEpisode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tmdb_id'] = Variable<int>(tmdbId);
    map['is_tv'] = Variable<bool>(isTv);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_re_watch_list'] = Variable<bool>(isReWatchList);
    if (!nullToAbsent || personalRanking != null) {
      map['personal_ranking'] = Variable<int>(personalRanking);
    }
    if (!nullToAbsent || personalNotes != null) {
      map['personal_notes'] = Variable<String>(personalNotes);
    }
    if (!nullToAbsent || personalTags != null) {
      map['personal_tags'] = Variable<String>(personalTags);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_actively_watching'] = Variable<bool>(isActivelyWatching);
    if (!nullToAbsent || lastWatchedEpisode != null) {
      map['last_watched_episode'] = Variable<int>(lastWatchedEpisode);
    }
    return map;
  }

  UserMovieSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserMovieSettingsCompanion(
      tmdbId: Value(tmdbId),
      isTv: Value(isTv),
      isFavorite: Value(isFavorite),
      isReWatchList: Value(isReWatchList),
      personalRanking: personalRanking == null && nullToAbsent
          ? const Value.absent()
          : Value(personalRanking),
      personalNotes: personalNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(personalNotes),
      personalTags: personalTags == null && nullToAbsent
          ? const Value.absent()
          : Value(personalTags),
      updatedAt: Value(updatedAt),
      isActivelyWatching: Value(isActivelyWatching),
      lastWatchedEpisode: lastWatchedEpisode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastWatchedEpisode),
    );
  }

  factory UserMovieSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserMovieSetting(
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      isTv: serializer.fromJson<bool>(json['isTv']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isReWatchList: serializer.fromJson<bool>(json['isReWatchList']),
      personalRanking: serializer.fromJson<int?>(json['personalRanking']),
      personalNotes: serializer.fromJson<String?>(json['personalNotes']),
      personalTags: serializer.fromJson<String?>(json['personalTags']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isActivelyWatching: serializer.fromJson<bool>(json['isActivelyWatching']),
      lastWatchedEpisode: serializer.fromJson<int?>(json['lastWatchedEpisode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tmdbId': serializer.toJson<int>(tmdbId),
      'isTv': serializer.toJson<bool>(isTv),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isReWatchList': serializer.toJson<bool>(isReWatchList),
      'personalRanking': serializer.toJson<int?>(personalRanking),
      'personalNotes': serializer.toJson<String?>(personalNotes),
      'personalTags': serializer.toJson<String?>(personalTags),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isActivelyWatching': serializer.toJson<bool>(isActivelyWatching),
      'lastWatchedEpisode': serializer.toJson<int?>(lastWatchedEpisode),
    };
  }

  UserMovieSetting copyWith({
    int? tmdbId,
    bool? isTv,
    bool? isFavorite,
    bool? isReWatchList,
    Value<int?> personalRanking = const Value.absent(),
    Value<String?> personalNotes = const Value.absent(),
    Value<String?> personalTags = const Value.absent(),
    DateTime? updatedAt,
    bool? isActivelyWatching,
    Value<int?> lastWatchedEpisode = const Value.absent(),
  }) => UserMovieSetting(
    tmdbId: tmdbId ?? this.tmdbId,
    isTv: isTv ?? this.isTv,
    isFavorite: isFavorite ?? this.isFavorite,
    isReWatchList: isReWatchList ?? this.isReWatchList,
    personalRanking: personalRanking.present
        ? personalRanking.value
        : this.personalRanking,
    personalNotes: personalNotes.present
        ? personalNotes.value
        : this.personalNotes,
    personalTags: personalTags.present ? personalTags.value : this.personalTags,
    updatedAt: updatedAt ?? this.updatedAt,
    isActivelyWatching: isActivelyWatching ?? this.isActivelyWatching,
    lastWatchedEpisode: lastWatchedEpisode.present
        ? lastWatchedEpisode.value
        : this.lastWatchedEpisode,
  );
  UserMovieSetting copyWithCompanion(UserMovieSettingsCompanion data) {
    return UserMovieSetting(
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      isTv: data.isTv.present ? data.isTv.value : this.isTv,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isReWatchList: data.isReWatchList.present
          ? data.isReWatchList.value
          : this.isReWatchList,
      personalRanking: data.personalRanking.present
          ? data.personalRanking.value
          : this.personalRanking,
      personalNotes: data.personalNotes.present
          ? data.personalNotes.value
          : this.personalNotes,
      personalTags: data.personalTags.present
          ? data.personalTags.value
          : this.personalTags,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isActivelyWatching: data.isActivelyWatching.present
          ? data.isActivelyWatching.value
          : this.isActivelyWatching,
      lastWatchedEpisode: data.lastWatchedEpisode.present
          ? data.lastWatchedEpisode.value
          : this.lastWatchedEpisode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserMovieSetting(')
          ..write('tmdbId: $tmdbId, ')
          ..write('isTv: $isTv, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isReWatchList: $isReWatchList, ')
          ..write('personalRanking: $personalRanking, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('personalTags: $personalTags, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActivelyWatching: $isActivelyWatching, ')
          ..write('lastWatchedEpisode: $lastWatchedEpisode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    tmdbId,
    isTv,
    isFavorite,
    isReWatchList,
    personalRanking,
    personalNotes,
    personalTags,
    updatedAt,
    isActivelyWatching,
    lastWatchedEpisode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserMovieSetting &&
          other.tmdbId == this.tmdbId &&
          other.isTv == this.isTv &&
          other.isFavorite == this.isFavorite &&
          other.isReWatchList == this.isReWatchList &&
          other.personalRanking == this.personalRanking &&
          other.personalNotes == this.personalNotes &&
          other.personalTags == this.personalTags &&
          other.updatedAt == this.updatedAt &&
          other.isActivelyWatching == this.isActivelyWatching &&
          other.lastWatchedEpisode == this.lastWatchedEpisode);
}

class UserMovieSettingsCompanion extends UpdateCompanion<UserMovieSetting> {
  final Value<int> tmdbId;
  final Value<bool> isTv;
  final Value<bool> isFavorite;
  final Value<bool> isReWatchList;
  final Value<int?> personalRanking;
  final Value<String?> personalNotes;
  final Value<String?> personalTags;
  final Value<DateTime> updatedAt;
  final Value<bool> isActivelyWatching;
  final Value<int?> lastWatchedEpisode;
  final Value<int> rowid;
  const UserMovieSettingsCompanion({
    this.tmdbId = const Value.absent(),
    this.isTv = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isReWatchList = const Value.absent(),
    this.personalRanking = const Value.absent(),
    this.personalNotes = const Value.absent(),
    this.personalTags = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActivelyWatching = const Value.absent(),
    this.lastWatchedEpisode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserMovieSettingsCompanion.insert({
    required int tmdbId,
    this.isTv = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isReWatchList = const Value.absent(),
    this.personalRanking = const Value.absent(),
    this.personalNotes = const Value.absent(),
    this.personalTags = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isActivelyWatching = const Value.absent(),
    this.lastWatchedEpisode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tmdbId = Value(tmdbId);
  static Insertable<UserMovieSetting> custom({
    Expression<int>? tmdbId,
    Expression<bool>? isTv,
    Expression<bool>? isFavorite,
    Expression<bool>? isReWatchList,
    Expression<int>? personalRanking,
    Expression<String>? personalNotes,
    Expression<String>? personalTags,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isActivelyWatching,
    Expression<int>? lastWatchedEpisode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (isTv != null) 'is_tv': isTv,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isReWatchList != null) 'is_re_watch_list': isReWatchList,
      if (personalRanking != null) 'personal_ranking': personalRanking,
      if (personalNotes != null) 'personal_notes': personalNotes,
      if (personalTags != null) 'personal_tags': personalTags,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isActivelyWatching != null)
        'is_actively_watching': isActivelyWatching,
      if (lastWatchedEpisode != null)
        'last_watched_episode': lastWatchedEpisode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserMovieSettingsCompanion copyWith({
    Value<int>? tmdbId,
    Value<bool>? isTv,
    Value<bool>? isFavorite,
    Value<bool>? isReWatchList,
    Value<int?>? personalRanking,
    Value<String?>? personalNotes,
    Value<String?>? personalTags,
    Value<DateTime>? updatedAt,
    Value<bool>? isActivelyWatching,
    Value<int?>? lastWatchedEpisode,
    Value<int>? rowid,
  }) {
    return UserMovieSettingsCompanion(
      tmdbId: tmdbId ?? this.tmdbId,
      isTv: isTv ?? this.isTv,
      isFavorite: isFavorite ?? this.isFavorite,
      isReWatchList: isReWatchList ?? this.isReWatchList,
      personalRanking: personalRanking ?? this.personalRanking,
      personalNotes: personalNotes ?? this.personalNotes,
      personalTags: personalTags ?? this.personalTags,
      updatedAt: updatedAt ?? this.updatedAt,
      isActivelyWatching: isActivelyWatching ?? this.isActivelyWatching,
      lastWatchedEpisode: lastWatchedEpisode ?? this.lastWatchedEpisode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (isTv.present) {
      map['is_tv'] = Variable<bool>(isTv.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isReWatchList.present) {
      map['is_re_watch_list'] = Variable<bool>(isReWatchList.value);
    }
    if (personalRanking.present) {
      map['personal_ranking'] = Variable<int>(personalRanking.value);
    }
    if (personalNotes.present) {
      map['personal_notes'] = Variable<String>(personalNotes.value);
    }
    if (personalTags.present) {
      map['personal_tags'] = Variable<String>(personalTags.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isActivelyWatching.present) {
      map['is_actively_watching'] = Variable<bool>(isActivelyWatching.value);
    }
    if (lastWatchedEpisode.present) {
      map['last_watched_episode'] = Variable<int>(lastWatchedEpisode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserMovieSettingsCompanion(')
          ..write('tmdbId: $tmdbId, ')
          ..write('isTv: $isTv, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isReWatchList: $isReWatchList, ')
          ..write('personalRanking: $personalRanking, ')
          ..write('personalNotes: $personalNotes, ')
          ..write('personalTags: $personalTags, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isActivelyWatching: $isActivelyWatching, ')
          ..write('lastWatchedEpisode: $lastWatchedEpisode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomListsTable extends CustomLists
    with TableInfo<$CustomListsTable, CustomList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    targetDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomListsTable createAlias(String alias) {
    return $CustomListsTable(attachedDatabase, alias);
  }
}

class CustomList extends DataClass implements Insertable<CustomList> {
  final int id;
  final String name;
  final String? description;
  final DateTime? targetDate;
  final DateTime createdAt;
  const CustomList({
    required this.id,
    required this.name,
    this.description,
    this.targetDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomListsCompanion toCompanion(bool nullToAbsent) {
    return CustomListsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      createdAt: Value(createdAt),
    );
  }

  factory CustomList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomList copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> targetDate = const Value.absent(),
    DateTime? createdAt,
  }) => CustomList(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomList copyWithCompanion(CustomListsCompanion data) {
    return CustomList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, targetDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomList &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.targetDate == this.targetDate &&
          other.createdAt == this.createdAt);
}

class CustomListsCompanion extends UpdateCompanion<CustomList> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime?> targetDate;
  final Value<DateTime> createdAt;
  const CustomListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CustomList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? targetDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (targetDate != null) 'target_date': targetDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomListsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime?>? targetDate,
    Value<DateTime>? createdAt,
  }) {
    return CustomListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CustomListMoviesTable extends CustomListMovies
    with TableInfo<$CustomListMoviesTable, CustomListMovie> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomListMoviesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _movieIdMeta = const VerificationMeta(
    'movieId',
  );
  @override
  late final GeneratedColumn<int> movieId = GeneratedColumn<int>(
    'movie_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTvMeta = const VerificationMeta('isTv');
  @override
  late final GeneratedColumn<bool> isTv = GeneratedColumn<bool>(
    'is_tv',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_tv" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rankingOrderMeta = const VerificationMeta(
    'rankingOrder',
  );
  @override
  late final GeneratedColumn<int> rankingOrder = GeneratedColumn<int>(
    'ranking_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    listId,
    movieId,
    isTv,
    rankingOrder,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_list_movies';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomListMovie> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('movie_id')) {
      context.handle(
        _movieIdMeta,
        movieId.isAcceptableOrUnknown(data['movie_id']!, _movieIdMeta),
      );
    } else if (isInserting) {
      context.missing(_movieIdMeta);
    }
    if (data.containsKey('is_tv')) {
      context.handle(
        _isTvMeta,
        isTv.isAcceptableOrUnknown(data['is_tv']!, _isTvMeta),
      );
    }
    if (data.containsKey('ranking_order')) {
      context.handle(
        _rankingOrderMeta,
        rankingOrder.isAcceptableOrUnknown(
          data['ranking_order']!,
          _rankingOrderMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {listId, movieId, isTv};
  @override
  CustomListMovie map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomListMovie(
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      movieId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}movie_id'],
      )!,
      isTv: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_tv'],
      )!,
      rankingOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ranking_order'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $CustomListMoviesTable createAlias(String alias) {
    return $CustomListMoviesTable(attachedDatabase, alias);
  }
}

class CustomListMovie extends DataClass implements Insertable<CustomListMovie> {
  final int listId;
  final int movieId;
  final bool isTv;
  final int? rankingOrder;
  final DateTime addedAt;
  const CustomListMovie({
    required this.listId,
    required this.movieId,
    required this.isTv,
    this.rankingOrder,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['list_id'] = Variable<int>(listId);
    map['movie_id'] = Variable<int>(movieId);
    map['is_tv'] = Variable<bool>(isTv);
    if (!nullToAbsent || rankingOrder != null) {
      map['ranking_order'] = Variable<int>(rankingOrder);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  CustomListMoviesCompanion toCompanion(bool nullToAbsent) {
    return CustomListMoviesCompanion(
      listId: Value(listId),
      movieId: Value(movieId),
      isTv: Value(isTv),
      rankingOrder: rankingOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(rankingOrder),
      addedAt: Value(addedAt),
    );
  }

  factory CustomListMovie.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomListMovie(
      listId: serializer.fromJson<int>(json['listId']),
      movieId: serializer.fromJson<int>(json['movieId']),
      isTv: serializer.fromJson<bool>(json['isTv']),
      rankingOrder: serializer.fromJson<int?>(json['rankingOrder']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'listId': serializer.toJson<int>(listId),
      'movieId': serializer.toJson<int>(movieId),
      'isTv': serializer.toJson<bool>(isTv),
      'rankingOrder': serializer.toJson<int?>(rankingOrder),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  CustomListMovie copyWith({
    int? listId,
    int? movieId,
    bool? isTv,
    Value<int?> rankingOrder = const Value.absent(),
    DateTime? addedAt,
  }) => CustomListMovie(
    listId: listId ?? this.listId,
    movieId: movieId ?? this.movieId,
    isTv: isTv ?? this.isTv,
    rankingOrder: rankingOrder.present ? rankingOrder.value : this.rankingOrder,
    addedAt: addedAt ?? this.addedAt,
  );
  CustomListMovie copyWithCompanion(CustomListMoviesCompanion data) {
    return CustomListMovie(
      listId: data.listId.present ? data.listId.value : this.listId,
      movieId: data.movieId.present ? data.movieId.value : this.movieId,
      isTv: data.isTv.present ? data.isTv.value : this.isTv,
      rankingOrder: data.rankingOrder.present
          ? data.rankingOrder.value
          : this.rankingOrder,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomListMovie(')
          ..write('listId: $listId, ')
          ..write('movieId: $movieId, ')
          ..write('isTv: $isTv, ')
          ..write('rankingOrder: $rankingOrder, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(listId, movieId, isTv, rankingOrder, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomListMovie &&
          other.listId == this.listId &&
          other.movieId == this.movieId &&
          other.isTv == this.isTv &&
          other.rankingOrder == this.rankingOrder &&
          other.addedAt == this.addedAt);
}

class CustomListMoviesCompanion extends UpdateCompanion<CustomListMovie> {
  final Value<int> listId;
  final Value<int> movieId;
  final Value<bool> isTv;
  final Value<int?> rankingOrder;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const CustomListMoviesCompanion({
    this.listId = const Value.absent(),
    this.movieId = const Value.absent(),
    this.isTv = const Value.absent(),
    this.rankingOrder = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomListMoviesCompanion.insert({
    required int listId,
    required int movieId,
    this.isTv = const Value.absent(),
    this.rankingOrder = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : listId = Value(listId),
       movieId = Value(movieId);
  static Insertable<CustomListMovie> custom({
    Expression<int>? listId,
    Expression<int>? movieId,
    Expression<bool>? isTv,
    Expression<int>? rankingOrder,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (listId != null) 'list_id': listId,
      if (movieId != null) 'movie_id': movieId,
      if (isTv != null) 'is_tv': isTv,
      if (rankingOrder != null) 'ranking_order': rankingOrder,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomListMoviesCompanion copyWith({
    Value<int>? listId,
    Value<int>? movieId,
    Value<bool>? isTv,
    Value<int?>? rankingOrder,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return CustomListMoviesCompanion(
      listId: listId ?? this.listId,
      movieId: movieId ?? this.movieId,
      isTv: isTv ?? this.isTv,
      rankingOrder: rankingOrder ?? this.rankingOrder,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (movieId.present) {
      map['movie_id'] = Variable<int>(movieId.value);
    }
    if (isTv.present) {
      map['is_tv'] = Variable<bool>(isTv.value);
    }
    if (rankingOrder.present) {
      map['ranking_order'] = Variable<int>(rankingOrder.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomListMoviesCompanion(')
          ..write('listId: $listId, ')
          ..write('movieId: $movieId, ')
          ..write('isTv: $isTv, ')
          ..write('rankingOrder: $rankingOrder, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MoviesTable movies = $MoviesTable(this);
  late final $WatchRecordsTable watchRecords = $WatchRecordsTable(this);
  late final $UserMovieSettingsTable userMovieSettings =
      $UserMovieSettingsTable(this);
  late final $CustomListsTable customLists = $CustomListsTable(this);
  late final $CustomListMoviesTable customListMovies = $CustomListMoviesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    movies,
    watchRecords,
    userMovieSettings,
    customLists,
    customListMovies,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'custom_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('custom_list_movies', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MoviesTableCreateCompanionBuilder =
    MoviesCompanion Function({
      required int tmdbId,
      required String title,
      Value<String?> originalTitle,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<int?> releaseYear,
      Value<int?> runtime,
      Value<String?> genres,
      Value<String?> director,
      Value<String?> actors,
      Value<String?> overview,
      Value<String?> country,
      Value<String?> language,
      Value<bool> isTv,
      Value<DateTime> createdAt,
      Value<int?> totalEpisodes,
      Value<int> rowid,
    });
typedef $$MoviesTableUpdateCompanionBuilder =
    MoviesCompanion Function({
      Value<int> tmdbId,
      Value<String> title,
      Value<String?> originalTitle,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<int?> releaseYear,
      Value<int?> runtime,
      Value<String?> genres,
      Value<String?> director,
      Value<String?> actors,
      Value<String?> overview,
      Value<String?> country,
      Value<String?> language,
      Value<bool> isTv,
      Value<DateTime> createdAt,
      Value<int?> totalEpisodes,
      Value<int> rowid,
    });

class $$MoviesTableFilterComposer
    extends Composer<_$AppDatabase, $MoviesTable> {
  $$MoviesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runtime => $composableBuilder(
    column: $table.runtime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actors => $composableBuilder(
    column: $table.actors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTv => $composableBuilder(
    column: $table.isTv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalEpisodes => $composableBuilder(
    column: $table.totalEpisodes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MoviesTableOrderingComposer
    extends Composer<_$AppDatabase, $MoviesTable> {
  $$MoviesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runtime => $composableBuilder(
    column: $table.runtime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get director => $composableBuilder(
    column: $table.director,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actors => $composableBuilder(
    column: $table.actors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTv => $composableBuilder(
    column: $table.isTv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalEpisodes => $composableBuilder(
    column: $table.totalEpisodes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MoviesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MoviesTable> {
  $$MoviesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get releaseYear => $composableBuilder(
    column: $table.releaseYear,
    builder: (column) => column,
  );

  GeneratedColumn<int> get runtime =>
      $composableBuilder(column: $table.runtime, builder: (column) => column);

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<String> get director =>
      $composableBuilder(column: $table.director, builder: (column) => column);

  GeneratedColumn<String> get actors =>
      $composableBuilder(column: $table.actors, builder: (column) => column);

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<bool> get isTv =>
      $composableBuilder(column: $table.isTv, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get totalEpisodes => $composableBuilder(
    column: $table.totalEpisodes,
    builder: (column) => column,
  );
}

class $$MoviesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MoviesTable,
          Movie,
          $$MoviesTableFilterComposer,
          $$MoviesTableOrderingComposer,
          $$MoviesTableAnnotationComposer,
          $$MoviesTableCreateCompanionBuilder,
          $$MoviesTableUpdateCompanionBuilder,
          (Movie, BaseReferences<_$AppDatabase, $MoviesTable, Movie>),
          Movie,
          PrefetchHooks Function()
        > {
  $$MoviesTableTableManager(_$AppDatabase db, $MoviesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MoviesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MoviesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MoviesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> tmdbId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> originalTitle = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<int?> runtime = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> actors = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<bool> isTv = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> totalEpisodes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoviesCompanion(
                tmdbId: tmdbId,
                title: title,
                originalTitle: originalTitle,
                posterPath: posterPath,
                backdropPath: backdropPath,
                releaseYear: releaseYear,
                runtime: runtime,
                genres: genres,
                director: director,
                actors: actors,
                overview: overview,
                country: country,
                language: language,
                isTv: isTv,
                createdAt: createdAt,
                totalEpisodes: totalEpisodes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int tmdbId,
                required String title,
                Value<String?> originalTitle = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<int?> releaseYear = const Value.absent(),
                Value<int?> runtime = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<String?> director = const Value.absent(),
                Value<String?> actors = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String?> language = const Value.absent(),
                Value<bool> isTv = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> totalEpisodes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoviesCompanion.insert(
                tmdbId: tmdbId,
                title: title,
                originalTitle: originalTitle,
                posterPath: posterPath,
                backdropPath: backdropPath,
                releaseYear: releaseYear,
                runtime: runtime,
                genres: genres,
                director: director,
                actors: actors,
                overview: overview,
                country: country,
                language: language,
                isTv: isTv,
                createdAt: createdAt,
                totalEpisodes: totalEpisodes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MoviesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MoviesTable,
      Movie,
      $$MoviesTableFilterComposer,
      $$MoviesTableOrderingComposer,
      $$MoviesTableAnnotationComposer,
      $$MoviesTableCreateCompanionBuilder,
      $$MoviesTableUpdateCompanionBuilder,
      (Movie, BaseReferences<_$AppDatabase, $MoviesTable, Movie>),
      Movie,
      PrefetchHooks Function()
    >;
typedef $$WatchRecordsTableCreateCompanionBuilder =
    WatchRecordsCompanion Function({
      Value<int> id,
      required int movieId,
      Value<bool> isTv,
      required DateTime watchDate,
      Value<String?> watchPlace,
      Value<String?> watchCompanion,
      required double rating,
      Value<String?> mood,
      Value<String?> notes,
      required int watchNumber,
      Value<String?> tags,
      Value<int> episodeCount,
      Value<DateTime> createdAt,
    });
typedef $$WatchRecordsTableUpdateCompanionBuilder =
    WatchRecordsCompanion Function({
      Value<int> id,
      Value<int> movieId,
      Value<bool> isTv,
      Value<DateTime> watchDate,
      Value<String?> watchPlace,
      Value<String?> watchCompanion,
      Value<double> rating,
      Value<String?> mood,
      Value<String?> notes,
      Value<int> watchNumber,
      Value<String?> tags,
      Value<int> episodeCount,
      Value<DateTime> createdAt,
    });

class $$WatchRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $WatchRecordsTable> {
  $$WatchRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movieId => $composableBuilder(
    column: $table.movieId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTv => $composableBuilder(
    column: $table.isTv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get watchDate => $composableBuilder(
    column: $table.watchDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get watchPlace => $composableBuilder(
    column: $table.watchPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get watchCompanion => $composableBuilder(
    column: $table.watchCompanion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get watchNumber => $composableBuilder(
    column: $table.watchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeCount => $composableBuilder(
    column: $table.episodeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WatchRecordsTable> {
  $$WatchRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movieId => $composableBuilder(
    column: $table.movieId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTv => $composableBuilder(
    column: $table.isTv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watchDate => $composableBuilder(
    column: $table.watchDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get watchPlace => $composableBuilder(
    column: $table.watchPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get watchCompanion => $composableBuilder(
    column: $table.watchCompanion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get watchNumber => $composableBuilder(
    column: $table.watchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeCount => $composableBuilder(
    column: $table.episodeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WatchRecordsTable> {
  $$WatchRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get movieId =>
      $composableBuilder(column: $table.movieId, builder: (column) => column);

  GeneratedColumn<bool> get isTv =>
      $composableBuilder(column: $table.isTv, builder: (column) => column);

  GeneratedColumn<DateTime> get watchDate =>
      $composableBuilder(column: $table.watchDate, builder: (column) => column);

  GeneratedColumn<String> get watchPlace => $composableBuilder(
    column: $table.watchPlace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get watchCompanion => $composableBuilder(
    column: $table.watchCompanion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get watchNumber => $composableBuilder(
    column: $table.watchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get episodeCount => $composableBuilder(
    column: $table.episodeCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WatchRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WatchRecordsTable,
          WatchRecord,
          $$WatchRecordsTableFilterComposer,
          $$WatchRecordsTableOrderingComposer,
          $$WatchRecordsTableAnnotationComposer,
          $$WatchRecordsTableCreateCompanionBuilder,
          $$WatchRecordsTableUpdateCompanionBuilder,
          (
            WatchRecord,
            BaseReferences<_$AppDatabase, $WatchRecordsTable, WatchRecord>,
          ),
          WatchRecord,
          PrefetchHooks Function()
        > {
  $$WatchRecordsTableTableManager(_$AppDatabase db, $WatchRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> movieId = const Value.absent(),
                Value<bool> isTv = const Value.absent(),
                Value<DateTime> watchDate = const Value.absent(),
                Value<String?> watchPlace = const Value.absent(),
                Value<String?> watchCompanion = const Value.absent(),
                Value<double> rating = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> watchNumber = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> episodeCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WatchRecordsCompanion(
                id: id,
                movieId: movieId,
                isTv: isTv,
                watchDate: watchDate,
                watchPlace: watchPlace,
                watchCompanion: watchCompanion,
                rating: rating,
                mood: mood,
                notes: notes,
                watchNumber: watchNumber,
                tags: tags,
                episodeCount: episodeCount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int movieId,
                Value<bool> isTv = const Value.absent(),
                required DateTime watchDate,
                Value<String?> watchPlace = const Value.absent(),
                Value<String?> watchCompanion = const Value.absent(),
                required double rating,
                Value<String?> mood = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int watchNumber,
                Value<String?> tags = const Value.absent(),
                Value<int> episodeCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WatchRecordsCompanion.insert(
                id: id,
                movieId: movieId,
                isTv: isTv,
                watchDate: watchDate,
                watchPlace: watchPlace,
                watchCompanion: watchCompanion,
                rating: rating,
                mood: mood,
                notes: notes,
                watchNumber: watchNumber,
                tags: tags,
                episodeCount: episodeCount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WatchRecordsTable,
      WatchRecord,
      $$WatchRecordsTableFilterComposer,
      $$WatchRecordsTableOrderingComposer,
      $$WatchRecordsTableAnnotationComposer,
      $$WatchRecordsTableCreateCompanionBuilder,
      $$WatchRecordsTableUpdateCompanionBuilder,
      (
        WatchRecord,
        BaseReferences<_$AppDatabase, $WatchRecordsTable, WatchRecord>,
      ),
      WatchRecord,
      PrefetchHooks Function()
    >;
typedef $$UserMovieSettingsTableCreateCompanionBuilder =
    UserMovieSettingsCompanion Function({
      required int tmdbId,
      Value<bool> isTv,
      Value<bool> isFavorite,
      Value<bool> isReWatchList,
      Value<int?> personalRanking,
      Value<String?> personalNotes,
      Value<String?> personalTags,
      Value<DateTime> updatedAt,
      Value<bool> isActivelyWatching,
      Value<int?> lastWatchedEpisode,
      Value<int> rowid,
    });
typedef $$UserMovieSettingsTableUpdateCompanionBuilder =
    UserMovieSettingsCompanion Function({
      Value<int> tmdbId,
      Value<bool> isTv,
      Value<bool> isFavorite,
      Value<bool> isReWatchList,
      Value<int?> personalRanking,
      Value<String?> personalNotes,
      Value<String?> personalTags,
      Value<DateTime> updatedAt,
      Value<bool> isActivelyWatching,
      Value<int?> lastWatchedEpisode,
      Value<int> rowid,
    });

class $$UserMovieSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserMovieSettingsTable> {
  $$UserMovieSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTv => $composableBuilder(
    column: $table.isTv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReWatchList => $composableBuilder(
    column: $table.isReWatchList,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get personalRanking => $composableBuilder(
    column: $table.personalRanking,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalNotes => $composableBuilder(
    column: $table.personalNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personalTags => $composableBuilder(
    column: $table.personalTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActivelyWatching => $composableBuilder(
    column: $table.isActivelyWatching,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastWatchedEpisode => $composableBuilder(
    column: $table.lastWatchedEpisode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserMovieSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserMovieSettingsTable> {
  $$UserMovieSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTv => $composableBuilder(
    column: $table.isTv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReWatchList => $composableBuilder(
    column: $table.isReWatchList,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get personalRanking => $composableBuilder(
    column: $table.personalRanking,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalNotes => $composableBuilder(
    column: $table.personalNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personalTags => $composableBuilder(
    column: $table.personalTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActivelyWatching => $composableBuilder(
    column: $table.isActivelyWatching,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastWatchedEpisode => $composableBuilder(
    column: $table.lastWatchedEpisode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserMovieSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserMovieSettingsTable> {
  $$UserMovieSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<bool> get isTv =>
      $composableBuilder(column: $table.isTv, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isReWatchList => $composableBuilder(
    column: $table.isReWatchList,
    builder: (column) => column,
  );

  GeneratedColumn<int> get personalRanking => $composableBuilder(
    column: $table.personalRanking,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personalNotes => $composableBuilder(
    column: $table.personalNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personalTags => $composableBuilder(
    column: $table.personalTags,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isActivelyWatching => $composableBuilder(
    column: $table.isActivelyWatching,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastWatchedEpisode => $composableBuilder(
    column: $table.lastWatchedEpisode,
    builder: (column) => column,
  );
}

class $$UserMovieSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserMovieSettingsTable,
          UserMovieSetting,
          $$UserMovieSettingsTableFilterComposer,
          $$UserMovieSettingsTableOrderingComposer,
          $$UserMovieSettingsTableAnnotationComposer,
          $$UserMovieSettingsTableCreateCompanionBuilder,
          $$UserMovieSettingsTableUpdateCompanionBuilder,
          (
            UserMovieSetting,
            BaseReferences<
              _$AppDatabase,
              $UserMovieSettingsTable,
              UserMovieSetting
            >,
          ),
          UserMovieSetting,
          PrefetchHooks Function()
        > {
  $$UserMovieSettingsTableTableManager(
    _$AppDatabase db,
    $UserMovieSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserMovieSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserMovieSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserMovieSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> tmdbId = const Value.absent(),
                Value<bool> isTv = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isReWatchList = const Value.absent(),
                Value<int?> personalRanking = const Value.absent(),
                Value<String?> personalNotes = const Value.absent(),
                Value<String?> personalTags = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActivelyWatching = const Value.absent(),
                Value<int?> lastWatchedEpisode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserMovieSettingsCompanion(
                tmdbId: tmdbId,
                isTv: isTv,
                isFavorite: isFavorite,
                isReWatchList: isReWatchList,
                personalRanking: personalRanking,
                personalNotes: personalNotes,
                personalTags: personalTags,
                updatedAt: updatedAt,
                isActivelyWatching: isActivelyWatching,
                lastWatchedEpisode: lastWatchedEpisode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int tmdbId,
                Value<bool> isTv = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isReWatchList = const Value.absent(),
                Value<int?> personalRanking = const Value.absent(),
                Value<String?> personalNotes = const Value.absent(),
                Value<String?> personalTags = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isActivelyWatching = const Value.absent(),
                Value<int?> lastWatchedEpisode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserMovieSettingsCompanion.insert(
                tmdbId: tmdbId,
                isTv: isTv,
                isFavorite: isFavorite,
                isReWatchList: isReWatchList,
                personalRanking: personalRanking,
                personalNotes: personalNotes,
                personalTags: personalTags,
                updatedAt: updatedAt,
                isActivelyWatching: isActivelyWatching,
                lastWatchedEpisode: lastWatchedEpisode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserMovieSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserMovieSettingsTable,
      UserMovieSetting,
      $$UserMovieSettingsTableFilterComposer,
      $$UserMovieSettingsTableOrderingComposer,
      $$UserMovieSettingsTableAnnotationComposer,
      $$UserMovieSettingsTableCreateCompanionBuilder,
      $$UserMovieSettingsTableUpdateCompanionBuilder,
      (
        UserMovieSetting,
        BaseReferences<
          _$AppDatabase,
          $UserMovieSettingsTable,
          UserMovieSetting
        >,
      ),
      UserMovieSetting,
      PrefetchHooks Function()
    >;
typedef $$CustomListsTableCreateCompanionBuilder =
    CustomListsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<DateTime?> targetDate,
      Value<DateTime> createdAt,
    });
typedef $$CustomListsTableUpdateCompanionBuilder =
    CustomListsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime?> targetDate,
      Value<DateTime> createdAt,
    });

final class $$CustomListsTableReferences
    extends BaseReferences<_$AppDatabase, $CustomListsTable, CustomList> {
  $$CustomListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomListMoviesTable, List<CustomListMovie>>
  _customListMoviesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customListMovies,
    aliasName: 'custom_lists__id__custom_list_movies__list_id',
  );

  $$CustomListMoviesTableProcessedTableManager get customListMoviesRefs {
    final manager = $$CustomListMoviesTableTableManager(
      $_db,
      $_db.customListMovies,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customListMoviesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomListsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomListsTable> {
  $$CustomListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customListMoviesRefs(
    Expression<bool> Function($$CustomListMoviesTableFilterComposer f) f,
  ) {
    final $$CustomListMoviesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customListMovies,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListMoviesTableFilterComposer(
            $db: $db,
            $table: $db.customListMovies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomListsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomListsTable> {
  $$CustomListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomListsTable> {
  $$CustomListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> customListMoviesRefs<T extends Object>(
    Expression<T> Function($$CustomListMoviesTableAnnotationComposer a) f,
  ) {
    final $$CustomListMoviesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customListMovies,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListMoviesTableAnnotationComposer(
            $db: $db,
            $table: $db.customListMovies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomListsTable,
          CustomList,
          $$CustomListsTableFilterComposer,
          $$CustomListsTableOrderingComposer,
          $$CustomListsTableAnnotationComposer,
          $$CustomListsTableCreateCompanionBuilder,
          $$CustomListsTableUpdateCompanionBuilder,
          (CustomList, $$CustomListsTableReferences),
          CustomList,
          PrefetchHooks Function({bool customListMoviesRefs})
        > {
  $$CustomListsTableTableManager(_$AppDatabase db, $CustomListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomListsCompanion(
                id: id,
                name: name,
                description: description,
                targetDate: targetDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomListsCompanion.insert(
                id: id,
                name: name,
                description: description,
                targetDate: targetDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customListMoviesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (customListMoviesRefs) db.customListMovies,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customListMoviesRefs)
                    await $_getPrefetchedData<
                      CustomList,
                      $CustomListsTable,
                      CustomListMovie
                    >(
                      currentTable: table,
                      referencedTable: $$CustomListsTableReferences
                          ._customListMoviesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomListsTableReferences(
                            db,
                            table,
                            p0,
                          ).customListMoviesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.listId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomListsTable,
      CustomList,
      $$CustomListsTableFilterComposer,
      $$CustomListsTableOrderingComposer,
      $$CustomListsTableAnnotationComposer,
      $$CustomListsTableCreateCompanionBuilder,
      $$CustomListsTableUpdateCompanionBuilder,
      (CustomList, $$CustomListsTableReferences),
      CustomList,
      PrefetchHooks Function({bool customListMoviesRefs})
    >;
typedef $$CustomListMoviesTableCreateCompanionBuilder =
    CustomListMoviesCompanion Function({
      required int listId,
      required int movieId,
      Value<bool> isTv,
      Value<int?> rankingOrder,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });
typedef $$CustomListMoviesTableUpdateCompanionBuilder =
    CustomListMoviesCompanion Function({
      Value<int> listId,
      Value<int> movieId,
      Value<bool> isTv,
      Value<int?> rankingOrder,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$CustomListMoviesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CustomListMoviesTable, CustomListMovie> {
  $$CustomListMoviesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomListsTable _listIdTable(_$AppDatabase db) => db.customLists
      .createAlias('custom_list_movies__list_id__custom_lists__id');

  $$CustomListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$CustomListsTableTableManager(
      $_db,
      $_db.customLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomListMoviesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomListMoviesTable> {
  $$CustomListMoviesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get movieId => $composableBuilder(
    column: $table.movieId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTv => $composableBuilder(
    column: $table.isTv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rankingOrder => $composableBuilder(
    column: $table.rankingOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomListsTableFilterComposer get listId {
    final $$CustomListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.customLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListsTableFilterComposer(
            $db: $db,
            $table: $db.customLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomListMoviesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomListMoviesTable> {
  $$CustomListMoviesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get movieId => $composableBuilder(
    column: $table.movieId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTv => $composableBuilder(
    column: $table.isTv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rankingOrder => $composableBuilder(
    column: $table.rankingOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomListsTableOrderingComposer get listId {
    final $$CustomListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.customLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListsTableOrderingComposer(
            $db: $db,
            $table: $db.customLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomListMoviesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomListMoviesTable> {
  $$CustomListMoviesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get movieId =>
      $composableBuilder(column: $table.movieId, builder: (column) => column);

  GeneratedColumn<bool> get isTv =>
      $composableBuilder(column: $table.isTv, builder: (column) => column);

  GeneratedColumn<int> get rankingOrder => $composableBuilder(
    column: $table.rankingOrder,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$CustomListsTableAnnotationComposer get listId {
    final $$CustomListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.customLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomListsTableAnnotationComposer(
            $db: $db,
            $table: $db.customLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomListMoviesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomListMoviesTable,
          CustomListMovie,
          $$CustomListMoviesTableFilterComposer,
          $$CustomListMoviesTableOrderingComposer,
          $$CustomListMoviesTableAnnotationComposer,
          $$CustomListMoviesTableCreateCompanionBuilder,
          $$CustomListMoviesTableUpdateCompanionBuilder,
          (CustomListMovie, $$CustomListMoviesTableReferences),
          CustomListMovie,
          PrefetchHooks Function({bool listId})
        > {
  $$CustomListMoviesTableTableManager(
    _$AppDatabase db,
    $CustomListMoviesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomListMoviesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomListMoviesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomListMoviesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> listId = const Value.absent(),
                Value<int> movieId = const Value.absent(),
                Value<bool> isTv = const Value.absent(),
                Value<int?> rankingOrder = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomListMoviesCompanion(
                listId: listId,
                movieId: movieId,
                isTv: isTv,
                rankingOrder: rankingOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int listId,
                required int movieId,
                Value<bool> isTv = const Value.absent(),
                Value<int?> rankingOrder = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomListMoviesCompanion.insert(
                listId: listId,
                movieId: movieId,
                isTv: isTv,
                rankingOrder: rankingOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomListMoviesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.listId,
                                referencedTable:
                                    $$CustomListMoviesTableReferences
                                        ._listIdTable(db),
                                referencedColumn:
                                    $$CustomListMoviesTableReferences
                                        ._listIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomListMoviesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomListMoviesTable,
      CustomListMovie,
      $$CustomListMoviesTableFilterComposer,
      $$CustomListMoviesTableOrderingComposer,
      $$CustomListMoviesTableAnnotationComposer,
      $$CustomListMoviesTableCreateCompanionBuilder,
      $$CustomListMoviesTableUpdateCompanionBuilder,
      (CustomListMovie, $$CustomListMoviesTableReferences),
      CustomListMovie,
      PrefetchHooks Function({bool listId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MoviesTableTableManager get movies =>
      $$MoviesTableTableManager(_db, _db.movies);
  $$WatchRecordsTableTableManager get watchRecords =>
      $$WatchRecordsTableTableManager(_db, _db.watchRecords);
  $$UserMovieSettingsTableTableManager get userMovieSettings =>
      $$UserMovieSettingsTableTableManager(_db, _db.userMovieSettings);
  $$CustomListsTableTableManager get customLists =>
      $$CustomListsTableTableManager(_db, _db.customLists);
  $$CustomListMoviesTableTableManager get customListMovies =>
      $$CustomListMoviesTableTableManager(_db, _db.customListMovies);
}
