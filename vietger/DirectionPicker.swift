import SwiftUI

struct DirectionPicker: View {
    @Binding var selected: QuizDirection?
    var onPicked: () -> Void  // parent decides what happens next (e.g., advance stage)

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose direction")
                .font(.title2)
                .bold()
                .padding(.top)

            ForEach(QuizDirection.allCases) { dir in
                Button {
                    selected = dir
                    onPicked()
                } label: {
                    HStack {
                        Text(dir.title).font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    DirectionPicker(selected: .constant(nil), onPicked: {})
        .padding()
}
