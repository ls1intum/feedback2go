//
//  ProgrammingSubmissionServiceStub.swift
//  Themis
//
//  Created by Anian Schleyer on 09.06.24.
//

import SharedModels

class ProgrammingSubmissionServiceStub: SubmissionService {
    func getAllSubmissions(exerciseId: Int) async throws -> [Submission] {
        [.programming(submission: .mock)]
    }
    
    func getTutorSubmissions(exerciseId: Int, correctionRound: CorrectionRound) async throws -> [Submission] {
        [.programming(submission: .mock)]
    }
    
    func getRandomSubmissionForAssessment(exerciseId: Int, correctionRound: CorrectionRound) async throws -> ProgrammingSubmission {
        .mock
    }
    
    func getSubmissionForAssessment(submissionId: Int, correctionRound: CorrectionRound) async throws -> ProgrammingSubmission {
        .mock
    }
    
    typealias SubmissionType = ProgrammingSubmission
}
