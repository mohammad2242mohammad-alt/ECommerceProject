class ApiResponse<T> {
  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  final bool success;
  final String? message;
  final T? data;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromData,
  }) {
    return ApiResponse<T>(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: fromData != null && json['data'] != null
          ? fromData(json['data'])
          : json['data'] as T?,
    );
  }
}
