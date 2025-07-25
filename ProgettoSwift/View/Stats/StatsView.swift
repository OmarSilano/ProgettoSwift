//
//  StatsView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//
import SwiftUI

struct StatsView: View {
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        entity: WorkoutDayCompleted.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutDayCompleted.date, ascending: true)]
    ) private var completions: FetchedResults<WorkoutDayCompleted>
    
    @State private var installDate: Date = {
        let defaults = UserDefaults.standard
        if let savedDate = defaults.object(forKey: "appInstallDate") as? Date {
            return savedDate
        } else {
            let now = Date()
            defaults.set(now, forKey: "appInstallDate")
            return now
        }
    }()
    
    @State private var selectedDate: DateComponents? = nil
    
    private var completionsForSelectedDate: [WorkoutDayCompleted] {
            guard let selectedDate else { return [] }
            
            let normalizedSelected = selectedDate.normalized()
            
            return completions.filter { completion in
                guard let date = completion.date else { return false }
                let comp = date.asNormalizedComponents()
                return comp == normalizedSelected
            }
        }
    
    @State private var showSheet = false
    
    @State var expandedDayID: UUID? = nil
    
    private var markedDates: Set<DateComponents> {
            let calendar = Calendar.current
            return Set(
                completions.compactMap { completion in
                    completion.date?.asNormalizedComponents(calendar: calendar)
                }
            )
        }
    
    private var chartData: [MuscleGroupCount] {
        let manager = WorkoutDayCompletedManager(context: context)
        let countsDict = manager.fetchCountLastNDaysByMuscle(n: 7)
        
        return MuscleGroup.allCases.map { group in
            MuscleGroupCount(muscleGroup: group, count: countsDict[group] ?? 0)
        }
    }
    
    
    private func formattedDate(_ comp: DateComponents?) -> String {
        guard let comp = comp,
              let date = Calendar.current.date(from: comp) else { return "—" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("STATS")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(Color("FourthColor"))
                        .padding(.top, 20)
                    
                    // l'intervallo navigabile del calendario và
                    // dalla data di installazione dell'app
                    // alla data odierna
                    let today = Date()
                    let interval = DateInterval(start: installDate, end: today)
                    
                    CalendarView(
                        interval: interval,
                        dateSelected: $selectedDate,
                        markedDates: markedDates
                    )
                    .frame(height: 500)
                    .cornerRadius(8)
                    .padding(.top, 10)
                    .onChange(of: selectedDate) {
                        if !completionsForSelectedDate.isEmpty {
                            showSheet = true
                        }
                    }
                    .sheet(isPresented: $showSheet, onDismiss: {
                        selectedDate = nil
                    }) {
                        VStack(spacing: 16) {
                            Text("\(formattedDate(selectedDate))")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(Color("FourthColor"))
                                .padding(.top, 16)

                            List(completionsForSelectedDate, id: \.objectID) { completion in
                                if let workoutDay = completion.workoutDay {
                                    let workoutName = workoutDay.workout?.name ?? "Workout"
                                    let workoutDayName = workoutDay.name ?? "WorkoutDay"
                                    let formattedName = "\(workoutName) - \(workoutDayName)"

                                    WorkoutDayRowView(
                                        day: workoutDay,
                                        expandedDayID: $expandedDayID,
                                        overrideName: formattedName
                                    )
                                    .listRowBackground(Color("PrimaryColor"))
                                }
                            }
                            .listStyle(.plain)
                            .listRowSeparator(.hidden)
                        }
                        .presentationDetents([.medium, .large])
                        .background(Color("PrimaryColor"))
                    }
                    
                    Spacer()
                    
                    ChartView(data: chartData)
                }
            }
            .background(Color("PrimaryColor").ignoresSafeArea())
            .scrollIndicators(.hidden)
        }
        
    }
}


#Preview {
    StatsView()
}
