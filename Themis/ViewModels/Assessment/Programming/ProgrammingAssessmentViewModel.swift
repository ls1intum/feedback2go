//
//  ProgrammingAssessmentViewModel.swift
//  Themis
//
//  Created by Anian Schleyer on 09.06.24.
//

import Common
import SharedModels

protocol ProgrammingAssessmentViewModel {
    func participationId(for repoType: RepositoryType) -> Int?
}

struct ProgrammingAssessmentViewModelFactory: DependencyFactory {
    init(exercise: Exercise, submissionId: Int?, participationId: Int?, resultId: Int?, correctionRound: CorrectionRound, readOnly: Bool) {
        Self.liveValue = ProgrammingAssessmentViewModelImpl(
            exercise: exercise,
            submissionId: submissionId,
            participationId: participationId,
            resultId: resultId,
            correctionRound: correctionRound,
            readOnly: readOnly
        )
        Self.testValue = ProgrammingAssessmentViewModelStub(
            exercise: exercise,
            submissionId: submissionId,
            participationId: participationId,
            resultId: resultId,
            correctionRound: correctionRound,
            readOnly: readOnly
        )
    }

    var shared: AssessmentViewModel {
        Self.shared
    }
    
    static var liveValue: AssessmentViewModel = ProgrammingAssessmentViewModelImpl(exercise: .mockText, correctionRound: .first, readOnly: true)
    static var testValue: AssessmentViewModel = ProgrammingAssessmentViewModelImpl(exercise: .mockText, correctionRound: .first, readOnly: true)
}
