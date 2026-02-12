class AuthResponse {
  final String accessToken;

  AuthResponse({required this.accessToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handling multiple potential structures: nested in 'token', nested in 'data', or flat
    String? token;
    if (json['token'] != null && json['token'] is Map) {
      token = json['token']['access'] as String?;
    } else if (json['data'] != null && json['data'] is Map) {
      token = json['data']['access'] as String?;
    } else {
      token = json['access'] as String?;
    }

    if (token == null) {
      throw Exception('Access token not found in response');
    }
    return AuthResponse(accessToken: token);
  }
}
