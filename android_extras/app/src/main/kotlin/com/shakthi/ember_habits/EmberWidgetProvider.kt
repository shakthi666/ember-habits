package com.shakthi.ember_habits

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class EmberWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val done = prefs.getInt("done", 0)
        val due = prefs.getInt("due", 0)
        val streak = prefs.getInt("streak", 0)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.ember_widget)
            views.setTextViewText(R.id.widget_title, "Ember")
            views.setTextViewText(R.id.widget_count, "$done / $due")
            views.setTextViewText(R.id.widget_streak, "🔥 $streak")
            views.setProgressBar(R.id.widget_progress, if (due > 0) due else 1, done, false)

            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launch != null) {
                val pending = PendingIntent.getActivity(
                    context, 0, launch,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_root, pending)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
