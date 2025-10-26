package com.example.ios_club_app

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class TodayAndTomorrowCourseListRemoteViewsFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private var courses = mutableListOf<TomorrowCoursesWidgetProvider.Course>()
    private var type = "today" // "today" 或 "tomorrow"

    init {
        type = intent.getStringExtra("type") ?: "today"
        println("TodayAndTomorrowCourseListRemoteViewsFactory - type: $type")
        // 不在init中加载数据，避免与onDataSetChanged重复加载
    }

    override fun onCreate() {}

    override fun onDataSetChanged() {
        println("onDataSetChanged - Loaded data for $type")
        loadData()
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
        }

        return views
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true
    
    private fun loadData() {
        val widgetData = HomeWidgetPlugin.getData(context)
        val dataKey = if (type == "today") "flutter.tomorrow.courses" else "flutter.tomorrow.tomorrowCourses"
        val coursesJson = widgetData.getString(dataKey, null) ?: "[]"
        
        parseCourses(coursesJson)
    }

    private fun parseCourses(jsonString: String) {
        courses.clear()
        try {
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                val courseObj = jsonArray.getJSONObject(i)
                courses.add(TomorrowCoursesWidgetProvider.Course(
                    title = courseObj.optString("title", ""),
                    time = courseObj.optString("time", ""),
                    location = courseObj.optString("location", ""),
                    teacher = courseObj.optString("teacher", "")
                ))
            }
            println("Parsed ${courses.size} courses for type: $type")
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}