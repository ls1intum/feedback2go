//
//  CourseView.swift
//  Themis
//
//  Created by Tom Rudnick on 12.11.22.
//

import SwiftUI
import Login
import APIClient
import UserStore

struct CourseView: View {
    @StateObject var courseVM = CourseViewModel()
        
    private var navTitle: String {
        guard let shownCourse = courseVM.shownCourse, !courseVM.loading else {
            return ""
        }
        return shownCourse.title ?? "Unnamed course"
    }

    var body: some View {
        NavigationStack {
            Group {
                if courseVM.showCoursesIsEmptyMessage {
                    coursesEmptyInfo
                } else if courseVM.showExercisesIsEmptyMessage {
                    exercisesEmptyInfo
                } else {
                    ScrollView(.vertical) {
                        VStack(spacing: 25) {
                            ExerciseGroups(courseVM: courseVM, type: .inAssessment)
                            ExerciseGroups(courseVM: courseVM, type: .viewOnly)
                            Spacer()
                        }
                        .padding(20)
                    }
                    .environmentObject(courseVM)
                    .refreshable {
                        courseVM.fetchAllCourses()
                        courseVM.fetchShownCourseAndSetExercises()
                    }
                }
            }
            .navigationTitle(navTitle)
            .toolbar(content: generateToolbarContent)
        }
        .task {
            courseVM.fetchAllCourses()
            courseVM.fetchShownCourseAndSetExercises()
        }
        .errorAlert(error: $courseVM.error)
    }
    
    private var logoutButton: some View {
        Button {
            APIClient().perfomLogout()
        } label: {
            Text("Logout")
        }
    }
    
    private var userFirstName: some View {
        Text(UserSessionFactory.shared.user?.name ?? "")
            .foregroundColor(.secondary)
            .font(.callout)
    }
    
    private var coursesEmptyInfo: some View {
        VStack {
            Image(systemName: "person.fill.xmark")
                .font(.system(size: 80))
                .padding(.bottom)
            
            Text("You are not assigned to any course as a teaching assistant")
                .textCase(.uppercase)
                .font(.system(size: 17, weight: .medium))
        }
        .foregroundColor(.secondary)
    }
    
    private var exercisesEmptyInfo: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "xmark")
                    .font(.system(size: 30, weight: .medium))
                    .frame(alignment: .trailing)
                
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.system(size: 60))
                    .padding([.top, .trailing], 25)
            }
            .padding(.bottom)
            
            Text("There are no exercises in this course")
                .textCase(.uppercase)
                .font(.system(size: 17, weight: .medium))
        }
        .foregroundColor(.secondary)
    }
    
    @ToolbarContentBuilder
    private func generateToolbarContent() -> some ToolbarContent {
        ToolbarItemGroup(placement: .cancellationAction) {
            logoutButton
            userFirstName
        }
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Picker("", selection: $courseVM.shownCourseID) {
                    ForEach(courseVM.pickerCourseIDs, id: \.self) { courseID in
                        if let courseID {
                            Text(courseVM.courseForID(id: courseID)?.title ?? "Invalid")
                                .padding(.leading, 40)
                        }
                    }
                }
                .padding(-10) // compensates for Picker's default padding
            } label: {
                Text("Change Course")
            }
            .popoverTip(CoursePickerTip())
            .onChange(of: courseVM.shownCourseID) { courseVM.fetchShownCourseAndSetExercises() }
            .isHidden(courseVM.showCoursesIsEmptyMessage)
        }
    }
}

struct CourseView_Previews: PreviewProvider {
    static var courseVM = CourseViewModel()
    
    static var previews: some View {
        AuthenticatedPreview(authenticationVM: PreviewAuthenticationViewModel()) {
            CourseView(courseVM: courseVM)
        }
    }
}
