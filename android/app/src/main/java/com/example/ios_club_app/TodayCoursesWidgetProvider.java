package com.example.ios_club_app;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;
import android.content.Intent;
import android.net.Uri;
import android.view.View;
import org.json.JSONArray;
import org.json.JSONException;
import java.util.ArrayList;

public class TodayCoursesWidgetProvider extends AppWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
        String title = prefs.getString("flutter.title", "今日课表");
        String date = prefs.getString("flutter.date", "");
        String coursesJson = prefs.getString("flutter.courses", "[]");

        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.today_courses_widget);
        views.setTextViewText(R.id.widget_title, title);
        views.setTextViewText(R.id.widget_date, date);

        // 设置ListView的适配器
        Intent intent = new Intent(context, CourseWidgetService.class);
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
        intent.putExtra("courses_data", coursesJson);
        intent.setData(Uri.parse(intent.toUri(Intent.URI_INTENT_SCHEME)));
        views.setRemoteAdapter(R.id.widget_courses_list, intent);

        // 更新小组件
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    public static class CourseWidgetService extends RemoteViewsService {
        @Override
        public RemoteViewsFactory onGetViewFactory(Intent intent) {
            return new CourseRemoteViewsFactory(this.getApplicationContext(), intent);
        }
    }

    public static class CourseRemoteViewsFactory implements RemoteViewsService.RemoteViewsFactory {
        private Context context;
        private ArrayList<String> courses = new ArrayList<>();
        private String coursesJson;

        public CourseRemoteViewsFactory(Context context, Intent intent) {
            this.context = context;
            this.coursesJson = intent.getStringExtra("courses_data");
        }

        @Override
        public void onCreate() {
            // 解析课程数据
            try {
                JSONArray jsonArray = new JSONArray(coursesJson);

                for (int i = 0; i < jsonArray.length(); i++) {
                    courses.add(jsonArray.getString(i));
                }

                if (courses.isEmpty()) {
                    courses.add("今天没有课了");
                }
            } catch (JSONException e) {
                e.printStackTrace();
                courses.add("今天没有课了");
            }
        }

        @Override
        public void onDataSetChanged() {
            // 数据更新时调用
        }

        @Override
        public void onDestroy() {
            courses.clear();
        }

        @Override
        public int getCount() {
            return courses.size();
        }

        @Override
        public RemoteViews getViewAt(int position) {
            RemoteViews rv = new RemoteViews(context.getPackageName(), R.layout.course_item);
            rv.setTextViewText(R.id.course_text, courses.get(position));
            return rv;
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
}
