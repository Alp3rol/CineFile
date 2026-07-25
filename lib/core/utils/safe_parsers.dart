import 'package:cloud_firestore/cloud_firestore.dart';

/// Safely parses a [DateTime] from [Timestamp], ISO 8601 [String], or milliseconds [num].
DateTime parseDateTime(dynamic val, {DateTime? fallback}) {
  final defaultFallback = fallback ?? DateTime.now();
  if (val == null) return defaultFallback;
  if (val is Timestamp) return val.toDate();
  if (val is String) return DateTime.tryParse(val) ?? defaultFallback;
  if (val is num) return DateTime.fromMillisecondsSinceEpoch(val.toInt());
  return defaultFallback;
}

/// Safely parses a nullable [DateTime] from [Timestamp], ISO 8601 [String], or milliseconds [num].
DateTime? parseNullableDateTime(dynamic val) {
  if (val == null) return null;
  if (val is Timestamp) return val.toDate();
  if (val is String) return DateTime.tryParse(val);
  if (val is num) return DateTime.fromMillisecondsSinceEpoch(val.toInt());
  return null;
}

/// Safely parses a [bool] from [bool], [num] (1/0), or [String] ('true'/'false'/'1'/'0').
bool parseBool(dynamic val, {bool defaultValue = false}) {
  if (val == null) return defaultValue;
  if (val is bool) return val;
  if (val is num) return val != 0;
  if (val is String) {
    final lower = val.trim().toLowerCase();
    if (lower == 'true' || lower == '1') return true;
    if (lower == 'false' || lower == '0') return false;
  }
  return defaultValue;
}

/// Safely parses an nullable [int] from [num] or [String].
int? parseInt(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val);
  return null;
}

/// Safely parses a nullable [double] from [num] or [String].
double? parseDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val);
  return null;
}

/// Safely parses a [List<String>] from a [List] or comma-separated [String].
List<String> parseStringList(dynamic val) {
  if (val is List) {
    return val.map((e) => e.toString()).toList();
  }
  if (val is String) {
    if (val.trim().isEmpty) return <String>[];
    return val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
  return <String>[];
}
