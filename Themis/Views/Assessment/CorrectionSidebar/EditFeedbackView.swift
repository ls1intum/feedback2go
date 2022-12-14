//
//  EditFeedbackView.swift
//  Themis
//
//  Created by Katjana Kosic on 28.11.22.
//

import Foundation
import SwiftUI

struct EditFeedbackView: View {
    @Binding var assessmentResult: AssessmentResult
    @ObservedObject var cvm: CodeEditorViewModel

    let feedback: AssessmentFeedback?
    @State var detailText = ""
    @State var score = 0.0
    @Binding var showEditFeedback: Bool

    let maxScore = Double(10)

    let edit: Bool
    let type: FeedbackType

    var pickerRange: [Double] {
        Array(stride(from: -1 * maxScore, to: maxScore +  0.5, by: 0.5))
            .sorted { $0 > $1 }
    }
    var title: String {
        edit ? "Edit Feedback" : "Add Feedback"
    }

    func updateFeedback() {
        guard let feedback else {
            return
        }
        assessmentResult.updateFeedback(
            id: feedback.id,
            detailText: detailText,
            credits: score
        )
    }

    func createFeedback() {
        var feedback = AssessmentFeedback(
            detailText: detailText,
            credits: score,
            type: type,
            file: cvm.selectedFile
        )
        let lines: NSRange? = cvm.selectedSectionParsed?.0
        let columns: NSRange? = cvm.selectedSectionParsed?.1
        feedback.buildLineDescription(lines: lines, columns: columns)
        cvm.addInlineHighlight(feedbackId: feedback.id)
        assessmentResult.addFeedback(feedback: feedback)
    }

    private func setStates() {
        guard let feedback else {
            return
        }
        self.detailText = feedback.detailText ?? ""
        self.score = feedback.credits
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.largeTitle)
                Spacer()
                Button {
                    if edit {
                        updateFeedback()
                    } else {
                        createFeedback()
                    }
                    showEditFeedback = false
                } label: {
                    Text("Save")
                }.font(.title)
                    .disabled(detailText.isEmpty)
            }
            HStack {
                TextField("Enter your feedback here", text: $detailText, axis: .vertical)
                    .submitLabel(.return)
                    .lineLimit(10...40)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 2))
                Text("Score:")
                    .font(.title)
                    .padding(.leading)
                Picker("Score", selection: $score) {
                    ForEach(pickerRange, id: \.self) { number in
                        if number < 0.0 {
                            Text(String(format: "%.1f", number)).foregroundColor(.red)
                        } else if number > 0.0 {
                            Text(String(format: "%.1f", number)).foregroundColor(.green)
                        } else {
                            Text(String(format: "%.1f", number))
                        }
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: 150)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            setStates()
        }
    }
}
