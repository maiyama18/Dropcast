import SwiftUI

struct DebugMenuScreen: View {
    var body: some View {
        NavigationView {
            List {
                Button("Copy SoundFiles Path") {
                    print("copy")
                }
                Button("Show Log") {
                    print("log")
                }
                Button("Inspect Core Data Objects") {
                    print("core data")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Debug Menu")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
