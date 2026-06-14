import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../injection_container.dart';
import '../constants/api_url.dart';
import '../error/failure.dart';
import '../helpers/user_local.dart';
import '../utils/helper_function.dart';
import 'api_general_model.dart';
import 'network_info.dart';

enum HttpMethods { get, post, download }

abstract class HttpManager {
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool isFormData = false,
    bool isWithBaseUrl = true,
    Function(int received, int total)? onReceiveProgress,
  });

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic>? params, {
    Map<String, String>? headers,
    bool isWithBaseUrl = true,
    bool isFormData = false,
  });

  Future<Response> postResponse(
    String url,
    Map<String, dynamic>? params, {
    Map<String, String>? headers,
    bool isWithBaseUrl = true,
    bool isFormData = false,
  });

  Future<void> download(
    String url,
    String savePath, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool isFormData = false,
    bool isWithBaseUrl = true,
    Function(int received, int total)? onReceiveProgress,
  });
}

class HttpManagerImpl implements HttpManager {
  late final Dio _dio;

  HttpManagerImpl({required BaseOptions baseOptions}) {
    initHttpManager(baseOptions: baseOptions);
  }

  Future<void> initHttpManager({
    required BaseOptions baseOptions,
  }) async {
    _dio = Dio(baseOptions);
    _dio.options.connectTimeout = const Duration(minutes: 2);
    _dio.options.receiveTimeout = const Duration(minutes: 2);
    _dio.options.sendTimeout = const Duration(minutes: 2);
  }

  Future<Response> request({
    required String path,
    required HttpMethods method,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool isFormData = false,
    bool isWithBaseUrl = true,
    Function(int sent, int total)? onSendProgress,
    Function(int sent, int total)? onReceiveProgress,
    Options? options,
    String? savePath,
  }) async {

    headers ??= {};

    if (UserLocal.user?.sessionId != null) {
      headers['Cookie'] = "session_id=${UserLocal.user!.sessionId}";
    }

    _dio.options.headers.addAll(headers);

    if(kDebugMode){
      if (!_dio.interceptors.contains(sl<PrettyDioLogger>())) {
        _dio.interceptors.add(sl<PrettyDioLogger>());
      }
    }


    log("Params: $params");
    log("FormData: $isFormData");

    Response response;

    switch (method) {
      case HttpMethods.get:
        response = await _dio.get(
            isWithBaseUrl ? "${APIsUrl.baseUrl}/$path" : path,
            queryParameters: params,
            onReceiveProgress: onReceiveProgress);
        break;
      case HttpMethods.post:
        dynamic data;
        if (isFormData && params != null) {
          data = FormData.fromMap(params, ListFormat.multiCompatible);
        } else {
          data = params;
        }
        response = await _dio.post(
            isWithBaseUrl ? "${APIsUrl.baseUrl}/$path" : path,
            data: data,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress);
        break;
      case HttpMethods.download:
        response = await _dio.download(
          isWithBaseUrl ? "${APIsUrl.baseUrl}/$path" : path,
          savePath!,
          queryParameters: params,
          options: options,
          onReceiveProgress: onReceiveProgress,
        );
        break;
    }

    return response;
  }

  @override
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool isFormData = false,
    bool isWithBaseUrl = true,
    Function(int received, int total)? onReceiveProgress,
  }) async {
    if (await sl<NetworkInfo>().isConnected ?? false) {
      try {
        final response = await request(
          path: url,
          method: HttpMethods.get,
          headers: headers,
          params: params,
          isFormData: isFormData,
          isWithBaseUrl: isWithBaseUrl,
          onReceiveProgress: onReceiveProgress,
        );

        final responseJson = returnResponse(response);
        return json.decode(responseJson);
      } on DioException catch (dioError) {
        throw ServerFailure(dioError.message ?? "Connection Error",
            dioError.response?.statusCode ?? 500)
          ..onError();
      }
    } else {
      throw OfflineFailure("No internet connection", 50);
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic>? params, {
    Map<String, String>? headers,
    bool isFormData = false,
    bool isWithBaseUrl = true,
  }) async {
    if (await sl<NetworkInfo>().isConnected ?? false) {
      try {
        final response = await request(
            path: url,
            method: HttpMethods.post,
            headers: headers,
            isFormData: isFormData,
            params: params);
        final responseJson = returnResponse(response);
        return json.decode(responseJson);
      } on DioException catch (dioError) {
        throw ServerFailure(dioError.message ?? "Server Error",
            dioError.response?.statusCode ?? 500)
          ..onError();
      }
    } else {
      throw OfflineFailure("No internet connection", 50);
    }
  }

  @override
  Future<Response> postResponse(
    String url,
    Map<String, dynamic>? params, {
    Map<String, String>? headers,
    bool isFormData = false,
    bool isWithBaseUrl = true,
  }) async {
    if (await sl<NetworkInfo>().isConnected ?? false) {
      try {
        final response = await request(
            path: url,
            method: HttpMethods.post,
            headers: headers,
            isFormData: isFormData,
            params: params);
        return response;
      } on DioException catch (dioError) {
        throw ServerFailure(dioError.message ?? "Server Error",
            dioError.response?.statusCode ?? 500)
          ..onError();
      }
    } else {
      throw OfflineFailure("No internet connection", 50);
    }
  }

  @override
  Future<void> download(
    String url,
    String savePath, {
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool isFormData = false,
    bool isWithBaseUrl = true,
    Function(int received, int total)? onReceiveProgress,
  }) async {
    if (await sl<NetworkInfo>().isConnected ?? false) {
      try {
        Response res = await request(
          path: url,
          method: HttpMethods.download,
          headers: headers,
          params: params,
          isFormData: isFormData,
          isWithBaseUrl: isWithBaseUrl,
          savePath: savePath,
          options: Options(headers: headers),
          onReceiveProgress: onReceiveProgress,
        );
        if (res.statusCode != 200) {
          throw ServerFailure("Download Error", res.statusCode!);
        }
      } on DioException catch (dioError) {
        throw ServerFailure(dioError.message ?? "Server Error", 50);
      }
    } else {
      throw OfflineFailure("No internet connection", 50);
    }
  }
}

HttpManager httpManager = HttpManagerImpl(
  baseOptions: BaseOptions(
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      "charset": "utf-8",
      "Accept-Charset": "utf-8",
    },
    responseType: ResponseType.json,
  ),
);

dynamic returnResponse(Response? response) {
  final dynamic data = (response?.data?.runtimeType == String
      ? json.decode(response?.data!)
      : response?.data!);

  if (response?.statusCode == 200) {
    ApiGeneralModel apiResponses = ApiGeneralModel.fromJson(data);
    if (apiResponses.status == true) {
      return json.encode(data);
    } else {
      throw GlobalFailure(
        apiResponses.errorMessage ?? "Global Error",
        apiResponses.code ?? -2,
      );
    }
  } else if (response?.statusCode == 500) {
    throw ServerFailure(
      "Server Error",
      response!.statusCode ?? 500,
    );
  } else if (response?.statusCode == 401) {
    removeUser();
    throw ServerFailure(
      "Unauthorized",
      response!.statusCode ?? 401,
    );
  } else {
    throw GlobalFailure(
      "Global Error",
      response?.statusCode ?? -2,
    );
  }
}
