//
//  ProblemStatementView.swift
//  Themis
//
//  Created by Tarlan Ismayilsoy on 22.05.23.
//

import SwiftUI
import DesignLibrary
import UserStore
import Common

/// A view that loads a standalone problem statement page in a WebView
struct ProblemStatementView: View {
    @State private var request: URLRequest?
    @State private var height: CGFloat = .l
    @State private var isLoading = true
    
    /// Used for setting the height after the page is loaded. Without this, the problem statement webpage cannot resize properly.
    private let heightQuery = "document.body.getElementsByClassName('instructions__content')[0].scrollHeight"

    init(courseId: Int?, exerciseId: Int?) {
        if let courseId,
           let exerciseId,
           let url = URL(string: "/courses/\(courseId)/exercises/\(exerciseId)/problem-statement", relativeTo: UserSessionFactory.shared.institution?.baseURL) {
            self._request = State(wrappedValue: URLRequest(url: url))
        }
    }
    
    var body: some View {
        if let request {
            ZStack {
                ArtemisWebView(urlRequest: .constant(request),
                               contentHeight: $height,
                               isLoading: $isLoading,
                               customJSHeightQuery: heightQuery)
                .disabled(true)
                .frame(height: isLoading ? 0 : height)
                
                TextSkeleton()
                    .isHidden(!isLoading, remove: true)
            }
        } else {
            errorMessage
        }
    }
    
    private var errorMessage: some View {
        VStack {
            Image(systemName: "text.badge.xmark")
                .font(.system(size: 40, weight: .medium))
                .padding(.bottom, 10)
            
            Text("Could not load content")
                .font(.system(size: 14, weight: .medium))
        }
        .padding(10)
        .foregroundColor(.gray.opacity(0.8))
        .textCase(.uppercase)
        .frame(maxWidth: .infinity)
        .onAppear {
            log.error("Problem statement could not be loaded")
        }
    }
}

struct ProblemStatementView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedPreview {
            ProblemStatementView(courseId: 3342, exerciseId: 5284)
        }
    }
}
