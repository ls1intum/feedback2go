//
//  RootViewModel.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 13.05.23.
//

import Foundation
import Combine
import UserStore
import SharedServices

@MainActor
class RootViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var isLoggedIn = false

    private var cancellables: Set<AnyCancellable> = Set()

    init() {
        UserSessionFactory.shared.objectWillChange.sink {
            DispatchQueue.main.async { [weak self] in
                self?.isLoggedIn = UserSessionFactory.shared.isLoggedIn
            }
        }
        .store(in: &cancellables)
        
        
        Task(priority: .high) {
            let user = await AccountServiceFactory.shared.getAccount()

            switch user {
            case .loading, .failure:
                UserSessionFactory.shared.setTokenExpired(expired: false)
            case .done:
                isLoggedIn = UserSessionFactory.shared.isLoggedIn
            }
            isLoading = false
        }
    }
}
