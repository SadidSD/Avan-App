package com.avanapp.avan_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class AvanSmallWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_small).apply {
                val quote = widgetData.getString("quote", "I am securely rooted in this exact moment, completely safe and capable.")
                val category = widgetData.getString("category", "DAILY AFFIRMATION")
                val author = widgetData.getString("author", "AVAN")

                setTextViewText(R.id.widget_quote, quote)
                setTextViewText(R.id.widget_category, category)
                setTextViewText(R.id.widget_author, "• $author")

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class AvanMediumWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_medium).apply {
                val quote = widgetData.getString("quote", "I attract peace, abundance, and clarity into my life every single day.")
                val category = widgetData.getString("category", "DAILY AFFIRMATION • AVAN")
                val author = widgetData.getString("author", "Mindset & Emotional Presence")
                val streakDays = widgetData.getInt("streakDays", 0)

                setTextViewText(R.id.widget_quote, "\"$quote\"")
                setTextViewText(R.id.widget_category, category)
                setTextViewText(R.id.widget_author, author)
                setTextViewText(R.id.widget_streak, if (streakDays > 0) "🔥 $streakDays Days" else "✨ Begin Streak")

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class AvanLargeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_large).apply {
                val quote = widgetData.getString("quote", "I release the need to control every outcome. I control my effort, my integrity, and my response.")
                val category = widgetData.getString("category", "AVAN • DAILY PRIME")
                val streakDays = widgetData.getInt("streakDays", 0)

                setTextViewText(R.id.widget_quote, "\"$quote\"")
                setTextViewText(R.id.widget_category, category)
                setTextViewText(R.id.widget_streak, if (streakDays > 0) "🔥 $streakDays Days" else "✨ Begin Streak")

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
