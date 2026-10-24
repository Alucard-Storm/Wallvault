package com.unaveragedevs.wallvault

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Handler
import android.os.Looper
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.unaveragedevs.wallvault/wallpaper"
    private val mainHandler = Handler(Looper.getMainLooper())

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

                    // Decoding a full-resolution wallpaper (often 4K-8K) and
                    // calling into WallpaperManager can take a while and can
                    // throw OutOfMemoryError, so this runs off the main thread.
                    Thread {
                        try {
                            val success = setWallpaper(filePath, location)
                            mainHandler.post {
                                if (success) {
                                    result.success(true)
                                } else {
                                    result.error("WALLPAPER_ERROR", "Failed to set wallpaper", null)
                                }
                            }
                        } catch (t: Throwable) {
                            mainHandler.post {
                                result.error("WALLPAPER_ERROR", t.message, null)
                            }
                        }
                    }.start()
                }
                else -> result.notImplemented()
            }
        }
    }

    // Caps the decoded bitmap's longest side so a 4K/8K source image can't
    // exhaust the heap (OutOfMemoryError is an Error, not an Exception, so
    // callers must not rely on try/catch(Exception) alone to guard this).
    private fun decodeBoundedBitmap(filePath: String, maxDimension: Int): Bitmap? {
        val boundsOptions = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeFile(filePath, boundsOptions)

        val sampleSize = computeSampleSize(boundsOptions.outWidth, boundsOptions.outHeight, maxDimension)

        val decodeOptions = BitmapFactory.Options().apply { inSampleSize = sampleSize }
        return BitmapFactory.decodeFile(filePath, decodeOptions)
    }

    private fun setWallpaper(filePath: String, location: Int): Boolean {
        return try {
            val wallpaperManager = WallpaperManager.getInstance(applicationContext)
            val file = File(filePath)

            if (!file.exists()) {
                return false
            }

            val bitmap = decodeBoundedBitmap(filePath, MAX_WALLPAPER_DIMENSION) ?: return false

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
        } catch (t: Throwable) {
            t.printStackTrace()
            false
        }
    }

    companion object {
        // Comfortably above any real device's screen's longest side, while
        // keeping a decoded bitmap's worst case (ARGB_8888) well under
        // typical per-app heap limits.
        private const val MAX_WALLPAPER_DIMENSION = 4096
    }
}
