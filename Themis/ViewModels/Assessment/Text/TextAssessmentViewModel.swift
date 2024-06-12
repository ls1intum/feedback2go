//
//  TextAssessmentViewModel.swift
//  Themis
//
//  Created by Anian Schleyer on 12.06.24.
//

import Common
import SharedModels

struct TextAssessmentViewModelFactory: DependencyFactory {
    init(exercise: Exercise, submissionId: Int?, participationId: Int?, resultId: Int?, correctionRound: CorrectionRound, readOnly: Bool) {
        Self.liveValue = TextAssessmentViewModelImpl(
            exercise: exercise,
            submissionId: submissionId,
            participationId: participationId,
            resultId: resultId,
            correctionRound: correctionRound,
            readOnly: readOnly
        )
        Self.testValue = TextAssessmentViewModelStub(
            exercise: .mockText,
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
    
    static var liveValue: AssessmentViewModel = TextAssessmentViewModelImpl(exercise: .mockText, correctionRound: .first, readOnly: true)
    static var testValue: AssessmentViewModel = TextAssessmentViewModelImpl(exercise: .mockText, correctionRound: .first, readOnly: true)
}
