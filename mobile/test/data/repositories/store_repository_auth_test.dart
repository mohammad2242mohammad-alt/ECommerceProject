import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:frontend/core/errors/app_exception.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/local_storage.dart';
import 'package:frontend/data/repositories/store_repository.dart';

class FakeLocalStorage implements LocalStorage {
  final Map<String, dynamic> values = {};

  @override
  Future<void> write(String key, dynamic value) async {
    values[key] = value;
  }

  @override
  Future<dynamic> read(String key) async {
    return values[key];
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<void> clear() async {
    values.clear();
  }
}

Map<String, dynamic> authResponse({
  String token = 'test-token',
  int userId = 1,
  String phone = '09120000000',
  String name = 'Test User',
  String role = 'customer',
  bool isActive = true,
}) {
  return {
    'success': true,
    'message': 'موفق',
    'data': {
      'user': {
        'id': userId,
        'phone': phone,
        'name': name,
        'role': role,
        'is_active': isActive,
      },
      'token': token,
    },
  };
}

StoreRepository createRepository({
  required FakeLocalStorage storage,
  required Future<http.Response> Function(http.Request) handler,
}) {
  final client = MockClient(handler);

  final api = ApiClient(
    client: client,
    storage: storage,
  );

  return StoreRepository(api, storage);
}

void main() {
  group('StoreRepository Auth', () {
    test('login sends correct request and stores token', () async {
      final storage = FakeLocalStorage();

      final repository = createRepository(
        storage: storage,
        handler: (request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/auth/login');

          final body = jsonDecode(request.body) as Map<String, dynamic>;

          expect(body['phone'], '09120000000');
          expect(body['password'], '123456');

          return http.Response(
            jsonEncode(authResponse(token: 'login-token')),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final session = await repository.login(
        '09120000000',
        '123456',
      );

      expect(session.token, 'login-token');
      expect(session.user.id, 1);
      expect(session.user.phone, '09120000000');
      expect(session.user.role, 'customer');

      expect(
        await storage.read('auth_token'),
        'login-token',
      );
    });

    test('register sends password confirmation and stores token', () async {
      final storage = FakeLocalStorage();

      final repository = createRepository(
        storage: storage,
        handler: (request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/auth/register');

          final body = jsonDecode(request.body) as Map<String, dynamic>;

          expect(body['phone'], '09121111111');
          expect(body['password'], '123456');
          expect(body['password_confirmation'], '123456');

          return http.Response(
            jsonEncode(
              authResponse(
                token: 'register-token',
                phone: '09121111111',
              ),
            ),
            201,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final session = await repository.register(
        '09121111111',
        '123456',
        '123456',
      );

      expect(session.token, 'register-token');
      expect(session.user.phone, '09121111111');

      expect(
        await storage.read('auth_token'),
        'register-token',
      );
    });

    test('me parses authenticated user from API response', () async {
      final storage = FakeLocalStorage();

      await storage.write(
        'auth_token',
        'existing-token',
      );

      final repository = createRepository(
        storage: storage,
        handler: (request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/api/auth/me');

          expect(
            request.headers['authorization'],
            'Bearer existing-token',
          );

          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'موفق',
              'data': {
                'user': {
                  'id': 7,
                  'phone': '09123333333',
                  'name': 'Mohammad',
                  'role': 'customer',
                  'is_active': true,
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      final user = await repository.me();

      expect(user.id, 7);
      expect(user.phone, '09123333333');
      expect(user.name, 'Mohammad');
      expect(user.role, 'customer');
      expect(user.isActive, true);
    });

    test('logout calls API and removes local token', () async {
      final storage = FakeLocalStorage();

      await storage.write(
        'auth_token',
        'logout-token',
      );

      final repository = createRepository(
        storage: storage,
        handler: (request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/auth/logout');

          expect(
            request.headers['authorization'],
            'Bearer logout-token',
          );

          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'خروج موفق',
              'data': null,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      await repository.logout();

      expect(
        await storage.read('auth_token'),
        isNull,
      );
    });

    test('logout removes token even when API request fails', () async {
      final storage = FakeLocalStorage();

      await storage.write(
        'auth_token',
        'logout-token',
      );

      final repository = createRepository(
        storage: storage,
        handler: (request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'خطای سرور',
              'data': null,
            }),
            500,
            headers: {'content-type': 'application/json'},
          );
        },
      );

      await expectLater(
        repository.logout(),
        throwsA(isA<ServerException>()),
      );

      expect(
        await storage.read('auth_token'),
        isNull,
      );
    });
  });
}