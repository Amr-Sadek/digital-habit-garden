package com.amrsadek.digitalhabitgarden

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import java.io.File

class GardenWidgetProvider : HomeWidgetProvider() {

    companion object {
        const val ACTION_NEXT_GARDEN = "com.amrsadek.digitalhabitgarden.ACTION_NEXT_GARDEN"
        const val ACTION_PREV_GARDEN = "com.amrsadek.digitalhabitgarden.ACTION_PREV_GARDEN"
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        when (intent.action) {
            ACTION_NEXT_GARDEN -> {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val currentPage = prefs.getInt("flutter.active_garden_page", 0)
                val nextPage = (currentPage + 1) % 4
                prefs.edit().putInt("flutter.active_garden_page", nextPage).apply()

                val appWidgetManager = AppWidgetManager.getInstance(context)
                val componentName = ComponentName(context, GardenWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                onUpdate(context, appWidgetManager, appWidgetIds, prefs)
            }
            ACTION_PREV_GARDEN -> {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val currentPage = prefs.getInt("flutter.active_garden_page", 0)
                val prevPage = (currentPage - 1 + 4) % 4
                prefs.edit().putInt("flutter.active_garden_page", prevPage).apply()

                val appWidgetManager = AppWidgetManager.getInstance(context)
                val componentName = ComponentName(context, GardenWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                onUpdate(context, appWidgetManager, appWidgetIds, prefs)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            try {
                val views = RemoteViews(context.packageName, R.layout.garden_widget)

                val activePage = widgetData.getInt("flutter.active_garden_page", 0).coerceIn(0, 3)

                // 1. Load rendered Flutter Garden image for active page
                val imagePath = widgetData.getString("flutter.garden_rendered_image_$activePage", null)
                    ?: widgetData.getString("garden_rendered_image_$activePage", null)

                if (imagePath != null && imagePath != "") {
                    val file = File(imagePath)
                    if (file.exists()) {
                        val bitmap = BitmapFactory.decodeFile(file.absolutePath)
                        if (bitmap != null) {
                            views.setImageViewBitmap(R.id.widget_rendered_image, bitmap)
                        }
                    }
                }

                // 2. Open Garden Screen Intent
                val gardenUri = Uri.parse("digitalhabitgarden://garden")
                val gardenIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    gardenUri
                )
                views.setOnClickPendingIntent(R.id.btn_open_garden, gardenIntent)
                views.setOnClickPendingIntent(R.id.widget_root, gardenIntent)

                // 3. Next / Prev Garden Page Intention Intents
                val nextIntent = Intent(context, GardenWidgetProvider::class.java).apply {
                    action = ACTION_NEXT_GARDEN
                }
                val nextPendingIntent = PendingIntent.getBroadcast(
                    context,
                    0,
                    nextIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.btn_next_garden, nextPendingIntent)

                val prevIntent = Intent(context, GardenWidgetProvider::class.java).apply {
                    action = ACTION_PREV_GARDEN
                }
                val prevPendingIntent = PendingIntent.getBroadcast(
                    context,
                    1,
                    prevIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.btn_prev_garden, prevPendingIntent)

                // 4. Hotspot Intents for habits on active page
                val slotIds = intArrayOf(R.id.plant_slot_0, R.id.plant_slot_1, R.id.plant_slot_2)
                for (i in 0..2) {
                    val habitIndex = activePage * 3 + i
                    val habitId = widgetData.getString("flutter.habit_id_$habitIndex", "")
                        ?: widgetData.getString("habit_id_$habitIndex", "") ?: ""

                    if (habitId != "") {
                        val habitUri = Uri.parse("digitalhabitgarden://habit?id=$habitId")
                        val habitIntent = HomeWidgetLaunchIntent.getActivity(
                            context,
                            MainActivity::class.java,
                            habitUri
                        )
                        views.setOnClickPendingIntent(slotIds[i], habitIntent)
                    } else {
                        views.setOnClickPendingIntent(slotIds[i], gardenIntent)
                    }
                }

                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (_: Throwable) {
                // Ignore widget render exceptions to prevent crash
            }
        }
    }
}
