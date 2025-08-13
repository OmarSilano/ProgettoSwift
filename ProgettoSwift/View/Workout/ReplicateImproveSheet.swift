import SwiftUI
import CoreData

struct ReplicateImproveSheet: View {
    @Environment(\.managedObjectContext) private var context

    let workout: Workout
    @Binding var isPresented: Bool

    // Intensità: -1 = più facile, 0 = uguale, +1 = più intenso
    enum IntensityChoice: Int, CaseIterable, Identifiable {
        case easier = -1, same = 0, harder = 1
        var id: Int { rawValue }
        var label: String {
            switch self {
            case .easier: return "Più facile"
            case .same:   return "Uguale"
            case .harder: return "Più intenso"
            }
        }
    }

    @State private var intensity: IntensityChoice = .same
    @State private var enforceVariety: Bool = true
    @State private var selectedTypology: Typology? = nil
    @State private var allTypologies: [Typology] = []

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Intensità")) {
                    Picker("Seleziona", selection: $intensity) {
                        ForEach(IntensityChoice.allCases) { choice in
                            Text(choice.label).tag(choice)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Tipologia (opzionale)")) {
                    Picker("Tipologia", selection: Binding(
                        get: { selectedTypology?.objectID },
                        set: { newID in
                            selectedTypology = allTypologies.first { $0.objectID == newID }
                        }
                    )) {
                        Text("Mantieni originali").tag(Optional<NSManagedObjectID>.none)
                        ForEach(allTypologies, id: \.objectID) { t in
                            Text(t.name ?? "-").tag(Optional(t.objectID))
                        }
                    }
                }

                Section {
                    Toggle("Massimizza varietà (evita esercizi già usati)", isOn: $enforceVariety)
                }
            }
            .navigationTitle("Replica e migliora")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crea") {
                        let manager = WorkoutManager(context: context)
                        let opts = WorkoutManager.ReplicateImproveOptions(
                            intensityDelta: intensity.rawValue,      // -1 / 0 / +1
                            preferredTypology: selectedTypology,     // nil = mantieni originali
                            enforceVariety: enforceVariety,
                            newNameOverride: nil
                        )
                        _ = manager.replicateAndImprove(from: workout, options: opts)
                        isPresented = false
                    }
                }
            }
            .onAppear {
                // carica tipologie esistenti
                let tm = TypologyManager(context: context)
                allTypologies = tm.fetchAllTypologies().sorted { ($0.name ?? "") < ($1.name ?? "") }
            }
        }
    }
}
