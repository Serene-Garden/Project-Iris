//
//  BookmarksView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/1.
//

import SwiftUI
import Cepheus
import Pictor
import Foundation



struct BookmarksView: View {
  @State var bookmarkLibrary: [(Bool, String, String, [(Bool, String, String, String)])] = [(false, "books.vertical", String(localized: "Bookmark.group.default"), [])] //[(isEmoji, BookmarkGroupSymbol, BookmarkGroupName, [(isEmoji, BookmarkSymbol, BookmarkName, BookmarkLink)])]
  @State var isEditingBookmarkGroups = false
  
  //For accessing web
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("currentEngine") var currentEngine = 0
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @State var engineLinks: [String] = ["https://www.bing.com/search?q=\\iris", "https://www.google.com/search?q=\\iris",  "https://www.baidu.com/s?wd=\\iris",  "https://www.sogou.com/web?query=\\iris"]
  @State var storageIsInitialized = false
  
  var body: some View {
    NavigationStack {
      if !bookmarkLibrary.isEmpty {
        List {
          ForEach(0..<bookmarkLibrary.count, id: \.self) { groupIndex in
            NavigationLink(destination: {
              Group {
                if !bookmarkLibrary[groupIndex].3.isEmpty {
                  List {
                    ForEach(0..<bookmarkLibrary[groupIndex].3.count, id: \.self) { bookmarkIndex in
                      Button(action: {
                        searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: bookmarkLibrary[groupIndex].3[bookmarkIndex].3, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[currentEngine])
                      }, label: {
                        HStack {
                          if bookmarkLibrary[groupIndex].3[bookmarkIndex].0 { //isEmoji
                            Text(bookmarkLibrary[groupIndex].3[bookmarkIndex].1)
                              .font(.title3)
                          } else {
                            Image(systemName: bookmarkLibrary[groupIndex].3[bookmarkIndex].1)
                          }
                          Text(bookmarkLibrary[groupIndex].3[bookmarkIndex].2)
                          Spacer()
                        }
                      })
                    }
                  }
                } else {
                  if #available(watchOS 10, *) {
                    ContentUnavailableView {
                      Label("Bookmark.item.empty", systemImage: "bookmark")
                    } description: {
                      Text("Bookmark.item.empty.description")
                    }
                  } else {
                    Text("Bookmark.item.empty")
                      .bold()
                      .foregroundStyle(.secondary)
                  }
                }
              }
              .navigationTitle(bookmarkLibrary[groupIndex].2)
            }, label: {
              HStack {
                if bookmarkLibrary[groupIndex].0 { //isEmoji
                  Text(bookmarkLibrary[groupIndex].1)
                    .font(.title3)
                } else {
                  Image(systemName: bookmarkLibrary[groupIndex].1)
                }
                Text(bookmarkLibrary[groupIndex].2)
                Spacer()
              }
            })
          }
        }
      } else {
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Bookmark.group.empty", systemImage: "books.vertical")
          } description: {
            Text("Bookmark.group.empty.description")
          }
        } else {
          Text("Bookmark.group.empty")
            .bold()
            .foregroundStyle(.secondary)
        }
      }
    }
    .onAppear {
      if !storageIsInitialized {
        updateBookmarkLibrary(bookmarkLibrary)
      }
      bookmarkLibrary = getBookmarkLibrary()
      
      //Legacy Bookmarks Handling
      if let legacyTitles = UserDefaults.standard.array(forKey: "BookmarkTitle") {
        print("Legacy Bookmark Handling Program Toggled")
        let legacyLinks = UserDefaults.standard.array(forKey: "BookmarkLink")!
        var legacyLinkGroups: [(Bool, String, String, String)] = []
        for index in 0..<legacyTitles.count {
          legacyLinkGroups.append((false, "bookmark", legacyTitles[index] as! String, legacyLinks[index] as! String))
        }
        bookmarkLibrary = [(false, "books.vertical", String(localized: "Bookmark.group.default"), legacyLinkGroups)]
        updateBookmarkLibrary(bookmarkLibrary)
        UserDefaults.standard.removeObject(forKey: "BookmarkTitle")
        UserDefaults.standard.removeObject(forKey: "BookmarkLink")
      }
    }
    .toolbar {
      if #available(watchOS 10, *) {
        ToolbarItemGroup(placement: .bottomBar, content: {
          HStack {
            Spacer()
            Button(action: {
              isEditingBookmarkGroups = true
            }, label: {
              Image(systemName: "pencil")
            })
          }
        })
      }
    }
    .sheet(isPresented: $isEditingBookmarkGroups, content: {
      BookmarksGroupEditingView(bookmarkLibrary: $bookmarkLibrary)
    })
  }
}

struct BookmarksGroupEditingView: View {
  @Binding var bookmarkLibrary: [(Bool, String, String, [(Bool, String, String, String)])]
  @State var bookmarkGroupIsEmoji = false
  @State var bookmarkGroupSymbol = ""
  @State var bookmarkGroupEmoji = ""
  @State var bookmarkGroupName = ""
  var body: some View {
    NavigationStack {
      if !bookmarkLibrary.isEmpty {
        List {
          ForEach(0..<bookmarkLibrary.count, id: \.self) { groupIndex in
            NavigationLink(destination: {
              List {
                Button(action: {
                  bookmarkGroupIsEmoji.toggle()
                }, label: {
                  HStack {
                    Text("Bookmark.icon.symbol")
                      .foregroundColor(bookmarkGroupIsEmoji ? .secondary : .primary)
                    Text(verbatim: "|").fontDesign(.rounded)
                    Text("Bookmark.icon.emoji")
                      .foregroundColor(bookmarkGroupIsEmoji ? .primary : .secondary)
                  }
                })
                if bookmarkGroupIsEmoji {
                  PictorEmojiPicker(emoji: $bookmarkGroupEmoji, label: {
                    HStack {
                      Text("Bookmark.group.emoji")
                      Spacer()
                      Text(bookmarkGroupEmoji)
                        .font(.title3)
                    }
                  })
                } else {
                  PictorSymbolPicker(symbol: $bookmarkGroupSymbol, label: {
                    HStack {
                      Text("Bookmark.group.symbol")
                      Spacer()
                      Image(systemName: bookmarkGroupSymbol)
                    }
                  })
                }
              }
              .onAppear {
                bookmarkGroupIsEmoji = bookmarkLibrary[groupIndex].0
                if bookmarkGroupIsEmoji {
                  bookmarkGroupEmoji = bookmarkLibrary[groupIndex].1
                  bookmarkGroupSymbol = "books.vertical"
                } else {
                  bookmarkGroupSymbol = bookmarkLibrary[groupIndex].1
                  bookmarkGroupEmoji = "📚"
                }
                bookmarkGroupName = bookmarkLibrary[groupIndex].2
              }
              .onDisappear {
                bookmarkLibrary[groupIndex] = (bookmarkGroupIsEmoji, bookmarkGroupIsEmoji ? bookmarkGroupEmoji : bookmarkGroupSymbol, bookmarkGroupName, bookmarkLibrary[groupIndex].3)
              }
            }, label: {
              HStack {
                if bookmarkLibrary[groupIndex].0 { //isEmoji
                  Text(bookmarkLibrary[groupIndex].1)
                    .font(.title3)
                } else {
                  Image(systemName: bookmarkLibrary[groupIndex].1)
                }
                Text(bookmarkLibrary[groupIndex].2)
                Spacer()
              }
            })
          }
        }
      } else {
        if #available(watchOS 10, *) {
          ContentUnavailableView {
            Label("Bookmark.group.empty", systemImage: "books.vertical")
          } description: {
            Text("Bookmark.group.empty.description")
          }
        } else {
          Text("Bookmark.group.empty")
            .bold()
            .foregroundStyle(.secondary)
        }
      }
    }
    .navigationTitle("Bookmark.group.edit")
    .onDisappear {
      updateBookmarkLibrary(bookmarkLibrary)
    }
  }
}

struct BookmarkLibraryStructure: Codable {
  var isEmoji: Bool
  var bookmarkGroupSymbol: String
  var bookmarkGroupName: String
  var bookmarkGroupContent: [BookmarkGroupStructure]
}

struct BookmarkGroupStructure: Codable {
  var isEmoji: Bool
  var bookmarkSymbol: String
  var bookmarkTitle: String
  var bookmarkLink: String
}

@MainActor @discardableResult func updateBookmarkLibrary(_ bookmarkLibrary: [(Bool, String, String, [(Bool, String, String, String)])]) -> Bool {
  let fileURL = getDocumentsDirectory().appendingPathComponent("BookmarkLibrary.txt")
  
  let encodedBookmarkLibrary: [BookmarkLibraryStructure] = bookmarkLibrary.map { (isEmoji, bookmarkGroupSymbol, bookmarkGroupName, bookmarkGroupContent) in
    let bookmarkGroupContentObjects = bookmarkGroupContent.map { BookmarkGroupStructure(isEmoji: $0.0, bookmarkSymbol: $0.1, bookmarkTitle: $0.2, bookmarkLink: $0.3) }
    return BookmarkLibraryStructure(isEmoji: isEmoji, bookmarkGroupSymbol: bookmarkGroupSymbol, bookmarkGroupName: bookmarkGroupName, bookmarkGroupContent: bookmarkGroupContentObjects)
  }
  
  do {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted // For pretty-printed JSON
    let jsonData = try jsonEncoder.encode(encodedBookmarkLibrary)
    if let jsonString = String(data: jsonData, encoding: .utf8) {
      do {
        try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
//        showTip(LocalizedStringResource(stringLiteral: jsonString), debug: true)
        return true
      } catch {
        showTip(LocalizedStringResource(stringLiteral: error.localizedDescription), debug: true)
        return false
      }
    }
  } catch {
    showTip(LocalizedStringResource(stringLiteral: error.localizedDescription), debug: true)
    return false
  }
  return false
}

@MainActor func getBookmarkLibrary() -> [(Bool, String, String, [(Bool, String, String, String)])] {
  do {
    let fileURL = getDocumentsDirectory().appendingPathComponent("BookmarkLibrary.txt")
    let fileData = try Data(contentsOf: fileURL)
    if let jsonString = String(data: fileData, encoding: .utf8) {
      let jsonData = jsonString.data(using: .utf8)!
      
      let bookmarkLibraries = try JSONDecoder().decode([BookmarkLibraryStructure].self, from: jsonData)
      
      let data: [(Bool, String, String, [(Bool, String, String, String)])] = bookmarkLibraries.map { library in
        let subItems = library.bookmarkGroupContent.map { subItem in
          (subItem.isEmoji, subItem.bookmarkSymbol, subItem.bookmarkTitle, subItem.bookmarkLink)
        }
        return (library.isEmoji, library.bookmarkGroupSymbol, library.bookmarkGroupName, subItems)
      }
      
      return data
    }
  } catch {
    showTip(LocalizedStringResource(stringLiteral: error.localizedDescription), debug: true)
    return []
  }
  return []
}

func getDocumentsDirectory() -> URL {
  let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
  return paths[0]
}


//      updateBookmarkLibrary([(true, "1", "2", [(true, "2", "e", "!"), (false, "3", "k", "-")]), (false, "3", "4", [(true, "9", "q", "?"), (false, "^", "c", "<")])])
//      print(getBookmarkLibrary())
