import SwiftUI

struct DebugLogScreen: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(1...100, id: \.self) { index in
                    Text("Log \(index)")
                }
            }
        }
    }
}

struct DebugLogScreen_Previews: PreviewProvider {
    static var previews: some View {
        DebugLogScreen()
    }
}
