package com.yandex.div.core.view2

import android.view.View
import androidx.core.view.ViewCompat
import com.yandex.div.core.dagger.DivViewScope
import com.yandex.div.util.arrayMap
import javax.inject.Inject

@DivViewScope
internal class DivViewIdProvider @Inject constructor() {

    private val cache = arrayMap<String, Int>()

    fun getViewId(id: String?): Int {
        if (id == null) return View.NO_ID

        return cache.getOrPut(id) {
            ViewCompat.generateViewId()
        }
    }

    fun reset() = cache.clear()
}
