//
//  ProgrammingSubmissionServiceImpl.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 16.05.23.
//

import Foundation
import SharedModels
import APIClient
import DesignLibrary

class ProgrammingSubmissionServiceImpl: SubmissionService {
    
    typealias SubmissionType = ProgrammingSubmission
    
    let client = APIClient()
    
    // MARK: - Get All Submissions
    private struct GetAllSubmissionsRequest: APIRequest {
        typealias Response = [Submission]
        
        var exerciseId: Int
        
        var method: HTTPMethod {
            .get
        }
        
        var resourceName: String {
            "api/exercises/\(exerciseId)/programming-submissions"
        }
    }
    
    func getAllSubmissions(exerciseId: Int) async throws -> [Submission] {
        try await client.sendRequest(GetAllSubmissionsRequest(exerciseId: exerciseId)).get().0
    }
    
    // MARK: - Get Tutor Submissions
    private struct GetTutorSubmissionsRequest: APIRequest {
        typealias Response = [Submission]
        
        var exerciseId: Int
        var correctionRound: Int
        
        var method: HTTPMethod {
            .get
        }
        
        var params: [URLQueryItem] {
            [
                URLQueryItem(name: "assessedByTutor", value: "true"),
                URLQueryItem(name: "correction-round", value: "\(correctionRound)")
            ]
        }
        
        var resourceName: String {
            "api/exercises/\(exerciseId)/programming-submissions"
        }
    }
    
    func getTutorSubmissions(exerciseId: Int, correctionRound: CorrectionRound) async throws -> [Submission] {
        try await client.sendRequest(GetTutorSubmissionsRequest(exerciseId: exerciseId,
                                                                correctionRound: correctionRound.rawValue))
            .get().0
    }
    
    // MARK: - Get Random Programming Submission For Assessment
    private struct GetRandomProgrammingSubmissionRequest: APIRequest {
        typealias Response = ProgrammingSubmission
        
        var exerciseId: Int
        var correctionRound: Int
        
        var method: HTTPMethod {
            .get
        }
        
        var params: [URLQueryItem] {
            [
                URLQueryItem(name: "lock", value: "true"),
                URLQueryItem(name: "correction-round", value: "\(correctionRound)")
            ]
        }
        
        var resourceName: String {
            "api/exercises/\(exerciseId)/programming-submission-without-assessment"
        }
    }
    
    func getRandomSubmissionForAssessment(exerciseId: Int, correctionRound: CorrectionRound) async throws -> ProgrammingSubmission {
        try await client.sendRequest(GetRandomProgrammingSubmissionRequest(exerciseId: exerciseId,
                                                                           correctionRound: correctionRound.rawValue))
            .get().0
    }
    
    // MARK: - Get Programming Submission For Assessment
    private struct GetProgrammingSubmissionRequest: APIRequest {
        typealias Response = ProgrammingSubmission
        
        var submissionId: Int
        var correctionRound: Int
        
        var method: HTTPMethod {
            .get
        }
        
        var params: [URLQueryItem] {
            [URLQueryItem(name: "correction-round", value: "\(correctionRound)")]
        }
        
        var resourceName: String {
            "api/programming-submissions/\(submissionId)/lock"
        }
    }
    
    func getSubmissionForAssessment(submissionId: Int, correctionRound: CorrectionRound) async throws -> ProgrammingSubmission {
        try await client.sendRequest(GetProgrammingSubmissionRequest(submissionId: submissionId,
                                                                     correctionRound: correctionRound.rawValue))
            .get().0
    }
    
    // MARK: - Get Result
    private struct GetResultRequest: APIRequest {
        typealias Response = Result
        
        var participationId: Int
        
        var method: HTTPMethod {
            .get
        }
        
        var params: [URLQueryItem] {
            [URLQueryItem(name: "withSubmission", value: "true")]
        }
        
        var resourceName: String {
            "api/programming-exercise-participations/\(participationId)/latest-result-with-feedbacks"
        }
    }
    
    func getResultFor(participationId: Int) async throws -> Result {
        try await client.sendRequest(GetResultRequest(participationId: participationId)).get().0
    }
}
