package com.cfore.hittracker.data

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import kotlinx.coroutines.flow.Flow
import java.io.File
import java.io.FileOutputStream

class HitTrackerRepository(private val dao: HitTrackerDao, private val context: Context) {

    // Teams
    val allTeams: Flow<List<Team>> = dao.getAllTeams()

    suspend fun getTeam(teamId: String): Team? = dao.getTeam(teamId)

    suspend fun insertTeam(team: Team) = dao.insertTeam(team)

    suspend fun updateTeam(team: Team) = dao.updateTeam(team)

    suspend fun deleteTeam(team: Team) = dao.deleteTeam(team)

    // Players
    val allPlayers: Flow<List<Player>> = dao.getAllPlayers()

    fun getPlayersForTeam(teamId: String): Flow<List<Player>> = dao.getPlayersForTeam(teamId)

    suspend fun getPlayersForTeamOnce(teamId: String): List<Player> = dao.getPlayersForTeamOnce(teamId)

    suspend fun getPlayer(playerId: String): Player? = dao.getPlayer(playerId)

    suspend fun insertPlayer(player: Player) = dao.insertPlayer(player)

    suspend fun updatePlayer(player: Player) = dao.updatePlayer(player)

    suspend fun updatePlayers(players: List<Player>) = dao.updatePlayers(players)

    suspend fun deletePlayer(player: Player) = dao.deletePlayer(player)

    suspend fun addPlayer(teamId: String, name: String, number: String) {
        val existingPlayers = dao.getPlayersForTeamOnce(teamId)
        val lineupOrder = (existingPlayers.maxOfOrNull { it.lineupOrder } ?: 0) + 1
        val player = Player(
            teamId = teamId,
            name = name,
            number = number,
            lineupOrder = lineupOrder
        )
        dao.insertPlayer(player)
    }

    suspend fun reorderPlayers(reorderedPlayers: List<Player>) {
        val updatedPlayers = reorderedPlayers.mapIndexed { index, player ->
            player.copy(lineupOrder = index + 1)
        }
        dao.updatePlayers(updatedPlayers)
    }

    // Hits
    val allHits: Flow<List<Hit>> = dao.getAllHits()

    fun getHitsForPlayer(playerId: String): Flow<List<Hit>> = dao.getHitsForPlayer(playerId)

    fun getHitsForTeam(teamId: String): Flow<List<Hit>> = dao.getHitsForTeam(teamId)

    suspend fun getHitsForPlayerOnce(playerId: String): List<Hit> = dao.getHitsForPlayerOnce(playerId)

    suspend fun getHitsForTeamOnce(teamId: String): List<Hit> = dao.getHitsForTeamOnce(teamId)

    fun getHitsInDateRange(startTime: Long, endTime: Long): Flow<List<Hit>> =
        dao.getHitsInDateRange(startTime, endTime)

    fun getHitsForTeamInDateRange(teamId: String, startTime: Long, endTime: Long): Flow<List<Hit>> =
        dao.getHitsForTeamInDateRange(teamId, startTime, endTime)

    suspend fun insertHit(hit: Hit) = dao.insertHit(hit)

    suspend fun addHit(
        playerId: String,
        teamId: String,
        locationX: Double,
        locationY: Double,
        hitType: HitType,
        pitchType: PitchType?,
        pitchLocation: PitchLocation?
    ) {
        val hit = Hit(
            playerId = playerId,
            teamId = teamId,
            locationX = locationX,
            locationY = locationY,
            hitType = hitType,
            pitchType = pitchType,
            pitchLocation = pitchLocation
        )
        dao.insertHit(hit)
    }

    suspend fun deleteHit(hit: Hit) = dao.deleteHit(hit)

    suspend fun deleteHitsForPlayer(playerId: String) = dao.deleteHitsForPlayer(playerId)

    suspend fun deleteHitsForTeam(teamId: String) = dao.deleteHitsForTeam(teamId)

    suspend fun deleteAllHits() = dao.deleteAllHits()

    // Statistics
    suspend fun getPitchStats(playerId: String): List<PitchStats> {
        val hits = dao.getHitsForPlayerOnce(playerId)
        return hits
            .filter { it.pitchType != null && it.pitchLocation != null }
            .groupBy { Pair(it.pitchType!!, it.pitchLocation!!) }
            .map { (key, hits) ->
                PitchStats(pitchType = key.first, pitchLocation = key.second, count = hits.size)
            }
            .sortedByDescending { it.count }
    }

    suspend fun getHitTypeStats(playerId: String): Map<HitType, Int> {
        val hits = dao.getHitsForPlayerOnce(playerId)
        return HitType.entries.associateWith { type ->
            hits.count { it.hitType == type }
        }
    }

    // Team Logo
    private val logoFile: File
        get() = File(context.filesDir, "team_logo.png")

    fun saveLogo(bitmap: Bitmap) {
        FileOutputStream(logoFile).use { out ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
        }
    }

    fun loadLogo(): Bitmap? {
        return if (logoFile.exists()) {
            BitmapFactory.decodeFile(logoFile.absolutePath)
        } else null
    }

    fun removeLogo() {
        if (logoFile.exists()) {
            logoFile.delete()
        }
    }

    fun hasLogo(): Boolean = logoFile.exists()
}
