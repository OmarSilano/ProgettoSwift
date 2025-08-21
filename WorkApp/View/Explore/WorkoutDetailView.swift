import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @State private var expandedDayID: UUID? = nil
    
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var tabRouter: TabRouter
    @Binding var explorePath: NavigationPath
    
    @State private var showInfoSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // HEADER
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
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                
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
            .padding(.bottom, 12)
            .background(
                Color("PrimaryColor")
                    .ignoresSafeArea(edges: .top)
            )
            .overlay(
                Divider()
                    .background(Color.gray.opacity(0.6)),
                alignment: .bottom
            )
            
            // CONTENUTO
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    if workout.category != nil {
                        DefaultWorkoutImageView(imageName: workout.pathToImage)
                    } else {
                        UserWorkoutImageView(imageName: workout.pathToImage)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            let relCount = workout.workoutDay?.count ?? 0
                            let daysCount = relCount > 0 ? relCount : Int(workout.days)
                            
                            Text("\(workout.weeks) Weeks • \(daysCount) Days")
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
                    
                    // spazio sotto per non far “schiacciare” l’ultimo elemento dal safeAreaInset del bottone
                    Spacer(minLength: 88)
                }
                .padding(.top, 16)
            }
        }
        .background(Color("PrimaryColor").ignoresSafeArea())
        // Bottone fisso in basso
        .safeAreaInset(edge: .bottom) {
            Button(action: {
                let manager = WorkoutManager(context: context)
                manager.cloneWorkout(workout)
                
                explorePath.removeLast(2)
                tabRouter.selectedTab = 1
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
            .padding(.vertical, 8)
            .background(
                // fondo sfumato per separare dal contenuto
                LinearGradient(
                    colors: [Color("PrimaryColor").opacity(0.9), Color("PrimaryColor").opacity(0.6), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea(edges: .bottom)
            )
        }
        .sheet(isPresented: $showInfoSheet) {
            WorkoutDetailInfoSheetView()
        }
    }
}
