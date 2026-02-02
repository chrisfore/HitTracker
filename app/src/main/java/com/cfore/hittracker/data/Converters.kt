package com.cfore.hittracker.data

import androidx.room.TypeConverter

class Converters {
    @TypeConverter
    fun fromHitType(value: HitType): String = value.name

    @TypeConverter
    fun toHitType(value: String): HitType = HitType.valueOf(value)

    @TypeConverter
    fun fromPitchType(value: PitchType?): String? = value?.name

    @TypeConverter
    fun toPitchType(value: String?): PitchType? = value?.let { PitchType.valueOf(it) }

    @TypeConverter
    fun fromPitchLocation(value: PitchLocation?): String? = value?.name

    @TypeConverter
    fun toPitchLocation(value: String?): PitchLocation? = value?.let { PitchLocation.valueOf(it) }
}
