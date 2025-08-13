import Foundation
import CoreData

extension WorkoutManager {
    // MARK: - Public API
    
    private struct MuscleMethodKey: Hashable {
        let muscle: MuscleGroup
        let method: Method

        func hash(into hasher: inout Hasher) {
            hasher.combine(muscle.rawValue)
            hasher.combine(method.rawValue)
        }

        static func == (lhs: MuscleMethodKey, rhs: MuscleMethodKey) -> Bool {
            lhs.muscle == rhs.muscle && lhs.method == rhs.method
        }
    }

    private enum SpecialExerciseName {
        static let pullUp = "Pull Up"
        static let assistedPullUp = "Assisted Pull Up"
        static let bwTricepDip = "Bodyweight Tricep Dip"
        static let assistedTricepDip = "Assisted Tricep Dip"
    }

    struct ReplicateImproveOptions {
        let intensityDelta: Int
        let preferredTypology: Typology?
        let enforceVariety: Bool
        let newNameOverride: String?

        init(intensityDelta: Int = 0,
             preferredTypology: Typology? = nil,
             enforceVariety: Bool = true,
             newNameOverride: String? = nil) {
            self.intensityDelta = intensityDelta
            self.preferredTypology = preferredTypology
            self.enforceVariety = enforceVariety
            self.newNameOverride = newNameOverride
        }
    }

    @discardableResult
    func replicateAndImprove(from original: Workout,
                             options: ReplicateImproveOptions) -> Workout {

        let analysis = analyze(workout: original)
        let targetDifficulty = shiftDifficulty(analysis.avgDifficulty, by: options.intensityDelta)

        let pool = buildExercisePool(targetDifficulty: targetDifficulty,
                                     bannedIDs: analysis.bannedExerciseIDs,
                                     excludeIDs: options.enforceVariety ? analysis.usedExerciseIDs : [],
                                     context: context)

        var usedNewIDs = Set<UUID>()

        let typologyManager = TypologyManager(context: context)
        let allTypologies = typologyManager.fetchAllTypologies()
        let preferredTypology = options.preferredTypology

        let baseName = (original.name ?? "Workout").trimmingCharacters(in: .whitespacesAndNewlines)
        let newWorkoutName = options.newNameOverride ?? nextVersionName(from: baseName)
        
        let newWorkout = createTempWorkout(
            name: newWorkoutName,
            difficulty: targetDifficulty,
            weeks: original.weeks,
            pathToImage: original.pathToImage,
            category: nil,
            isSaved: true
        )

        let workoutDayManager = WorkoutDayManager(context: context)
        let detailManager = WorkoutDayDetailManager(context: context)
        let exManager = ExerciseManager(context: context)

        let originalDays: [WorkoutDay] = (original.workoutDay?.allObjects as? [WorkoutDay]) ?? []
        for day in originalDays.sorted(by: { ($0.name ?? "") < ($1.name ?? "") }) {
            let newDay = workoutDayManager.createTempWorkoutDay(
                isCompleted: false,
                name: day.name ?? "Day",
                muscles: [],
                workout: newWorkout
            )

            let originalDetails = (day.workoutDayDetail?.allObjects as? [WorkoutDayDetail]) ?? []
            let grouped = groupDetailsByMuscleMethod(originalDetails)

            var order: Int16 = 0
            for (key, details) in grouped {
                let muscle = key.muscle
                let method = key.method

                for originalDetail in details {
                    let originalExercise = originalDetail.exercise

                    if let specialPick = resolveSpecialExercise(
                        originalExercise: originalExercise,
                        targetDifficulty: targetDifficulty,
                        intensityDelta: options.intensityDelta,
                        pool: pool,
                        exerciseManager: exManager
                    ) {
                        if let id = specialPick.id, usedNewIDs.contains(id) == false {
                            usedNewIDs.insert(id)
                            createDetail(detailManager: detailManager,
                                         day: newDay,
                                         exercise: specialPick,
                                         preferredTypology: preferredTypology,
                                         originalDetail: originalDetail,
                                         allTypologies: allTypologies,
                                         orderIndex: order)
                            order += 1
                            continue
                        }
                    }

                    if let exercise = pickExercise(for: muscle,
                                                   method: method,
                                                   pool: pool,
                                                   fallbackDifficulty: analysis.avgDifficulty,
                                                   usedIDs: usedNewIDs) {
                        if let id = exercise.id { usedNewIDs.insert(id) }
                        createDetail(detailManager: detailManager,
                                     day: newDay,
                                     exercise: exercise,
                                     preferredTypology: preferredTypology,
                                     originalDetail: originalDetail,
                                     allTypologies: allTypologies,
                                     orderIndex: order)
                        order += 1
                    } else if let fallback = pickAnyExercise(for: muscle,
                                                             pool: pool,
                                                             usedIDs: usedNewIDs) {
                        if let id = fallback.id { usedNewIDs.insert(id) }
                        createDetail(detailManager: detailManager,
                                     day: newDay,
                                     exercise: fallback,
                                     preferredTypology: preferredTypology,
                                     originalDetail: originalDetail,
                                     allTypologies: allTypologies,
                                     orderIndex: order)
                        order += 1
                    }
                }
            }


            newDay.updateMusclesFromDetails()
            WorkoutDayManager(context: context).updateOrder(for: newDay)
        }

        do { try context.save() } catch { print("❌ Errore salvataggio replicateAndImprove: \(error)") }

        return newWorkout
    }

    // MARK: - Analysis

    private func analyze(workout: Workout) -> WorkoutAnalysis {
        let days = (workout.workoutDay?.allObjects as? [WorkoutDay]) ?? []
        var usedExerciseIDs = Set<UUID>()
        var bannedIDs = Set<UUID>()
        var difficulties: [Difficulty] = []

        for day in days {
            let details = (day.workoutDayDetail?.allObjects as? [WorkoutDayDetail]) ?? []
            for d in details {
                if let ex = d.exercise {
                    if let id = ex.id { usedExerciseIDs.insert(id) }
                    if ex.isBanned { if let id = ex.id { bannedIDs.insert(id) } }
                    if let raw = ex.difficulty, let diff = Difficulty(rawValue: raw) {
                        difficulties.append(diff)
                    }
                }
            }
        }

        let avg = averageDifficulty(difficulties)

        return WorkoutAnalysis(
            dayCount: Int(workout.days),
            usedExerciseIDs: usedExerciseIDs,
            bannedExerciseIDs: bannedIDs,
            avgDifficulty: avg
        )
    }

    private struct WorkoutAnalysis {
        let dayCount: Int
        let usedExerciseIDs: Set<UUID>
        let bannedExerciseIDs: Set<UUID>
        let avgDifficulty: Difficulty
    }

    private func averageDifficulty(_ diffs: [Difficulty]) -> Difficulty {
        guard !diffs.isEmpty else { return .beginner }
        let map: [Difficulty: Int] = [.beginner: 1, .intermediate: 2, .advanced: 3]
        let reverse: [Int: Difficulty] = [1: .beginner, 2: .intermediate, 3: .advanced]
        let avg = Int(round(Double(diffs.map { map[$0]! }.reduce(0,+)) / Double(diffs.count)))
        return reverse[min(3, max(1, avg))] ?? .beginner
    }

    private func shiftDifficulty(_ base: Difficulty, by delta: Int) -> Difficulty {
        let ordered: [Difficulty] = [.beginner, .intermediate, .advanced]
        guard let idx = ordered.firstIndex(of: base) else { return base }
        let newIdx = max(0, min(2, idx + delta))
        return ordered[newIdx]
    }

    // MARK: - Pool building

    private struct ExercisePool {
        var byMuscleMethod: [MuscleGroup: [Method: [Exercise]]] = [:]
        var byMuscle: [MuscleGroup: [Exercise]] = [:]
        var all: [Exercise] = []
    }

    private func buildExercisePool(targetDifficulty: Difficulty,
                                   bannedIDs: Set<UUID>,
                                   excludeIDs: Set<UUID>,
                                   context: NSManagedObjectContext) -> ExercisePool {
        let exManager = ExerciseManager(context: context)
        let all = exManager.fetchAllExercises()
            .filter { !$0.isBanned }
            .filter { ex in
                guard let id = ex.id else { return false }
                return !bannedIDs.contains(id) && !excludeIDs.contains(id)
            }

        // Preferisci esercizi della difficoltà target, ma tieni anche gli altri come fallback
        func score(_ e: Exercise) -> Int {
            let d = Difficulty(rawValue: e.difficulty ?? "") ?? .beginner
            // 0 = match, 1 = dist 1, 2 = dist 2
            switch (targetDifficulty, d) {
            case (.beginner, .beginner), (.intermediate, .intermediate), (.advanced, .advanced):
                return 0
            case (.beginner, .intermediate), (.intermediate, .beginner), (.intermediate, .advanced), (.advanced, .intermediate):
                return 1
            default:
                return 2
            }
        }

        let sortedAll = all.sorted { score($0) < score($1) }

        var byMuscleMethod: [MuscleGroup: [Method: [Exercise]]] = [:]
        var byMuscle: [MuscleGroup: [Exercise]] = [:]

        for e in sortedAll {
            guard let mRaw = e.muscle, let muscle = MuscleGroup(rawValue: mRaw),
                  let methRaw = e.method, let method = Method(rawValue: methRaw) else { continue }

            byMuscleMethod[muscle, default: [:]][method, default: []].append(e)
            byMuscle[muscle, default: []].append(e)
        }

        return ExercisePool(byMuscleMethod: byMuscleMethod, byMuscle: byMuscle, all: sortedAll)
    }

    // MARK: - Grouping helper

    private func groupDetailsByMuscleMethod(_ details: [WorkoutDayDetail]) -> [MuscleMethodKey: [WorkoutDayDetail]] {
        var dict: [MuscleMethodKey: [WorkoutDayDetail]] = [:]
        for d in details.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            guard let ex = d.exercise,
                  let mRaw = ex.muscle, let muscle = MuscleGroup(rawValue: mRaw),
                  let methRaw = ex.method, let method = Method(rawValue: methRaw) else { continue }

            let key = MuscleMethodKey(muscle: muscle, method: method)
            dict[key, default: []].append(d)
        }
        return dict
    }

    // MARK: - Picking (con filtro anti-duplicati)

    private func pickExercise(for muscle: MuscleGroup,
                              method: Method,
                              pool: ExercisePool,
                              fallbackDifficulty: Difficulty,
                              usedIDs: Set<UUID>) -> Exercise? {

        if var list = pool.byMuscleMethod[muscle]?[method] {
            list = list.filter { ex in
                guard let id = ex.id else { return true }
                return !usedIDs.contains(id)
            }
            if !list.isEmpty {
                list.shuffle()
                return list.first
            }
        }
        if var list = pool.byMuscle[muscle] {
            list = list.filter { ex in
                guard let id = ex.id else { return true }
                return !usedIDs.contains(id)
            }
            if !list.isEmpty {
                list.shuffle()
                return list.first
            }
        }
        var all = pool.all.filter { ex in
            guard let id = ex.id else { return true }
            return !usedIDs.contains(id)
        }
        all.shuffle()
        return all.first
    }

    private func pickAnyExercise(for muscle: MuscleGroup,
                                 pool: ExercisePool,
                                 usedIDs: Set<UUID>) -> Exercise? {
        if var list = pool.byMuscle[muscle] {
            list = list.filter { ex in
                guard let id = ex.id else { return true }
                return !usedIDs.contains(id)
            }
            if !list.isEmpty {
                list.shuffle()
                return list.first
            }
        }
        var all = pool.all.filter { ex in
            guard let id = ex.id else { return true }
            return !usedIDs.contains(id)
        }
        all.shuffle()
        return all.first
    }

    // MARK: - Detail creation

    private func createDetail(detailManager: WorkoutDayDetailManager,
                              day: WorkoutDay,
                              exercise: Exercise,
                              preferredTypology: Typology?,
                              originalDetail: WorkoutDayDetail?,
                              allTypologies: [Typology],
                              orderIndex: Int16) {
        let typology: Typology = {
            if let preferred = preferredTypology {
                return preferred
            }
            if let original = originalDetail?.typology {
                if let name = original.name,
                   let found = allTypologies.first(where: { $0.name == name }) {
                    return found
                }
                return original
            }
            // fallback: una default qualunque
            return allTypologies.first
                ?? TypologyManager(context: context).createTypology(
                    name: "3x12",
                    detail: "3 sets of 12 reps",
                    isDefault: true
                )
        }()

        _ = detailManager.createTempWorkoutDayDetail(
            workoutDay: day,
            exercise: exercise,
            typology: typology,
            orderIndex: orderIndex
        )
    }

    // MARK: - Special-case resolver

    /// Ritorna un esercizio da usare al posto del pick standard se la regola speciale si applica.
    /// - Se l'esercizio originale è Pull Up o BW Tricep Dip: preserva lo stesso,
    ///   oppure passa alla versione Assisted se intensityDelta < 0.
    /// - Se l'originale è Assisted e il target è Advanced: prova a promuovere a non-assisted.
    /// - Ritorna `nil` se non si applica nessuna regola speciale.
    private func resolveSpecialExercise(originalExercise: Exercise?,
                                        targetDifficulty: Difficulty,
                                        intensityDelta: Int,
                                        pool: ExercisePool,
                                        exerciseManager: ExerciseManager) -> Exercise? {
        guard let ex = originalExercise, let name = ex.name else { return nil }

        // Helper per trovare per nome, preferendo il pool filtrato (non bannati),
        // altrimenti cercando in tutto il DB (e scartando bannati).
        func findByName(_ n: String) -> Exercise? {
            if let fromPool = pool.all.first(where: { $0.name == n && !$0.isBanned }) {
                return fromPool
            }
            return exerciseManager.fetchAllExercises().first(where: { $0.name == n && !$0.isBanned })
        }

        switch name {
        case SpecialExerciseName.pullUp:
            if intensityDelta < 0 {
                return findByName(SpecialExerciseName.assistedPullUp) ?? ex
            }
            return ex

        case SpecialExerciseName.bwTricepDip:
            if intensityDelta < 0 {
                return findByName(SpecialExerciseName.assistedTricepDip) ?? ex
            }
            return ex

        case SpecialExerciseName.assistedPullUp:
            if targetDifficulty == .advanced {
                return findByName(SpecialExerciseName.pullUp) ?? ex
            }
            return ex

        case SpecialExerciseName.assistedTricepDip:
            if targetDifficulty == .advanced {
                return findByName(SpecialExerciseName.bwTricepDip) ?? ex
            }
            return ex

        default:
            return nil
        }
    }
    
    private func nextVersionName(from name: String) -> String {
        let pattern = #"\s*\(v(\d+)\)\s*$"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return "\(name) (v2)"
        }

        let range = NSRange(name.startIndex..<name.endIndex, in: name)
        if let match = regex.firstMatch(in: name, options: [], range: range),
           let fullRange = Range(match.range, in: name),
           let verRange = Range(match.range(at: 1), in: name),
           let ver = Int(name[verRange]) {

            let base = name[..<fullRange.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
            return "\(base) (v\(ver + 1))"
        }

        return "\(name) (v2)"
    }

}
