import SwiftUI

struct TrackingView: View {
    @EnvironmentObject var database: DatabaseManager
    @State private var selectedPlayerIndex = 0
    @State private var showingHitInput = false
    @State private var tapLocation: CGPoint = .zero
    @State private var fieldSize: CGSize = .zero
    @State private var selectedPitchFilter: PitchStats?

    var sortedPlayers: [Player] {
        guard let teamId = database.selectedTeamId else { return [] }
        return database.getPlayers(for: teamId)
    }

    var selectedPlayer: Player? {
        guard !sortedPlayers.isEmpty, selectedPlayerIndex < sortedPlayers.count else { return nil }
        return sortedPlayers[selectedPlayerIndex]
    }

    var playerHits: [Hit] {
        guard let player = selectedPlayer else { return [] }
        return database.getHits(forPlayer: player.id)
    }

    var pitchStats: [PitchStats] {
        guard let player = selectedPlayer else { return [] }
        return database.getPitchStats(for: player.id)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Batter Selector
                if !sortedPlayers.isEmpty {
                    BatterSelector(
                        players: sortedPlayers,
                        selectedIndex: $selectedPlayerIndex
                    )
                    .padding(.vertical, 8)
                }

                // Pitch Stats for Selected Batter (tappable for filtering)
                if !pitchStats.isEmpty {
                    PitchStatsBar(stats: pitchStats, selectedFilter: $selectedPitchFilter)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                }

                // Softball Field (smaller to fit screen)
                GeometryReader { geometry in
                    SoftballFieldView(
                        hits: playerHits,
                        pitchFilter: selectedPitchFilter,
                        onTap: { location in
                            tapLocation = location
                            fieldSize = geometry.size
                            showingHitInput = true
                        }
                    )
                }
                .padding()
                .frame(maxHeight: 320)

                // Hit Type Legend
                HitTypeLegend()
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Team selector menu
                    Menu {
                        ForEach(database.opponentTeams) { team in
                            Button {
                                database.selectTeam(team.id)
                                selectedPlayerIndex = 0
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
                            Text(database.selectedTeam?.name ?? "Select Team")
                                .font(.headline)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingHitInput) {
                HitInputSheet(
                    playerName: selectedPlayer?.displayName ?? "",
                    onSave: { hitType, pitchType, pitchLocation in
                        if let player = selectedPlayer, let teamId = database.selectedTeamId {
                            let relativeX = tapLocation.x / fieldSize.width
                            let relativeY = tapLocation.y / fieldSize.height
                            database.addHit(
                                playerId: player.id,
                                teamId: teamId,
                                locationX: relativeX,
                                locationY: relativeY,
                                hitType: hitType,
                                pitchType: pitchType,
                                pitchLocation: pitchLocation
                            )
                        }
                    }
                )
                .presentationDetents([.medium])
            }
            .onChange(of: database.selectedTeamId) {
                selectedPlayerIndex = 0
                selectedPitchFilter = nil
            }
        }
    }
}

// MARK: - Batter Selector

struct BatterSelector: View {
    let players: [Player]
    @Binding var selectedIndex: Int

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                        BatterPill(
                            player: player,
                            isSelected: index == selectedIndex
                        )
                        .id(index)
                        .onTapGesture {
                            withAnimation {
                                selectedIndex = index
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: selectedIndex) {
                withAnimation {
                    proxy.scrollTo(selectedIndex, anchor: .center)
                }
            }
        }
    }
}

struct BatterPill: View {
    let player: Player
    let isSelected: Bool

    var body: some View {
        Text(player.displayName)
            .font(.subheadline)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
    }
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

                // Infield dirt
                InfieldShape()
                    .fill(Color.brown.opacity(0.3))
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.75)

                // Base paths
                BasePathsView()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.35, height: geometry.size.height * 0.35)
                    .position(x: geometry.size.width / 2, y: geometry.size.height * 0.78)

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
                onTap(location)
            }
        }
        .aspectRatio(1, contentMode: .fit)
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
        let radius = min(rect.width, rect.height)

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
        let radius = min(rect.width, rect.height) * 0.8

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
        let diamondWidth = size.width * 0.35
        let diamondHeight = size.height * 0.35
        let centerX = size.width / 2
        let centerY = size.height * 0.78

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
                        onSave(selectedHitType, selectedPitchType, selectedPitchLocation)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TrackingView()
        .environmentObject(DatabaseManager.shared)
}
