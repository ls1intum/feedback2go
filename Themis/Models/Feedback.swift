//
//  Feedback.swift
//  Themis
//
//  Created by Katjana Kosic on 19.11.22.
//

// Will be deleted in the future, as struct already exists in Assessment.swift

import Foundation

public class Feedback: Identifiable {
    public var id: UUID
    public var feedbackText: String
    public var score: Double

    init(id: UUID? = nil, feedbackText: String, score: Double) {
        self.id = id ?? UUID()
        self.feedbackText = feedbackText
        self.score = score
    }
}