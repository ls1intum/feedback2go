//
//  ExamSectionDetailView.swift
//  Themis
//
//  Created by Andreas Cselovszky on 07.02.23.
//

import SwiftUI
import SharedModels

struct ExamSectionDetailView: View {
    @EnvironmentObject var courseVM: CourseViewModel
    
    let examID: Int
    let courseID: Int
    let examTitle: String
    
    @State var exam: Exam?
    @State var exercises: [Exercise] = []
    
    var body: some View {
        Form {
            Section("Exercise Groups") {
                ForEach(exercises) { exercise in
                    NavigationLink {
                        ExerciseView(exercise: exercise, courseId: courseVM.shownCourse?.id ?? -1, exam: exam)
                            .environmentObject(courseVM)
                    } label: {
                        HStack {
                            exercise.image
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: .smallImage)
                            
                            Text(exercise.baseExercise.title ?? "")
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                    }
                    .disabled(exercise.isDisabled)
                }
            }
        }.task {
            let exam = try? await ExamServiceFactory.shared.getExamForAssessment(courseId: courseID, examId: examID)
            
            if let exam {
                self.exam = exam
                self.exercises = exam.exercises
            }
        }
        .navigationTitle(examTitle)
    }
}
