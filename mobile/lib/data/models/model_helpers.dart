int asInt(dynamic value, [int fallback = 0]) => int.tryParse(value?.toString() ?? '') ?? fallback;
double? asDouble(dynamic value) => value == null ? null : double.tryParse(value.toString());
bool asBool(dynamic value, [bool fallback = false]) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return fallback;
}
Map<String, dynamic> asMap(dynamic value) => value is Map<String, dynamic>
    ? value
    : value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
List<dynamic> asList(dynamic value) => value is List ? value : const [];
