class LinkModel {
  const LinkModel({
    required this.key,
    required this.name,
    this.icon,
    required this.url,
    this.description,
    required this.index,
  });

  final String key;
  final String name;
  final String? icon;
  final String url;
  final String? description;
  final int index;

  LinkModel copyWith({
    String? key,
    String? name,
    String? icon,
    String? url,
    String? description,
    int? index,
  }) {
    return LinkModel(
      key: key ?? this.key,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      url: url ?? this.url,
      description: description ?? this.description,
      index: index ?? this.index,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'name': name,
      'icon': icon,
      'url': url,
      'description': description,
      'index': index,
    };
  }

  factory LinkModel.fromJson(Map<String, dynamic> map) {
    return LinkModel(
      key: map['key'] as String,
      name: map['name'] as String,
      icon: map['icon'] != null ? map['icon'] as String : null,
      url: map['url'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      index: map['index'] as int,
    );
  }
}

class CategoryModel {
  const CategoryModel({
    required this.key,
    required this.name,
    this.description,
    required this.icon,
    required this.index,
    this.links = const <LinkModel>[],
  });

  final String key;
  final String name;
  final String? description;
  final String icon;
  final int index;
  final List<LinkModel> links;

  CategoryModel copyWith({
    String? key,
    String? name,
    String? description,
    String? icon,
    int? index,
    List<LinkModel>? links,
  }) {
    return CategoryModel(
      key: key ?? this.key,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      index: index ?? this.index,
      links: links ?? this.links,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'key': key,
      'name': name,
      'description': description,
      'icon': icon,
      'index': index,
      'links': links.map((x) => x.toJson()).toList(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> map) {
    return CategoryModel(
      key: map['key'] as String,
      name: map['name'] as String,
      description:
          map['description'] != null ? map['description'] as String : null,
      icon: map['icon'] as String,
      index: map['index'] as int,
      links: List<LinkModel>.from(
        (map['links'] as List<dynamic>).map<LinkModel>(
          (x) => LinkModel.fromJson(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}
