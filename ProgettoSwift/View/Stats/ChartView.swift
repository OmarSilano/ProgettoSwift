//
//  ChartView.swift
//  ProgettoSwift
//
//  Created by Studente on 17/07/25.
//
import SwiftUI
import Charts

struct MuscleGroupCount: Identifiable {
    let id = UUID()
    let muscleGroup: MuscleGroup
    let count: Int
}

struct ChartView: View {
    let data: [MuscleGroupCount]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Last 7 Days: Exercises Done by Muscle")
                .font(.headline)
                .padding(.bottom, 8)
                .padding(.leading, 16)
                .foregroundColor(.white)
            
            Chart(data) { item in
                BarMark(
                    x: .value("Muscle Group", item.muscleGroup.rawValue),
                    y: .value("Exercises", item.count)
                )
                .foregroundStyle(Color("SecondaryColor")) // colore del tuo tema dark
            }
            .chartXAxis {
                AxisMarks() { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
                    AxisTick()
                        .foregroundStyle(Color.gray)
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }
            .chartYAxis {
                AxisMarks() { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
                    AxisTick()
                        .foregroundStyle(Color.gray)
                    AxisGridLine()
                        .foregroundStyle(Color.gray.opacity(0.3))
                }
            }
            .frame(height: 250)
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color("CardBackground"))
        .cornerRadius(16)
    }
}

