class BusModel {
  List<BusItem> records;
  final int total;

  BusModel({
    required this.records,
    required this.total,
  });

  // 从JSON构造方法
  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      records: (json['records'] as List)
          .map((item) => BusItem.fromJson(item))
          .toList(),
      total: json['total'] as int,
    );
  }

  // 转换为JSON方法
  Map<String, dynamic> toJson() => {
        'records': records.map((item) => item.toJson()).toList(),
        'total': total,
      };
}

class BusItem {
  final String lineName;
  final String description;
  final String departureStation;
  final String arrivalStation;
  String runTime;
  String arrivalStationTime;
  String totalTime = '';

  BusItem({
    required this.lineName,
    required this.description,
    required this.departureStation,
    required this.arrivalStation,
    required this.runTime,
    required this.arrivalStationTime,
  }) {
    if (runTime.isNotEmpty) {
      runTime = runTime.substring(0, runTime.lastIndexOf(':'));
    }
    if (arrivalStationTime.isNotEmpty) {
      arrivalStationTime = arrivalStationTime.substring(1);
      var s = arrivalStationTime.split(':');
      arrivalStationTime = '${s[0]}小时 ${s[1]}分钟';
      if (s.length == 2) {
        int h = int.parse(s[0]);
        int m = int.parse(s[1]);
        var runTimeSplit = runTime.split(':');
        h += int.parse(runTimeSplit[0]);
        m += int.parse(runTimeSplit[1]);
        if (m >= 60) {
          m -= 60;
          h++;
        }
        totalTime = '$h:${m < 10 ? '0$m' : m}';
      }
    }
  }

  // 从JSON构造方法
  factory BusItem.fromJson(Map<String, dynamic> json) {
    return BusItem(
      lineName: json['lineName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      departureStation: json['departureStation'] as String? ?? '',
      arrivalStation: json['arrivalStation'] as String? ?? '',
      runTime: json['runTime'] as String? ?? '',
      arrivalStationTime: json['arrivalStationTime'] as String? ?? '',
    );
  }

  // 转换为JSON方法
  Map<String, dynamic> toJson() => {
        'lineName': lineName,
        'description': description,
        'departureStation': departureStation,
        'arrivalStation': arrivalStation,
        'runTime': runTime,
        'arrivalStationTime': arrivalStationTime,
      };
}
