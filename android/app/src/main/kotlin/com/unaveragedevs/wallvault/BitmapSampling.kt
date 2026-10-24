package com.unaveragedevs.wallvault

/**
 * Picks the smallest power-of-two sample size BitmapFactory can use so a
 * decoded image's longest side does not exceed [maxDimension].
 *
 * Pure arithmetic with no Android dependency, kept separate from
 * MainActivity so it can be unit tested without the Android framework.
 */
fun computeSampleSize(width: Int, height: Int, maxDimension: Int): Int {
    var sampleSize = 1
    while (width / sampleSize > maxDimension || height / sampleSize > maxDimension) {
        sampleSize *= 2
    }
    return sampleSize
}
