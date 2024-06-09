//
//  ProgrammingSubmissionService.swift
//  Themis
//
//  Created by Anian Schleyer on 09.06.24.
//

import Common

enum ProgrammingSubmissionServiceFactory: DependencyFactory {
    static let liveValue: any SubmissionService = ProgrammingSubmissionServiceImpl()
    static let testValue: any SubmissionService = ProgrammingSubmissionServiceStub()
}
