//
//  SubmissionListViewModel.swift
//  Themis
//
//  Created by Paul Schwind on 24.11.22.
//

import Common
import Foundation
import SharedModels

class SubmissionListViewModel: ObservableObject {
    @Published var submissions: [Submission] = []
    @Published var error: Error?
    
    var submittedSubmissions: [Submission] {
        submissions.filter { $0.baseSubmission.results?.last?.completionDate != nil }
    }
    
    var openSubmissions: [Submission] {
        submissions.filter { $0.baseSubmission.results?.last?.completionDate == nil }
    }
    
    @MainActor
    func fetchTutorSubmissions(exerciseId: Int) async {
        do {
            self.submissions = try await ArtemisAPI.getTutorSubmissions(exerciseId: exerciseId)
        } catch let error {
            self.error = error
            log.error(String(describing: error))
        }
    }
}

 enum SubmissionStatus {
    case open
    case submitted
 }
