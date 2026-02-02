package com.cfore.hittracker.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.cfore.hittracker.viewmodel.HitTrackerViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TeamSetupScreen(viewModel: HitTrackerViewModel) {
    var teamName by remember { mutableStateOf("") }
    var showError by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Welcome to HitTracker") }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "Track softball hits against opponent teams",
                style = MaterialTheme.typography.bodyLarge,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(bottom = 32.dp)
            )

            Text(
                text = "Enter your first opponent team name to get started:",
                style = MaterialTheme.typography.bodyMedium,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(bottom = 16.dp)
            )

            OutlinedTextField(
                value = teamName,
                onValueChange = {
                    teamName = it
                    showError = false
                },
                label = { Text("Opponent Team Name") },
                singleLine = true,
                isError = showError,
                supportingText = if (showError) {
                    { Text("Please enter a team name") }
                } else null,
                modifier = Modifier.fillMaxWidth()
            )

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = {
                    if (teamName.isBlank()) {
                        showError = true
                    } else {
                        viewModel.addTeam(teamName.trim())
                    }
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Get Started")
            }
        }
    }
}
