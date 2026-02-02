package com.cfore.hittracker.data

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters

@Database(
    entities = [Team::class, Player::class, Hit::class],
    version = 1,
    exportSchema = false
)
@TypeConverters(Converters::class)
abstract class HitTrackerDatabase : RoomDatabase() {
    abstract fun hitTrackerDao(): HitTrackerDao

    companion object {
        @Volatile
        private var INSTANCE: HitTrackerDatabase? = null

        fun getDatabase(context: Context): HitTrackerDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    HitTrackerDatabase::class.java,
                    "hittracker_database"
                ).build()
                INSTANCE = instance
                instance
            }
        }
    }
}
