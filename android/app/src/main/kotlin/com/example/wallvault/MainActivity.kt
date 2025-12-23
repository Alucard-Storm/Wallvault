package com.example.wallvault

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.WallpaperManager
import android.graphics.BitmapFactory
import android.os.Build
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.wallvault/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setWallpaper" -> {
                    val filePath = call.argument<String>("filePath")
                    val location = call.argument<Int>("location") ?: 0
                    
                    if (filePath == null) {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                        return@setMethodCallHandler
                    }
                    
                    try {
                        val success = setWallpaper(filePath, location)
                        if (success) {
                            result.success(true)
                        } else {
                            result.error("WALLPAPER_ERROR", "Failed to set wallpaper", null)
                        }
                    } catch (e: Exception) {
                        result.error("WALLPAPER_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun setWallpaper(filePath: String, location: Int): Boolean {
        return try {
            val wallpaperManager = WallpaperManager.getInstance(applicationContext)
            val file = File(filePath)
            
            if (!file.exists()) {
                return false
            }
            
            val bitmap = BitmapFactory.decodeFile(filePath)
            
            // Location: 0 = both, 1 = home screen, 2 = lock screen
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                when (location) {
                    1 -> wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
                    2 -> wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                    else -> {
                        // Set both
                        wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_SYSTEM)
                        wallpaperManager.setBitmap(bitmap, null, true, WallpaperManager.FLAG_LOCK)
                    }
                }
            } else {
                wallpaperManager.setBitmap(bitmap)
            }
            
            bitmap.recycle()
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
