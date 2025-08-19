//
//  WorkoutDetailInfoSheetView.swift
//  ProgettoSwift
//
//  Created by Studente on 05/08/25.
//

import SwiftUI

struct WorkoutDetailInfoSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    Text("""
This screen shows the full structure of the selected workout.

- **Weeks** indicate for how many weeks the workout should be repeated.
- **Days** represent how many training days there are per week.
- Each day can be expanded to view the list of exercises and their training methodology 
- Tap **ADD WORKOUT** at the bottom to clone it and add it to your personal workouts.

You can then customize it further from your workout list.
""")
                        .font(.body)
                    
                    Text("""
                    To learn more about training methodologies used in this workout, go to **Settings > Training Methodologies**.
                    """)
                    .font(.footnote)
                    .foregroundColor(.secondary)


                    Divider()

                    Text("Train Responsibly")
                        .font(.headline)

                    Text("""
There’s no place for ego in the gym.

Always lift weights you can control with proper form. If you feel pain, **listen to your body**: **safety comes first**. Stop, rest, and come back stronger when you're ready.
""")
                        .font(.body)
                        .foregroundColor(.red)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Info")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Close")
                            .foregroundColor(Color("SecondaryColor"))
                    }
                }
            }
        }
    }
}

