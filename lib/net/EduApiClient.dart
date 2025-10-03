import 'package:http/http.dart' as http;
import 'package:ios_club_app/net/NetworkException.dart';

class EduApiClient {
  static const String baseUrl = 'https://xauatapi.xauat.site';
  final http.Client _client;

  EduApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// 获取学期信息
  Future<String> getSemester(String studentId, String cookie) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'xauat': cookie,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/Score/Semester?studentId=$studentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response.statusCode, response.body);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', response.statusCode);
    }
  }

  /// 获取课程信息
  Future<String> getCourse(String studentId, String cookie) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'xauat': cookie,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/Course?studentId=$studentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response.statusCode, response.body);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', response.statusCode);
    }
  }

  /// 获取成绩信息
  Future<String> getScore(
      String studentId, String semester, String cookie) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'xauat': cookie,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/Score?studentId=$studentId&semester=$semester'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response.statusCode, response.body);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', response.statusCode);
    }
  }

  /// 获取考试信息
  Future<String> getExam(String studentId, String cookie) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'xauat': cookie,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/Exam?studentId=$studentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response.statusCode, response.body);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', response.statusCode);
    }
  }

  /// 获取学生信息完成度
  Future<String> getInfoCompletion(String cookie) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'xauat': cookie,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/Info/Completion'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response.statusCode, response.body);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', response.statusCode);
    }
  }

  /// 获取本学期成绩
  Future<String> getThisSemester(String cookie) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'xauat': cookie,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/Score/ThisSemester'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response.statusCode, response.body);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', response.statusCode);
    }
  }

  /// 获取培养方案
  Future<String> getProgram(String studentId, String cookie) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'xauat': cookie,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/Program?id=$studentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response.statusCode, response.body);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', response.statusCode);
    }
  }

  /// 获取培养方案字典
  Future<String> getProgramDic(String studentId, String cookie) async {
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookie,
      'xauat': cookie,
    };

    final response = await _client.get(
      Uri.parse('$baseUrl/Program/GetDic?id=$studentId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      _handleErrorResponse(response.statusCode, response.body);
      // 添加返回语句以避免编译错误
      throw NetworkException('未知错误', response.statusCode);
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
    _client.close();
  }
}
