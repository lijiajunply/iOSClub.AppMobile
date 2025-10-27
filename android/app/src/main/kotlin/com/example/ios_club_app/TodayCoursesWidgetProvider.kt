package com.example.ios_club_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class TodayCoursesWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        // 处理小部件更新事件
        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val widgetData = HomeWidgetPlugin.getData(context)
            
            // 解析课程数据
            val coursesJson = widgetData.getString("flutter.courses", null) ?: "[]"
            
            // 获取所有小部件ID
            val appWidgetIds = intent.getIntArrayExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS)
            if (appWidgetIds != null) {
                for (appWidgetId in appWidgetIds) {
                    // 通知数据变更
                    appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_courses_list)
                }
            }
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.today_courses_widget)

        try {
            views.setTextViewText(R.id.widget_title, "今日课表")

            // 解析课程数据
            val coursesJson = widgetData.getString("flutter.courses", null) ?: "[]"
            val courses = parseCourses(coursesJson)

            if (courses.isEmpty()) {
                // 显示空状态
                views.setViewVisibility(R.id.widget_courses_list, android.view.View.GONE)
                views.setViewVisibility(R.id.empty_view, android.view.View.VISIBLE)
            } else {
                // 显示课程列表
                views.setViewVisibility(R.id.empty_view, android.view.View.GONE)
                views.setViewVisibility(R.id.widget_courses_list, android.view.View.VISIBLE)

                // 设置RemoteViewsService
                val intent = Intent(context, CourseListRemoteViewsService::class.java)
                intent.putExtra("courses", coursesJson)
                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                views.setRemoteAdapter(R.id.widget_courses_list, intent)
            }

            // 设置点击打开应用
            val pendingIntent = PendingIntent.getActivity(
                context, 0,
                Intent(context, MainActivity::class.java),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_title, pendingIntent)

        } catch (e: Exception) {
            e.printStackTrace()
            // 发生错误时显示默认状态
            views.setTextViewText(R.id.widget_title, "课表加载失败")
            views.setViewVisibility(R.id.widget_courses_list, android.view.View.GONE)
            views.setViewVisibility(R.id.empty_view, android.view.View.VISIBLE)
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
        // 总是通知数据改变，以确保列表更新
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_courses_list)
    }

    private fun getCurrentDate(): String {
        val formatter = SimpleDateFormat("MM月 dd日", Locale.getDefault())
        return formatter.format(Date())
    }

    private fun parseCourses(jsonString: String): List<Course> {
        val courses = mutableListOf<Course>()
        try {
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                val courseObj = jsonArray.getJSONObject(i)
                courses.add(Course(
                    title = courseObj.optString("title", ""),
                    time = courseObj.optString("time", ""),
                    location = courseObj.optString("location", ""),
                    teacher = courseObj.optString("teacher", "")
                ))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return courses
    }

    data class Course(
        val title: String,
        val time: String,
        val location: String,
        val teacher: String
    )
}