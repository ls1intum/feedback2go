//
//  SubmissionService.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 16.05.23.
//

import Foundation
import SharedModels
import Common

protocol SubmissionService {
    associatedtype SubmissionType: BaseSubmission
    
    /// Fetch all submissions of the exercise
    func getAllSubmissions(exerciseId: Int) async throws -> [Submission]
    
    /// Fetches all submissions of that exercise previously assessed by the tutor (user)
    func getTutorSubmissions(exerciseId: Int, correctionRound: CorrectionRound) async throws -> [Submission]
    
    /// Fetches a random submission and locks it. This should be used to assess a random submission
    func getRandomSubmissionForAssessment(exerciseId: Int, correctionRound: CorrectionRound) async throws -> SubmissionType
    
    /// Fetches a submission associated with submissionId and locks it, so no one else can assess it. This should be used to assess a specific Submission from the list of open submissions.
    func getSubmissionForAssessment(submissionId: Int, correctionRound: CorrectionRound) async throws -> SubmissionType
    
    /// Fetches a result associated with participationId without locking.
    func getResultFor(participationId: Int) async throws -> Result
    
    /// Fetches a submission associated with participationId without locking.
    func getSubmission(participationId: Int) async throws -> Submission
}

extension SubmissionService { // default implementations
    func getResultFor(participationId: Int) async throws -> Result {
        throw UserFacingError.operationNotSupportedForExercise
    }
    
    func getSubmission(participationId: Int) async throws -> Submission {
        throw UserFacingError.operationNotSupportedForExercise
    }
}

enum SubmissionServiceFactory {
    static func service(for exercise: Exercise) -> any SubmissionService {
        switch exercise {
        case .programming:
            return ProgrammingSubmissionServiceFactory.shared
        case .text:
            return TextSubmissionServiceImpl()
        case .modeling:
            return ModelingSubmissionServiceImpl()
        case .fileUpload:
            return FileUploadSubmissionServiceImpl()
        default:
            return UnknownSubmissionServiceImpl()
        }
    }
}
