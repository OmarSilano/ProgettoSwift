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
    
    private var markedDates: Set<DateComponents> {
        let calendar = Calendar.current
        return Set(
            completions.compactMap { completion in
                guard let date = completion.date else { return nil }
                return calendar.dateComponents([.year, .month, .day], from: date)
            }
        )
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
                    
                    /*
                     LOGICA PER VISUALIZZARE ALLENAMENTI SVOLTI
                     */
                    
                    Spacer()
                    
                    /*
                     ISTOGRAMMA ALLENAMENTI
                     */
                    
                    
                    
                }
            }
            .background(Color("PrimaryColor").ignoresSafeArea())

        }
    }
    
}

#Preview {
    StatsView()
}
