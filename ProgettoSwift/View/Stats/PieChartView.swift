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
    
    // Individuo il gruppo dominante
    private var dominantGroup: MuscleGroupCount? {
        filteredData.max(by: { $0.count < $1.count })
    }
    
    var body: some View {
        Chart {
            ForEach(filteredData, id: \.muscleGroup) { entry in
                let isDominant = entry.muscleGroup == dominantGroup?.muscleGroup
                let percentage = (Double(entry.count) / Double(totalCount)) * 100
                
                SectorMark(
                    angle: .value("Count", entry.count),
                    innerRadius: .ratio(0.4),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Muscle Group", entry.muscleGroup.rawValue))
                .annotation(position: .overlay) {
                    Text("\(Int(percentage))%")
                        .font(.title3)
                        .fontWeight(isDominant ? .bold : .regular)
                        .foregroundColor(.white)
                }
            }
        }
        .chartLegend(.visible)
        .chartLegend(position: .bottom)
    }
}
