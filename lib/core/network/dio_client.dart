import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;

  DioClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    int retryCount = 0;
    while (retryCount < AppConstants.maxRetryCount) {
      try {
        return await _dio.get(
          path,
          queryParameters: queryParameters,
          options: options,
        );
      } catch (e) {
        retryCount++;
        if (retryCount >= AppConstants.maxRetryCount) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('Max retry count exceeded');
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    int retryCount = 0;
    while (retryCount < AppConstants.maxRetryCount) {
      try {
        return await _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      } catch (e) {
        retryCount++;
        if (retryCount >= AppConstants.maxRetryCount) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('Max retry count exceeded');
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    int retryCount = 0;
    while (retryCount < AppConstants.maxRetryCount) {
      try {
        return await _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      } catch (e) {
        retryCount++;
        if (retryCount >= AppConstants.maxRetryCount) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('Max retry count exceeded');
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    int retryCount = 0;
    while (retryCount < AppConstants.maxRetryCount) {
      try {
        return await _dio.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
      } catch (e) {
        retryCount++;
        if (retryCount >= AppConstants.maxRetryCount) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('Max retry count exceeded');
  }

  Future<Response> upload(
    String path, {
    required FormData formData,
    Options? options,
  }) async {
    int retryCount = 0;
    while (retryCount < AppConstants.maxRetryCount) {
      try {
        return await _dio.post(
          path,
          data: formData,
          options: options,
        );
      } catch (e) {
        retryCount++;
        if (retryCount >= AppConstants.maxRetryCount) {
          rethrow;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception('Max retry count exceeded');
  }
}
