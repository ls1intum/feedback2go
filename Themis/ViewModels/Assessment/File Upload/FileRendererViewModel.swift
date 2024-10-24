//
//  FileRendererViewModel.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 11.09.23.
//

import Foundation
import SharedModels
import UserStore
import Common

class FileRendererViewModel: ExerciseRendererViewModel {
    @Published var remoteFileURL: URL?
    @Published var localFileURL: URL?
    @Published var fileExtension: FileUploadExerciseFileExtension?
    @Published var isSetupComplete = false
    @Published var canDirectlyRenderFile = false
    @Published var error: UserFacingError?
    
    var fileDownloadService = FileDownloadService()
    
    /// Sets this VM up based on the given submission
    @MainActor
    func setup(basedOn submission: BaseSubmission? = nil) async {
        guard let fileUploadSubmission = submission as? FileUploadSubmission,
              let baseUrl = UserSessionFactory.shared.institution?.baseURL?.absoluteString,
              let filePath = fileUploadSubmission.filePath?.dropFirst(),
              let remoteFileUrl = URL(string: "\(baseUrl)\(filePath)") else {
            log.error("Setup failed")
            error = UserFacingError.couldNotFetchFileDetails
            isSetupComplete = true
            return
        }
        
        reset()
        
        isLoading = true
        defer {
            isLoading = false
            isSetupComplete = true
        }
        
        self.remoteFileURL = remoteFileUrl
        let parsedFileExtension = FileUploadExerciseFileExtension(rawValue: remoteFileUrl.pathExtension) ?? .other
        fileExtension = parsedFileExtension
        
        canDirectlyRenderFile = (parsedFileExtension != .other)
        guard canDirectlyRenderFile else {
            return
        }
        
        localFileURL = await fileDownloadService.download(from: remoteFileUrl)
    }
    
    private func reset() {
        remoteFileURL = nil
        localFileURL = nil
        fileExtension = nil
        isSetupComplete = false
        canDirectlyRenderFile = false
        error = nil
    }
}
