import SwiftUI

struct TrackingView: View {
    @EnvironmentObject var database: DatabaseManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedPlayer: Player?
    @State private var showingHitInput = false
    @State private var showingAddTeam = false
    @State private var normalizedTapLocation: CGPoint = .zero  // Already normalized 0-1
    @State private var selectedPitchFilter: PitchStats?
    @State private var isLandscape = false

    var sortedPlayers: [Player] {
        guard let teamId = database.selectedTeamId else { return [] }
        return database.getPlayers(for: teamId)
    }

    var playerHits: [Hit] {
        guard let player = selectedPlayer else { return [] }
        return database.getHits(forPlayer: player.id)
    }

    var pitchStats: [PitchStats] {
        guard let player = selectedPlayer else { return [] }
        return database.getPitchStats(for: player.id)
    }

    private var teamSelectorText: String {
        if database.opponentTeams.isEmpty {
            return "Enter Team"
        }
        return database.selectedTeam?.name ?? "Select Team"
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let currentIsLandscape = geometry.size.width > geometry.size.height
                let safeWidth = max(geometry.size.width, 100)
                let safeHeight = max(geometry.size.height, 100)

                Group {
                    if currentIsLandscape {
                        // Landscape layout: controls on left, field on right
                        HStack(spacing: 0) {
                            // Left side: Team, Player, Pitch Stats
                            VStack(alignment: .leading, spacing: 12) {
                                // Team Selector
                                if database.opponentTeams.isEmpty {
                                    Button {
                                        showingAddTeam = true
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text("Enter Team")
                                                .font(.headline)
                                            Image(systemName: "plus.circle")
                                                .font(.caption)
                                        }
                                    }
                                } else {
                                    Menu {
                                        ForEach(database.opponentTeams) { team in
                                            Button {
                                                database.selectTeam(team.id)
                                                selectedPlayer = nil
                                                selectedPitchFilter = nil
                                            } label: {
                                                HStack {
                                                    Text(team.name)
                                                    if team.id == database.selectedTeamId {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(teamSelectorText)
                                                .font(.headline)
                                            Image(systemName: "chevron.down")
                                                .font(.caption)
                                        }
                                    }
                                }

                                // Player Selector
                                if !sortedPlayers.isEmpty {
                                    Picker("Select Player", selection: $selectedPlayer) {
                                        Text("Select Player").tag(nil as Player?)
                                        ForEach(sortedPlayers) { player in
                                            Text(player.displayName).tag(player as Player?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }

                                // Pitch Stats (vertical in landscape)
                                if !pitchStats.isEmpty {
                                    PitchStatsBarVertical(stats: pitchStats, selectedFilter: $selectedPitchFilter)
                                }

                                Spacer()
                            }
                            .padding()
                            .frame(width: safeWidth * 0.3)

                            // Right side: Field and Legend
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)

                                let landscapeFieldSize = max(min(safeWidth * 0.65, safeHeight - 50), 100)
                                SoftballFieldView(
                                    hits: playerHits,
                                    pitchFilter: selectedPitchFilter,
                                    onTap: { normalizedLocation in
                                        normalizedTapLocation = normalizedLocation
                                        showingHitInput = true
                                    }
                                )
                                .frame(width: landscapeFieldSize, height: landscapeFieldSize)

                                Spacer(minLength: 0)

                                HitTypeLegend()
                                    .padding(.bottom, 8)
                            }
                            .frame(width: safeWidth * 0.7)
                        }
                    } else {
                        // Portrait layout: vertical stack
                        let headerHeight: CGFloat = sortedPlayers.isEmpty ? 0 : 52
                        let pitchStatsHeight: CGFloat = pitchStats.isEmpty ? 0 : 70
                        let legendHeight: CGFloat = 44
                        let horizontalPadding: CGFloat = 32
                        let availableHeight = safeHeight - headerHeight - pitchStatsHeight - legendHeight
                        let availableWidth = safeWidth - horizontalPadding
                        let fieldSize = max(min(availableWidth, availableHeight), 100)

                        VStack(spacing: 0) {
                            // Player Selector Dropdown
                            if !sortedPlayers.isEmpty {
                                Picker("Select Player", selection: $selectedPlayer) {
                                    Text("Select Player").tag(nil as Player?)
                                    ForEach(sortedPlayers) { player in
                                        Text(player.displayName).tag(player as Player?)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }

                            // Pitch Stats for Selected Batter (tappable for filtering)
                            if !pitchStats.isEmpty {
                                PitchStatsBar(stats: pitchStats, selectedFilter: $selectedPitchFilter)
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                            }

                            Spacer(minLength: 0)

                            // Softball Field (sized to fill available space)
                            SoftballFieldView(
                                hits: playerHits,
                                pitchFilter: selectedPitchFilter,
                                onTap: { normalizedLocation in
                                    normalizedTapLocation = normalizedLocation
                                    showingHitInput = true
                                }
                            )
                            .frame(width: fieldSize, height: fieldSize)

                            Spacer(minLength: 0)

                            // Hit Type Legend
                            HitTypeLegend()
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                        }
                    }
                }
                .frame(width: safeWidth, height: safeHeight)
                .onChange(of: currentIsLandscape) { _, newValue in
                    isLandscape = newValue
                }
                .onAppear {
                    isLandscape = geometry.size.width > geometry.size.height
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !isLandscape {
                    ToolbarItem(placement: .principal) {
                        // Team selector (only in portrait)
                        if database.opponentTeams.isEmpty {
                            Button {
                                showingAddTeam = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Enter Team")
                                        .font(.headline)
                                    Image(systemName: "plus.circle")
                                        .font(.caption)
                                }
                            }
                        } else {
                            Menu {
                                ForEach(database.opponentTeams) { team in
                                    Button {
                                        database.selectTeam(team.id)
                                        selectedPlayer = nil
                                        selectedPitchFilter = nil
                                    } label: {
                                        HStack {
                                            Text(team.name)
                                            if team.id == database.selectedTeamId {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(teamSelectorText)
                                        .font(.headline)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingHitInput) {
                HitInputSheet(
                    playerName: selectedPlayer?.displayName ?? "",
                    onSave: { hitType, pitchType, pitchLocation in
                        if let player = selectedPlayer, let teamId = database.selectedTeamId {
                            database.addHit(
                                playerId: player.id,
                                teamId: teamId,
                                locationX: normalizedTapLocation.x,
                                locationY: normalizedTapLocation.y,
                                hitType: hitType,
                                pitchType: pitchType,
                                pitchLocation: pitchLocation
                            )
                        }
                    }
                )
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showingAddTeam) {
                AddTeamSheet(onComplete: { teamName, players in
                    let team = database.addTeam(name: teamName)
                    database.selectTeam(team.id)
                    for player in players {
                        database.addPlayer(teamId: team.id, name: player.name, number: player.number)
                    }
                })
            }
            .onChange(of: database.selectedTeamId) {
                selectedPlayer = nil
                selectedPitchFilter = nil
            }
        }
    }
}

// MARK: - Add Team Sheet

struct AddTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onComplete: (String, [AddTeamPlayerInput]) -> Void

    @State private var teamName = ""
    @State private var players: [AddTeamPlayerInput] = [
        AddTeamPlayerInput(name: "", number: "")
    ]

    var isValid: Bool {
        !teamName.isEmpty && players.contains { !$0.number.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Team Information") {
                    TextField("Team Name", text: $teamName)
                }

                Section("Lineup") {
                    ForEach($players) { $player in
                        HStack {
                            TextField("Number", text: $player.number)
                                .keyboardType(.numberPad)
                                .frame(width: 60)

                            TextField("Name (Optional)", text: $player.name)
                        }
                    }
                    .onDelete(perform: deletePlayer)

                    Button {
                        players.append(AddTeamPlayerInput(name: "", number: ""))
                    } label: {
                        Label("Add Player", systemImage: "plus.circle")
                    }
                }

                Section {
                    Button {
                        onComplete(teamName, players.filter { !$0.number.isEmpty })
                        dismiss()
                    } label: {
                        Text("Save Team")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Add Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func deletePlayer(at offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }
}

struct AddTeamPlayerInput: Identifiable {
    let id = UUID()
    var name: String
    var number: String
}

// MARK: - Pitch Stats Bar (Tappable for filtering)

struct PitchStatsBar: View {
    let stats: [PitchStats]
    @Binding var selectedFilter: PitchStats?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(stats.prefix(5)) { stat in
                    VStack(spacing: 2) {
                        Text("\(stat.pitchType.rawValue)")
                            .font(.system(size: 10))
                        Text("\(stat.pitchLocation.rawValue)")
                            .font(.system(size: 9))
                            .foregroundColor(isSelected(stat) ? .white.opacity(0.8) : .secondary)
                        Text("\(stat.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(isSelected(stat) ? Color.blue : Color(.systemGray6))
                    .foregroundColor(isSelected(stat) ? .white : .primary)
                    .cornerRadius(8)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isSelected(stat) {
                                selectedFilter = nil
                            } else {
                                selectedFilter = stat
                            }
                        }
                    }
                }
            }
        }
    }

    private func isSelected(_ stat: PitchStats) -> Bool {
        guard let selected = selectedFilter else { return false }
        return selected.pitchType == stat.pitchType &&
               selected.pitchLocation == stat.pitchLocation
    }
}

// MARK: - Pitch Stats Bar Vertical (for landscape)

struct PitchStatsBarVertical: View {
    let stats: [PitchStats]
    @Binding var selectedFilter: PitchStats?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                ForEach(stats.prefix(5)) { stat in
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(stat.pitchType.rawValue)")
                                .font(.system(size: 11))
                            Text("\(stat.pitchLocation.rawValue)")
                                .font(.system(size: 9))
                                .foregroundColor(isSelected(stat) ? .white.opacity(0.8) : .secondary)
                        }
                        Spacer()
                        Text("\(stat.count)")
                            .font(.caption)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isSelected(stat) ? Color.blue : Color(.systemGray6))
                    .foregroundColor(isSelected(stat) ? .white : .primary)
                    .cornerRadius(8)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if isSelected(stat) {
                                selectedFilter = nil
                            } else {
                                selectedFilter = stat
                            }
                        }
                    }
                }
            }
        }
    }

    private func isSelected(_ stat: PitchStats) -> Bool {
        guard let selected = selectedFilter else { return false }
        return selected.pitchType == stat.pitchType &&
               selected.pitchLocation == stat.pitchLocation
    }
}

// MARK: - Hit Type Legend

struct HitTypeLegend: View {
    var body: some View {
        HStack(spacing: 16) {
            ForEach(HitType.allCases, id: \.self) { hitType in
                HStack(spacing: 4) {
                    Circle()
                        .fill(hitColor(for: hitType))
                        .frame(width: 10, height: 10)
                    Text(hitType.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    func hitColor(for hitType: HitType) -> Color {
        switch hitType {
        case .flyBall: return .blue
        case .lineDrive: return .red
        case .popUp: return .purple
        case .grounder: return .orange
        }
    }
}

// MARK: - Softball Field View

struct SoftballFieldView: View {
    let hits: [Hit]
    var pitchFilter: PitchStats?
    let onTap: (CGPoint) -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Field background
                SoftballFieldShape()
                    .fill(Color.green.opacity(0.3))
                    .overlay(
                        SoftballFieldShape()
                            .stroke(Color.green, lineWidth: 2)
                    )

                // Infield dirt - sized to cover base paths
                InfieldShape()
                    .fill(Color.brown.opacity(0.3))
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.82)

                // Base paths
                BasePathsView()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.4)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.82)

                // Bases
                BasesView(size: geometry.size)

                // Hit dots with filtering
                ForEach(hits) { hit in
                    Circle()
                        .fill(dotColor(for: hit))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .position(
                            x: hit.locationX * geometry.size.width,
                            y: hit.locationY * geometry.size.height
                        )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { location in
                // Normalize coordinates to 0-1 range using internal geometry
                let normalizedX = location.x / geometry.size.width
                let normalizedY = location.y / geometry.size.height
                onTap(CGPoint(x: normalizedX, y: normalizedY))
            }
        }
    }

    func dotColor(for hit: Hit) -> Color {
        // If filter is active, show matching hits as black
        if let filter = pitchFilter {
            if hit.pitchType == filter.pitchType && hit.pitchLocation == filter.pitchLocation {
                return .black
            }
        }
        // Non-matching or no filter: use original hit type color
        return hitColor(for: hit.hitType)
    }

    func hitColor(for hitType: HitType) -> Color {
        switch hitType {
        case .flyBall: return .blue
        case .lineDrive: return .red
        case .popUp: return .purple
        case .grounder: return .orange
        }
    }
}

// MARK: - Field Shapes

struct SoftballFieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.maxY)
        // For a 90° arc (225° to 315°), the corners extend to 0.707 * radius horizontally
        // To fit within width W, we need: radius * 0.707 * 2 <= W, so radius <= W / 1.414
        // To fit within height H, we need: radius <= H
        let maxRadiusForWidth = rect.width / 1.414
        let maxRadiusForHeight = rect.height
        let radius = min(maxRadiusForWidth, maxRadiusForHeight)

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: .degrees(225), endAngle: .degrees(315), clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct InfieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.midX, y: rect.maxY)
        let maxRadiusForWidth = rect.width / 1.414
        let maxRadiusForHeight = rect.height
        let radius = min(maxRadiusForWidth, maxRadiusForHeight) * 0.8

        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: .degrees(225), endAngle: .degrees(315), clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct BasePathsView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let homeBase = CGPoint(x: rect.midX, y: rect.maxY)
        let firstBase = CGPoint(x: rect.maxX, y: rect.midY)
        let secondBase = CGPoint(x: rect.midX, y: rect.minY)
        let thirdBase = CGPoint(x: rect.minX, y: rect.midY)

        path.move(to: homeBase)
        path.addLine(to: firstBase)
        path.addLine(to: secondBase)
        path.addLine(to: thirdBase)
        path.addLine(to: homeBase)

        return path
    }
}

struct BasesView: View {
    let size: CGSize

    var body: some View {
        let baseSize: CGFloat = 12
        let diamondWidth = size.width * 0.4
        let diamondHeight = size.height * 0.4
        let centerX = size.width / 2
        let centerY = size.height * 0.82

        ZStack {
            // Home plate
            HomePlateShape()
                .fill(Color.white)
                .frame(width: baseSize * 1.2, height: baseSize)
                .position(x: centerX, y: centerY + diamondHeight / 2)

            // First base
            Rectangle()
                .fill(Color.white)
                .frame(width: baseSize, height: baseSize)
                .rotationEffect(.degrees(45))
                .position(x: centerX + diamondWidth / 2, y: centerY)

            // Second base
            Rectangle()
                .fill(Color.white)
                .frame(width: baseSize, height: baseSize)
                .rotationEffect(.degrees(45))
                .position(x: centerX, y: centerY - diamondHeight / 2)

            // Third base
            Rectangle()
                .fill(Color.white)
                .frame(width: baseSize, height: baseSize)
                .rotationEffect(.degrees(45))
                .position(x: centerX - diamondWidth / 2, y: centerY)
        }
    }
}

struct HomePlateShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Hit Input Sheet

struct HitInputSheet: View {
    let playerName: String
    let onSave: (HitType, PitchType?, PitchLocation?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var selectedHitType: HitType = .lineDrive
    @State private var selectedPitchType: PitchType?
    @State private var selectedPitchLocation: PitchLocation?

    var body: some View {
        NavigationStack {
            Form {
                Section("Hit Type (Required)") {
                    Picker("Hit Type", selection: $selectedHitType) {
                        ForEach(HitType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Pitch Type (Optional)") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PitchType.allCases, id: \.self) { type in
                                Button {
                                    if selectedPitchType == type {
                                        selectedPitchType = nil
                                    } else {
                                        selectedPitchType = type
                                    }
                                } label: {
                                    Text(type.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedPitchType == type ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(selectedPitchType == type ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }

                Section("Pitch Location (Optional)") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PitchLocation.allCases, id: \.self) { location in
                                Button {
                                    if selectedPitchLocation == location {
                                        selectedPitchLocation = nil
                                    } else {
                                        selectedPitchLocation = location
                                    }
                                } label: {
                                    Text(location.rawValue)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedPitchLocation == location ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(selectedPitchLocation == location ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Record Hit - \(playerName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveAndDismiss()
                    }
                }
            }
            .onChange(of: selectedPitchType) {
                checkAutoSave()
            }
            .onChange(of: selectedPitchLocation) {
                checkAutoSave()
            }
        }
    }

    private func checkAutoSave() {
        // Auto-save when all three fields are selected
        if selectedPitchType != nil && selectedPitchLocation != nil {
            saveAndDismiss()
        }
    }

    private func saveAndDismiss() {
        onSave(selectedHitType, selectedPitchType, selectedPitchLocation)
        dismiss()
    }
}

#Preview {
    TrackingView()
        .environmentObject(DatabaseManager.shared)
}
