import SwiftUI

struct SizePicker: View {
    @Binding var customSize: String
    @Binding var stage: QuizStage
    var onPick: (Int) -> Void   // Closure to trigger startSession from QuizView
    
    private let presetSizes = [5, 10, 25, 50, 100]
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Choose amount of words")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center) // ✅ Horizontal center
                .frame(maxWidth: .infinity, alignment: .center) // ✅ Ensures centering
                        
            ForEach(presetSizes, id: \.self) { n in
                Button("\(n) words") {
                    onPick(n)  // ✅ Calls parent’s startSession
                }
                .buttonStyle(.borderedProminent)
            }
            
            HStack {
                TextField("Custom", text: $customSize)
                    .keyboardType(.numberPad)
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button("Start") {
                    if let n = Int(customSize), n > 0 {
                        onPick(n)
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            
            Button("Back") {
                stage = .pickDirection
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
