//
//  AssessmentService.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 16.05.23.
//

import Foundation
import SharedModels
import Common

protocol AssessmentService {
    /// Delete all saved feedback and release the lock of the submission
    func cancelAssessment(submissionId: Int) async throws
    
    /// Save feedback to the submission
    func saveAssessment(participationId: Int, newAssessment: AssessmentResult, submit: Bool) async throws
    
    /// Fetches the participation with all data needed for assessment
    func fetchParticipationForSubmission(participationId: Int, submissionId: Int) async throws -> Participation
}

enum AssessmentServiceFactory {
    static func service(for exercise: Exercise) -> any AssessmentService {
        switch exercise {
        case .programming(exercise: _):
            return ProgrammingAssessmentServiceImpl()
        case .text(exercise: _):
            return TextAssessmentServiceImpl()
        default:
            return UnknownAssessmentServiceImpl()
        }
    }
}
