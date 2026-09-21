import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/local_storage.dart';

class _FakeLocalStorage implements LocalStorage {
  _FakeLocalStorage({this.token});

  final String? token;

  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<dynamic> read(String key) async {
    if (key == 'auth_token') return token;
    return null;
  }

  @override
  Future<void> write(String key, dynamic value) async {}
}

http.Response _jsonResponse(
  Map<String, dynamic> body, {
  int statusCode = 200,
}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: const {'content-type': 'application/json'},
  );
}

void main() {
  group('ApiClient', () {
    test('GET sends query parameters and parses the API envelope', () async {
      late http.Request captured;

      final client = ApiClient(
        client: MockClient((request) async {
          captured = request;
          return _jsonResponse({
            'success': true,
            'message': 'ok',
            'data': {'value': 42},
          });
        }),
      );

      final response = await client.get<int>(
        '/products',
        queryParameters: const {
          'search': 'phone',
          'page': '2',
        },
        fromData: (data) => data['value'] as int,
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/api/products');
      expect(captured.url.queryParameters, {
        'search': 'phone',
        'page': '2',
      });
      expect(captured.headers['accept'], 'application/json');
      expect(captured.headers['content-type'], 'application/json');
      expect(response.success, isTrue);
      expect(response.message, 'ok');
      expect(response.data, 42);
    });

    test('GET without query parameters does not add a query string', () async {
      late http.Request captured;

      final client = ApiClient(
        client: MockClient((request) async {
          captured = request;
          return _jsonResponse({
            'success': true,
            'data': {'value': 'ready'},
          });
        }),
      );

      final response = await client.get<String>(
        '/health',
        fromData: (data) => data['value'] as String,
      );

      expect(captured.url.query, isEmpty);
      expect(response.data, 'ready');
    });

    test('POST sends JSON body and Bearer token', () async {
      late http.Request captured;

      final client = ApiClient(
        client: MockClient((request) async {
          captured = request;
          return _jsonResponse({
            'success': true,
            'message': 'created',
            'data': {'id': 10},
          });
        }),
        storage: _FakeLocalStorage(token: 'test-token'),
      );

      final response = await client.post<int>(
        '/cart/items',
        body: const {
          'product_id': 10,
          'quantity': 2,
        },
        fromData: (data) => data['id'] as int,
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/api/cart/items');
      expect(captured.headers['authorization'], 'Bearer test-token');
      expect(jsonDecode(captured.body), {
        'product_id': 10,
        'quantity': 2,
      });
      expect(response.data, 10);
    });

    test('POST uses an empty JSON object when no body is supplied', () async {
      late http.Request captured;

      final client = ApiClient(
        client: MockClient((request) async {
          captured = request;
          return _jsonResponse({
            'success': true,
            'data': null,
          });
        }),
      );

      await client.post<void>('/ping');

      expect(captured.method, 'POST');
      expect(jsonDecode(captured.body), <String, dynamic>{});
    });

    test('PUT sends JSON body and parses response data', () async {
      late http.Request captured;

      final client = ApiClient(
        client: MockClient((request) async {
          captured = request;
          return _jsonResponse({
            'success': true,
            'data': {'updated': true},
          });
        }),
      );

      final response = await client.put<bool>(
        '/addresses/7',
        body: const {'title': 'home'},
        fromData: (data) => data['updated'] as bool,
      );

      expect(captured.method, 'PUT');
      expect(captured.url.path, '/api/addresses/7');
      expect(jsonDecode(captured.body), {'title': 'home'});
      expect(response.data, isTrue);
    });

    test('DELETE sends the request with authentication', () async {
      late http.Request captured;

      final client = ApiClient(
        client: MockClient((request) async {
          captured = request;
          return _jsonResponse({
            'success': true,
            'message': 'deleted',
            'data': null,
          });
        }),
        storage: _FakeLocalStorage(token: 'delete-token'),
      );

      final response = await client.delete<void>('/cart/items/7');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/api/cart/items/7');
      expect(captured.headers['authorization'], 'Bearer delete-token');
      expect(response.success, isTrue);
      expect(response.message, 'deleted');
    });

    test('does not send Authorization when storage has no token', () async {
      late http.Request captured;

      final client = ApiClient(
        client: MockClient((request) async {
          captured = request;
          return _jsonResponse({
            'success': true,
            'data': null,
          });
        }),
        storage: _FakeLocalStorage(),
      );

      await client.get<void>('/public');

      expect(captured.headers.containsKey('authorization'), isFalse);
    });

    test('maps a 4xx response to ApiException', () async {
      final client = ApiClient(
        client: MockClient((request) async {
          return _jsonResponse({
            'success': false,
            'message': 'Unauthorized',
          }, statusCode: 401);
        }),
      );

      await expectLater(
        client.get<void>('/private'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.code, 'code', '401')
              .having((error) => error.message, 'message', 'Unauthorized'),
        ),
      );
    });

    test('uses the first validation error message for a 422 response', () async {
      final client = ApiClient(
        client: MockClient((request) async {
          return _jsonResponse({
            'success': false,
            'message': 'Validation failed',
            'errors': {
              'phone': ['The phone field is required.'],
              'password': ['The password field is required.'],
            },
          }, statusCode: 422);
        }),
      );

      await expectLater(
        client.post<void>('/auth/register'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.code, 'code', '422')
              .having(
                (error) => error.message,
                'message',
                'The phone field is required.',
              ),
        ),
      );
    });

    test('maps a 5xx response to ServerException', () async {
      final client = ApiClient(
        client: MockClient((request) async {
          return _jsonResponse({
            'success': false,
            'message': 'Database unavailable',
          }, statusCode: 503);
        }),
      );

      await expectLater(
        client.get<void>('/products'),
        throwsA(
          isA<ServerException>()
              .having((error) => error.code, 'code', '503')
              .having(
                (error) => error.message,
                'message',
                'Database unavailable',
              ),
        ),
      );
    });

    test('maps invalid JSON to ParseException', () async {
      final client = ApiClient(
        client: MockClient((request) async {
          return http.Response(
            '<html>not json</html>',
            200,
            headers: const {'content-type': 'text/html'},
          );
        }),
      );

      await expectLater(
        client.get<void>('/broken'),
        throwsA(
          isA<ParseException>()
              .having((error) => error.code, 'code', 'INVALID_JSON'),
        ),
      );
    });

    test('maps a non-object JSON response to ApiException', () async {
      final client = ApiClient(
        client: MockClient((request) async {
          return http.Response('[]', 200);
        }),
      );

      await expectLater(
        client.get<void>('/invalid-envelope'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.code, 'code', 'API_ERROR'),
        ),
      );
    });

    test('maps success false with HTTP 200 to ApiException', () async {
      final client = ApiClient(
        client: MockClient((request) async {
          return _jsonResponse({
            'success': false,
            'message': 'Business rule failed',
          });
        }),
      );

      await expectLater(
        client.get<void>('/business-error'),
        throwsA(
          isA<ApiException>()
              .having((error) => error.code, 'code', 'API_ERROR')
              .having(
                (error) => error.message,
                'message',
                'Business rule failed',
              ),
        ),
      );
    });

    test('maps a network failure to NetworkException', () async {
      final client = ApiClient(
        client: MockClient((request) async {
          throw Exception('connection failed');
        }),
      );

      await expectLater(
        client.get<void>('/offline'),
        throwsA(
          isA<NetworkException>()
              .having((error) => error.code, 'code', 'NETWORK_ERROR'),
        ),
      );
    });

    test('supports an empty successful response envelope', () async {
      final client = ApiClient(
        client: MockClient((request) async {
          return _jsonResponse({
            'success': true,
            'message': 'done',
            'data': null,
          });
        }),
      );

      final response = await client.delete<void>('/cleanup');

      expect(response.success, isTrue);
      expect(response.message, 'done');
      expect(response.data, isNull);
    });
  });
}
