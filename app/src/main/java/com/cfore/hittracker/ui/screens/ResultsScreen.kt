package com.cfore.hittracker.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.cfore.hittracker.data.HitType
import com.cfore.hittracker.data.Player
import com.cfore.hittracker.data.Team
import com.cfore.hittracker.ui.components.HitLegend
import com.cfore.hittracker.ui.components.SoftballField
import com.cfore.hittracker.ui.components.getHitColor
import com.cfore.hittracker.viewmodel.HitTrackerViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ResultsScreen(viewModel: HitTrackerViewModel) {
    val teams by viewModel.teams.collectAsState()
    val allPlayers by viewModel.allPlayers.collectAsState()
    val allHits by viewModel.allHits.collectAsState()

    var selectedTeam by remember { mutableStateOf<Team?>(null) }
    var selectedPlayer by remember { mutableStateOf<Player?>(null) }
    var showTeamDropdown by remember { mutableStateOf(false) }
    var showPlayerDropdown by remember { mutableStateOf(false) }

    // Filter hits based on selection
    val filteredHits = remember(allHits, selectedTeam, selectedPlayer) {
        when {
            selectedPlayer != null -> allHits.filter { it.playerId == selectedPlayer?.id }
            selectedTeam != null -> allHits.filter { it.teamId == selectedTeam?.id }
            else -> allHits
        }
    }

    // Filter players based on selected team
    val filteredPlayers = remember(allPlayers, selectedTeam) {
        if (selectedTeam != null) {
            allPlayers.filter { it.teamId == selectedTeam?.id }
        } else {
            allPlayers
        }
    }

    // Calculate hit type stats
    val hitTypeStats = remember(filteredHits) {
        HitType.entries.associateWith { type ->
            filteredHits.count { it.hitType == type }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Results") }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Filters
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    // Team filter
                    Box(modifier = Modifier.weight(1f)) {
                        OutlinedButton(
                            onClick = { showTeamDropdown = true },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(selectedTeam?.name ?: "All Teams")
                            Icon(Icons.Default.ArrowDropDown, contentDescription = null)
                        }
                        DropdownMenu(
                            expanded = showTeamDropdown,
                            onDismissRequest = { showTeamDropdown = false }
                        ) {
                            DropdownMenuItem(
                                text = { Text("All Teams") },
                                onClick = {
                                    selectedTeam = null
                                    selectedPlayer = null
                                    showTeamDropdown = false
                                }
                            )
                            Divider()
                            teams.forEach { team ->
                                DropdownMenuItem(
                                    text = { Text(team.name) },
                                    onClick = {
                                        selectedTeam = team
                                        selectedPlayer = null
                                        showTeamDropdown = false
                                    }
                                )
                            }
                        }
                    }

                    // Player filter
                    Box(modifier = Modifier.weight(1f)) {
                        OutlinedButton(
                            onClick = { showPlayerDropdown = true },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(selectedPlayer?.displayName ?: "All Players")
                            Icon(Icons.Default.ArrowDropDown, contentDescription = null)
                        }
                        DropdownMenu(
                            expanded = showPlayerDropdown,
                            onDismissRequest = { showPlayerDropdown = false }
                        ) {
                            DropdownMenuItem(
                                text = { Text("All Players") },
                                onClick = {
                                    selectedPlayer = null
                                    showPlayerDropdown = false
                                }
                            )
                            Divider()
                            filteredPlayers.forEach { player ->
                                DropdownMenuItem(
                                    text = { Text(player.displayName) },
                                    onClick = {
                                        selectedPlayer = player
                                        showPlayerDropdown = false
                                    }
                                )
                            }
                        }
                    }
                }
            }

            // Spray chart
            item {
                Card(
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "Spray Chart",
                            style = MaterialTheme.typography.titleMedium
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        SoftballField(
                            hits = filteredHits,
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(300.dp)
                        )
                        HitLegend()
                    }
                }
            }

            // Hits by Player (if viewing team or all)
            if (selectedPlayer == null && filteredPlayers.isNotEmpty()) {
                item {
                    Card(modifier = Modifier.fillMaxWidth()) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Text(
                                text = "Hits by Player",
                                style = MaterialTheme.typography.titleMedium
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                        }
                    }
                }

                items(filteredPlayers) { player ->
                    val playerHitCount = allHits.count { it.playerId == player.id }
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedPlayer = player }
                    ) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(player.displayName)
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Text("$playerHitCount hits")
                                Icon(
                                    Icons.Default.ChevronRight,
                                    contentDescription = "View details"
                                )
                            }
                        }
                    }
                }
            }

            // Hit Types breakdown
            item {
                Card(modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(
                            text = "Hit Types",
                            style = MaterialTheme.typography.titleMedium
                        )
                        Spacer(modifier = Modifier.height(8.dp))

                        Text(
                            text = "Total Hits: ${filteredHits.size}",
                            style = MaterialTheme.typography.bodyMedium
                        )

                        Spacer(modifier = Modifier.height(8.dp))

                        HitType.entries.forEach { hitType ->
                            val count = hitTypeStats[hitType] ?: 0
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 4.dp),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Row(
                                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Surface(
                                        color = getHitColor(hitType),
                                        shape = MaterialTheme.shapes.small,
                                        modifier = Modifier.size(16.dp)
                                    ) {}
                                    Text(hitType.displayName)
                                }
                                Text("$count")
                            }
                        }
                    }
                }
            }

            // Bottom spacing
            item {
                Spacer(modifier = Modifier.height(16.dp))
            }
        }
    }
}
