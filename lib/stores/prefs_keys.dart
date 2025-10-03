/// SharedPreferences 键统一管理
class PrefsKeys {
  /// 用户相关
  static const String USERNAME = 'username';
  static const String PASSWORD = 'password';
  static const String USER_DATA = 'user_data';
  static const String LAST_FETCH_TIME = 'last_fetch_time';

  /// 课程相关
  static const String COURSE_DATA = 'course_data';
  static const String IGNORE_DATA = 'ignore_data';

  /// 学期相关
  static const String SEMESTER_DATA = 'semester_data';
  static const String SEMESTER_TIME = 'semester_time';

  /// 成绩相关
  static const String ALL_SCORE_DATA = 'all_score_data';
  static const String LAST_SCORE_TIME = 'last_Score_time';
  static const String THIS_SEMESTER_DATA = 'this_semester_data';

  /// 考试相关
  static const String EXAM_DATA = 'exam_data';
  static const String EXAM_TIME = 'exam_time';

  /// 时间相关
  static const String TIME_DATA = 'time_data';
  static const String TIME_LAST_UPDATED = 'time_last_updated';

  /// 信息完成度相关
  static const String INFO_DATA = 'info_data';
  static const String INFO_DATA_TIME = 'info_data_time';

  /// 通知相关
  static const String NOTIFICATION_TIME = 'notification_time';
  static const String IS_REMIND = 'is_remind';
  static const String LAST_REMIND_DATE = 'last_remind_date';
  static const String IS_SHOW_TOMORROW = 'is_show_tomorrow';

  /// 社团相关
  static const String MEMBER_DATA = 'member_data';
  static const String MEMBER_JWT = 'member_jwt';
  static const String CLUB_NAME = 'club_name';
  static const String CLUB_ID = 'club_id';

  /// 待办事项相关
  static const String TODO_DATA = 'todo_data';
  static const String IS_UPDATE_CLUB = 'is_update_club';

  /// 电费相关
  static const String ELECTRICITY_URL = 'electricity_url';
  static const String TILES = 'tiles';

  /// 支付相关
  static const String PAYMENT_NUM = 'payment_num';

  /// 更新相关
  static const String UPDATE_IGNORED = 'update_ignored';

  /// 页面相关
  static const String PAGE_DATA = 'page_data';
}