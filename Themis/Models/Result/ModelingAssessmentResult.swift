//
//  ModelingAssessmentResult.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 22.07.23.
//

import Foundation
import SharedModels
import Common

class ModelingAssessmentResult: AssessmentResult {
    var resultId: Int?
    var submissionId: Int?
    
    init(resultId: Int? = nil, submissionId: Int? = nil) {
        super.init()
        self.resultId = resultId
        self.submissionId = submissionId
    }
    
    override func setReferenceData(basedOn submission: BaseSubmission?) {
        self.resultId = submission?.results?.last?.id
        self.submissionId = submission?.id
    }
    
    override func reset() {
        self.resultId = nil
        self.submissionId = nil
    }
    
    override func encode(to encoder: Encoder) throws {
        try ModelingAssessmentResultDTO(basedOn: self).encode(to: encoder)
    }
}

struct ModelingAssessmentResultDTO: Encodable {
    let feedbacks: [Feedback]
    
    init(basedOn modelingAssessmentResult: ModelingAssessmentResult) {
        self.feedbacks = modelingAssessmentResult.feedbacks.map({ $0.baseFeedback })
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: feedbacks)
    }
}
