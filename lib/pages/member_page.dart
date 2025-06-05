import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Services/club_service.dart';
import '../widgets/BlurWidget.dart';
import '../widgets/empty_widget.dart';
import '../widgets/memberPages/member_data_page.dart';

class MemberPage extends StatelessWidget {
  const MemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('社团详情'),
        flexibleSpace: BlurWidget(child: SizedBox.expand()),
      ),
      body: FutureBuilder(
        future: ClubService.getMemberInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          final identity = data['memberData']['identity'] ?? 'Member';
          final memberData = data['memberData'];
          final infoData = data['info'];
          String role = _mapIdentityToRole(identity);

          final info = Column(
            children: [
              Image(
                  image: AssetImage('assets/${memberData['gender']}生.png'),
                  height: isTablet ? 200 : 120),
              Text(
                memberData['userName'],
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('ID: ${memberData['userId']}'),
              SizedBox(height: 8),
              Text('身份: $role'),
            ],
          );

          List<Widget> task = [];
          if (identity != 'Member') {
            task = [
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      '我的任务',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if ((infoData['tasks'] as List<dynamic>).isNotEmpty)
                      ...infoData['tasks'].map((department) {
                        return _buildDepartmentItem(
                            department['title'], department['description']);
                      }).toList(),
                    if ((infoData['tasks'] as List<dynamic>).isEmpty)
                      Column(
                        children: [
                          EmptyWidget(),
                          Center(
                              child: Text(
                            '您的任务都已经完成了',
                            style: TextStyle(fontSize: 20),
                          ))
                        ],
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      '我的项目',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if ((infoData['projects'] as List<dynamic>).isNotEmpty)
                      ...infoData['projects'].map((department) {
                        return _buildDepartmentItem(
                            department['title'], department['description']);
                      }).toList(),
                    if ((infoData['projects'] as List<dynamic>).isEmpty)
                      Column(
                        children: [
                          EmptyWidget(),
                          Center(
                              child: Text(
                            '您的项目都已经完成了',
                            style: TextStyle(fontSize: 20),
                          ))
                        ],
                      ),
                  ],
                ),
              ),
            ];
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // 基本信息
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: isTablet
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: info),
                              Expanded(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: task,
                              ))
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [info],
                          ),
                  ),
                ),

                if (!isTablet) SizedBox(height: 16),

                if (!isTablet)
                  ...task.map((item) => Column(
                        children: [
                          SizedBox(
                              width: double.infinity,
                              child: Card(
                                child: item,
                              )),
                          SizedBox(height: 16)
                        ],
                      )),

                if (identity != 'Member' && identity != 'Department')
                  // 部门卡片
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 16, bottom: 8),
                          child: Text(
                            '社团部门',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...infoData['departments'].map((department) {
                          return _buildDepartmentItem(
                              department['name'], department['description']);
                        }).toList(),
                      ],
                    ),
                  ),

                if (identity != 'Member' && identity != 'Department')
                  SizedBox(height: 16),

                if (identity != 'Member' && identity != 'Department')
                  // 数据中心卡片
                  Card(
                      child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '数据中心',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildDataItem('当前成员', '${infoData['total']}',
                                      onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return MemberDataPage();
                                    }));
                                  }),
                                  _buildDataItem(
                                      '部员数量', '${infoData['staffsCount']}'),
                                  _buildDataItem('项目数量',
                                      '${(infoData['projects'] as List<dynamic>).length}'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildDataItem('任务数量',
                                      '${(infoData['tasks'] as List<dynamic>).length}'),
                                  _buildDataItem('资源数量',
                                      '${(infoData['resources'] as List<dynamic>).length}'),
                                  _buildDataItem('部门数量',
                                      '${(infoData['departments'] as List<dynamic>).length}'),
                                ],
                              ),
                            ],
                          ))),

                if (identity != 'Member' || identity != 'Department')
                  const SizedBox(height: 16),

                if (identity != 'Member' || identity != 'Department')
                  SizedBox(
                    width: double.infinity, // 让容器占据所有可用宽度
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 16, bottom: 8),
                            child: Text(
                              '社团资源',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if ((infoData['resources'] as List<dynamic>)
                              .isNotEmpty)
                            ...infoData['resources'].map((department) {
                              return _buildDepartmentItem(
                                  department['name'], department['description'],
                                  rightWidget: Icon(Icons.open_in_new),
                                  onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(department['name']),
                                        content:
                                            Text(department['description']),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('关闭'))
                                        ],
                                      );
                                    });
                              });
                            }).toList(),
                          if ((infoData['resources'] as List<dynamic>).isEmpty)
                            Column(
                              children: [
                                EmptyWidget(),
                                Center(
                                    child: Text(
                                  '当前没有资源',
                                  style: TextStyle(fontSize: 20),
                                ))
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 身份映射
  String _mapIdentityToRole(String identity) {
    switch (identity) {
      case 'Founder':
        return '创始人';
      case 'President':
        return '社长/副社长/团支书';
      case 'Minister':
        return '部长/副部长';
      case 'Department':
        return '部员成员';
      default:
        return '普通成员';
    }
  }

  // 部门项构建
  Widget _buildDepartmentItem(String title, String subtitle,
      {GestureTapCallback? onTap, Widget? rightWidget}) {
    return ListTile(
        title: Text(title, style: TextStyle(fontSize: 16)),
        subtitle:
            Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey)),
        //trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        trailing: rightWidget);
  }

  // 数据项构建
  Widget _buildDataItem(String label, String value,
      {GestureTapCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
