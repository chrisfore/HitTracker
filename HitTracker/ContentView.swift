import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "baseball.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("HitTracker")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
