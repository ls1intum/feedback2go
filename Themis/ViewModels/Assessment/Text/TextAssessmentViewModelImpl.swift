//
//  TextAssessmentViewModelImpl.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 29.07.23.
//

import Foundation
import Common
import SharedModels

class TextAssessmentViewModelImpl: AssessmentViewModel {
    @MainActor
    override func initSubmission() async {
        guard submission == nil else {
            return
        }
        
        if readOnly {
            if let submissionId {
                await getReadOnlySubmission(submissionId: submissionId)
            } else {
                self.error = UserFacingError.participationNotFound
                log.error("Could not find participation for text exercise: \(exercise.baseExercise.title ?? "")")
            }
        } else {
            if let submissionId, participationId != nil {
                await getParticipationForSubmission(submissionId: submissionId)
            } else {
                await initRandomSubmission()
            }
        }
        
        ThemisUndoManager.shared.removeAllActions()
    }
    
    @MainActor
    func getReadOnlySubmission(submissionId: Int) async {
        guard readOnly else {
            self.error = UserFacingError.unknown
            log.error("This function should only be called for read-only mode")
            return
        }
        
        loading = true
        defer {
            loading = false
        }
        
        do {
            let submissionService = SubmissionServiceFactory.service(for: exercise)
            // We are not actually getting the submission for assessment, but this is the only endpoint that can be used to
            // get the submission based on the submissionId without locking it
            let response = try await submissionService.getSubmissionForAssessment(submissionId: submissionId, correctionRound: .first)
            self.submission = response
            assessmentResult.setComputedFeedbacks(basedOn: submission?.results?.last??.feedbacks ?? [])
        } catch {
            self.error = error
            log.error(String(describing: error))
        }
    }
    
    @MainActor
    private func getParticipationForSubmission(submissionId: Int?) async {
        guard let submissionId else {
            return
        }
        
        loading = true
        defer {
            loading = false
        }
        do {
            let assessmentService = AssessmentServiceFactory.service(for: exercise)
            let fetchedParticipation = try await assessmentService
                .fetchParticipationForSubmission(submissionId: submissionId,
                                                 correctionRound: correctionRound).baseParticipation
            self.submission = fetchedParticipation.submissions?.last?.baseSubmission
            self.participation = fetchedParticipation
            assessmentResult.setComputedFeedbacks(basedOn: participation?.results?.last?.feedbacks ?? [])
            assessmentResult.setReferenceData(basedOn: submission)
            ThemisUndoManager.shared.removeAllActions()
        } catch {
            self.submission = nil
            self.error = error
            log.info(String(describing: error))
        }
    }
}
