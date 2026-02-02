package com.cfore.hittracker.viewmodel

import android.graphics.Bitmap
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.cfore.hittracker.data.*
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class HitTrackerViewModel(private val repository: HitTrackerRepository) : ViewModel() {

    // Teams
    val teams: StateFlow<List<Team>> = repository.allTeams
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    private val _selectedTeamId = MutableStateFlow<String?>(null)
    val selectedTeamId: StateFlow<String?> = _selectedTeamId.asStateFlow()

    val selectedTeam: StateFlow<Team?> = combine(teams, selectedTeamId) { teams, id ->
        id?.let { teamId -> teams.find { it.id == teamId } }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    // Players
    val allPlayers: StateFlow<List<Player>> = repository.allPlayers
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val playersForSelectedTeam: StateFlow<List<Player>> = selectedTeamId
        .filterNotNull()
        .flatMapLatest { teamId -> repository.getPlayersForTeam(teamId) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    private val _selectedPlayerId = MutableStateFlow<String?>(null)
    val selectedPlayerId: StateFlow<String?> = _selectedPlayerId.asStateFlow()

    val selectedPlayer: StateFlow<Player?> = combine(allPlayers, selectedPlayerId) { players, id ->
        id?.let { playerId -> players.find { it.id == playerId } }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    // Hits
    val allHits: StateFlow<List<Hit>> = repository.allHits
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val hitsForSelectedTeam: StateFlow<List<Hit>> = selectedTeamId
        .filterNotNull()
        .flatMapLatest { teamId -> repository.getHitsForTeam(teamId) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val hitsForSelectedPlayer: StateFlow<List<Hit>> = selectedPlayerId
        .filterNotNull()
        .flatMapLatest { playerId -> repository.getHitsForPlayer(playerId) }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // Setup state
    val hasTeamSetup: StateFlow<Boolean> = teams
        .map { it.isNotEmpty() }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), false)

    // Team operations
    fun selectTeam(teamId: String?) {
        _selectedTeamId.value = teamId
        _selectedPlayerId.value = null // Clear player selection when team changes
    }

    fun addTeam(name: String) {
        viewModelScope.launch {
            val team = Team(name = name)
            repository.insertTeam(team)
            if (_selectedTeamId.value == null) {
                _selectedTeamId.value = team.id
            }
        }
    }

    fun updateTeamName(teamId: String, name: String) {
        viewModelScope.launch {
            repository.getTeam(teamId)?.let { team ->
                repository.updateTeam(team.copy(name = name))
            }
        }
    }

    fun deleteTeam(team: Team) {
        viewModelScope.launch {
            repository.deleteTeam(team)
            if (_selectedTeamId.value == team.id) {
                _selectedTeamId.value = null
            }
        }
    }

    // Player operations
    fun selectPlayer(playerId: String?) {
        _selectedPlayerId.value = playerId
    }

    fun addPlayer(teamId: String, name: String, number: String) {
        viewModelScope.launch {
            repository.addPlayer(teamId, name, number)
        }
    }

    fun updatePlayer(player: Player) {
        viewModelScope.launch {
            repository.updatePlayer(player)
        }
    }

    fun deletePlayer(player: Player) {
        viewModelScope.launch {
            repository.deletePlayer(player)
            if (_selectedPlayerId.value == player.id) {
                _selectedPlayerId.value = null
            }
        }
    }

    fun reorderPlayers(players: List<Player>) {
        viewModelScope.launch {
            repository.reorderPlayers(players)
        }
    }

    // Hit operations
    fun addHit(
        locationX: Double,
        locationY: Double,
        hitType: HitType,
        pitchType: PitchType?,
        pitchLocation: PitchLocation?
    ) {
        val playerId = _selectedPlayerId.value ?: return
        val teamId = _selectedTeamId.value ?: return

        viewModelScope.launch {
            repository.addHit(
                playerId = playerId,
                teamId = teamId,
                locationX = locationX,
                locationY = locationY,
                hitType = hitType,
                pitchType = pitchType,
                pitchLocation = pitchLocation
            )
        }
    }

    fun deleteHit(hit: Hit) {
        viewModelScope.launch {
            repository.deleteHit(hit)
        }
    }

    fun clearHitsForPlayer(playerId: String) {
        viewModelScope.launch {
            repository.deleteHitsForPlayer(playerId)
        }
    }

    fun clearHitsForTeam(teamId: String) {
        viewModelScope.launch {
            repository.deleteHitsForTeam(teamId)
        }
    }

    fun clearAllHits() {
        viewModelScope.launch {
            repository.deleteAllHits()
        }
    }

    // Statistics
    private val _pitchStats = MutableStateFlow<List<PitchStats>>(emptyList())
    val pitchStats: StateFlow<List<PitchStats>> = _pitchStats.asStateFlow()

    private val _hitTypeStats = MutableStateFlow<Map<HitType, Int>>(emptyMap())
    val hitTypeStats: StateFlow<Map<HitType, Int>> = _hitTypeStats.asStateFlow()

    fun loadStatsForPlayer(playerId: String) {
        viewModelScope.launch {
            _pitchStats.value = repository.getPitchStats(playerId)
            _hitTypeStats.value = repository.getHitTypeStats(playerId)
        }
    }

    // Logo
    fun saveLogo(bitmap: Bitmap) {
        repository.saveLogo(bitmap)
    }

    fun loadLogo(): Bitmap? = repository.loadLogo()

    fun removeLogo() {
        repository.removeLogo()
    }

    fun hasLogo(): Boolean = repository.hasLogo()

    // Factory
    class Factory(private val repository: HitTrackerRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            if (modelClass.isAssignableFrom(HitTrackerViewModel::class.java)) {
                return HitTrackerViewModel(repository) as T
            }
            throw IllegalArgumentException("Unknown ViewModel class")
        }
    }
}
