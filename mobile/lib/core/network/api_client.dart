import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/app_exception.dart';
import '../storage/local_storage.dart';
import 'models/api_response.dart';

class ApiClient {
  ApiClient({http.Client? client, LocalStorage? storage})
      : _client = client ?? http.Client(),
        _storage = storage;

  final http.Client _client;
  final LocalStorage? _storage;

  Future<ApiResponse<T>> get<T>(String endpoint, {Map<String, String>? queryParameters, T Function(dynamic)? fromData}) =>
      _request<T>('GET', endpoint, queryParameters: queryParameters, fromData: fromData);

  Future<ApiResponse<T>> post<T>(String endpoint, {Map<String, dynamic>? body, T Function(dynamic)? fromData}) =>
      _request<T>('POST', endpoint, body: body, fromData: fromData);

  Future<ApiResponse<T>> put<T>(String endpoint, {Map<String, dynamic>? body, T Function(dynamic)? fromData}) =>
      _request<T>('PUT', endpoint, body: body, fromData: fromData);

  Future<ApiResponse<T>> delete<T>(String endpoint, {T Function(dynamic)? fromData}) =>
      _request<T>('DELETE', endpoint, fromData: fromData);

  Future<ApiResponse<T>> _request<T>(String method, String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    T Function(dynamic)? fromData,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint').replace(
      queryParameters: queryParameters == null || queryParameters.isEmpty ? null : queryParameters,
    );
    final token = await _storage?.read('auth_token');
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token is String && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    http.Response response;
    try {
      switch (method) {
        case 'POST':
          response = await _client.post(uri, headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'PUT':
          response = await _client.put(uri, headers: headers, body: jsonEncode(body ?? {}));
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers);
          break;
        default:
          response = await _client.get(uri, headers: headers);
      }
    } catch (_) {
      throw NetworkException('خطا در برقراری ارتباط با سرور', code: 'NETWORK_ERROR');
    }

    dynamic decoded;
    try {
      decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    } catch (_) {
      throw ParseException('پاسخ سرور قابل پردازش نیست', code: 'INVALID_JSON');
    }
    final payload = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'success': false, 'message': 'فرمت پاسخ نامعتبر است'};

    if (response.statusCode >= 500) {
      throw ServerException(payload['message']?.toString() ?? 'خطا در سرور', code: response.statusCode.toString());
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errors = payload['errors'];
      var message = payload['message']?.toString() ?? 'درخواست API ناموفق بود';
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) message = first.first.toString();
      }
      throw ApiException(message, code: response.statusCode.toString());
    }

    final result = ApiResponse<T>.fromJson(payload, fromData: fromData);
    if (!result.success) throw ApiException(result.message ?? 'درخواست API ناموفق بود', code: 'API_ERROR');
    return result;
  }
}
