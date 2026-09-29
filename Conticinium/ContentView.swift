import SwiftUI

/// Root of the folio-locked chrome. Ritual stays on screen. History and Settings arrive as sheets.
struct ContentView: View {
    @EnvironmentObject private var box: StoreBox

    var body: some View {
        RitualScreen(store: box.chart)
    }
}
