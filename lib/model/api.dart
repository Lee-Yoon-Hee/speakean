// ignore_for_file: annotate_overrides

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

//typedef JsonConstructor<D> = D Function(dynamic json);

// class BaseApiResponse<D> {
//   late final D? data;
//
//   BaseApiResponse(Map<String, dynamic> json);
// }
//
// class ApiResponse<D> extends BaseApiResponse {
//   ApiResponse._(super.json);
//
//   ApiResponse.fromJson(dynamic json, JsonConstructor<D> fromJson) : super(json) {
//     data = fromJson(json);
//   }
// }
//
// class ListApiResponse<D> extends ApiResponse<List<D>> {
//
//   ListApiResponse.fromJson(dynamic json, JsonConstructor<D> fromJson) : super._(json) {
//     data = [ for(final e in json) fromJson(e) ];
//   }
//
// }

typedef FromJson<E> = E Function(dynamic json);

FromJson<String> stringFromJson = (json) => json;


class ApiManagerStorage {
  static final Map<String, ApiManager> storage = {};
}

class ApiManager {
  static late final ApiManager instance;

  final Map<String, ApiFetch> _map = {};

  final String host;

  ApiManager({
    required this.host,
    required List<ApiPath> sub,
  }) {
    for(ApiPath apiPath in sub) {
      _constituteUrl(apiPath, host);
    }
    for(ApiPath apiPath in sub) {
      _registerApiFetch(apiPath);
    }

    instance = this;
  }

  Map<String, String> get urlMapping {
    return _map.map((k, v) {
      return MapEntry(k, v.url);
    });
  }

  Future<E> fetch<E>({
    required String name,
    RequestParam? requestParam,
    RequestBody? requestBody,
    Map<String, dynamic>? namedPathVariable,
    Map<String, dynamic>? headers,
    required FromJson<E> fromJson,
    bool mock = false,
  }) async {
    final apiFetch = _map[name];
    final data = await _fetch(apiFetch, requestParam, requestBody, namedPathVariable, headers, mock);

    if(kDebugMode) {
      print("[DATA] $name : $data");
    }

    return fromJson(data);
  }

  Future<List<E>> fetchList<E>({
    required String name,
    RequestParam? requestParam,
    RequestBody? requestBody,
    Map<String, dynamic>? namedPathVariable,
    Map<String, dynamic>? headers,
    required FromJson<E> fromJson,
    bool mock = false,
  }) async {
    final apiFetch = _map[name];
    final data = await _fetch(apiFetch, requestParam, requestBody, namedPathVariable, headers, mock);

    if(kDebugMode) {
      print("[DATA] $name : $data");
    }

    return [ for(var e in data) fromJson(e) ];
  }

  Future<dynamic> _fetch(
      ApiFetch? apiFetch,
      RequestParam? requestParam,
      RequestBody? requestBody,
      Map<String, dynamic>? namedPathVariable,
      Map<String, dynamic>? headers,
      bool mock
      ) async {
    if(apiFetch == null) {
      throw Exception("해당 이름의 api가 존재하지 않습니다.");
    }

    String targetUrl = apiFetch.url;
    if(namedPathVariable != null) {
      targetUrl = _replacePathVariable(targetUrl, namedPathVariable);
    }
    if(targetUrl.contains(RegExp("[{}]"))) {
      throw Exception("PathVariable이 설정되지 않았습니다.");
    }

    if (kDebugMode) {
      final log = "${mock ? "[M]" : ""}[${apiFetch.methodType.name}] target url : $targetUrl"
          "${requestParam == null ? "" : ", requestParam : ${requestParam.toString()}"}"
          "${requestBody == null ? "" : ", requestBody : ${requestBody.toString()}"}";

      print(log);
    }

    late final dynamic data;
    if(mock) {
      if(apiFetch.mock == null) {
        throw Exception("mock을 호출할 수 없습니다.");
      }

      String? key = apiFetch.mock!.keyFrom != null ? apiFetch.mock!.keyFrom!(namedPathVariable, requestParam, requestBody) : apiFetch.mock!.defaultKey;
      if(key == null) {
        throw Exception("설정한 요청값에 대하여 해당하는 키가 존재하지 않습니다.");
      }

      String? jsonString = apiFetch.mock!.data?[key];
      if(jsonString == null) {
        throw Exception("키($key)에 대응되는 mock가 존재하지 않습니다.");
      }

      data = jsonDecode(jsonString);
    } else {
      final response = await Dio().request(
        targetUrl,
        options: Options(
          method: apiFetch.methodType.name,
          contentType: requestBody != null ? "application/json; encoding=utf-8" : null,
          headers: headers,
        ),
        data: requestBody?.data,
        queryParameters: requestParam?.data,
      );

      if(response.statusCode != 200) {
        throw Exception("옳바른 데이터를 받지 못했습니다.");
      }

      data = response.data;
    }

    return data;
  }

  String _replacePathVariable(String url, Map<String, dynamic> namedPathVariable) {
    for(final entry in namedPathVariable.entries) {
      url = url.replaceAll("{${entry.key}}", entry.value.toString());
    }

    return url;
  }

  // Future<T> call1<T>({
  //   required String name,
  //   ApiRequest? apiRequest,
  //   required JsonConstructor<T> fromJson,
  //   Map<String, dynamic>? namedPathVariable,
  //   Map<String, dynamic>? headers,
  // }) async {
  //   final apiCall = _map[name];
  //
  //   if(apiCall == null) {
  //     throw Exception("해당 이름의 api가 존재하지 않습니다.");
  //   }
  //
  //   return (await _call<T, T>(apiCall, apiRequest, ApiResponse.fromJson, fromJson, namedPathVariable, headers))!;
  // }
  //
  // Future<List<T>> call2<T>({
  //   required String name,
  //   ApiRequest? apiRequest,
  //   required JsonConstructor<T> fromJson,
  //   Map<String, dynamic>? namedPathVariable,
  //   Map<String, dynamic>? headers,
  // }) async {
  //   final apiCall = _map[name];
  //
  //   if(apiCall == null) {
  //     throw Exception("해당 이름의 api가 존재하지 않습니다.");
  //   }
  //
  //   return (await _call<List<T>, T>(apiCall, apiRequest, ListApiResponse.fromJson, fromJson, namedPathVariable, headers));
  // }

  void _constituteUrl(ApiPath apiPath, String parentUrl) {

    String url = _appendUrl(parentUrl, apiPath.isPathVariable ? "{${apiPath.name ?? ""}}" : apiPath.name!);

    for(ApiPath sub in apiPath.subs) {
      _constituteUrl(sub, url);
    }

    if(apiPath.fetches.isEmpty) return;

    for(final apiFetch in apiPath.fetches) {
      apiFetch.url = url;
    }
  }

  void _registerApiFetch(ApiPath apiPath) {

    if(apiPath.fetches.isNotEmpty) {
      for(final apiFetch in apiPath.fetches) {
        String key = apiFetch.name;
        if(_map.containsKey(key)) {
          throw Exception("기존에 있는 메소드 이름입니다. : $key");
        }

        _map[key] = apiFetch;
      }
    }

    for(ApiPath apiPath in apiPath.subs) {
      _registerApiFetch(apiPath);
    }
  }

  String _appendUrl(String parentUrl, String subUrl) {
    while(parentUrl.endsWith("/")) {
      parentUrl = parentUrl.substring(0, parentUrl.length - 1);
    }
    while(subUrl.startsWith("/")) {
      subUrl.substring(1, subUrl.length);
    }
    while(subUrl.endsWith("/")) {
      subUrl.substring(0, subUrl.length - 1);
    }

    if(parentUrl.isEmpty || subUrl.isEmpty) {
      throw Exception("(parentUrl, subUrl) = ($parentUrl, $subUrl)");
    }

    return "$parentUrl/$subUrl";
  }
}

class ApiPath {
  final String? name;
  final List<ApiPath> subs;
  final List<ApiFetch> fetches;
  final bool isPathVariable;

  ApiPath({this.subs = const [], this.fetches = const [], this.isPathVariable = false, this.name}) {
    assert(name != null || (isPathVariable && name == null));
  }

}


enum MethodType {
  get("GET"),
  post("POST"),
  put("PUT"),
  delete("DELETE"),
  create("CREATE");

  const MethodType(this.name);
  final String name;
}

class ApiFetch {
  late final String url;
  final String name;
  final MethodType methodType;
  final ApiMock? mock;

  ApiFetch({required this.name, required this.methodType, this.mock});

}

abstract class ApiRequest {
  late final Map<String, dynamic> data;

  String toString() {
    return data.entries.map((e) => "${e.key}=${e.value}").join("&");
  }
}

class RequestParam extends ApiRequest {

  RequestParam();

  RequestParam.fromJson(Map<String, dynamic> json) {
    data = json;
  }
}

class RequestBody extends ApiRequest {

  RequestBody();

  RequestBody.fromJson(Map<String, dynamic> json) {
    data = json;
  }
}

// request param - (key, value)
// request body  - Map<String, dynamic>
// path variable - value

class ApiMock {
  final String? defaultKey;
  final String? Function(Map<String, dynamic>? pathVariable, RequestParam? requestParam, RequestBody? requestBody)? keyFrom;
  final Map<String, String>? data;

  const ApiMock({
    this.defaultKey,
    this.keyFrom,
    this.data,
  });
}
