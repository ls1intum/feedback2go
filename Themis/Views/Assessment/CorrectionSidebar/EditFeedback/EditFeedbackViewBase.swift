//
//  EditFeedbackView.swift
//  Themis
//
//  Created by Katjana Kosic on 28.11.22.
//

import Foundation
import SwiftUI
import CodeEditor
import SharedModels

struct EditFeedbackViewBase: View {
    var assessmentResult: AssessmentResult
    weak var feedbackDelegate: (any FeedbackDelegate)?
    var idForUpdate: UUID?
    var incompleteFeedback: AssessmentFeedback?
    var feedbackSuggestion: FeedbackSuggestion?
    
    let title: String?
    let isEditing: Bool
    let scope: ThemisFeedbackScope
    let gradingCriteria: [GradingCriterion]
    
    @Binding var showSheet: Bool
    @State private var detailText = ""
    @State private var score = 0.0
    @State private var linkedGradingInstruction: GradingInstruction?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title ?? "Edit Feedback")
                    .font(.largeTitle)
                
                Spacer()
                
                if isEditing {
                    deleteButton
                }
                
                editOrSaveButton
            }
            
            linkedCriterionInfo
            
            HStack(spacing: 15) {
                textField
                
                ScorePicker(score: $score, maxScore: assessmentResult.maxPoints)
                    .frame(maxWidth: 130)
                    .disabled(linkedGradingInstruction != nil)
            }
            
            Spacer()
            
            gradingCriteriaList
        }
        .padding()
        .onAppear {
            setStates()
        }
        .onChange(of: linkedGradingInstruction) { _, newValue in
            self.score = newValue?.credits ?? 0.0
        }
        .animation(.easeIn(duration: 0.2), value: linkedGradingInstruction)
    }
    
    private var textField: some View {
        TextField("Enter \(linkedGradingInstruction != nil ? "additional" : "your") feedback here", text: $detailText, axis: .vertical)
            .foregroundColor(Color.getTextColor(forCredits: score))
            .submitLabel(.return)
            .lineLimit(10...40)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 5)
                .stroke(lineWidth: 2)
                .foregroundColor(.getTextColor(forCredits: score)))
            .background(Color.getBackgroundColor(forCredits: score))
    }
    
    private var gradingCriteriaList: some View {
        ScrollView(.vertical) {
            VStack {
                ForEach(gradingCriteria) { gradingCriterion in
                    GradingCriteriaCellView(gradingCriterion: gradingCriterion,
                                            selectedGradingInstruction: $linkedGradingInstruction)
                }
            }
        }
    }
    
    private var editOrSaveButton: some View {
        Button {
            if isEditing {
                updateFeedback()
            } else {
                createFeedback()
            }
            showSheet = false
        } label: {
            Text("Save")
        }
        .buttonStyle(ThemisButtonStyle())
        .font(.title2)
        // Don't remove, this is needed for UI Test
        .accessibilityIdentifier("SaveAssessment")
    }
    
    private var deleteButton: some View {
        Button {
            deleteFeedback()
            showSheet = false
        } label: {
            Image(systemName: "trash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 27)
        }
        .buttonStyle(ThemisButtonStyle(color: .themisRed))
        .font(.title2)
    }
    
    @ViewBuilder
    private var linkedCriterionInfo: some View {
        if let instructionFeedback = linkedGradingInstruction?.feedback {
            HStack(alignment: .top, spacing: 5) {
                Image(systemName: "link")
                Text("\(instructionFeedback)")
                
                Spacer()
                
                Button(action: { linkedGradingInstruction = nil }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color.themisSecondary)
                        .font(.title2)
                })
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundStyle(Color.getBackgroundColor(forCredits: score))
            }
            .padding(.bottom)
            .foregroundColor(Color.getTextColor(forCredits: score))
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
    
    private func updateFeedback() {
        if let id = idForUpdate,
           let updatedFeedback = assessmentResult.updateFeedback(id: id,
                                                                 detailText: detailText,
                                                                 credits: score,
                                                                 instruction: linkedGradingInstruction) {
            feedbackDelegate?.onFeedbackUpdate(updatedFeedback)
        }
    }
    
    private func createFeedback() {
        if let feedbackSuggestion {
            addFeedbackSuggestionToFeedbacks(feedbackSuggestion: feedbackSuggestion)
        } else {
            let feedbackType = (scope == .inline) ? FeedbackType.MANUAL : .MANUAL_UNREFERENCED
            let feedbackDetail = (scope == .inline) ? incompleteFeedback?.detail : nil
            let feedback = AssessmentFeedback(baseFeedback: Feedback(detailText: detailText,
                                                                     credits: score,
                                                                     type: feedbackType,
                                                                     gradingInstruction: linkedGradingInstruction),
                                              scope: scope,
                                              detail: feedbackDetail)
            
            assessmentResult.addFeedback(feedback: feedback)
            
            if scope == .inline {
                feedbackDelegate?.onFeedbackCreation(feedback)
            }
        }
    }
    
    private func deleteFeedback() {
        guard let feedback = assessmentResult.feedbacks.first(where: { idForUpdate == $0.id }) else {
            return
        }
        assessmentResult.deleteFeedback(id: feedback.id)
        feedbackDelegate?.onFeedbackDeletion(feedback)
    }
    
    private func addFeedbackSuggestionToFeedbacks(feedbackSuggestion: FeedbackSuggestion) {
        guard var incompleteFeedbackDetail = incompleteFeedback?.detail as? ProgrammingFeedbackDetail else {
            return
        }
        
        let lines = NSRange(location: feedbackSuggestion.fromLine, length: feedbackSuggestion.toLine - feedbackSuggestion.fromLine)
        incompleteFeedbackDetail.lines = lines
        
        let feedback = AssessmentFeedback(
            baseFeedback: Feedback(detailText: feedbackSuggestion.text,
                                   credits: feedbackSuggestion.credits,
                                   type: .MANUAL_UNREFERENCED),
            scope: .inline,
            detail: incompleteFeedbackDetail)
        
        assessmentResult.addFeedback(feedback: feedback)
        feedbackDelegate?.onFeedbackSuggestionSelection(feedbackSuggestion, feedback)
    }
    
    private func setStates() {
        if idForUpdate != nil {
            if let feedback = assessmentResult.feedbacks.first(where: { idForUpdate == $0.id }) {
                var detailText = feedback.baseFeedback.detailText ?? feedback.baseFeedback.text ?? ""
                // If an instruction is applied, the user can not edit the `text` field
                if feedback.baseFeedback.gradingInstruction != nil {
                    detailText = feedback.baseFeedback.detailText ?? ""
                }
                self.detailText = detailText
                
                self.score = feedback.baseFeedback.credits ?? 0.0
                self.linkedGradingInstruction = feedback.baseFeedback.gradingInstruction
            }
        }
        if let feedbackSuggestion = feedbackSuggestion {
            self.detailText = feedbackSuggestion.text
            self.score = feedbackSuggestion.credits
        }
    }
}

struct EditFeedbackViewBase_Previews: PreviewProvider {
    static var result = AssessmentResult()
    static var cvm = CodeEditorViewModel()
    
    static var previews: some View {
        EditFeedbackViewBase(assessmentResult: result,
                             feedbackDelegate: cvm,
                             title: "Title",
                             isEditing: false,
                             scope: .inline,
                             gradingCriteria: [.mock],
                             showSheet: .constant(true)
        )
    }
}
