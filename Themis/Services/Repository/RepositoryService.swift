//
//  RepositoryService.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 16.05.23.
//

import Foundation
import SharedModels
import Common

protocol RepositoryService {
    /// Fetch all file names from repository of submission with participationId
    func getFileNamesOfRepository(participationId: Int) async throws -> [String: FileType]
    /// Fetch file of filePath from repository of submission with participationId
    func getFileOfRepository(participationId: Int, filePath: String) async throws -> String
}

enum RepositoryServiceFactory: DependencyFactory {
    static let liveValue: RepositoryService = RepositoryServiceImpl()
    static let testValue: RepositoryService = RepositoryServiceStub()
}
