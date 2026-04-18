class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final dynamic error;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.error,
  });

  // Réponse réussie
  factory ApiResponse.success({
    required T data,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  // Réponse d'erreur
  factory ApiResponse.error({
    required String message,
    int? statusCode,
    dynamic error,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      error: error,
    );
  }

  @override
  String toString() {
    return 'ApiResponse{success: $success, message: $message, statusCode: $statusCode}';
  }
}
