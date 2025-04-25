class TotalData {
  final String name;
  final double actual;
  final double full;

  TotalData({
    required this.name,
    required this.actual,
    required this.full,
  });

  factory TotalData.fromJson(Map<String, dynamic> json) {
    return TotalData(
      name: json['name'],
      actual: json['actual']?.toDouble() ?? 0.0,
      full: json['full']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'actual': actual,
    'full': full,
  };
}

// 主数据模型类
class InfoModel {
  final String type;
  final TotalData total;
  final List<TotalData> other;

  InfoModel({
    required this.type,
    required this.total,
    required this.other,
  });

  // 从JSON Map构建实例的工厂构造函数
  factory InfoModel.fromJson(Map<String, dynamic> json) {
    return InfoModel(
      type: json['type'],
      total: TotalData.fromJson(json['total']),
      other: List<TotalData>.from(
        (json['other'] as List)
            .map((item) => TotalData.fromJson(item)),
      ),
    );
  }

  // 转换为JSON格式的Map
  Map<String, dynamic> toJson() => {
    'type': type,
    'total': total.toJson(),
    'other': other.map((item) => item.toJson()).toList(),
  };
}