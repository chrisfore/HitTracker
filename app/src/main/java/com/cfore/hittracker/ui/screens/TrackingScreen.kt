package com.cfore.hittracker.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.cfore.hittracker.data.HitType
import com.cfore.hittracker.data.PitchLocation
import com.cfore.hittracker.data.PitchType
import com.cfore.hittracker.ui.components.HitLegend
import com.cfore.hittracker.ui.components.SoftballField
import com.cfore.hittracker.viewmodel.HitTrackerViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TrackingScreen(viewModel: HitTrackerViewModel) {
    val teams by viewModel.teams.collectAsState()
    val selectedTeam by viewModel.selectedTeam.collectAsState()
    val players by viewModel.playersForSelectedTeam.collectAsState()
    val selectedPlayer by viewModel.selectedPlayer.collectAsState()
    val teamHits by viewModel.hitsForSelectedTeam.collectAsState()
    val playerHits by viewModel.hitsForSelectedPlayer.collectAsState()

    var showTeamDropdown by remember { mutableStateOf(false) }
    var showPlayerDropdown by remember { mutableStateOf(false) }
    var showHitDialog by remember { mutableStateOf(false) }
    var pendingHitLocation by remember { mutableStateOf<Pair<Double, Double>?>(null) }

    // Display hits based on whether a player is selected
    val displayHits = if (selectedPlayer != null) playerHits else teamHits

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Track Hits") },
                actions = {
                    // Team selector
                    Box {
                        TextButton(onClick = { showTeamDropdown = true }) {
                            Text(selectedTeam?.name ?: "Select Team")
                            Icon(Icons.Default.ArrowDropDown, contentDescription = null)
                        }
                        DropdownMenu(
                            expanded = showTeamDropdown,
                            onDismissRequest = { showTeamDropdown = false }
                        ) {
                            teams.forEach { team ->
                                DropdownMenuItem(
                                    text = { Text(team.name) },
                                    onClick = {
                                        viewModel.selectTeam(team.id)
                                        showTeamDropdown = false
                                    },
                                    leadingIcon = if (team.id == selectedTeam?.id) {
                                        { Icon(Icons.Default.Check, contentDescription = null) }
                                    } else null
                                )
                            }
                        }
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Player selector
            if (selectedTeam != null) {
                if (players.isEmpty()) {
                    OutlinedButton(
                        onClick = { /* Navigate to settings to add players */ },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Icon(Icons.Default.Add, contentDescription = null)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Create Players")
                    }
                } else {
                    Box(modifier = Modifier.fillMaxWidth()) {
                        OutlinedButton(
                            onClick = { showPlayerDropdown = true },
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(selectedPlayer?.displayName ?: "Select Player (Team View)")
                            Spacer(modifier = Modifier.weight(1f))
                            Icon(Icons.Default.ArrowDropDown, contentDescription = null)
                        }
                        DropdownMenu(
                            expanded = showPlayerDropdown,
                            onDismissRequest = { showPlayerDropdown = false }
                        ) {
                            DropdownMenuItem(
                                text = { Text("Team View (All Hits)") },
                                onClick = {
                                    viewModel.selectPlayer(null)
                                    showPlayerDropdown = false
                                },
                                leadingIcon = if (selectedPlayer == null) {
                                    { Icon(Icons.Default.Check, contentDescription = null) }
                                } else null
                            )
                            HorizontalDivider()
                            players.forEach { player ->
                                DropdownMenuItem(
                                    text = { Text(player.displayName) },
                                    onClick = {
                                        viewModel.selectPlayer(player.id)
                                        showPlayerDropdown = false
                                    },
                                    leadingIcon = if (player.id == selectedPlayer?.id) {
                                        { Icon(Icons.Default.Check, contentDescription = null) }
                                    } else null
                                )
                            }
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Softball field
            SoftballField(
                hits = displayHits,
                onFieldTap = if (selectedPlayer != null && selectedTeam != null) { x, y ->
                    pendingHitLocation = Pair(x, y)
                    showHitDialog = true
                } else null,
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
            )

            // Legend
            HitLegend()

            // Hit count
            Text(
                text = "Total Hits: ${displayHits.size}",
                style = MaterialTheme.typography.bodyMedium
            )
        }
    }

    // Hit type selection dialog
    if (showHitDialog && pendingHitLocation != null) {
        HitInputDialog(
            onDismiss = {
                showHitDialog = false
                pendingHitLocation = null
            },
            onConfirm = { hitType, pitchType, pitchLocation ->
                pendingHitLocation?.let { (x, y) ->
                    viewModel.addHit(
                        locationX = x,
                        locationY = y,
                        hitType = hitType,
                        pitchType = pitchType,
                        pitchLocation = pitchLocation
                    )
                }
                showHitDialog = false
                pendingHitLocation = null
            }
        )
    }
}

@Composable
private fun HitInputDialog(
    onDismiss: () -> Unit,
    onConfirm: (HitType, PitchType?, PitchLocation?) -> Unit
) {
    var selectedHitType by remember { mutableStateOf<HitType?>(null) }
    var selectedPitchType by remember { mutableStateOf<PitchType?>(null) }
    var selectedPitchLocation by remember { mutableStateOf<PitchLocation?>(null) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Record Hit") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
                // Hit type selection
                Text("Hit Type", style = MaterialTheme.typography.labelLarge)
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    HitType.entries.chunked(2).forEach { row ->
                        Column(
                            verticalArrangement = Arrangement.spacedBy(8.dp),
                            modifier = Modifier.weight(1f)
                        ) {
                            row.forEach { hitType ->
                                FilterChip(
                                    selected = selectedHitType == hitType,
                                    onClick = { selectedHitType = hitType },
                                    label = { Text(hitType.displayName) },
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }
                        }
                    }
                }

                // Pitch type selection
                Text("Pitch Type (Optional)", style = MaterialTheme.typography.labelLarge)
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    PitchType.entries.forEach { pitchType ->
                        FilterChip(
                            selected = selectedPitchType == pitchType,
                            onClick = {
                                selectedPitchType = if (selectedPitchType == pitchType) null else pitchType
                            },
                            label = { Text(pitchType.displayName) }
                        )
                    }
                }

                // Pitch location selection
                Text("Pitch Location (Optional)", style = MaterialTheme.typography.labelLarge)
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    PitchLocation.entries.forEach { location ->
                        FilterChip(
                            selected = selectedPitchLocation == location,
                            onClick = {
                                selectedPitchLocation = if (selectedPitchLocation == location) null else location
                            },
                            label = { Text(location.displayName) }
                        )
                    }
                }
            }
        },
        confirmButton = {
            TextButton(
                onClick = {
                    selectedHitType?.let { hitType ->
                        onConfirm(hitType, selectedPitchType, selectedPitchLocation)
                    }
                },
                enabled = selectedHitType != null
            ) {
                Text("Save")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
