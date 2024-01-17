//
//  Reader.swift
//  bible
//
//  Created by Joshua Chan on 1/26/24.
//

import SwiftUI

struct Reader: View {
  @Binding var currentChapterValue: Bible.Chapter
  
  var body: some View {
    ScrollView {
      getChapter(currentChapterValue: currentChapterValue)
        .frame(maxWidth: CGFloat.infinity, alignment: Alignment.topLeading)
    }
  }
}

func getChapter(currentChapterValue: Bible.Chapter) -> Text {
  var display = Text("  ")
  currentChapterValue.forEach { section in
    section.data.forEach { line in
      let verseNumber = String(line.verseNumber ?? 0)
      display = display + Text(verseNumber)
        .baselineOffset(5)
        .font(.system(size: 15))
      + Text(line.value)
        .font(.system(size: 20))
    }
  }
  return display
}

#Preview {
  Reader(currentChapterValue: .constant(Bible.nilChapter))
}

