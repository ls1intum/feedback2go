//
//  ExerciseViewModel.swift
//  Themis
//
//  Created by Tom Rudnick on 28.11.22.
//

import Foundation

class ExerciseViewModel: ObservableObject {
    @Published var exercise: Exercise?
    @Published var exerciseStats: ExerciseForAssessment?
    @Published var exerciseStatsForDashboard: ExerciseStatistics?

    @MainActor
    func fetchExercise(exerciseId: Int) async {
        do {
            self.exercise = try await ArtemisAPI.getExercise(exerciseId: exerciseId)
        } catch {
            print(error)
        }
    }

    @MainActor
    func fetchExerciseStats(exerciseId: Int) async {
        do {
            self.exerciseStats = try await ArtemisAPI.getExerciseStats(exerciseId: exerciseId)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    func fetchExerciseStatsForDashboard(exerciseId: Int) async {
        do {
            self.exerciseStatsForDashboard = try await ArtemisAPI.getExerciseStatsForDashboard(exerciseId: exerciseId)
        } catch let error {
            print(error.localizedDescription)
        }
    }

    var reviewStudents: String {
        let totalNumberOfStudents = exerciseStats?.numberOfSubmissions?.inTime ?? -1
        let totalNumberOfAssessments = exerciseStats?.totalNumberOfAssessments?.inTime ?? -1
        let percentage = Double(totalNumberOfAssessments) / Double(totalNumberOfStudents)
        let percentageString = String(format: "%.2f", percentage)
        return "\(totalNumberOfAssessments) / \(totalNumberOfStudents) (\(percentageString))"
    }
    
    var participationRate: Double {
        let numOfParticipations = Double(exerciseStatsForDashboard?.numberOfParticipations ?? 0)
        let numOfStudents = Double(exerciseStatsForDashboard?.numberOfStudentsOrTeamsInCourse ?? 0)
        return Double(numOfParticipations / numOfStudents)
    }
    
    var averageScore: Double {
        let avgScore = Double(exerciseStatsForDashboard?.averageScoreOfExercise ?? 0)
        let maxPoints = Double(exerciseStatsForDashboard?.maxPointsOfExercise ?? 0)
        return Double(avgScore / maxPoints)
    }
    
    var assessed: Double {
        let numOfAssessments = Double(exerciseStats?.totalNumberOfAssessments?.inTime ?? 0)
        let numOfStudents = Double(exerciseStats?.numberOfSubmissions?.inTime ?? 0)
        return Double(CGFloat(numOfAssessments / numOfStudents))
    }
}
