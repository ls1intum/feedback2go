//
//  ProblemStatementView.swift
//  Themis
//
//  Created by Florian Huber on 13.11.22.
//

import SwiftUI
import Foundation

struct ProblemStatementCellView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 40) {
                /*ForEach(ProblemStatementCellViewModel.splitString(ProblemStatementCellViewModel.mockData), id: \.self) { line in
                    Text(line)
                }*/
                Text("Problem Statement")
                    .font(.largeTitle)
                Spacer()
                Text(ProblemStatementCellViewModel.convertString(ProblemStatementCellViewModel.mockData))
            }
            Spacer()
        }.padding()
    }
}

struct ProblemStatementCellView_Previews: PreviewProvider {
    static var previews: some View {
        ProblemStatementCellView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}