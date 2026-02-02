package com.cfore.hittracker

import android.app.Application
import com.cfore.hittracker.data.HitTrackerDatabase
import com.cfore.hittracker.data.HitTrackerRepository

class HitTrackerApp : Application() {
    val database by lazy { HitTrackerDatabase.getDatabase(this) }
    val repository by lazy { HitTrackerRepository(database.hitTrackerDao(), this) }
}
