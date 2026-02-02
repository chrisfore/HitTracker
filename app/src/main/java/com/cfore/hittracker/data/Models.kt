package com.cfore.hittracker.data

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey
import java.util.UUID

@Entity(tableName = "teams")
data class Team(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val name: String = ""
)

@Entity(
    tableName = "players",
    foreignKeys = [
        ForeignKey(
            entity = Team::class,
            parentColumns = ["id"],
            childColumns = ["teamId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("teamId")]
)
data class Player(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val teamId: String,
    val name: String = "",
    val number: String,
    val lineupOrder: Int
) {
    val displayName: String
        get() = if (name.isEmpty()) "#$number" else "#$number $name"
}

@Entity(
    tableName = "hits",
    foreignKeys = [
        ForeignKey(
            entity = Player::class,
            parentColumns = ["id"],
            childColumns = ["playerId"],
            onDelete = ForeignKey.CASCADE
        ),
        ForeignKey(
            entity = Team::class,
            parentColumns = ["id"],
            childColumns = ["teamId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index("playerId"), Index("teamId")]
)
data class Hit(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val playerId: String,
    val teamId: String,
    val locationX: Double,  // 0.0 to 1.0 relative to field width
    val locationY: Double,  // 0.0 to 1.0 relative to field height
    val hitType: HitType,
    val pitchType: PitchType? = null,
    val pitchLocation: PitchLocation? = null,
    val timestamp: Long = System.currentTimeMillis()
)

enum class HitType(val displayName: String) {
    FLY_BALL("Fly Ball"),
    LINE_DRIVE("Line Drive"),
    POP_UP("Pop Up"),
    GROUNDER("Grounder")
}

enum class PitchType(val displayName: String) {
    FASTBALL("Fastball"),
    CHANGE_UP("Change Up"),
    CURVE("Curve"),
    RISE("Rise"),
    DROP("Drop")
}

enum class PitchLocation(val displayName: String) {
    HIGH("High"),
    LOW("Low"),
    INSIDE("Inside"),
    OUTSIDE("Outside"),
    MIDDLE("Middle")
}

data class PitchStats(
    val pitchType: PitchType,
    val pitchLocation: PitchLocation,
    val count: Int
)
