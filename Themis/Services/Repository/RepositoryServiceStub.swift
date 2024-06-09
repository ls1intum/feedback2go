//
//  RepositoryServiceStub.swift
//  Themis
//
//  Created by Anian Schleyer on 09.06.24.
//

import SharedModels

class RepositoryServiceStub: RepositoryService {
    func getFileNamesOfRepository(participationId: Int) async throws -> [String: FileType] {
        [
            "code.swift": .file,
            "assets": .folder
        ]
    }
    
    func getFileOfRepository(participationId: Int, filePath: String) async throws -> String {
        // Using code from ThemisButtonStyle.swift as example
        """
        //
        //  ThemisButtonStyle.swift
        //  Themis
        //
        //  Created by Andreas Cselovszky on 10.01.23.
        //

        import SwiftUI

        struct ThemisButtonStyle: ButtonStyle {
            @Environment(\\.isEnabled) var isEnabled: Bool
            var color = Color.themisSecondary
            var iconImageName: String?
            var horizontalPadding: CGFloat = 15
            var verticalPadding: CGFloat = 8
            
            func makeBody(configuration: Configuration) -> some View {
                HStack {
                    if let iconImageName {
                        Image(iconImageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 14, height: 6)
                            .foregroundColor(.white)
                    }
                    
                    configuration.label
                }
                .foregroundColor(Color(.systemBackground))
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .background(isEnabled ? color : Color(.systemGray))
                .cornerRadius(5)
                .fontWeight(.semibold)
                .scaleEffect(configuration.isPressed ? 1.1 : 1)
                .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            }
        }

        struct NavigationBarButtonStyle_Previews: PreviewProvider {
            static var previews: some View {
                Button("Save", action: {})
                    .buttonStyle(ThemisButtonStyle(iconImageName: "saveIcon"))
            }
        }
        """
    }
}
