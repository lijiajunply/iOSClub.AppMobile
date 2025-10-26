package com.example.ios_club_app

import android.graphics.Color

class CourseColorManager {
    companion object {
        /**
         * 根据课程名称生成柔和的颜色
         * 算法与 Flutter 端保持一致
         */
        fun generateSoftColor(key: String): Int {
            val hashCode = key.hashCode()
            val hue = (hashCode % 360).toDouble()
            val saturation = 0.4f
            val lightness = 0.6f
            val hsv = floatArrayOf(hue.toFloat(), saturation, lightness)
            return Color.HSVToColor(hsv)
        }
    }
}