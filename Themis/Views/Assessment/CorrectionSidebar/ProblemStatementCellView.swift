//
//  ProblemStatementView.swift
//  Themis
//
//  Created by Florian Huber on 13.11.22.
//

import SwiftUI
import Foundation
import MarkdownUI

struct ProblemStatementCellView: View {
    @Environment(\.colorScheme) var colorScheme
    var problemStatement: String?
    var feedbacks: [AssessmentFeedback]
    @ObservedObject var umlVM: UMLViewModel

    @StateObject var vm = ProblemStatementCellViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Problem Statement")
                .font(.largeTitle)

            ForEach(vm.problemStatementParts, id: \.text) { part in
                if let puml = part as? ProblemStatementPlantUML {
                    AsyncImage(url: puml.url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    Markdown(part.text)
                }
            }
        }
        .padding()
        .onAppear {
            vm.convertProblemStatement(
                problemStatement: problemStatement ?? "",
                colorScheme: colorScheme
            )
        }
    }
}

struct ProblemStatementCellView_Previews: PreviewProvider {
    static var umlVM = UMLViewModel()
    static let feedbacks: [AssessmentFeedback] = []

    static var previews: some View {
        ProblemStatementCellView(
            problemStatement: "Test",
            feedbacks: feedbacks,
            umlVM: umlVM
        )
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
