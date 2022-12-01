import SwiftUI

// used to show opened tabs on top of CodeView
struct TabsView: View {
    @EnvironmentObject var cvm: CodeEditorViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollReader in
                HStack {
                    Divider()
                    ForEach(cvm.openFiles, id: \.path) { file in
                        HStack {
                            Text(file.name)
                                .bold(cvm.selectedFile?.path == file.path)
                            Button(action: {
                                cvm.closeFile(file: file)
                            }, label: {
                                if file.path == cvm.selectedFile?.path {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .buttonStyle(.borderless)
                                }
                            })
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .id(file)
                        .onTapGesture {
                            withAnimation {
                                cvm.selectedFile = file
                            }
                        }
                        Divider()
                    }
                }
                .frame(height: 20)
                .onChange(of: cvm.selectedFile, perform: { file in
                    scrollReader.scrollTo(file, anchor: nil)
                })
                .padding()
            }
        }
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView()
    }
}
