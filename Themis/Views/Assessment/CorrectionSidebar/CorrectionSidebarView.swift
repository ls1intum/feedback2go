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
    @EnvironmentObject var courseVM: CourseViewModel
    @State private var correctionSidebarStatus = CorrectionSidebarElements.problemStatement
    
    @Binding var assessmentResult: AssessmentResult
    @ObservedObject var assessmentVM: AssessmentViewModel
    
    weak var feedbackDelegate: (any FeedbackDelegate)?
    
    private var exercise: (any BaseExercise)? {
        assessmentVM.participation?.getExercise()
    }
    
    private var templateParticipationId: Int? {
        assessmentVM.participation?.getExercise(as: ProgrammingExercise.self)?.templateParticipation?.id
    }
    
    var body: some View {
        VStack {
            sideBarElementPicker
            
            if !assessmentVM.loading {
                ZStack {
                    VStack {
                        List {
                            problemStatementSection
                            exampleSolutionSection
                        }
                        .listStyle(.sidebar)
                        .scrollContentBackground(.hidden)
                    }
                    .opacity(correctionSidebarStatus == .problemStatement ? 1.0 : 0.0001)
                    // 0.0 causes this view to be redrawn and webview to send a new request
                    
                    switch correctionSidebarStatus {
                    case .problemStatement:
                        EmptyView() // handled above
                    case .correctionGuidelines:
                        correctionGuidelines
                    case .generalFeedback:
                        generalFeedbackList
                    }
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
    
    @ViewBuilder
    private var problemStatementSection: some View {
        Section {
            ProblemStatementView(courseId: courseVM.shownCourseID, exerciseId: exercise?.id)
                .frame(maxHeight: .infinity)
        } header: {
            Text("Problem Statement")
        }
        .headerProminence(.increased)
    }
    
    @ViewBuilder
    private var exampleSolutionSection: some View {
        if let exercise = assessmentVM.participation?.exercise,
           exercise.canShowExampleSolution {
            Section {
                ExampleSolutionView(exercise: assessmentVM.participation?.exercise)
            } header: {
                Text("Example Solution")
            }
            .headerProminence(.increased)
        }
    }
    
    @ViewBuilder
    private var correctionGuidelines: some View {
        ScrollView {
            CorrectionGuidelinesCellView(
                gradingCriteria: exercise?.gradingCriteria ?? [],
                gradingInstructions: exercise?.gradingInstructions
            )
        }
    }
    
    @ViewBuilder
    private var generalFeedbackList: some View {
        FeedbackListView(
            assessmentVM: assessmentVM,
            assessmentResult: assessmentResult,
            feedbackDelegate: feedbackDelegate,
            participationId: assessmentVM.participation?.id,
            templateParticipationId: templateParticipationId,
            gradingCriteria: exercise?.gradingCriteria ?? []
        )
    }
}

struct CorrectionSidebarView_Previews: PreviewProvider {
    static let cvm = CodeEditorViewModel()
    @State static var assessmentResult = AssessmentResult()
    @State static var assessmentVM = MockAssessmentViewModel(exercise: Exercise.mockText, readOnly: false)
    
    static var previews: some View {
        CorrectionSidebarView(
            assessmentResult: $assessmentResult,
            assessmentVM: assessmentVM,
            feedbackDelegate: cvm
        )
        .environmentObject(cvm)
    }
}
