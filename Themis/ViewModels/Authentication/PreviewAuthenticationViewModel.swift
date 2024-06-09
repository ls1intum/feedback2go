//
//  PreviewAuthenticationViewModel.swift
//  Themis
//
//  Created by Paul Schwind on 24.11.22.
//


import Foundation
import Login
import UserStore

/// This is an AuthenticationViewModel you can use for the XCode preview feature.
/// Usually, you would have to somehow log in, but would be quite annoying and would also duplicate a lot of code.
/// Instead, you can just use a PreviewAuthenticationViewModel, which will automatically log in using credentials found in your environment.
/// For this to work, you have to edit the Themis scheme in XCode to include the following environment variables:
/// - ARTEMIS_STAGING_SERVER
/// - ARTEMIS_STAGING_USER
/// - ARTEMIS_STAGING_PASSWORD
/// Consult https://confluence.ase.in.tum.de/display/IOS2223CIT/Authentication+Preview+Setup for an explanation on how to configure them.
/// (alternative for people without access: https://m25lazi.medium.com/environment-variables-in-xcode-a78e07d223ed)
class PreviewAuthenticationViewModel: LoginViewModel {
    override init() {
        super.init()
        UserSessionFactory.shared.wipeKeychain()
        
        guard let serverURL = stagingServer else {
            fatalError("Set the staging server in the environment to use PreviewAuthenticationViewModel.")
        }
        UserSessionFactory.shared.saveInstitution(identifier: .custom(URL(string: serverURL)))
        self.institution = .custom(URL(string: serverURL))
        
        guard let username = stagingUser else {
            fatalError("Set the staging user in the environment to use PreviewAuthenticationViewModel.")
        }
        UserSessionFactory.shared.saveUsername(username: username)
        self.username = username
        
        guard let password = stagingPassword else {
            fatalError("Set the staging password in the environment to use PreviewAuthenticationViewModel.")
        }
        UserSessionFactory.shared.savePassword(password: password)
        self.password = password
        
        Task {
            await self.login()
        }
    }
}
