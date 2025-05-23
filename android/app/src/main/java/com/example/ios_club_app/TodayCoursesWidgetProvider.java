package com.example.ios_club_app;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;
import android.content.Intent;
import android.net.Uri;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.util.ArrayList;
import java.util.List;

public class TodayCoursesWidgetProvider extends AppWidgetProvider {
    private static final String FLUTTER_PREFS_PREFIX = "flutter.";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        // 1. 从SharedPreferences获取数据
        SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        String title = prefs.getString(FLUTTER_PREFS_PREFIX + "title", "今日课表");
        String date = prefs.getString(FLUTTER_PREFS_PREFIX + "date", "");
        String coursesJson = "[{\"title\":\"测试课\",\"time\":\"1-2节\",\"location\":\"教室1\"}]"; //prefs.getString(FLUTTER_PREFS_PREFIX + "courses", "[]");



        // 2. 设置基础视图
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.today_courses_widget);
        views.setTextViewText(R.id.widget_title, title);
        views.setTextViewText(R.id.widget_date, date);

        // 3. 设置ListView适配器
        Intent intent = new Intent(context, CourseWidgetService.class);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        intent.putExtra("courses_data", coursesJson);
        intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));

        // 4. Android 12+ 需要显式设置RemoteViewsFactory
        views.setRemoteAdapter(R.id.widget_courses_list, intent);

        // 5. 设置空视图
        views.setEmptyView(R.id.widget_courses_list, R.id.empty_view);

        // 6. 更新小组件
        appWidgetManager.updateAppWidget(appWidgetId, views);
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_courses_list);
    }

    public static class CourseWidgetService extends RemoteViewsService {
        @Override
        public RemoteViewsFactory onGetViewFactory(Intent intent) {
            return new CourseRemoteViewsFactory(this.getApplicationContext(), intent);
        }
    }

    public static class CourseRemoteViewsFactory implements RemoteViewsService.RemoteViewsFactory {
        private final Context context;
        private final String coursesJson;
        private List<Course> courses = new ArrayList<>();

        public CourseRemoteViewsFactory(Context context, Intent intent) {
            this.context = context;
            this.coursesJson = intent.getStringExtra("courses_data");
        }

        @Override
        public void onCreate() {
            parseCoursesData();
        }

        @Override
        public void onDataSetChanged() {
            parseCoursesData();
        }

        private void parseCoursesData() {
            try {
                JSONArray jsonArray = new JSONArray(coursesJson);
                courses.clear();

                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject courseObj = jsonArray.getJSONObject(i);
                    courses.add(new Course(
                            courseObj.getString("title"),
                            courseObj.getString("time"),
                            courseObj.getString("location")
                    ));
                }
            } catch (JSONException e) {
                e.printStackTrace();
                courses.add(new Course("数据解析错误", "", ""));
            }

            if (courses.isEmpty()) {
                courses.add(new Course("今天没有课程", "", ""));
            }
        }

        @Override
        public RemoteViews getViewAt(int position) {
            if (position >= courses.size()) return null;

            Course course = courses.get(position);
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.course_item);

            // 设置课程信息
            views.setTextViewText(R.id.course_title, course.title);
            views.setTextViewText(R.id.course_time, course.time);
            views.setTextViewText(R.id.course_location, course.location);

            // 设置点击意图（可选）
//            Intent fillInIntent = new Intent();
//            fillInIntent.putExtra("course_position", position);
//            views.setOnClickFillInIntent(R.id.course_item_root, fillInIntent);

            return views;
        }

        @Override
        public int getCount() {
            return courses.size();
        }

        @Override
        public void onDestroy() {
            courses.clear();
        }

        @Override
        public RemoteViews getLoadingView() {
            return null;
        }

        @Override
        public int getViewTypeCount() {
            return 1;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @Override
        public boolean hasStableIds() {
            return true;
        }
    }

    // 课程数据模型
    private static class Course {
        final String title;
        final String time;
        final String location;

        Course(String title, String time, String location) {
            this.title = title;
            this.time = time;
            this.location = location;
        }
    }
}