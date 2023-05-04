//
//  CorrectionHelpView.swift
//  Themis
//
//  Created by Florian Huber on 13.11.22.
//

import SwiftUI
import SharedModels

enum CorrectionSidebarElements {
    case problemStatement, correctionGuidelines, generalFeedback
}

struct CorrectionSidebarView: View {

    @State var correctionSidebarStatus = CorrectionSidebarElements.problemStatement
    let exercise: (any BaseExercise)?
    let readOnly: Bool
    @Binding var assessmentResult: AssessmentResult
    @ObservedObject var cvm: CodeEditorViewModel
    @ObservedObject var umlVM: UMLViewModel
    let loading: Bool
    

    var problemStatement: String
    var participationId: Int?
    var templateParticipationId: Int?

    var body: some View {
        VStack {
            sideBarElementPicker
            
            if !loading {
                switch correctionSidebarStatus {
                case .problemStatement:
                    ScrollView {
                        ProblemStatementCellView(
                            problemStatement: .constant(problemStatement), // TODO: remove unnecessary binding
                            feedbacks: assessmentResult.feedbacks,
                            umlVM: umlVM
                        )
                    }
                case .correctionGuidelines:
                    ScrollView {
                        CorrectionGuidelinesCellView(
                            gradingCriteria: exercise?.gradingCriteria ?? [],
                            gradingInstructions: exercise?.gradingInstructions
                        )
                    }
                case .generalFeedback:
                    FeedbackListView(
                        readOnly: readOnly,
                        assessmentResult: assessmentResult,
                        cvm: cvm,
                        participationId: participationId,
                        templateParticipationId: templateParticipationId,
                        gradingCriteria: exercise?.gradingCriteria ?? []
                    )
                }
            }
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .background(Color("sidebarBackground"))
    }
    
    private var sideBarElementPicker: some View {
        Picker(selection: $correctionSidebarStatus, label: Text("")) {
            Text("Problem")
                .tag(CorrectionSidebarElements.problemStatement)
            Text("Guidelines")
                .tag(CorrectionSidebarElements.correctionGuidelines)
            Text("Feedback")
                .tag(CorrectionSidebarElements.generalFeedback)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

struct CorrectionSidebarView_Previews: PreviewProvider {
    static let cvm = CodeEditorViewModel()
    static let umlVM = UMLViewModel()
    @State static var assessmentResult = AssessmentResult()

    static var previews: some View {
        CorrectionSidebarView(
            exercise: nil,
            readOnly: false,
            assessmentResult: $assessmentResult,
            cvm: cvm,
            umlVM: umlVM,
            loading: true,
            problemStatement: "test"
        )
        .previewInterfaceOrientation(.landscapeLeft)
    }
 }
