//
//  ProgrammingAssessmentViewModelStub.swift
//  Themis
//
//  Created by Anian Schleyer on 09.06.24.
//

import SharedModels

class ProgrammingAssessmentViewModelStub: AssessmentViewModel, ProgrammingAssessmentViewModel {
    override func initSubmission() async {
        participationId = 1
        participation = ProgrammingExerciseStudentParticipation.mock
    }

    func participationId(for repoType: RepositoryType) -> Int? {
        1
    }
}
