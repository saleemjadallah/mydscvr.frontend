class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });

  bool get isSuccess => success;
  String? get error => message;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      message: json['message'],
      statusCode: json['status_code'],
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) {
    return {
      'success': success,
      'data': data != null ? toJsonT(data as T) : null,
      'message': message,
      'status_code': statusCode,
      'errors': errors,
    };
  }
} 