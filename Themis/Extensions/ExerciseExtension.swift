//
//  ExerciseExtension.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 02.05.23.
//

import Foundation
import SharedModels

extension Exercise {
    
    var assessmentDueDateString: String? {
        ArtemisDateHelpers.stringifyDate(self.baseExercise.assessmentDueDate)
    }
    
    var dueDateString: String? {
        ArtemisDateHelpers.stringifyDate(self.baseExercise.dueDate)
    }
    
    var releaseDateString: String? {
        ArtemisDateHelpers.stringifyDate(self.baseExercise.releaseDate)
    }
    
    var isDisabled: Bool {
        switch self {
        case .programming(exercise: _), .text(exercise: _):
            return false
        default:
            return true
        }
    }
    
    var isSubmissionDueDateOver: Bool {
        if let dueDate = self.baseExercise.dueDate {
            return dueDate <= .now
        }
        return false
    }
    
    var isFormer: Bool {
        if let dueDate = self.baseExercise.assessmentDueDate, dueDate < Date.now {
            return true
        }
        return false
    }
    
    var isCurrentlyInAssessment: Bool {
        if let assessmentDueDate = self.baseExercise.assessmentDueDate {
            return isSubmissionDueDateOver && assessmentDueDate > .now
        }
        
        return isSubmissionDueDateOver
    }
    
    var isFuture: Bool {
        // exercises without a release date are automatically published
        if let releaseDate = self.baseExercise.releaseDate {
            return Date.now < releaseDate
        }
        return false
    }
}
