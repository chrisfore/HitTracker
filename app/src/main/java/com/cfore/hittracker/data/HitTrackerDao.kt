package com.cfore.hittracker.data

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface HitTrackerDao {
    // Team operations
    @Query("SELECT * FROM teams ORDER BY name")
    fun getAllTeams(): Flow<List<Team>>

    @Query("SELECT * FROM teams WHERE id = :teamId")
    suspend fun getTeam(teamId: String): Team?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTeam(team: Team)

    @Update
    suspend fun updateTeam(team: Team)

    @Delete
    suspend fun deleteTeam(team: Team)

    // Player operations
    @Query("SELECT * FROM players WHERE teamId = :teamId ORDER BY lineupOrder")
    fun getPlayersForTeam(teamId: String): Flow<List<Player>>

    @Query("SELECT * FROM players WHERE teamId = :teamId ORDER BY lineupOrder")
    suspend fun getPlayersForTeamOnce(teamId: String): List<Player>

    @Query("SELECT * FROM players WHERE id = :playerId")
    suspend fun getPlayer(playerId: String): Player?

    @Query("SELECT * FROM players ORDER BY lineupOrder")
    fun getAllPlayers(): Flow<List<Player>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertPlayer(player: Player)

    @Update
    suspend fun updatePlayer(player: Player)

    @Update
    suspend fun updatePlayers(players: List<Player>)

    @Delete
    suspend fun deletePlayer(player: Player)

    // Hit operations
    @Query("SELECT * FROM hits WHERE playerId = :playerId ORDER BY timestamp DESC")
    fun getHitsForPlayer(playerId: String): Flow<List<Hit>>

    @Query("SELECT * FROM hits WHERE teamId = :teamId ORDER BY timestamp DESC")
    fun getHitsForTeam(teamId: String): Flow<List<Hit>>

    @Query("SELECT * FROM hits ORDER BY timestamp DESC")
    fun getAllHits(): Flow<List<Hit>>

    @Query("SELECT * FROM hits WHERE playerId = :playerId")
    suspend fun getHitsForPlayerOnce(playerId: String): List<Hit>

    @Query("SELECT * FROM hits WHERE teamId = :teamId")
    suspend fun getHitsForTeamOnce(teamId: String): List<Hit>

    @Query("SELECT * FROM hits WHERE timestamp BETWEEN :startTime AND :endTime ORDER BY timestamp DESC")
    fun getHitsInDateRange(startTime: Long, endTime: Long): Flow<List<Hit>>

    @Query("SELECT * FROM hits WHERE teamId = :teamId AND timestamp BETWEEN :startTime AND :endTime ORDER BY timestamp DESC")
    fun getHitsForTeamInDateRange(teamId: String, startTime: Long, endTime: Long): Flow<List<Hit>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertHit(hit: Hit)

    @Delete
    suspend fun deleteHit(hit: Hit)

    @Query("DELETE FROM hits WHERE playerId = :playerId")
    suspend fun deleteHitsForPlayer(playerId: String)

    @Query("DELETE FROM hits WHERE teamId = :teamId")
    suspend fun deleteHitsForTeam(teamId: String)

    @Query("DELETE FROM hits")
    suspend fun deleteAllHits()
}
