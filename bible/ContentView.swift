import SwiftUI

/*
type bible = {
  type: String,
  books: [
    {
      name: String(Book)
      chapters: [
        [
          section: String
          verses: String[]
        ]
      ]
    }
  ]
 }
 */


class Bible {
  static var type = "WEB"
  static let books = ["Genesis", "Exodus", "Leviticus", "Numbers", "Duteronomy", "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel", "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles", "Ezra", "Neamiah", "Esther", "Job", "Psalms", "Proverbs", "Ecclesiastes", "Song of Songs", "Isaiah", "Jeramiah", "Lamenations", "Ezekiel", "Daniel", "Hosea", "Joel", "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk", "Zephanaiah", "Haggai", "Zecharaih", "Malachi", "Matthew", "Mark", "Luke", "John", "Acts", "Romans", "1 Corinthians", "2 Corinthians", "Galations", "Ephesians", "Philippians", "Colosians", "1 Thessalonians", "2 Thessalonlians", "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews", "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John", "Jude", "Revelations"]
  static let nilChapter = try! JSONDecoder().decode(Bible.Chapter.self, from: """
  [{"type": "para", "data": [{"value": "e"}]}]
""".data(using: .utf8)!)
  static let nilBook = try! JSONDecoder().decode(Bible.Book.self, from: """
  [[{"type": "para", "data": [{"value": "e"}]}]]
""".data(using: .utf8)!)
  typealias Book = [[Section]]
  typealias Chapter = [Section]
  struct Section: Decodable {
    var type: Mode
    var data: [Line]
    enum Mode: String, Decodable {
      case para, stan
    }
    struct Line: Decodable {
      var value: String
      var verseNumber: Int?
      var chapterNumber: Int?
    }
  }
}

struct ContentView: View {
  @Namespace var namespace
  @Environment(\.verticalSizeClass) var verticalSizeClass
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @State var showNotes = false
  @State var currentBook = 0
  @State var currentChapter = 0
  @State var currentChapterValue: Bible.Chapter = Bible.nilChapter
  @State var currentBookValue: Bible.Book = Bible.nilBook
  
  var body: some View {
    ZStack {
      HStack {
        Reader(currentChapterValue: $currentChapterValue)
        if showNotes && verticalSizeClass == .compact {
          Notes()
        }
      }
      if verticalSizeClass == .compact {
        Button(action: { withAnimation { showNotes.toggle() } }) {
          Image(systemName: "note.text")
        }
        .font(.title)
        .frame(width: 48, height: 48)
        .background(RoundedRectangle(cornerRadius: 44).fill(.ultraThinMaterial))
        .padding(.all, 8)
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      }
      Menu(currentChapter: $currentChapter, currentBook: $currentBook, currentBookValue: $currentBookValue)
        .zIndex(1)
        .defersSystemGestures(on: .all)
        .onChange(of: currentChapter) {
          updateChapter()
        }.onChange(of: currentBook) {
          updateBook()
          updateChapter()
        }
        .onAppear {
          updateBook()
          updateChapter()
        }
    }
  }
  
  func updateChapter() {
    if currentChapter < currentBookValue.count && currentChapter > -1 {
      currentChapterValue = currentBookValue[currentChapter]
    } else if currentChapter > 0 && currentChapter < currentBookValue.count + 1 && currentBook < Bible.books.count {
      currentBook += 1
      currentChapter = 0
    } else if currentChapter < 0 && currentBook > 0 {
      currentBook -= 1
      updateBook()
      currentChapter = currentBookValue.count - 1
    } else {
      currentBook = 0
      currentChapter = 0
    }
  }
  
  func updateBook() {
    let filepath = Bundle.main.path(forResource: "\(currentBook)-\(Bible.books[currentBook])", ofType: "json")
    do {
      let data = (try String(contentsOfFile: filepath!).data(using: .utf8))!
      if let book: Bible.Book = try? JSONDecoder().decode(Bible.Book.self, from: data) {
        withAnimation {
          currentBookValue = book
        }
      }
    } catch {
      print(error)
    }
  }
}

#Preview {
  ContentView()
}
