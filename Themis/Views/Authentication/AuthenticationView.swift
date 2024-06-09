//
//  AuthenticationView.swift
//  Themis
//
//  Created by Tom Rudnick on 11.11.22.
//

import SwiftUI
import Login
import UserStore
import DesignLibrary

struct AuthenticationView: View {
    enum SecureFieldFocus { case plain, secure }
    enum FocusedField { case serverurl, username, password }

    @StateObject private var loginVM = LoginViewModel()
    @State private var isSecured = true
    @State private var invalidAttempts: Int = 0
    @State private var showInstitutionSelection = false
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var passwordFocus: SecureFieldFocus?
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        VStack {
            appIcon
            
            welcomeText
            
            usernameField
            
            passwordField
            
            rememberMeToggle
            
            authenticateButton
            
            universitySelectionButton
        }
        .onSubmit {
            handleSubmit()
        }
        .onChange(of: loginVM.institution) { _, newIdentifier in
            updateRESTController(for: newIdentifier)
        }
        .task {
            await loginVM.getProfileInfo()
        }
    }
    
    private var appIcon: some View {
        Image("AppIconVectorTransparent")
            .resizable()
            .frame(maxWidth: 300, maxHeight: 300)
            .scaledToFit()
    }
    
    private var welcomeText: some View {
        Group {
            Text("Welcome to Themis!")
                .font(.title)
                .bold()
            
            Text("Please sign in with your \(loginVM.institution.shortName) account")
                .font(.headline)
            
            showCaptchaInfoIfNeeded()
        }
        .padding()
    }

    private var authenticateButton: some View {
        Button {
            loginVM.isLoading = true
            Task {
                await loginVM.login()
                if loginVM.error != nil { // login failed
                    withAnimation(.linear) {
                        self.invalidAttempts += 1
                    }
                } else { // login successful, reset error and failed attempts
                    withAnimation(.easeOut(duration: 0.3)) {
                        loginVM.error = nil
                        self.invalidAttempts = 0
                    }
                }
            }
        } label: {
            Group {
                if loginVM.isLoading {
                    ProgressView()
                } else {
                    Text("Sign in")
                }
            }
        }
        .disabled(loginVM.loginDisabled)
        .buttonStyle(LoginButtonStyle(loginDisabled: loginVM.loginDisabled))
    }
    
    private var usernameField: some View {
        TextField("Username", text: $loginVM.username)
            .textFieldStyle(LoginTextFieldStyle(error: $loginVM.error))
            .textInputAutocapitalization(.never)
            .focused($focusedField, equals: .username)
            .submitLabel(.next)
            .modifier(ShakeEffect(animatableData: CGFloat(invalidAttempts)))
    }

    private var passwordField: some View {
        ZStack(alignment: .trailing) {
            Group {
                SecureField("Password", text: $loginVM.password)
                    .focused($passwordFocus, equals: .secure)
                    .opacity(isSecured ? 1.0 : 0.0)
                TextField("Password", text: $loginVM.password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .focused($passwordFocus, equals: .plain)
                    .opacity(!isSecured ? 1.0 : 0.0)
            }
            .focused($focusedField, equals: .password)
            .submitLabel(.join)
            .padding(.trailing, 32)
            
            Button(action: {
                isSecured.toggle()
                passwordFocus = isSecured ? .secure : .plain
            }) {
                Image(systemName: self.isSecured ? "eye" : "eye.slash")
                    .accentColor(.gray)
            }
        }
        .padding()
        .frame(width: 500, height: 50)
        .background(colorScheme == .light ? Color.black.opacity(0.1) : Color(uiColor: UIColor.systemGray6))
        .cornerRadius(10)
        .overlay {
            if loginVM.error != nil {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.red.opacity(0.4), lineWidth: 3)
            }
        }
        .modifier(ShakeEffect(animatableData: CGFloat(invalidAttempts)))
    }
    
    private var rememberMeToggle: some View {
        Toggle("Remember me", isOn: $loginVM.rememberMe)
            .frame(maxWidth: 500)
            .padding()
    }
    
    private var universitySelectionButton: some View {
        Button("Select university") {
            showInstitutionSelection = true
        }
        .sheet(isPresented: $showInstitutionSelection) {
            InstitutionSelectionView(institution: $loginVM.institution,
                                     handleProfileInfoCompletion: loginVM.handleProfileInfoReceived)
        }
        .padding(.top, 40)
#if DEBUG
        .onAppear {
            //UserSession.shared.saveInstitution(identifier: .custom(URL(string: "https://artemis-staging.ase.in.tum.de/")))
        }
#endif
    }
    
    private func handleSubmit() {
        switch focusedField {
        case .serverurl:
            focusedField = .username
        case .username:
            focusedField = .password
        case .password:
            Task {
                await loginVM.login()
            }
            focusedField = nil
        case .none:
            focusedField = nil
        }
    }
    
    private func updateRESTController(for identifier: InstitutionIdentifier) {
        // swiftlint:disable:next force_unwrapping
        RESTController.shared = RESTController(baseURL: identifier.baseURL ?? URL(string: "https://artemis.ase.cit.tum.de/")!)
    }
    
    @ViewBuilder
    private func showCaptchaInfoIfNeeded() -> some View {
        if loginVM.captchaRequired {
            DataStateView(data: $loginVM.externalUserManagementUrl, retryHandler: loginVM.getProfileInfo) { externalUserManagementURL in
                DataStateView(data: $loginVM.externalUserManagementName, retryHandler: loginVM.getProfileInfo) { externalUserManagementName in
                    VStack {
                        Text(R.string.localizable.account_captcha_title())
                        Text(.init(R.string.localizable.account_captcha_message(externalUserManagementName,
                                                                                externalUserManagementURL.absoluteString,
                                                                                externalUserManagementURL.absoluteString)))
                    }
                    .padding()
                    .border(.red)
                }
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .previewInterfaceOrientation(.landscapeRight)
    }
}
