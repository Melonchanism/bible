import SwiftUI

struct Menu: View {
  @Namespace var namespace
  @Environment(\.verticalSizeClass) var verticalSizeClass
  @State var showMenu = false
  @State var translation = CGSize.zero
  @State var bookSize: CGFloat = 0
  @State var chapterSize: CGFloat = 0
  @Binding var currentChapter: Int
  @Binding var currentBook: Int
  @Binding var currentBookValue: Bible.Book
  
  var isLandscape: Bool { verticalSizeClass == .compact }
  var landscapeLeft: Bool { UIDevice.current.orientation == .landscapeLeft }
  var navSize: CGFloat { isLandscape ? 48 : 80 }
  
  var body: some View {
    let DStack = isLandscape ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())
    if !showMenu {
      ZStack {
        DStack {
          Text("\(Bible.books[currentBook])")
            .font(.title2)
            .monospacedDigit()
            .lineLimit(1)
            .rotationEffect(Angle(degrees: isLandscape ? 90 : 0))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .matchedGeometryEffect(id: "book", in: namespace)
            .frame(width: bookSize, height: bookSize)
          Text("\(currentChapter)")
            .font(.title2)
            .lineLimit(1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .matchedGeometryEffect(id: "chapter", in: namespace)
            .frame(width: chapterSize, height: 30)
          Text(Bible.type)
            .font(.subheadline)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(width: 40, height: 20)
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.all, 0)
        DStack {
          Button(action: { withAnimation { isLandscape ? (currentChapter += 1) : (currentChapter -= 1) } }) {
            Image(systemName: "chevron.left")
              .frame(width: navSize - 16, height: 64)
              .font(.title)
              .rotationEffect(.degrees(isLandscape ? 180 : 0))
          }
          .background(RoundedRectangle(cornerRadius: 44).fill(Material.bar))
          .matchedGeometryEffect(id: "previousButton", in: namespace)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isLandscape ? .top : .leading)
          .padding(.all, 8)
          .buttonStyle(PressEffectButtonStyle())
          Button(action: { withAnimation { isLandscape ? (currentChapter -= 1) : (currentChapter += 1) } }) {
            Image(systemName: "chevron.right")
              .frame(width: navSize - 16, height: 64)
              .font(.title)
              .rotationEffect(.degrees(isLandscape ? 180 : 0))
          }
          .background(RoundedRectangle(cornerRadius: 44).fill(Material.bar))
          .matchedGeometryEffect(id: "nextButton", in: namespace)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: isLandscape ? .bottom : .trailing)
          .padding(.all, 8)
          .buttonStyle(PressEffectButtonStyle())
        }
      }
      .frame(maxWidth: isLandscape ? navSize : .infinity, maxHeight: isLandscape ? UIScreen.main.bounds.size.height : navSize)
      .background(RoundedRectangle(cornerRadius: 44)
        .fill(.ultraThinMaterial)
        .matchedGeometryEffect(id: "menu", in: namespace)
      )
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
      .padding(.all, 8)
      .ignoresSafeArea()
      .onTapGesture {
        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8)) {
          showMenu.toggle()
        }
      }
    } else {
      ZStack {
        HStack {
          VStack {
            Text("Book")
            Picker("Book", selection: $currentBook) {
              ForEach(0..<Bible.books.count, id: \.self) { index in
                Text(Bible.books[index]).tag(index)
              }
            }
            .pickerStyle(WheelPickerStyle())
            .matchedGeometryEffect(id: "book", in: namespace)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          VStack {
            Text("Chapter")
            Picker("Chapter", selection: $currentChapter) {
              ForEach(0..<currentBookValue.count, id: \.self) { index in
                Text("\(index)").tag(index)
              }
            }
            .pickerStyle(WheelPickerStyle())
            .matchedGeometryEffect(id: "chapter", in: namespace)
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .highPriorityGesture(DragGesture().onChanged { _ in  })
        .background(RoundedRectangle(cornerRadius: 44)
          .fill(.ultraThinMaterial)
          .matchedGeometryEffect(id: "menu", in: namespace)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea(edges: .bottom)
        Button(action: {
          withAnimation {
            showMenu.toggle()
          }
        }) {
          Image(systemName: "xmark")
            .padding(.all, 7)
        }
        .background(Circle().fill(.ultraThickMaterial))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .ignoresSafeArea()
        .padding()
      }
      .offset(y: translation.height)
      .gesture(DragGesture()
        .onChanged { value in
          translation = value.translation
        }
        .onEnded { value in
          withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.8)) {
            if translation.height > 150 || translation.height < -150 {
              showMenu.toggle()
            }
            translation = .zero
          }
        }
      )
    }
    ZStack {
      Text("\(currentChapter)")
        .font(.title2)
        .monospaced()
        .lineLimit(1)
        .background(GeometryReader { geometry in
          Color.clear.onAppear {
            chapterSize = geometry.size.width + 4
          }.onChange(of: currentChapter) {
            withAnimation {
              chapterSize = geometry.size.width + 4
            }
          }
        })
      Text("\(Bible.books[currentBook])")
        .font(.title2)
        .lineLimit(1)
        .background(GeometryReader { geometry in
          Color.clear.onAppear {
            bookSize = geometry.size.width + 4
          }.onChange(of: currentBook) {
            withAnimation {
              bookSize = geometry.size.width + 4
            }
          }
        })
    }
    .frame(maxHeight: 0)
    .foregroundColor(.clear)
  }
}

struct PressEffectButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .contentShape(Rectangle())
      .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
      .sensoryFeedback(.impact(weight: .heavy), trigger: configuration.isPressed)
      .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
  }
}

#Preview {
  Menu(currentChapter: .constant(0), currentBook: .constant(0), currentBookValue: .constant(Bible.nilBook))
}


