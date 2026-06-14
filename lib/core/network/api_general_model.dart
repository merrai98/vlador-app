class ApiGeneralModel<T> {
  bool? status;
  int? code;
  T? data;
  String? errorMessage;
  int? totalCount;

  ApiGeneralModel({
    this.status,
    this.code,
    this.data,
    this.errorMessage,
    this.totalCount,
  });

  ApiGeneralModel.fromJson(Map<String, dynamic> json, {T? model}) {
    _parse(json, model: model);
  }

  ApiGeneralModel.fromJsonList(Map<String, dynamic> json, {List? models}) {
    _parse(json, model: models as T?);
  }

  ApiGeneralModel.fromJsonData(Map<String, dynamic> json, {T? model}) {
    _parse(json, model: model);
  }

  void _parse(Map<String, dynamic> json, {T? model}) {
    // Handling Odoo JSON-RPC structure as provided:
    // { "jsonrpc": "2.0", "result": { "state_code": 200, "description": "...", "data": [...] } }
    if (json.containsKey('result')) {
      final result = json['result'];
      if (result is Map<String, dynamic>) {
        code = result['state_code'];
        errorMessage = result['description'] ?? result['message'] ?? "";
        
        if (result.containsKey('success')) {
          status = result['success'];
        } else {
          status = code == 200 || code == 350;
        }
        
        data = model ?? result['data'] ?? result;
      } else {
        // Fallback for non-map result
        status = true;
        data = model ?? result;
      }
    } else if (json.containsKey('error')) {
      // Handling standard JSON-RPC error structure
      final error = json['error'];
      status = false;
      code = error['code'] ?? -1;
      errorMessage = error['message'] ?? "JSON-RPC Error";
      data = model;
    } else {
      // Fallback for traditional API formats (Status, Code, Data, ErrorMessage)
      status = json['Status'] ?? json['status'] ?? false;
      code = json['Code'] ?? json['code'];
      errorMessage = json['ErrorMessage'] ??
          json['errorMessage'] ??
          json['message'] ??
          "";
      data = model ?? json['Data'] ?? json['data'];
    }
    totalCount = json['TotalCount'] ?? json['totalCount'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Status'] = status;
    map['Code'] = code;
    map['Data'] = data;
    map['ErrorMessage'] = errorMessage;
    map['TotalCount'] = totalCount;
    return map;
  }
}
