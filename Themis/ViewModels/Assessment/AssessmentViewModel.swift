import Foundation
import SwiftUI
import Combine
import SharedModels
import Common
import APIClient

class AssessmentViewModel: ObservableObject {
    @Published var submission: BaseSubmission?
    /// Is set automatically when the submission is set
    @Published var participation: BaseParticipation?
    @Published var assessmentResult: AssessmentResult
    @Published var readOnly: Bool
    @Published var loading = false
    @Published var isSaving = false
    @Published var error: Error?
    @Published var pencilModeDisabled = true
    @Published var allowsInlineFeedbackOperations = true
    @Published var fontSize: CGFloat = 16.0
    
    var submissionId: Int?
    var participationId: Int?
    var resultId: Int?
    var exercise: Exercise
    var correctionRound: CorrectionRound
    
    private var cancellables: [AnyCancellable] = []
    
    init(exercise: Exercise,
         submissionId: Int? = nil,
         participationId: Int? = nil,
         resultId: Int? = nil,
         correctionRound: CorrectionRound = .first,
         readOnly: Bool) {
        self.exercise = exercise
        self.submissionId = submissionId
        self.participationId = participationId
        self.resultId = resultId
        self.assessmentResult = AssessmentResultFactory.assessmentResult(for: exercise, resultIdFromServer: resultId)
        self.correctionRound = correctionRound
        self.readOnly = readOnly
        
        $submission
            .sink(receiveValue: { self.participation = $0?.participation?.baseParticipation })
            .store(in: &cancellables)
        
        $participation
            .sink(receiveValue: { self.resultId = $0?.results?.last?.id })
            .store(in: &cancellables)
    }
    
    // Resets some properties of this viewmodel to prepare it for reuse between assessments
    func resetForNewAssessment() {
        self.submission = nil
        self.participation = nil
        self.loading = false
        self.error = nil
        self.submissionId = nil
        self.participationId = nil
        self.resultId = nil
    }
    
    /// Resets some properties of this viewmodel that affect the toolbar
    func resetToolbarProperties() {
        pencilModeDisabled = true
        fontSize = 16.0
    }
    
    var gradingCriteria: [GradingCriterion] {
        participation?.getExercise()?.gradingCriteria ?? []
    }
    
    @MainActor
    func initSubmission() async {
        log.error("This function should be overridden")
        self.error = UserFacingError.unknown
    }
    
    @MainActor
    func initRandomSubmission() async {
        loading = true
        defer {
            loading = false
        }
        do {
            let submissionService = SubmissionServiceFactory.service(for: exercise)
            self.submission = try await submissionService.getRandomSubmissionForAssessment(exerciseId: exercise.id,
                                                                                           correctionRound: correctionRound)
            assessmentResult.setComputedFeedbacks(basedOn: submission?.results?.last??.feedbacks ?? [])
            assessmentResult.setReferenceData(basedOn: submission)
            ThemisUndoManager.shared.removeAllActions()
        } catch {
            self.submission = nil
            
            if case .decodingError(_, let statusCode) = (error as? APIClientError),
               statusCode == 200 { // Status is OK, but the body is not decodable (empty)
                self.error = UserFacingError.noMoreAssessments
            } else if let error = error as? APIClientError,
                      case .jhipsterError = error {
                var userFacingError = UserFacingError(error: error)
                userFacingError.message = nil // message from the server is not user-friendly, so we remove it
                self.error = userFacingError
            } else {
                self.error = UserFacingError.unknown
            }
            
            log.error(String(describing: error))
        }
    }

    @MainActor
    func getSubmission(submissionId: Int) async {
        guard !readOnly else {
            self.error = UserFacingError.unknown
            log.error("This function should not be called for read-only mode")
            return
        }
        
        loading = true
        defer {
            loading = false
        }
        
        let submissionService = SubmissionServiceFactory.service(for: exercise)
        
        do {
            self.submission = try await submissionService.getSubmissionForAssessment(submissionId: submissionId,
                                                                                     correctionRound: correctionRound)
            assessmentResult.setComputedFeedbacks(basedOn: submission?.results?.last??.feedbacks ?? [])
            assessmentResult.setReferenceData(basedOn: submission)
            ThemisUndoManager.shared.removeAllActions()
        } catch {
            self.error = error
            log.error(String(describing: error))
        }
    }
    
    @MainActor
    func getReadOnlySubmission(participationId: Int) async {
        log.error("This function should be overridden")
        self.error = UserFacingError.unknown
    }

    @MainActor
    func cancelAssessment() async {
        guard let submissionId = submission?.id,
              let participationId = participation?.id else {
            log.error("Could not cancel assessment due to missing participation or submission ID")
            return
        }
        
        loading = true
        defer {
            loading = false
        }
        
        do {
            let assessmentService = AssessmentServiceFactory.service(for: exercise)
            try await assessmentService.cancelAssessment(participationId: participationId, submissionId: submissionId)
        } catch {
            if error as? RESTError != RESTError.empty {
                self.error = error
                log.error(String(describing: error))
            }
        }
        self.submission = nil
        self.assessmentResult = AssessmentResult()
    }

    @MainActor
    func saveAssessment() async {
        guard let participationId = participation?.id else {
            return
        }
        
        isSaving = true
        defer { isSaving = false }
        
        let assessmentService = AssessmentServiceFactory.service(for: exercise)
        
        do {
            try await assessmentService.saveAssessment(participationId: participationId,
                                                       newAssessment: assessmentResult)
        } catch {
            self.error = error
            log.error(String(describing: error))
        }
    }
    
    @MainActor
    func submitAssessment() async {
        guard let participationId = participation?.id else {
            return
        }
        
        loading = true
        defer { loading = false }
        
        let assessmentService = AssessmentServiceFactory.service(for: exercise)
        
        do {
            try await assessmentService.submitAssessment(participationId: participationId,
                                                         newAssessment: assessmentResult)
        } catch {
            self.error = error
            log.error(String(describing: error))
        }
    }
    
    func notifyThemisML() async { // TODO: Make this function more general once Athene is integrated
        guard let participationId = participation?.id,
              case .programming = exercise
        else {
            return
        }
        
        do {
            try await ThemisAPI.notifyAboutNewFeedback(exerciseId: exercise.id, participationId: participationId)
        } catch {
            log.error(String(describing: error))
        }
    }
    
    func getFeedback(byId id: UUID) -> AssessmentFeedback? {
        assessmentResult.feedbacks.first(where: { $0.id == id })
    }
}

enum AssessmentViewModelFactory {
    static func assessmentViewModel(for exercise: Exercise,
                                    submissionId: Int? = nil,
                                    participationId: Int? = nil,
                                    resultId: Int? = nil,
                                    correctionRound: CorrectionRound = .first,
                                    readOnly: Bool) -> AssessmentViewModel {
        switch exercise {
        case .programming:
            return ProgrammingAssessmentViewModelFactory(exercise: exercise,
                                                         submissionId: submissionId,
                                                         participationId: participationId,
                                                         resultId: resultId,
                                                         correctionRound: correctionRound,
                                                         readOnly: readOnly).shared
        case .text:
            return TextAssessmentViewModel(exercise: exercise,
                                           submissionId: submissionId,
                                           participationId: participationId,
                                           resultId: resultId,
                                           correctionRound: correctionRound,
                                           readOnly: readOnly)
        case .modeling:
            return ModelingAssessmentViewModel(exercise: exercise,
                                               submissionId: submissionId,
                                               participationId: participationId,
                                               resultId: resultId,
                                               correctionRound: correctionRound,
                                               readOnly: readOnly)
        case .fileUpload:
            return FileUploadAssessmentViewModel(exercise: exercise,
                                                 submissionId: submissionId,
                                                 participationId: participationId,
                                                 resultId: resultId,
                                                 correctionRound: correctionRound,
                                                 readOnly: readOnly)
        default:
            log.warning("Could not find the corresponding AssessmentViewModel subtype for exercise \(exercise)")
            return AssessmentViewModel(exercise: exercise,
                                       submissionId: submissionId,
                                       participationId: participationId,
                                       resultId: resultId,
                                       correctionRound: correctionRound,
                                       readOnly: readOnly)
        }
    }
}
