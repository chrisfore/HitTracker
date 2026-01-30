import SwiftUI

/// A view that renders a batter icon suitable for app icon export
/// To export: Run in preview, screenshot at 1024x1024, save as PNG
struct AppIconView: View {
    var size: CGFloat = 1024
    var backgroundColor: Color = .white
    var foregroundColor: Color = .black

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 100

            // Head
            let headCenter = CGPoint(x: 55 * scale, y: 22 * scale)
            let headRadius: CGFloat = 8 * scale
            let headPath = Path(ellipseIn: CGRect(
                x: headCenter.x - headRadius,
                y: headCenter.y - headRadius,
                width: headRadius * 2,
                height: headRadius * 2
            ))
            context.fill(headPath, with: .color(foregroundColor))

            // Body (torso) - slightly angled for batting stance
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: 52 * scale, y: 30 * scale))
            bodyPath.addLine(to: CGPoint(x: 45 * scale, y: 55 * scale))
            context.stroke(bodyPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 8 * scale, lineCap: .round))

            // Back leg (planted)
            var backLegPath = Path()
            backLegPath.move(to: CGPoint(x: 45 * scale, y: 55 * scale))
            backLegPath.addLine(to: CGPoint(x: 30 * scale, y: 70 * scale))
            backLegPath.addLine(to: CGPoint(x: 25 * scale, y: 85 * scale))
            context.stroke(backLegPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 7 * scale, lineCap: .round, lineJoin: .round))

            // Front leg (stepping forward)
            var frontLegPath = Path()
            frontLegPath.move(to: CGPoint(x: 45 * scale, y: 55 * scale))
            frontLegPath.addLine(to: CGPoint(x: 55 * scale, y: 70 * scale))
            frontLegPath.addLine(to: CGPoint(x: 65 * scale, y: 85 * scale))
            context.stroke(frontLegPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 7 * scale, lineCap: .round, lineJoin: .round))

            // Back arm (holding bat handle)
            var backArmPath = Path()
            backArmPath.move(to: CGPoint(x: 50 * scale, y: 35 * scale))
            backArmPath.addLine(to: CGPoint(x: 38 * scale, y: 38 * scale))
            backArmPath.addLine(to: CGPoint(x: 30 * scale, y: 30 * scale))
            context.stroke(backArmPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 6 * scale, lineCap: .round, lineJoin: .round))

            // Front arm (holding bat)
            var frontArmPath = Path()
            frontArmPath.move(to: CGPoint(x: 50 * scale, y: 35 * scale))
            frontArmPath.addLine(to: CGPoint(x: 60 * scale, y: 32 * scale))
            frontArmPath.addLine(to: CGPoint(x: 68 * scale, y: 25 * scale))
            context.stroke(frontArmPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 6 * scale, lineCap: .round, lineJoin: .round))

            // Baseball bat
            var batPath = Path()
            batPath.move(to: CGPoint(x: 28 * scale, y: 35 * scale))  // Bat handle
            batPath.addLine(to: CGPoint(x: 70 * scale, y: 12 * scale))  // Bat barrel
            context.stroke(batPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 5 * scale, lineCap: .round))

            // Bat barrel (thicker end)
            var barrelPath = Path()
            barrelPath.move(to: CGPoint(x: 62 * scale, y: 16 * scale))
            barrelPath.addLine(to: CGPoint(x: 75 * scale, y: 10 * scale))
            context.stroke(barrelPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 8 * scale, lineCap: .round))
        }
        .frame(width: size, height: size)
        .background(backgroundColor)
    }
}

/// Alternative simpler batter design
struct AppIconViewSimple: View {
    var size: CGFloat = 1024
    var backgroundColor: Color = .white
    var foregroundColor: Color = .black

    var body: some View {
        Canvas { context, canvasSize in
            let scale = canvasSize.width / 100

            // Head
            let headPath = Path(ellipseIn: CGRect(
                x: 48 * scale,
                y: 12 * scale,
                width: 16 * scale,
                height: 16 * scale
            ))
            context.fill(headPath, with: .color(foregroundColor))

            // Body
            var bodyPath = Path()
            bodyPath.move(to: CGPoint(x: 56 * scale, y: 28 * scale))
            bodyPath.addLine(to: CGPoint(x: 50 * scale, y: 52 * scale))
            context.stroke(bodyPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 9 * scale, lineCap: .round))

            // Left leg
            var leftLegPath = Path()
            leftLegPath.move(to: CGPoint(x: 50 * scale, y: 52 * scale))
            leftLegPath.addLine(to: CGPoint(x: 35 * scale, y: 75 * scale))
            leftLegPath.addLine(to: CGPoint(x: 30 * scale, y: 88 * scale))
            context.stroke(leftLegPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 8 * scale, lineCap: .round, lineJoin: .round))

            // Right leg
            var rightLegPath = Path()
            rightLegPath.move(to: CGPoint(x: 50 * scale, y: 52 * scale))
            rightLegPath.addLine(to: CGPoint(x: 60 * scale, y: 72 * scale))
            rightLegPath.addLine(to: CGPoint(x: 70 * scale, y: 88 * scale))
            context.stroke(rightLegPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 8 * scale, lineCap: .round, lineJoin: .round))

            // Arms together (batting grip)
            var armsPath = Path()
            armsPath.move(to: CGPoint(x: 54 * scale, y: 34 * scale))
            armsPath.addLine(to: CGPoint(x: 38 * scale, y: 30 * scale))
            context.stroke(armsPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 7 * scale, lineCap: .round))

            // Bat (angled ready position)
            var batPath = Path()
            batPath.move(to: CGPoint(x: 35 * scale, y: 32 * scale))
            batPath.addLine(to: CGPoint(x: 22 * scale, y: 8 * scale))
            context.stroke(batPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 6 * scale, lineCap: .round))

            // Bat barrel
            var barrelPath = Path()
            barrelPath.move(to: CGPoint(x: 24 * scale, y: 14 * scale))
            barrelPath.addLine(to: CGPoint(x: 18 * scale, y: 5 * scale))
            context.stroke(barrelPath, with: .color(foregroundColor), style: StrokeStyle(lineWidth: 10 * scale, lineCap: .round))
        }
        .frame(width: size, height: size)
        .background(backgroundColor)
    }
}

/// SF Symbol-based app icon (uses built-in figure.baseball)
struct SFSymbolAppIcon: View {
    var size: CGFloat = 1024
    var backgroundColor: Color = .white
    var foregroundColor: Color = .black

    var body: some View {
        ZStack {
            backgroundColor

            Image(systemName: "figure.baseball")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(foregroundColor)
                .padding(size * 0.15)
        }
        .frame(width: size, height: size)
    }
}

#Preview("Custom Batter - Swinging") {
    AppIconView(size: 400)
}

#Preview("Custom Batter - Ready") {
    AppIconViewSimple(size: 400)
}

#Preview("SF Symbol Icon") {
    SFSymbolAppIcon(size: 400)
}

#Preview("All Icons Comparison") {
    HStack(spacing: 20) {
        VStack {
            AppIconView(size: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            Text("Swinging")
                .font(.caption)
        }
        VStack {
            AppIconViewSimple(size: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            Text("Ready")
                .font(.caption)
        }
        VStack {
            SFSymbolAppIcon(size: 100)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            Text("SF Symbol")
                .font(.caption)
        }
    }
    .padding()
}
