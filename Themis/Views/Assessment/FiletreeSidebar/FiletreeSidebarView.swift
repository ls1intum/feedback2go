import SwiftUI

struct FiletreeSidebarView: View {
    let participationID: Int?
    @ObservedObject var cvm: CodeEditorViewModel
    let loading: Bool

    let templateParticipationId: Int?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Filetree")
                .font(.title)
                .bold()
                .padding(.leading, 18)
            if !loading {
                List {
                    OutlineGroup(cvm.fileTree, id: \.path, children: \.children) { tree in
                        if tree.type == .folder {
                            nodeFolderView(folder: tree)
                        } else {
                            nodeFileView(file: tree)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color("sidebarBackground"))
                }
                .listStyle(.inset)
                .background(Color("sidebarBackground"))
                .scrollContentBackground(.hidden)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 35)
        .background(Color("sidebarBackground"))
    }
    
    @ViewBuilder
    func nodeFolderView(folder: Node) -> some View {
        HStack {
            Image(systemName: "folder")
            Text(folder.name)
        }
    }
    
    @ViewBuilder
    func nodeFileView(file: Node) -> some View {
        Button {
            withAnimation {
                guard let participationID else {
                    return
                }
                cvm.openFile(file: file,
                             participationId: participationID,
                             templateParticipationId: templateParticipationId
                )
            }
        } label: {
            FileView(file: file)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .bold(file === cvm.selectedFile)
        .background(file === cvm.selectedFile ? Color("selectedFileBackground") : Color("sidebarBackground"))
        .cornerRadius(10)
    }
}
