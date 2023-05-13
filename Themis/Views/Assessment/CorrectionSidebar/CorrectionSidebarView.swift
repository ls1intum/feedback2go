//
//  CorrectionHelpView.swift
//  Themis
//
//  Created by Florian Huber on 13.11.22.
//

import SwiftUI
import DesignLibrary
import SharedModels

enum CorrectionSidebarElements {
    case problemStatement, correctionGuidelines, generalFeedback
}

struct CorrectionSidebarView: View {

    @State private var correctionSidebarStatus = CorrectionSidebarElements.problemStatement
    @State private var problemStatementHeight: CGFloat = 1.0
    @State private var problemStatementRequest: URLRequest
    
    @Binding var assessmentResult: AssessmentResult
    @ObservedObject var assessmentVM: AssessmentViewModel
    @ObservedObject var cvm: CodeEditorViewModel
        
    private var exercise: (any BaseExercise)? {
        assessmentVM.participation?.getExercise()
    }
    
    private var templateParticipationId: Int? {
        assessmentVM.participation?.getExercise(as: ProgrammingExercise.self)?.templateParticipation?.id
    }
    
    init(assessmentResult: Binding<AssessmentResult>,
         assessmentVM: AssessmentViewModel,
         cvm: CodeEditorViewModel,
         courseId: Int) {
        self._assessmentResult = assessmentResult
        self.assessmentVM = assessmentVM
        self.cvm = cvm
        
        let exercise = assessmentVM.participation?.getExercise()
        self._problemStatementRequest = State(
            wrappedValue: URLRequest(url: URL(string: "/courses/\(courseId)/exercises/\(exercise?.id ?? -1)/problem-statement", relativeTo: RESTController.shared.baseURL)!)
        )
    }
    
    var body: some View {
        VStack {
            sideBarElementPicker
            
            if !assessmentVM.loading {
                switch correctionSidebarStatus {
                case .problemStatement:
                    ScrollView {
                        ArtemisWebView(urlRequest: $problemStatementRequest, contentHeight: $problemStatementHeight)
                            .frame(height: problemStatementHeight)
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
                        readOnly: assessmentVM.readOnly,
                        assessmentResult: assessmentResult,
                        codeEditorVM: cvm,
                        participationId: assessmentVM.participation?.id,
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
    @State static var assessmentResult = AssessmentResult()
    @State static var assessmentVM = AssessmentViewModel(readOnly: false)
    
    static var previews: some View {
        CorrectionSidebarView(
            assessmentResult: $assessmentResult,
            assessmentVM: assessmentVM,
            cvm: cvm,
            courseId: -1
        )
        .previewInterfaceOrientation(.landscapeLeft)
    }
}
