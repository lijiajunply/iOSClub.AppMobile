// 进度回调类型定义
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/widgets/show_club_snack_bar.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

Future<void> updateApp(
  String name, {
  Function(int downloaded, int total, double progress, String speed)?
      onProgress,
}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  if (name != packageInfo.version) {
    final Uri uri = Uri.parse(
        'https://gitee.com/luckyfishisdashen/iOSClub.AppMobile/releases/download/$name/app-release.apk');

// 获取应用缓存目录
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/app-release.apk';

// 删除已存在的文件
    final file = File(filePath);
    if (file.existsSync()) {
      await file.delete();
    }

    await _downloadFileWithProgress(
      uri.toString(),
      filePath,
      onProgress: onProgress,
    );

    try {
      await OpenFile.open(filePath);
    } catch (e) {
      if (kDebugMode) {
        print('无法打开APK: $e');
      }
    }

    if (kDebugMode) {
      print('APK下载成功: $filePath');
    }
  }
}

Future<void> _downloadFileWithProgress(
  String url,
  String filePath, {
  Function(int downloaded, int total, double progress, String speed)?
      onProgress,
}) async {
  final httpClient = HttpClient();

  try {
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode == 200) {
      final contentLength = response.contentLength;
      final file = File(filePath);
      final sink = file.openWrite();

      int downloaded = 0;
      final stopwatch = Stopwatch()..start();
      int lastTime = 0;
      int lastDownloaded = 0;

// 创建一个完成器来等待下载完成
      final Completer<void> completer = Completer<void>();

// 监听数据流
      response.listen(
        (List<int> chunk) {
          sink.add(chunk);
          downloaded += chunk.length;

          final progress = contentLength > 0 ? downloaded / contentLength : 0.0;

// 计算下载速度
          final currentTime = stopwatch.elapsedMilliseconds;
          String speedText = '';

          if (currentTime - lastTime >= 500) {
            // 每500ms更新一次速度
            if (lastTime > 0) {
              final timeDiff = currentTime - lastTime;
              final bytesDiff = downloaded - lastDownloaded;
              final speed = (bytesDiff * 1000) / timeDiff; // bytes per second
              speedText = '${_formatSpeed(speed.round())}/s';
            }
            lastTime = currentTime;
            lastDownloaded = downloaded;
          }

// 调用进度回调
          onProgress?.call(downloaded, contentLength, progress, speedText);
        },
        onDone: () async {
          await sink.close();
          stopwatch.stop();
          completer.complete();
        },
        onError: (error) async {
          await sink.close();
          stopwatch.stop();
          completer.completeError('下载失败: $error');
        },
      );

// 等待下载完成
      await completer.future;
    } else {
      throw '下载失败，状态码: ${response.statusCode}';
    }
  } finally {
    httpClient.close();
  }
}

String _formatSpeed(int bytesPerSecond) {
  if (bytesPerSecond < 1024) return '${bytesPerSecond}B';
  if (bytesPerSecond < 1024 * 1024) {
    return '${(bytesPerSecond / 1024).toStringAsFixed(1)}KB';
  }
  return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)}MB';
}

class DownloadProgress {
  final double progress;
  final String progressText;
  final String sizeText;
  final String speedText;

  DownloadProgress({
    required this.progress,
    required this.progressText,
    required this.sizeText,
    required this.speedText,
  });
}

class UpdateManager {
  static Future<void> showUpdateWithProgress(BuildContext context, String version) async {
    final ValueNotifier<DownloadProgress> progressNotifier = ValueNotifier(
      DownloadProgress(
        progress: 0.0,
        progressText: '0%',
        sizeText: '0B/0B',
        speedText: '',
      ),
    );

    // 显示进度对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ValueListenableBuilder<DownloadProgress>(
          valueListenable: progressNotifier,
          builder: (context, downloadProgress, child) {
            return AlertDialog(
              title: Text('正在下载更新 $version'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 线性进度条
                  LinearProgressIndicator(
                    value: downloadProgress.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 进度信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(downloadProgress.progressText),
                      Text(downloadProgress.sizeText),
                    ],
                  ),
                  if (downloadProgress.speedText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      downloadProgress.speedText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
              ],
            );
          },
        );
      },
    );

    try {
      // 开始下载
      await updateApp(
        version,
        onProgress: (downloaded, total, progress, speed) {
          progressNotifier.value = DownloadProgress(
            progress: progress,
            progressText: '${(progress * 100).toStringAsFixed(1)}%',
            sizeText: '${_formatBytes(downloaded)}/${_formatBytes(total)}',
            speedText: speed,
          );
        },
      );

      // 下载完成
      if (context.mounted) {
        Navigator.of(context).pop();
        showClubSnackBar(
          context,
          const Text('下载完成，正在安装...'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        showClubSnackBar(
          context,
          Text('下载失败: $e'),
        );
      }
    } finally {
      progressNotifier.dispose();
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
