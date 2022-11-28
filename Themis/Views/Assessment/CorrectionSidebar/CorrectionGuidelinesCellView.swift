//
//  CorrectionGuidelinesView.swift
//  Themis
//
//  Created by Florian Huber on 13.11.22.
//

import SwiftUI

struct CorrectionGuidelinesCellView: View {
    @EnvironmentObject var assessment: AssessmentViewModel

    var gradingCriteria: [GradingCriteria] {
        guard let criteria = assessment.submission?.participation.exercise.gradingCriteria else {
            return []
        }
        return criteria
    }

    let artemisColor = Color(#colorLiteral(red: 0.20944947, green: 0.2372354269, blue: 0.2806544006, alpha: 1))

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 40) {
                Text("Correction Guidelines")
                    .font(.largeTitle)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Assessment Instructions").font(.title2)

                    Text(assessment.submission?.participation.exercise.gradingInstructions ?? "").padding()
                }.padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Structured Assessment Criteria").font(.title2)

                    ForEach(gradingCriteria) { gradingCriterium in
                        GradingCriteriaCellView(gradingCriterium: gradingCriterium)
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 20)
                        .stroke(artemisColor, lineWidth: 2))
                }.padding()

                Spacer()
            }
        }.padding()
    }
}

struct CorrectionGuidelinesCellView_Previews: PreviewProvider {
    static var previews: some View {
        CorrectionGuidelinesCellView(correctionGuidelinesModel: CorrectionGuidelines.mock)
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
