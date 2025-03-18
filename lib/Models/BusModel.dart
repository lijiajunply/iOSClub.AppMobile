class BusModel {
  final List<BusItem> records;
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
  final String runTime;
  final String arrivalStationTime;

  BusItem({
    required this.lineName,
    required this.description,
    required this.departureStation,
    required this.arrivalStation,
    required this.runTime,
    required this.arrivalStationTime,
  });

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