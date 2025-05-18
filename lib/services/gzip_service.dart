import 'dart:convert';
import 'package:archive/archive.dart';

class GzipService {
  static Future<String> compress(String data) async {
    //先来转换一下
    List<int> stringBytes = utf8.encode(data);
    //然后使用 gzip 压缩
    List<int> gzipBytes = GZipEncoder().encode(stringBytes);
    //然后再编码一下进行网络传输
    String compressedString = base64UrlEncode(gzipBytes);
    return compressedString;
  }

  static Future<String> decompress(String data) async {
    //先来解码一下
    List<int> stringBytes = base64Url.decode(data);
    //然后使用 gzip 压缩
    List<int> gzipBytes = GZipDecoder().decodeBytes(stringBytes);
    //然后再编码一下
    String compressedString = utf8.decode(gzipBytes);
    return compressedString;
  }
}
