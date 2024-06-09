//
//  ParticipationExtension.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 06.05.23.
//
// swiftlint:disable identifier_name

import Foundation
import SharedModels

extension BaseParticipation {
    func getExercise<T>(as: T.Type = (any BaseExercise).self) -> T? {
        let exercise = self.exercise?.baseExercise
        return exercise as? T
    }
    
    /// A convenience function that casts this BaseParticipation instance into a ProgrammingExerciseStudentParticipation and sets its exercise property
    mutating func setProgrammingExercise(_ exercise: Exercise) {
        // TODO: I think this works, but please test!!!
        if var programmingParticipation = self as? ProgrammingExerciseStudentParticipation {
            programmingParticipation.exercise = exercise
            // swiftlint:disable:next force_cast
            self = programmingParticipation as! Self
        }
    }
    
    /// A convenience function that casts this BaseParticipation instance into a ProgrammingExerciseStudentParticipation and returns the participation id for the given repository type
    func getId(for repoType: RepositoryType) -> Int? {
        guard let _ = (self as? ProgrammingExerciseStudentParticipation) else {
            return nil
        }
        
        switch repoType {
        case .student:
            return self.id
        case .solution:
            return self.getExercise(as: ProgrammingExercise.self)?.solutionParticipation?.id
        case .template:
            return self.getExercise(as: ProgrammingExercise.self)?.templateParticipation?.id
        }
    }
}

extension Participation {
    func getExercise<T>(as: T.Type = (any BaseExercise).self) -> T? {
        self.baseParticipation.getExercise(as: T.self)
    }
}
