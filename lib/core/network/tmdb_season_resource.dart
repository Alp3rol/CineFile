part of 'tmdb_service.dart';

mixin _TmdbSeasonResource on _TmdbCore {
  Future<Map<String, dynamic>?> getTvSeasonDetails(
    int tvId,
    int seasonNumber, {
    String? language,
  }) async {
    if (!ApiConstants.hasTmdbAccess) {
      return null;
    }
    try {
      final response = await _dio.get(
        '/tv/$tvId/season/$seasonNumber',
        queryParameters: {
          'api_key': _apiKey,
          'language': language ?? this.language,
        },
      );
      return response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      debugPrint('TMDb Sezon Detay Hatası: ${e.message}');
      return null;
    }
  }
}
