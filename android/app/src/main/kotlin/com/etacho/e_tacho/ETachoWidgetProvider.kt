package com.etacho.e_tacho

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class ETachoWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.etacho_widget).apply {
                setTextViewText(R.id.break_label, widgetData.getString("break_label", "Do przerwy"))
                setTextViewText(R.id.break_value, widgetData.getString("break_value", "--:--"))
                setTextViewText(R.id.duty_label, widgetData.getString("duty_label", "Do końca doby"))
                setTextViewText(R.id.duty_value, widgetData.getString("duty_value", "--:--"))
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
