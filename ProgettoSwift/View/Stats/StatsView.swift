//
//  StatsView.swift
//  ProgettoSwift
//
//  Created by Studente on 04/07/25.
//
import SwiftUI

struct StatsView: View {
    var body: some View {
            VStack {
                Text("STATS")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(Color("FourthColor"))
                    .padding(.top, 20)

                //CalendarView(markedDates: completedDates)
            }
            .padding()
        }
    
}

#Preview {
    StatsView()
}
