//
//  ProgrammingAssessmentViewModel.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 29.07.23.
//

import Foundation
import Common
import SharedModels

class ProgrammingAssessmentViewModel: AssessmentViewModel {
    @MainActor
    override func initSubmission() async {
        guard submission == nil else {
            return
        }
        
        if readOnly {
            if let participationId {
                await getReadOnlySubmission(participationId: participationId)
            } else {
                self.error = UserFacingError.participationNotFound
                log.error("Could not find participation for programming exercise: \(exercise.baseExercise.title ?? "")")
            }
        } else {
            if let submissionId {
                await getSubmission(submissionId: submissionId)
            } else {
                await initRandomSubmission()
            }
        }
        
        ThemisUndoManager.shared.removeAllActions()
    }
    
    @MainActor
    override func getReadOnlySubmission(participationId: Int) async {
        guard readOnly else {
            self.error = UserFacingError.unknown
            log.error("This function should only be called for read-only mode")
            return
        }
        
        loading = true
        defer {
            loading = false
        }
        
        let submissionService = SubmissionServiceFactory.service(for: exercise)
        
        do {
            let result = try await submissionService.getResultFor(participationId: participationId)
            self.submission = result.submission?.baseSubmission
            self.participation = result.participation?.baseParticipation
            assessmentResult.setComputedFeedbacks(basedOn: result.feedbacks ?? [])
            
            if let exerciseId = participation?.exercise?.id {
                let exerciseWithTemplateAndSolution = try await ExerciseHelperService()
                    .getProgrammingExerciseWithTemplateAndSolutionParticipations(exerciseId: exerciseId)
                self.participation?.setProgrammingExercise(exerciseWithTemplateAndSolution)
            }
        } catch {
            self.error = error
            log.error(String(describing: error))
        }
    }

    func participationId(for repoType: RepositoryType) -> Int? {
        switch repoType {
        case .student:
            return participation?.id
        case .solution:
            return participation?.getExercise(as: ProgrammingExercise.self)?.solutionParticipation?.id
        case .template:
            return participation?.getExercise(as: ProgrammingExercise.self)?.templateParticipation?.id
        }
    }
}
