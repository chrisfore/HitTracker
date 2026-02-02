package com.cfore.hittracker.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import com.cfore.hittracker.data.Player
import com.cfore.hittracker.data.Team
import com.cfore.hittracker.viewmodel.HitTrackerViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(viewModel: HitTrackerViewModel) {
    val teams by viewModel.teams.collectAsState()
    val selectedTeam by viewModel.selectedTeam.collectAsState()
    val players by viewModel.playersForSelectedTeam.collectAsState()

    var showAddTeamDialog by remember { mutableStateOf(false) }
    var showAddPlayerDialog by remember { mutableStateOf(false) }
    var showRenameTeamDialog by remember { mutableStateOf(false) }
    var teamToDelete by remember { mutableStateOf<Team?>(null) }
    var playerToDelete by remember { mutableStateOf<Player?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") }
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Teams Section
            item {
                Text(
                    text = "Teams",
                    style = MaterialTheme.typography.titleMedium
                )
            }

            items(teams) { team ->
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = if (team.id == selectedTeam?.id)
                            MaterialTheme.colorScheme.primaryContainer
                        else MaterialTheme.colorScheme.surface
                    )
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(team.name)
                        Row {
                            if (team.id == selectedTeam?.id) {
                                IconButton(onClick = { showRenameTeamDialog = true }) {
                                    Icon(Icons.Default.Edit, contentDescription = "Rename")
                                }
                            }
                            IconButton(
                                onClick = { viewModel.selectTeam(team.id) }
                            ) {
                                Icon(
                                    if (team.id == selectedTeam?.id) Icons.Default.CheckCircle
                                    else Icons.Default.RadioButtonUnchecked,
                                    contentDescription = "Select"
                                )
                            }
                            IconButton(onClick = { teamToDelete = team }) {
                                Icon(
                                    Icons.Default.Delete,
                                    contentDescription = "Delete",
                                    tint = MaterialTheme.colorScheme.error
                                )
                            }
                        }
                    }
                }
            }

            item {
                OutlinedButton(
                    onClick = { showAddTeamDialog = true },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.Add, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Add Team")
                }
            }

            // Players Section
            if (selectedTeam != null) {
                item {
                    HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))
                    Text(
                        text = "Players - ${selectedTeam?.name}",
                        style = MaterialTheme.typography.titleMedium
                    )
                }

                items(players) { player ->
                    Card(modifier = Modifier.fillMaxWidth()) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Text(player.displayName)
                                Text(
                                    text = "Lineup #${player.lineupOrder}",
                                    style = MaterialTheme.typography.bodySmall
                                )
                            }
                            IconButton(onClick = { playerToDelete = player }) {
                                Icon(
                                    Icons.Default.Delete,
                                    contentDescription = "Delete",
                                    tint = MaterialTheme.colorScheme.error
                                )
                            }
                        }
                    }
                }

                item {
                    OutlinedButton(
                        onClick = { showAddPlayerDialog = true },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Icon(Icons.Default.Add, contentDescription = null)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Add Player")
                    }
                }
            }

            // Data Management
            item {
                HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))
                Text(
                    text = "Data Management",
                    style = MaterialTheme.typography.titleMedium
                )
            }

            item {
                OutlinedButton(
                    onClick = { viewModel.clearAllHits() },
                    colors = ButtonDefaults.outlinedButtonColors(
                        contentColor = MaterialTheme.colorScheme.error
                    ),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Icon(Icons.Default.DeleteSweep, contentDescription = null)
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Clear All Hit Data")
                }
            }

            // App Info
            item {
                HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))
                Text(
                    text = "HitTracker for Android",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "Version 1.0",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }

    // Add Team Dialog
    if (showAddTeamDialog) {
        AddTeamDialog(
            onDismiss = { showAddTeamDialog = false },
            onConfirm = { name ->
                viewModel.addTeam(name)
                showAddTeamDialog = false
            }
        )
    }

    // Add Player Dialog
    if (showAddPlayerDialog && selectedTeam != null) {
        AddPlayerDialog(
            onDismiss = { showAddPlayerDialog = false },
            onConfirm = { name, number ->
                viewModel.addPlayer(selectedTeam!!.id, name, number)
                showAddPlayerDialog = false
            }
        )
    }

    // Rename Team Dialog
    if (showRenameTeamDialog && selectedTeam != null) {
        RenameTeamDialog(
            currentName = selectedTeam!!.name,
            onDismiss = { showRenameTeamDialog = false },
            onConfirm = { newName ->
                viewModel.updateTeamName(selectedTeam!!.id, newName)
                showRenameTeamDialog = false
            }
        )
    }

    // Delete Team Confirmation
    teamToDelete?.let { team ->
        AlertDialog(
            onDismissRequest = { teamToDelete = null },
            title = { Text("Delete Team?") },
            text = { Text("This will delete \"${team.name}\" and all associated players and hits.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        viewModel.deleteTeam(team)
                        teamToDelete = null
                    }
                ) {
                    Text("Delete", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { teamToDelete = null }) {
                    Text("Cancel")
                }
            }
        )
    }

    // Delete Player Confirmation
    playerToDelete?.let { player ->
        AlertDialog(
            onDismissRequest = { playerToDelete = null },
            title = { Text("Delete Player?") },
            text = { Text("This will delete \"${player.displayName}\" and all their hit data.") },
            confirmButton = {
                TextButton(
                    onClick = {
                        viewModel.deletePlayer(player)
                        playerToDelete = null
                    }
                ) {
                    Text("Delete", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { playerToDelete = null }) {
                    Text("Cancel")
                }
            }
        )
    }
}

@Composable
private fun AddTeamDialog(
    onDismiss: () -> Unit,
    onConfirm: (String) -> Unit
) {
    var teamName by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Team") },
        text = {
            OutlinedTextField(
                value = teamName,
                onValueChange = { teamName = it },
                label = { Text("Team Name") },
                singleLine = true
            )
        },
        confirmButton = {
            TextButton(
                onClick = { onConfirm(teamName.trim()) },
                enabled = teamName.isNotBlank()
            ) {
                Text("Add")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
private fun AddPlayerDialog(
    onDismiss: () -> Unit,
    onConfirm: (String, String) -> Unit
) {
    var playerName by remember { mutableStateOf("") }
    var playerNumber by remember { mutableStateOf("") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Add Player") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                OutlinedTextField(
                    value = playerNumber,
                    onValueChange = { if (it.length <= 3) playerNumber = it.filter { c -> c.isDigit() } },
                    label = { Text("Number") },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
                )
                OutlinedTextField(
                    value = playerName,
                    onValueChange = { playerName = it },
                    label = { Text("Name (Optional)") },
                    singleLine = true
                )
            }
        },
        confirmButton = {
            TextButton(
                onClick = { onConfirm(playerName.trim(), playerNumber.trim()) },
                enabled = playerNumber.isNotBlank()
            ) {
                Text("Add")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
private fun RenameTeamDialog(
    currentName: String,
    onDismiss: () -> Unit,
    onConfirm: (String) -> Unit
) {
    var teamName by remember { mutableStateOf(currentName) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Rename Team") },
        text = {
            OutlinedTextField(
                value = teamName,
                onValueChange = { teamName = it },
                label = { Text("Team Name") },
                singleLine = true
            )
        },
        confirmButton = {
            TextButton(
                onClick = { onConfirm(teamName.trim()) },
                enabled = teamName.isNotBlank()
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
