import SwiftUI

struct Notes: View {
  @State var currentNotes = ""
  
  var body: some View {
    TextEditor(text: $currentNotes)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(RoundedRectangle(cornerRadius: 22).fill(Material.ultraThin))
      .scrollContentBackground(.hidden)
      .ignoresSafeArea(.container, edges: .bottom)
  }
}

#Preview {
  Notes()
}

