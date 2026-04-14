import 'dart:convert';

class CurlUtils {
  /// Build curl command từ request
  static String build({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    final curl = StringBuffer();

    curl.write("curl -X $method '$url'");

    // headers
    headers?.forEach((key, value) {
      curl.write(" -H '$key: $value'");
    });

    // body
    if (body != null) {
      final encodedBody = body is String ? body : jsonEncode(body);
      curl.write(" -d '$encodedBody'");
    }

    return curl.toString();
  }

  /// Helper riêng cho PATCH
  static String patch({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    return build(method: 'PATCH', url: url, headers: headers, body: body);
  }

  /// Helper cho POST
  static String post({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    return build(method: 'POST', url: url, headers: headers, body: body);
  }

  /// Helper cho DELETE
  static String delete({
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    return build(method: 'DELETE', url: url, headers: headers, body: body);
  }
}
