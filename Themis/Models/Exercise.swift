//
//  Exercise.swift
//  Themis
//
//  Created by Tom Rudnick on 12.11.22.
//

import Foundation

struct Exercise: Codable {
    let id: Int
    let title: String?
    let shortName: String?
    let maxPoints: Double?
    let assessmentType: String?
    let problemStatement: String?
    let gradingInstructions: String? // For Programming Assesments this might be nil
    let releaseDate: String?
    let dueDate: String?
    let assessmentDueDate: String?

    init() {
        self.id = -1
        self.title = nil
        self.shortName = nil
        self.maxPoints = nil
        self.assessmentType = nil
        self.problemStatement = nil
        self.gradingInstructions = nil
        self.releaseDate = nil
        self.dueDate = nil
        self.assessmentDueDate = nil
    }
    
    private func dateNow() -> String {
        ArtemisDateHelpers.stringifyDate(Date.now) ?? ""
    }
    
    func isFormer() -> Bool {
        guard let assessmentDueDate else {
            return false
        }
        return assessmentDueDate < dateNow()
    }
    
    func isCurrent() -> Bool {
        // exercises without release date are future exercises
        guard let releaseDate else {
            return false
        }
        if releaseDate >= dateNow() {
            return false
        }
        // exercises without assessment due date are current exercises
        guard let assessmentDueDate else {
            return true
        }
        return dateNow() < assessmentDueDate
    }
    
    func isFuture() -> Bool {
        // exercises without a release date are future exercises
        guard let releaseDate else {
            return true
        }
        return dateNow() < releaseDate
    }
}

struct DueDateStat: Codable {
    let inTime: Int
    let late: Int
}
/// This Struct represents the Statstics for a an Exercise
struct ExerciseForAssessment: Codable {
    let numberOfStudent: Int?
    let numberOfSubmissions: DueDateStat?
    let totalNumberOfAssessments: DueDateStat?
    // let totalNumberOfAssessments: DueDateStat?
    // let totalNumberOfAssessmentLocks: DueDateStat?
    let complaintsEnabled: Bool?
    let feedbackRequestEnabled: Bool?
    // let numberOfAssessmentsOfCorrectionRounds: DueDateStat? - this is an Array?!?! see ExerciseResource.java
    // let numberOfLockedAssessmentByOtherTutorsOfCorrectionRound: DueDateStat?
    // let numberOfAutomaticAssistedAssessments: DueDateStat?

}

struct ExerciseStatistics: Codable {
    let averageScoreOfExercise: Double?
    let maxPointsOfExercise: Double?
    let scoreDistribution: [Int]?
    let numberOfExerciseScores: Int?
    let numberOfParticipations: Int?
    let numberOfStudentsOrTeamsInCourse: Int?
    let numberOfPosts: Int?
    let numberOfResolvedPosts: Int?
}

extension ArtemisAPI {
    static func getExercise(exerciseId: Int) async throws -> Exercise {
        let request = Request(method: .get, path: "/api/exercises/\(exerciseId)/for-assessment-dashboard")
        return try await sendRequest(Exercise.self, request: request)
    }

    static func getExerciseStats(exerciseId: Int) async throws -> ExerciseForAssessment {
        let request = Request(method: .get, path: "/api/exercises/\(exerciseId)/stats-for-assessment-dashboard")
        return try await sendRequest(ExerciseForAssessment.self, request: request)
    }
    
    static func getExerciseStatsForDashboard(exerciseId: Int) async throws -> ExerciseStatistics {
        let request = Request(method: .get,
                              path: "api/management/statistics/exercise-statistics",
                              params: [URLQueryItem(name: "exerciseId", value: String(exerciseId))]
        )
        return try await sendRequest(ExerciseStatistics.self, request: request)
    }
}
