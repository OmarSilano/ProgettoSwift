//
//  ExploreInfoSheetView.swift
//  ProgettoSwift
//
//  Created by Studente on 05/08/25.
//

import SwiftUI

struct ExploreInfoSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Explore Workouts")
                        .font(.title)
                        .bold()

                    Text("""
This screen features a collection of preset workouts divided by difficulty:

- **Beginner**: for those who are just starting out with training.  
- **Intermediate**: for users who are not new and already at a good level.  
- **Advanced**: for experienced lifters who can handle more intense and demanding workouts.

Browse and select the one that suits your current level. You can preview and add them directly to your workout list.
""")
                        .font(.body)

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
