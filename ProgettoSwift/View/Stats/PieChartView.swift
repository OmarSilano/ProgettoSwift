import SwiftUI
import Charts

struct PieChartView: View {
    let data: [MuscleGroupCount]
    
    // Calcola il totale degli esercizi per tutte le categorie muscolari
    private var totalCount: Int {
        data.map { $0.count }.reduce(0, +)
    }
    
    // Filtra solo i gruppi muscolari con conteggio maggiore di zero
    private var filteredData: [MuscleGroupCount] {
        data.filter { $0.count > 0 }
    }
    
    // Calcola il massimo valore tra tutti i gruppi
    private var maxCount: Int {
        filteredData.map { $0.count }.max() ?? 0
    }
    
    // Verifica se un gruppo muscolare è dominante
    private func isDominant(_ group: MuscleGroupCount) -> Bool {
        group.count == maxCount
    }
    
    var body: some View {
        Chart {
            ForEach(filteredData, id: \.muscleGroup) { entry in
                let dominant = isDominant(entry)
                let percentage = (Double(entry.count) / Double(totalCount)) * 100
                let label = "\(entry.muscleGroup.rawValue)\n\(Int(percentage))%"
                
                
                SectorMark(
                    angle: .value("Count", entry.count),
                    innerRadius: .ratio(0.4),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Muscle Group", entry.muscleGroup.rawValue))
                .annotation(position: .overlay) {
                    Text(label)
                        .font(.headline)
                        .fontWeight(dominant ? .bold : .regular)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .chartLegend(.hidden)
    }
}
