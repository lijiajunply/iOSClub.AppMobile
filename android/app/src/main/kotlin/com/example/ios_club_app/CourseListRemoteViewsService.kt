package com.example.ios_club_app

import android.content.Intent
import android.widget.RemoteViewsService

class CourseListRemoteViewsService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return CourseListRemoteViewsFactory(this.applicationContext, intent)
    }
}