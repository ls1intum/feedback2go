//
//  EditFeedbackView.swift
//  Themis
//
//  Created by Paul Schwind on 14.12.22.
//

import SwiftUI
import SharedModels

struct EditFeedbackView: View {
    var assessmentResult: AssessmentResult
    @ObservedObject var cvm: CodeEditorViewModel
    let scope: ThemisFeedbackScope

    @Binding var showSheet: Bool
    var idForUpdate: UUID
    
    let gradingCriteria: [GradingCriterion]

    var body: some View {
        EditFeedbackViewBase(
            assessmentResult: assessmentResult,
            cvm: cvm,
            showSheet: $showSheet,
            idForUpdate: idForUpdate,
            title: "Edit Feedback",
            edit: true,
            scope: scope,
            gradingCriteria: gradingCriteria
        )
    }
}
