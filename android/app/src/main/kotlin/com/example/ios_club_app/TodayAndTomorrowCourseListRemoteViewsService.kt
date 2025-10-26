package com.example.ios_club_app

import android.content.Intent
import android.widget.RemoteViewsService

class TodayAndTomorrowCourseListRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TodayAndTomorrowCourseListRemoteViewsFactory(this.applicationContext, intent)
    }
}