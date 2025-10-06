import 'package:dio/dio.dart';
import 'network_exception.dart';

class EduApiClient {
  static const String baseUrl = 'https://xauatapi.xauat.site';
  final Dio _dio;

  EduApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: 'application/json',
    );
  }

  /// 获取学期信息
  Future<String> getSemester(String studentId, String cookie) async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Cookie': cookie,
        'xauat': cookie,
      };

      final response = await _dio.get(
        '/Score/Semester',
        queryParameters: {'studentId': studentId},
        options: Options(headers: headers),
      );

      return response.data.toString();
    } on DioException catch (e) {
      _handleDioError(e);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', e.response?.statusCode ?? -1);
    }
  }

  /// 获取课程信息
  Future<String> getCourse(String studentId, String cookie) async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Cookie': cookie,
        'xauat': cookie,
      };

      final response = await _dio.get(
        '/Course',
        queryParameters: {'studentId': studentId},
        options: Options(headers: headers),
      );

      return response.data.toString();
    } on DioException catch (e) {
      _handleDioError(e);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', e.response?.statusCode ?? -1);
    }
  }

  /// 获取成绩信息
  Future<String> getScore(
      String studentId, String semester, String cookie) async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Cookie': cookie,
        'xauat': cookie,
      };

      final response = await _dio.get(
        '/Score',
        queryParameters: {
          'studentId': studentId,
          'semester': semester,
        },
        options: Options(headers: headers),
      );

      return response.data.toString();
    } on DioException catch (e) {
      _handleDioError(e);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', e.response?.statusCode ?? -1);
    }
  }

  /// 获取考试信息
  Future<String> getExam(String studentId, String cookie) async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Cookie': cookie,
        'xauat': cookie,
      };

      final response = await _dio.get(
        '/Exam',
        queryParameters: {'studentId': studentId},
        options: Options(headers: headers),
      );

      return response.data.toString();
    } on DioException catch (e) {
      _handleDioError(e);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', e.response?.statusCode ?? -1);
    }
  }

  /// 获取学生信息完成度
  Future<String> getInfoCompletion(String cookie) async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Cookie': cookie,
        'xauat': cookie,
      };

      final response = await _dio.get(
        '/Info/Completion',
        options: Options(headers: headers),
      );

      return response.data.toString();
    } on DioException catch (e) {
      _handleDioError(e);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', e.response?.statusCode ?? -1);
    }
  }

  /// 获取本学期成绩
  Future<String> getThisSemester(String cookie) async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Cookie': cookie,
        'xauat': cookie,
      };

      final response = await _dio.get(
        '/Score/ThisSemester',
        options: Options(headers: headers),
      );

      return response.data.toString();
    } on DioException catch (e) {
      _handleDioError(e);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', e.response?.statusCode ?? -1);
    }
  }

  /// 获取培养方案
  Future<String> getProgram(String studentId, String cookie) async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Cookie': cookie,
        'xauat': cookie,
      };

      final response = await _dio.get(
        '/Program',
        queryParameters: {'id': studentId},
        options: Options(headers: headers),
      );

      return response.data.toString();
    } on DioException catch (e) {
      _handleDioError(e);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', e.response?.statusCode ?? -1);
    }
  }

  /// 获取培养方案字典
  Future<String> getProgramDic(String studentId, String cookie) async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'Cookie': cookie,
        'xauat': cookie,
      };

      final response = await _dio.get(
        '/Program/GetDic',
        queryParameters: {'id': studentId},
        options: Options(headers: headers),
      );

      return response.data.toString();
    } on DioException catch (e) {
      _handleDioError(e);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', e.response?.statusCode ?? -1);
    }
  }

  void _handleDioError(DioException e) {
    if (e.response != null) {
      _handleErrorResponse(e.response!.statusCode ?? -1, e.response!.data?.toString() ?? '');
    } else {
      throw NetworkException('网络请求失败: ${e.message}', -1);
    }
  }

  void _handleErrorResponse(int statusCode, String body) {
    switch (statusCode) {
      case 401:
        throw AuthenticationException('认证失败');
      case 403:
        throw AuthorizationException('权限不足');
      case 404:
        throw NotFoundException('资源未找到');
      case 500:
        throw ServerException('服务器内部错误');
      default:
        throw NetworkException('请求失败: $body', statusCode);
    }
  }

  void dispose() {
    _dio.close();
  }
}