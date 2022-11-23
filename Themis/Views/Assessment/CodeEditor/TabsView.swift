import SwiftUI

// used to show opened tabs on top of CodeView
struct TabsView: View {
    @ObservedObject var model: AssessmentViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { scrollReader in
                HStack {
                    Divider()
                    ForEach(model.openFiles, id: \.path) { file in
                        HStack {
                            Text(file.name)
                                .bold(model.selectedFile?.path == file.path)
                            Button(action: {
                                model.closeFile(file: file)
                            }, label: {
                                if file.path == model.selectedFile?.path {
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
                                model.selectedFile = file
                            }
                        }
                        Divider()
                    }
                }
                .frame(height: 20)
                .onChange(of: model.selectedFile, perform: { file in
                    scrollReader.scrollTo(file, anchor: nil)
                })
                .padding()
            }
        }
    }
}

struct TabsView_Previews: PreviewProvider {
    static var previews: some View {
        TabsView(model: AssessmentViewModel.mock)
    }
}
