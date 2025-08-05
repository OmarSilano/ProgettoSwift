import SwiftUI

struct WorkoutInfoSheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Workout Management")
                        .font(.title)
                        .bold()

                    Text("""
In this screen, you can organize your custom workouts.

- Tap the **+** icon at the top right to **create a new workout**.
- You can also **add preset workouts** from the **Explore** screen.
- For each workout, you can:
  • **Edit it**  
  • **Replicate and improve it**  
  • **Share it**  
  • **Delete it**
""")
                        .font(.body)

                    Divider()

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
