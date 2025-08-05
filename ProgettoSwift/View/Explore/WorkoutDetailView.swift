import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @State private var expandedDayID: UUID? = nil

    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var tabRouter: TabRouter
    @Binding var explorePath: NavigationPath
    
    @State private var showInfoSheet = false


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Button {
                        explorePath.removeLast()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title3)
                    }

                    Spacer()

                    Text(workout.name ?? "Workout")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    Spacer()

                    Button {
                        showInfoSheet = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .frame(width: 22, height: 22)
                            .foregroundColor(Color("FourthColor"))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                if (workout.category != nil) {    //allora è un workout di default
                    DefaultWorkoutImageView(imageName: workout.pathToImage)
                } else {    //...altrimenti è un workout creato dall'utente
                    UserWorkoutImageView(imageName: workout.pathToImage)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(workout.weeks) Weeks • \(workout.days ?? 0) Days")
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Text(workout.difficulty ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                Divider().background(Color.gray)

                if let days = workout.workoutDay?.allObjects as? [WorkoutDay] {
                    ForEach(days.sorted(by: { ($0.name ?? "") < ($1.name ?? "") })) { day in
                        WorkoutDayRowView(day: day, expandedDayID: $expandedDayID)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.top)
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        .overlay(
            VStack {
                Spacer()
                Button(action: {
                    let manager = WorkoutManager(context: context)
                    manager.cloneWorkout(workout)
                    
                    explorePath.removeLast(2) // Torna direttamente a ExploreView
                    tabRouter.selectedTab = 1 // Cambia tab su "WORKOUT"
                }) {
                    Text("ADD WORKOUT")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .padding(.bottom, 12)
            }
        )
        .sheet(isPresented: $showInfoSheet) {
            WorkoutDetailInfoSheetView()
        }
    }
}
