import SwiftUI
import PDFKit

struct ResultsView: View {
    @EnvironmentObject var database: DatabaseManager
    @State private var selectedPlayer: Player?
    @State private var selectedTeam: Team?
    @State private var showingShareSheet = false
    @State private var pdfURL: URL?
    @State private var isGeneratingPDF = false

    // Date filtering
    @State private var filterByDate = false
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var endDate = Date()

    var filteredPlayers: [Player] {
        if let team = selectedTeam {
            return database.getPlayers(for: team.id)
        }
        // When showing all teams, sort by team name first, then lineup order
        return database.players.sorted { p1, p2 in
            let team1Name = database.opponentTeams.first { $0.id == p1.teamId }?.name ?? ""
            let team2Name = database.opponentTeams.first { $0.id == p2.teamId }?.name ?? ""
            if team1Name != team2Name {
                return team1Name < team2Name
            }
            return p1.lineupOrder < p2.lineupOrder
        }
    }

    // Filtered hits based on date range
    var dateFilteredHits: [Hit] {
        guard filterByDate else { return database.hits }
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
        return database.hits.filter { $0.timestamp >= startOfDay && $0.timestamp <= endOfDay }
    }

    var body: some View {
        NavigationStack {
            List {
                // Date Filter & Export Section
                Section {
                    Toggle("Filter by Date", isOn: $filterByDate)

                    if filterByDate {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }

                    if !database.opponentTeams.isEmpty {
                        Button {
                            exportToPDF()
                        } label: {
                            HStack {
                                Text("Export to PDF")
                                Spacer()
                                if isGeneratingPDF {
                                    ProgressView()
                                } else {
                                    Image(systemName: "square.and.arrow.up")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .disabled(isGeneratingPDF)
                    }
                }

                // Team Filter
                Section {
                    Picker("Team", selection: $selectedTeam) {
                        Text("All Teams").tag(nil as Team?)
                        ForEach(database.opponentTeams) { team in
                            Text(team.name).tag(team as Team?)
                        }
                    }
                }

                // Player Filter
                Section {
                    Picker("Player", selection: $selectedPlayer) {
                        Text("All Players").tag(nil as Player?)
                        ForEach(filteredPlayers) { player in
                            Text(player.displayName).tag(player as Player?)
                        }
                    }
                }

                if database.opponentTeams.isEmpty {
                    // Empty state - no teams
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "person.3")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No Teams Yet")
                                .font(.headline)
                            Text("Create a team in Settings to start tracking hits.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                    }
                } else if let player = selectedPlayer {
                    // Individual player stats
                    PlayerStatsSection(player: player, dateFilteredHits: dateFilteredHits)
                } else {
                    // Team overview
                    TeamOverviewSection(selectedTeam: selectedTeam, dateFilteredHits: dateFilteredHits, selectedPlayer: $selectedPlayer)
                }
            }
            .sheet(isPresented: $showingShareSheet, onDismiss: {
                // Clean up temp file after sharing
                if let url = pdfURL {
                    try? FileManager.default.removeItem(at: url)
                    pdfURL = nil
                }
            }) {
                if let url = pdfURL {
                    ShareSheet(items: [url])
                }
            }
            .onChange(of: selectedTeam) {
                // Reset player selection when team changes
                selectedPlayer = nil
            }
            .onChange(of: database.players) {
                // Clear selection if selected player was deleted
                if let player = selectedPlayer,
                   !database.players.contains(where: { $0.id == player.id }) {
                    selectedPlayer = nil
                }
            }
            .onChange(of: database.opponentTeams) {
                // Clear team selection if selected team was deleted
                if let team = selectedTeam,
                   !database.opponentTeams.contains(where: { $0.id == team.id }) {
                    selectedTeam = nil
                }
            }
        }
    }

    private func exportToPDF() {
        isGeneratingPDF = true

        // Generate PDF on background thread with delay to ensure UI updates
        DispatchQueue.global(qos: .userInitiated).async {
            let pdfGenerator = PDFGenerator(
                database: database,
                selectedTeam: selectedTeam,
                selectedPlayer: selectedPlayer,
                dateFilteredHits: dateFilteredHits,
                filterByDate: filterByDate,
                startDate: startDate,
                endDate: endDate
            )

            let data = pdfGenerator.generatePDF()
            let fileName = pdfGenerator.generateFileName()

            // Save to temp file
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent(fileName)

            do {
                try data.write(to: fileURL)

                // Small delay to ensure file is written
                Thread.sleep(forTimeInterval: 0.3)

                DispatchQueue.main.async {
                    self.pdfURL = fileURL
                    self.isGeneratingPDF = false
                    self.showingShareSheet = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.isGeneratingPDF = false
                }
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - PDF Generator

class PDFGenerator {
    let database: DatabaseManager
    let selectedTeam: Team?
    let selectedPlayer: Player?
    let dateFilteredHits: [Hit]
    let filterByDate: Bool
    let startDate: Date
    let endDate: Date

    private let pageWidth: CGFloat = 612  // Letter size
    private let pageHeight: CGFloat = 792
    private let margin: CGFloat = 40

    init(database: DatabaseManager, selectedTeam: Team?, selectedPlayer: Player?,
         dateFilteredHits: [Hit], filterByDate: Bool, startDate: Date, endDate: Date) {
        self.database = database
        self.selectedTeam = selectedTeam
        self.selectedPlayer = selectedPlayer
        self.dateFilteredHits = dateFilteredHits
        self.filterByDate = filterByDate
        self.startDate = startDate
        self.endDate = endDate
    }

    func generateFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())

        var baseName: String
        if let player = selectedPlayer {
            // Clean player name for filename
            let playerName = player.name.isEmpty ? "Player\(player.number)" : player.name
            baseName = playerName.replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "/", with: "-")
        } else if let team = selectedTeam {
            baseName = team.name.replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "/", with: "-")
        } else {
            baseName = "All_Data"
        }

        return "\(baseName)_\(timestamp).pdf"
    }

    func generatePDF() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "HitTracker",
            kCGPDFContextAuthor: "HitTracker App",
            kCGPDFContextTitle: pdfTitle()
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()
            var yPosition = margin

            // Draw logo if available
            if let logo = database.loadLogo() {
                yPosition = drawLogo(logo, at: yPosition, in: context.cgContext)
            }

            // Draw title
            yPosition = drawTitle(at: yPosition)

            // Draw date range if filtering
            if filterByDate {
                yPosition = drawDateRange(at: yPosition)
            }

            // Draw content based on selection
            if let player = selectedPlayer {
                yPosition = drawPlayerStats(player, at: yPosition, context: context)
            } else {
                yPosition = drawTeamOverview(at: yPosition, context: context)
            }

            // Draw generation date
            drawFooter()
        }

        return data
    }

    private func pdfTitle() -> String {
        if let player = selectedPlayer {
            return "HitTracker Report - \(player.displayName)"
        } else if let team = selectedTeam {
            return "HitTracker Report - \(team.name)"
        }
        return "HitTracker Report - All Teams"
    }

    private func drawDateRange(at yPosition: CGFloat) -> CGFloat {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateRange = "Date Range: \(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"

        let font = UIFont.italicSystemFont(ofSize: 12)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.darkGray
        ]

        let size = dateRange.size(withAttributes: attributes)
        let x = (pageWidth - size.width) / 2
        dateRange.draw(at: CGPoint(x: x, y: yPosition), withAttributes: attributes)

        return yPosition + size.height + 15
    }

    private func drawLogo(_ logo: UIImage, at yPosition: CGFloat, in context: CGContext) -> CGFloat {
        let maxLogoHeight: CGFloat = 60
        let maxLogoWidth: CGFloat = 120

        let aspectRatio = logo.size.width / logo.size.height
        var logoWidth = maxLogoWidth
        var logoHeight = logoWidth / aspectRatio

        if logoHeight > maxLogoHeight {
            logoHeight = maxLogoHeight
            logoWidth = logoHeight * aspectRatio
        }

        let logoX = (pageWidth - logoWidth) / 2
        let logoRect = CGRect(x: logoX, y: yPosition, width: logoWidth, height: logoHeight)
        logo.draw(in: logoRect)

        return yPosition + logoHeight + 20
    }

    private func drawTitle(at yPosition: CGFloat) -> CGFloat {
        let title = pdfTitle()
        let titleFont = UIFont.boldSystemFont(ofSize: 24)
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]

        let titleSize = title.size(withAttributes: titleAttributes)
        let titleX = (pageWidth - titleSize.width) / 2
        title.draw(at: CGPoint(x: titleX, y: yPosition), withAttributes: titleAttributes)

        // Draw subtitle with date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        let subtitle = "Generated: \(dateFormatter.string(from: Date()))"
        let subtitleFont = UIFont.systemFont(ofSize: 12)
        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: subtitleFont,
            .foregroundColor: UIColor.gray
        ]
        let subtitleSize = subtitle.size(withAttributes: subtitleAttributes)
        let subtitleX = (pageWidth - subtitleSize.width) / 2
        subtitle.draw(at: CGPoint(x: subtitleX, y: yPosition + titleSize.height + 4), withAttributes: subtitleAttributes)

        return yPosition + titleSize.height + subtitleSize.height + 30
    }

    private func drawPlayerStats(_ player: Player, at yPosition: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        var y = yPosition

        // Filter hits for this player from date-filtered hits
        let hits = dateFilteredHits.filter { $0.playerId == player.id }
        let hitTypeStats = getHitTypeStats(for: hits)
        let pitchStats = getPitchStats(for: hits)

        // Hit Types section
        y = drawSectionHeader("Hit Types", at: y)
        y = drawStatRow("Total Hits", value: "\(hits.count)", at: y)
        for (hitType, count) in hitTypeStats {
            y = drawStatRow(hitType.rawValue, value: "\(count)", at: y, color: hitColor(for: hitType))
        }
        y += 15

        // Pitch Breakdown section (if available)
        if !pitchStats.isEmpty {
            y = drawSectionHeader("Pitch Breakdown", at: y)
            for stat in pitchStats {
                let label = "\(stat.pitchType.rawValue) - \(stat.pitchLocation.rawValue)"
                y = drawStatRow(label, value: "\(stat.count) hit\(stat.count == 1 ? "" : "s")", at: y)
            }
            y += 15
        }

        // Spray Chart
        y = drawSectionHeader("Spray Chart", at: y)
        y = drawSprayChart(hits: hits, at: y)

        // Legend
        y = drawLegend(at: y)

        return y
    }

    private func getHitTypeStats(for hits: [Hit]) -> [(HitType, Int)] {
        var stats: [HitType: Int] = [:]
        for hit in hits {
            stats[hit.hitType, default: 0] += 1
        }
        return HitType.allCases.map { ($0, stats[$0] ?? 0) }
    }

    private func getPitchStats(for hits: [Hit]) -> [PitchStats] {
        var statsDict: [String: Int] = [:]

        for hit in hits {
            if let pitchType = hit.pitchType, let pitchLocation = hit.pitchLocation {
                let key = "\(pitchType.rawValue)|\(pitchLocation.rawValue)"
                statsDict[key, default: 0] += 1
            }
        }

        var stats: [PitchStats] = []
        for (key, count) in statsDict {
            let components = key.split(separator: "|")
            if components.count == 2,
               let pitchType = PitchType(rawValue: String(components[0])),
               let pitchLocation = PitchLocation(rawValue: String(components[1])) {
                stats.append(PitchStats(pitchType: pitchType, pitchLocation: pitchLocation, count: count))
            }
        }

        return stats.sorted { $0.count > $1.count }
    }

    private func drawTeamOverview(at yPosition: CGFloat, context: UIGraphicsPDFRendererContext) -> CGFloat {
        var y = yPosition

        let teamName = selectedTeam?.name ?? "All Teams"
        let players: [Player]
        let relevantHits: [Hit]

        if let team = selectedTeam {
            players = database.getPlayers(for: team.id)
            relevantHits = dateFilteredHits.filter { $0.teamId == team.id }
        } else {
            players = database.players.sorted { $0.lineupOrder < $1.lineupOrder }
            relevantHits = dateFilteredHits
        }

        // Team name
        y = drawSectionHeader("Team: \(teamName)", at: y)
        y = drawStatRow("Total Hits", value: "\(relevantHits.count)", at: y)
        y += 15

        // Hits by Player section
        y = drawSectionHeader("Hits by Player", at: y)
        for player in players {
            let playerHits = relevantHits.filter { $0.playerId == player.id }.count
            let displayName = player.name.isEmpty ? "#\(player.number)" : "#\(player.number) \(player.name)"
            y = drawStatRow(displayName, value: "\(playerHits)", at: y)
        }
        y += 15

        // Combined spray chart for team
        if !relevantHits.isEmpty {
            y = drawSectionHeader("Team Spray Chart", at: y)
            y = drawSprayChart(hits: relevantHits, at: y)
            y = drawLegend(at: y)
        }

        return y
    }

    private func drawSectionHeader(_ title: String, at yPosition: CGFloat) -> CGFloat {
        let font = UIFont.boldSystemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black
        ]
        title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: attributes)
        return yPosition + font.lineHeight + 8
    }

    private func drawStatRow(_ label: String, value: String, at yPosition: CGFloat, color: UIColor? = nil) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 14)
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.darkGray
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]

        // Draw color indicator if provided
        var labelX = margin
        if let color = color {
            let circleRect = CGRect(x: margin, y: yPosition + 3, width: 10, height: 10)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            color.setFill()
            circlePath.fill()
            labelX = margin + 16
        }

        label.draw(at: CGPoint(x: labelX, y: yPosition), withAttributes: labelAttributes)

        let valueSize = value.size(withAttributes: valueAttributes)
        value.draw(at: CGPoint(x: pageWidth - margin - valueSize.width, y: yPosition), withAttributes: valueAttributes)

        return yPosition + font.lineHeight + 4
    }

    private func drawSprayChart(hits: [Hit], at yPosition: CGFloat) -> CGFloat {
        let chartSize: CGFloat = 200
        let chartX = (pageWidth - chartSize) / 2
        let chartRect = CGRect(x: chartX, y: yPosition, width: chartSize, height: chartSize)

        // Draw field background
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()

        // Field shape (90-degree arc)
        let center = CGPoint(x: chartRect.midX, y: chartRect.maxY)
        let radius = chartSize / 1.414

        let fieldPath = UIBezierPath()
        fieldPath.move(to: center)
        fieldPath.addArc(withCenter: center, radius: radius, startAngle: .pi * 1.25, endAngle: .pi * 1.75, clockwise: true)
        fieldPath.close()

        UIColor.green.withAlphaComponent(0.2).setFill()
        fieldPath.fill()
        UIColor.green.setStroke()
        fieldPath.lineWidth = 1
        fieldPath.stroke()

        // Draw hits
        for hit in hits {
            let hitX = chartRect.minX + hit.locationX * chartSize
            let hitY = chartRect.minY + hit.locationY * chartSize
            let hitRect = CGRect(x: hitX - 4, y: hitY - 4, width: 8, height: 8)
            let hitPath = UIBezierPath(ovalIn: hitRect)
            hitColor(for: hit.hitType).setFill()
            hitPath.fill()
        }

        context.restoreGState()

        return yPosition + chartSize + 15
    }

    private func drawLegend(at yPosition: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 10)
        let legendItems: [(String, UIColor)] = [
            ("Fly Ball", .blue),
            ("Line Drive", .red),
            ("Pop Up", .purple),
            ("Grounder", .orange)
        ]

        let itemWidth: CGFloat = 100
        let totalWidth = CGFloat(legendItems.count) * itemWidth
        var x = (pageWidth - totalWidth) / 2

        for (label, color) in legendItems {
            // Draw color circle
            let circleRect = CGRect(x: x, y: yPosition + 2, width: 8, height: 8)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            color.setFill()
            circlePath.fill()

            // Draw label
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.gray
            ]
            label.draw(at: CGPoint(x: x + 12, y: yPosition), withAttributes: attributes)

            x += itemWidth
        }

        return yPosition + font.lineHeight + 10
    }

    private func drawFooter() {
        let font = UIFont.systemFont(ofSize: 10)
        let footer = "Generated by HitTracker - Build \(AppVersion.displayVersion)"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.lightGray
        ]
        let footerSize = footer.size(withAttributes: attributes)
        let footerX = (pageWidth - footerSize.width) / 2
        footer.draw(at: CGPoint(x: footerX, y: pageHeight - margin), withAttributes: attributes)
    }

    private func hitColor(for hitType: HitType) -> UIColor {
        switch hitType {
        case .flyBall: return .blue
        case .lineDrive: return .red
        case .popUp: return .purple
        case .grounder: return .orange
        }
    }
}

// MARK: - Player Stats Section

struct PlayerStatsSection: View {
    let player: Player
    let dateFilteredHits: [Hit]
    @EnvironmentObject var database: DatabaseManager

    var hits: [Hit] {
        dateFilteredHits.filter { $0.playerId == player.id }
    }

    var hitTypeStats: [(HitType, Int)] {
        var stats: [HitType: Int] = [:]
        for hit in hits {
            stats[hit.hitType, default: 0] += 1
        }
        return HitType.allCases.map { ($0, stats[$0] ?? 0) }
    }

    var pitchStats: [PitchStats] {
        var statsDict: [String: Int] = [:]

        for hit in hits {
            if let pitchType = hit.pitchType, let pitchLocation = hit.pitchLocation {
                let key = "\(pitchType.rawValue)|\(pitchLocation.rawValue)"
                statsDict[key, default: 0] += 1
            }
        }

        var stats: [PitchStats] = []
        for (key, count) in statsDict {
            let components = key.split(separator: "|")
            if components.count == 2,
               let pitchType = PitchType(rawValue: String(components[0])),
               let pitchLocation = PitchLocation(rawValue: String(components[1])) {
                stats.append(PitchStats(pitchType: pitchType, pitchLocation: pitchLocation, count: count))
            }
        }

        return stats.sorted { $0.count > $1.count }
    }

    var body: some View {
        Section("Hit Types") {
            HStack {
                Text("Total Hits")
                Spacer()
                Text("\(hits.count)")
                    .fontWeight(.bold)
            }
            ForEach(hitTypeStats, id: \.0) { hitType, count in
                HStack {
                    Circle()
                        .fill(hitColor(for: hitType))
                        .frame(width: 12, height: 12)
                    Text(hitType.rawValue)
                    Spacer()
                    Text("\(count)")
                        .foregroundColor(.secondary)
                }
            }
        }

        if !pitchStats.isEmpty {
            Section("Pitch Breakdown") {
                ForEach(pitchStats) { stat in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(stat.pitchType.rawValue)
                                .font(.subheadline)
                            Text(stat.pitchLocation.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(stat.count) hit\(stat.count == 1 ? "" : "s")")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }

        Section("Spray Chart") {
            HStack {
                Spacer()
                MiniSprayChart(hits: hits)
                    .frame(width: 200, height: 200)
                Spacer()
            }
            .padding(.vertical)
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

// MARK: - Team Overview Section

struct TeamOverviewSection: View {
    let selectedTeam: Team?
    let dateFilteredHits: [Hit]
    @Binding var selectedPlayer: Player?
    @EnvironmentObject var database: DatabaseManager

    var relevantHits: [Hit] {
        if let team = selectedTeam {
            return dateFilteredHits.filter { $0.teamId == team.id }
        }
        return dateFilteredHits
    }

    var playerHitCounts: [(Player, Int)] {
        let players: [Player]
        if let team = selectedTeam {
            players = database.getPlayers(for: team.id)
        } else {
            players = database.players.sorted { $0.lineupOrder < $1.lineupOrder }
        }
        return players.map { player in
            (player, relevantHits.filter { $0.playerId == player.id }.count)
        }
    }

    var body: some View {
        Section("Hits by Player") {
            ForEach(playerHitCounts, id: \.0.id) { player, count in
                Button {
                    selectedPlayer = player
                } label: {
                    HStack {
                        Text("#\(player.number)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 30, alignment: .leading)
                        Text(player.name.isEmpty ? "(No name)" : player.name)
                            .foregroundColor(player.name.isEmpty ? .secondary : .primary)
                        Spacer()
                        Text("\(count)")
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }

        Section("Team Summary") {
            HStack {
                Text("Total Hits")
                Spacer()
                Text("\(relevantHits.count)")
                    .fontWeight(.bold)
            }
        }
    }
}

// MARK: - Mini Spray Chart

struct MiniSprayChart: View {
    let hits: [Hit]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Field outline
                SoftballFieldShape()
                    .fill(Color.green.opacity(0.2))
                    .overlay(
                        SoftballFieldShape()
                            .stroke(Color.green, lineWidth: 1)
                    )

                // Hit dots
                ForEach(hits) { hit in
                    Circle()
                        .fill(hitColor(for: hit.hitType))
                        .frame(width: 10, height: 10)
                        .position(
                            x: hit.locationX * geometry.size.width,
                            y: hit.locationY * geometry.size.height
                        )
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
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

#Preview {
    ResultsView()
        .environmentObject(DatabaseManager.shared)
}
