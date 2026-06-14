class LoginRequestModel {
  final String jsonrpc;
  final LoginParams params;

  LoginRequestModel({
    this.jsonrpc = "2.0",
    required this.params,
  });

  Map<String, dynamic> toJson() {
    return {
      'jsonrpc': jsonrpc,
      'params': params.toJson(),
    };
  }
}

class LoginParams {
  final String login;
  final String password;

  LoginParams({
    required this.login,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'password': password,
    };
  }
}
