package com.example.nutrition_tracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.*

class NutriFitDailySummaryWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.nutrifit_daily_summary_widget)
        
        // Get data from SharedPreferences (updated by Flutter app)
        val widgetData = HomeWidgetPlugin.getData(context)
        
        val calories = widgetData.getInt("calories", 0)
        val targetCalories = widgetData.getInt("target_calories", 2000)
        val tdee = widgetData.getInt("tdee", 2000)
        val protein = widgetData.getInt("protein", 0)
        val carbs = widgetData.getInt("carbs", 0)
        val fat = widgetData.getInt("fat", 0)
        val goal = widgetData.getString("goal", "maintain")

        // Calculate target macros based on standard ratios
        val targetProtein = (targetCalories * 0.25 / 4).toInt() // 25% protein
        val targetCarbs = (targetCalories * 0.45 / 4).toInt()   // 45% carbs
        val targetFat = (targetCalories * 0.30 / 9).toInt()     // 30% fat

        // Update calories
        views.setTextViewText(R.id.widget_calories_current, calories.toString())
        views.setTextViewText(R.id.widget_calories_target, targetCalories.toString())

        // Update macros with progress
        views.setTextViewText(R.id.widget_protein_text, "${protein}g")
        views.setProgressBar(R.id.widget_protein_progress, targetProtein, protein, false)

        views.setTextViewText(R.id.widget_carbs_text, "${carbs}g")
        views.setProgressBar(R.id.widget_carbs_progress, targetCarbs, carbs, false)

        views.setTextViewText(R.id.widget_fat_text, "${fat}g")
        views.setProgressBar(R.id.widget_fat_progress, targetFat, fat, false)

        // Update date
        val dateFormat = SimpleDateFormat("MMM dd", Locale.getDefault())
        views.setTextViewText(R.id.widget_date, dateFormat.format(Date()))

        // Update status
        val remaining = targetCalories - calories
        val statusText = when {
            remaining > 0 -> "$remaining cal left"
            remaining == 0 -> "Perfect balance!"
            else -> "${-remaining} cal over"
        }
        views.setTextViewText(R.id.widget_status, statusText)

        // Set click intent to open app
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 
            0, 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}