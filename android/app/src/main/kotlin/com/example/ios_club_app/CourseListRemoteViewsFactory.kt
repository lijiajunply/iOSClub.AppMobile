package com.example.ios_club_app

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class CourseListRemoteViewsFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private var courses = mutableListOf<TodayCoursesWidgetProvider.Course>()

    init {
        val coursesJson = intent.getStringExtra("courses") ?: "[]"
        parseCourses(coursesJson)
    }

    override fun onCreate() {}

    override fun onDataSetChanged() {
        // 当数据集改变时重新从共享数据中获取最新的数据
        val widgetData = HomeWidgetPlugin.getData(context)
        val coursesJson = widgetData.getString("flutter.courses", null) ?: "[]"
        parseCourses(coursesJson)
    }

    override fun onDestroy() {
        courses.clear()
    }

    override fun getCount(): Int = courses.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.course_item)

        if (position < courses.size) {
            val course = courses[position]
            views.setTextViewText(R.id.course_title, course.title)
            views.setTextViewText(R.id.course_time, course.time)
            views.setTextViewText(R.id.course_location, course.location)
            views.setTextViewText(R.id.course_teacher, course.teacher)

            // 根据课程名称生成颜色并设置给分隔线
            val color = CourseColorManager.generateSoftColor(course.title)
            views.setTextViewTextSize(
                R.id.course_title,
                android.util.TypedValue.COMPLEX_UNIT_SP,
                14f
            )
            // 设置分隔线颜色
            views.setInt(R.id.course_divider, "setBackgroundColor", color)

            // 移除了点击事件处理
        }

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
    private fun parseCourses(jsonString: String) {
        courses.clear()
        try {
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                val courseObj = jsonArray.getJSONObject(i)
                courses.add(
                    TodayCoursesWidgetProvider.Course(
                        title = courseObj.optString("title", ""),
                        time = courseObj.optString("time", ""),
                        location = courseObj.optString("location", ""),
                        teacher = courseObj.optString("teacher", "")
                    )
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}