package com.unaveragedevs.wallvault

import org.junit.Assert.assertEquals
import org.junit.Test

class BitmapSamplingTest {
    @Test
    fun `image already within bounds keeps sample size 1`() {
        assertEquals(1, computeSampleSize(width = 1920, height = 1080, maxDimension = 4096))
    }

    @Test
    fun `dimension exactly at the limit does not get downsampled`() {
        assertEquals(1, computeSampleSize(width = 4096, height = 4096, maxDimension = 4096))
    }

    @Test
    fun `oversized image is downsampled by the smallest power of two that fits`() {
        // 8000 / 2 = 4000 <= 4096, so sample size 2 is enough.
        assertEquals(2, computeSampleSize(width = 8000, height = 4500, maxDimension = 4096))
    }

    @Test
    fun `very large image needs more than one doubling`() {
        // 16000 / 4 = 4000 <= 4096
        assertEquals(4, computeSampleSize(width = 16000, height = 9000, maxDimension = 4096))
    }

    @Test
    fun `the larger dimension drives the sample size`() {
        // A tall, narrow image: height alone forces the downsample.
        assertEquals(2, computeSampleSize(width = 2000, height = 8192, maxDimension = 4096))
    }
}
