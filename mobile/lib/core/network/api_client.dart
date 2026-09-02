import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../errors/app_exception.dart';
import 'models/api_response.dart';

/// کلاینت مرکزی ارتباط Flutter با REST API.
///
/// تمام درخواست‌های HTTP پروژه باید از این لایه عبور کنند
/// تا مدیریت Header، خطا، JSON و پاسخ استاندارد API
/// در یک نقطه انجام شود.
class ApiClient {
  ApiClient({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  /// ارسال درخواست GET به Backend.
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic)? fromData,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}$endpoint',
    ).replace(
      queryParameters:
          queryParameters == null || queryParameters.isEmpty
              ? null
              : queryParameters,
    );

    late http.Response response;

    try {
      response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          ...?headers,
        },
      );
    } catch (e) {
      throw NetworkException(
        'خطا در برقراری ارتباط با سرور',
        code: 'NETWORK_ERROR',
      );
    }

    if (response.statusCode >= 500) {
      throw ServerException(
        'خطا در سرور',
        code: response.statusCode.toString(),
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw ApiException(
        'خطا در درخواست API',
        code: response.statusCode.toString(),
      );
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      throw ParseException(
        'پاسخ سرور قابل پردازش نیست',
        code: 'INVALID_JSON',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ParseException(
        'فرمت پاسخ API نامعتبر است',
        code: 'INVALID_RESPONSE',
      );
    }

    final apiResponse = ApiResponse<T>.fromJson(
      decoded,
      fromData: fromData,
    );

    if (!apiResponse.success) {
      throw ApiException(
        apiResponse.message ?? 'درخواست API ناموفق بود',
        code: 'API_ERROR',
      );
    }

    return apiResponse;
  }

  /// ارسال درخواست POST به Backend.
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromData,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}$endpoint',
    );

    late http.Response response;

    try {
      response = await _client.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body == null ? null : jsonEncode(body),
      );
    } catch (e) {
      throw NetworkException(
        'خطا در برقراری ارتباط با سرور',
        code: 'NETWORK_ERROR',
      );
    }

    if (response.statusCode >= 500) {
      throw ServerException(
        'خطا در سرور',
        code: response.statusCode.toString(),
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw ApiException(
        'خطا در درخواست API',
        code: response.statusCode.toString(),
      );
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      throw ParseException(
        'پاسخ سرور قابل پردازش نیست',
        code: 'INVALID_JSON',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ParseException(
        'فرمت پاسخ API نامعتبر است',
        code: 'INVALID_RESPONSE',
      );
    }

    final apiResponse = ApiResponse<T>.fromJson(
      decoded,
      fromData: fromData,
    );

    if (!apiResponse.success) {
      throw ApiException(
        apiResponse.message ?? 'درخواست API ناموفق بود',
        code: 'API_ERROR',
      );
    }

    return apiResponse;
  }

  /// ارسال درخواست PUT به Backend.
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(dynamic)? fromData,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}$endpoint',
    );

    late http.Response response;

    try {
      response = await _client.put(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: body == null ? null : jsonEncode(body),
      );
    } catch (e) {
      throw NetworkException(
        'خطا در برقراری ارتباط با سرور',
        code: 'NETWORK_ERROR',
      );
    }

    if (response.statusCode >= 500) {
      throw ServerException(
        'خطا در سرور',
        code: response.statusCode.toString(),
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw ApiException(
        'خطا در درخواست API',
        code: response.statusCode.toString(),
      );
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      throw ParseException(
        'پاسخ سرور قابل پردازش نیست',
        code: 'INVALID_JSON',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ParseException(
        'فرمت پاسخ API نامعتبر است',
        code: 'INVALID_RESPONSE',
      );
    }

    final apiResponse = ApiResponse<T>.fromJson(
      decoded,
      fromData: fromData,
    );

    if (!apiResponse.success) {
      throw ApiException(
        apiResponse.message ?? 'درخواست API ناموفق بود',
        code: 'API_ERROR',
      );
    }

    return apiResponse;
  }

  /// ارسال درخواست DELETE به Backend.
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(dynamic)? fromData,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}$endpoint',
    );

    late http.Response response;

    try {
      response = await _client.delete(
        uri,
        headers: {
          'Accept': 'application/json',
          ...?headers,
        },
      );
    } catch (e) {
      throw NetworkException(
        'خطا در برقراری ارتباط با سرور',
        code: 'NETWORK_ERROR',
      );
    }

    if (response.statusCode >= 500) {
      throw ServerException(
        'خطا در سرور',
        code: response.statusCode.toString(),
      );
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw ApiException(
        'خطا در درخواست API',
        code: response.statusCode.toString(),
      );
    }

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      throw ParseException(
        'پاسخ سرور قابل پردازش نیست',
        code: 'INVALID_JSON',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw ParseException(
        'فرمت پاسخ API نامعتبر است',
        code: 'INVALID_RESPONSE',
      );
    }

    final apiResponse = ApiResponse<T>.fromJson(
      decoded,
      fromData: fromData,
    );

    if (!apiResponse.success) {
      throw ApiException(
        apiResponse.message ?? 'درخواست API ناموفق بود',
        code: 'API_ERROR',
      );
    }

    return apiResponse;
  }
}