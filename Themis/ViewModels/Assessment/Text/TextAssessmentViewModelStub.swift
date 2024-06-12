//
//  TextAssessmentViewModelStub.swift
//  Themis
//
//  Created by Anian Schleyer on 12.06.24.
//

import SharedModels

class TextAssessmentViewModelStub: AssessmentViewModel {
    @MainActor
    override func initSubmission() async {
        submission = Submission.mockText.baseSubmission
    }
    
    @MainActor
    func getReadOnlySubmission(submissionId: Int) async {
        submission = Submission.mockText.baseSubmission
    }
    
    @MainActor
    private func getParticipationForSubmission(submissionId: Int?) async {
        self.participation = ProgrammingExerciseStudentParticipation.mock
    }
}
