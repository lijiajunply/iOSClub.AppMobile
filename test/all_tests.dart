import 'unit/course_model_test.dart' as course_model_test;
import 'unit/score_model_test.dart' as score_model_test;
import 'unit/turnover_analyzer_test.dart' as turnover_analyzer_test;
import 'unit/course_store_test.dart' as course_store_test;
import 'widget/empty_widget_test.dart' as empty_widget_test;
import 'widget/club_card_test.dart' as club_card_test;
import 'widget/show_club_snack_bar_test.dart' as show_club_snack_bar_test;

void main() {
  // 运行所有单元测试
  course_model_test.main();
  score_model_test.main();
  turnover_analyzer_test.main();
  course_store_test.main();
  
  // 运行所有小部件测试
  empty_widget_test.main();
  club_card_test.main();
  show_club_snack_bar_test.main();
}