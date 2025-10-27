package com.example.ios_club_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import java.util.*
import android.net.Uri

class TomorrowCoursesWidgetProvider : AppWidgetProvider() {

    // 课程数据类
    data class Course(
        val title: String,
        val time: String,
        val location: String,
        val teacher: String
    )

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
            
            // 获取所有小部件ID
            val appWidgetIds = intent.getIntArrayExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS)
            if (appWidgetIds != null) {
                // 检查数据是否真正发生变化
                val widgetData = HomeWidgetPlugin.getData(context)
                val currentTodayCourses = widgetData.getString("flutter.tomorrow.courses", null) ?: "[]"
                val currentTomorrowCourses = widgetData.getString("flutter.tomorrow.tomorrowCourses", null) ?: "[]"
                
                    for (appWidgetId in appWidgetIds) {
                        // 通知数据变更
                        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.today_courses_list)
                        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.tomorrow_courses_list)
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
        val views = RemoteViews(context.packageName, R.layout.tomorrow_courses_widget)

        try {
            // 设置标题和日期
            val tomorrowDate = widgetData.getString("flutter.tomorrow.tomorrowDate", "")

            views.setTextViewText(R.id.widget_title, "近日课表")
            views.setTextViewText(R.id.tomorrow_date_text, tomorrowDate)

            // 解析今日课程数据
            val todayCoursesJson = widgetData.getString("flutter.tomorrow.courses", null) ?: "[]"
            val todayCourses = parseCourses(todayCoursesJson)

            // 解析明日课程数据
            val tomorrowCoursesJson = widgetData.getString("flutter.tomorrow.tomorrowCourses", null) ?: "[]"
            val tomorrowCourses = parseCourses(tomorrowCoursesJson)

            println("Today courses JSON: $todayCoursesJson")
            println("Tomorrow courses JSON: $tomorrowCoursesJson")

            // 设置今日课程列表
            updateCourseList(views, context, todayCourses, todayCoursesJson, "today", R.id.today_courses_list, R.id.today_empty_view, appWidgetId)

            // 设置明日课程列表
            updateCourseList(views, context, tomorrowCourses, tomorrowCoursesJson, "tomorrow", R.id.tomorrow_courses_list, R.id.tomorrow_empty_view, appWidgetId)

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
            views.setViewVisibility(R.id.today_courses_list, android.view.View.GONE)
            views.setViewVisibility(R.id.tomorrow_courses_list, android.view.View.GONE)
            views.setViewVisibility(R.id.today_empty_view, android.view.View.VISIBLE)
        }

        // 更新小组件
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    // 通用的课程列表更新方法，消除重复代码
    private fun updateCourseList(
        views: RemoteViews,
        context: Context,
        courses: List<Course>,
        coursesJson: String,
        type: String,
        listViewId: Int,
        emptyViewId: Int,
        appWidgetId: Int
    ) {
        if (courses.isEmpty()) {
            views.setViewVisibility(listViewId, android.view.View.GONE)
            views.setViewVisibility(emptyViewId, android.view.View.VISIBLE)
        } else {
            views.setViewVisibility(emptyViewId, android.view.View.GONE)
            views.setViewVisibility(listViewId, android.view.View.VISIBLE)

            val intent = Intent(context, TodayAndTomorrowCourseListRemoteViewsService::class.java)
            // 不再传递 coursesJson，让 Factory 自己根据 type 获取对应数据
            intent.putExtra("type", type)
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            intent.data = Uri.parse("widget://tomorrow_courses?type=" + type + "&appWidgetId=" + appWidgetId)
            views.setRemoteAdapter(listViewId, intent)
        }
    }

    private fun getCurrentDate(): String {
        val calendar = Calendar.getInstance()
        val weekDays = arrayOf("日", "一", "二", "三", "四", "五", "六")
        return "第${(calendar.get(Calendar.WEEK_OF_YEAR) % 20) + 1}周 周${weekDays[calendar.get(Calendar.DAY_OF_WEEK) - 1]}"
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
}