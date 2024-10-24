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
  @State var bookmarkSingeGroupContainer: [(Bool, String, String, String)] = []
  @State var isEditingBookmarkGroups = false
  @State var isEditingBookmarkItems = false
  @State var editingBookmarkItemGroupIndex = -1
  @AppStorage("storageIsInitialized") var storageIsInitialized = false
  
  //For accessing web
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("currentEngine") var currentEngine = 0
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @State var engineLinks: [String] = defaultSearchEngineLinks as! [String]
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
                    if #unavailable(watchOS 10) {
                      Button(action: {
                        editingBookmarkItemGroupIndex = groupIndex
                        bookmarkSingeGroupContainer = bookmarkLibrary[editingBookmarkItemGroupIndex].3
                        isEditingBookmarkItems = true
                      }, label: {
                        Label("Bookmark.item.edit", systemImage: "pencil")
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
                    List {
                      Text("Bookmark.item.empty")
                        .bold()
                        .foregroundStyle(.secondary)
                      Button(action: {
                        isEditingBookmarkItems = true
                      }, label: {
                        Label("Bookmark.item.edit", systemImage: "pencil")
                      })
                    }
                  }
                }
              }
              .navigationTitle(bookmarkLibrary[groupIndex].2)
              .toolbar {
                if #available(watchOS 10, *) {
                  ToolbarItemGroup(placement: .bottomBar, content: {
                    HStack {
                      Spacer()
                      Button(action: {
                        editingBookmarkItemGroupIndex = groupIndex
                        bookmarkSingeGroupContainer = bookmarkLibrary[editingBookmarkItemGroupIndex].3
                        isEditingBookmarkItems = true
                      }, label: {
                        Image(systemName: "pencil")
                      })
                    }
                  })
                }
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
          if #unavailable(watchOS 10) {
            Button(action: {
              isEditingBookmarkGroups = true
            }, label: {
              Label("Bookmark.group.edit", systemImage: "pencil")
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
          List {
            Text("Bookmark.group.empty")
              .bold()
              .foregroundStyle(.secondary)
            Button(action: {
              isEditingBookmarkGroups = true
            }, label: {
              Label("Bookmark.group.edit", systemImage: "pencil")
            })
          }
        }
      }
    }
    .navigationTitle("Bookmark")
    .onAppear {
      if !storageIsInitialized {
        updateBookmarkLibrary(bookmarkLibrary)
        storageIsInitialized = true
      }
      bookmarkLibrary = getBookmarkLibrary()
      engineLinks = (UserDefaults.standard.array(forKey: "engineLinks") ?? defaultSearchEngineLinks) as! [String]
      
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
    //Edit Button
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
    //Sheet - Group Editing
    .sheet(isPresented: $isEditingBookmarkGroups, content: {
      BookmarksGroupEditingView(bookmarkLibrary: $bookmarkLibrary)
        .onDisappear {
          updateBookmarkLibrary(bookmarkLibrary)
        }
    })
    .sheet(isPresented: $isEditingBookmarkItems, content: {
      BookmarksItemEditingView(bookmarkGroup: $bookmarkSingeGroupContainer)
        .onDisappear {
//          if #available(watchOS 10, *) {
            bookmarkLibrary[editingBookmarkItemGroupIndex].3 = bookmarkSingeGroupContainer
            updateBookmarkLibrary(bookmarkLibrary)
          }
//        }
    })
  }
}

struct BookmarksGroupEditingView: View {
  @Binding var bookmarkLibrary: [(Bool, String, String, [(Bool, String, String, String)])]
  @State var bookmarkGroupIsEmoji = false
  @State var bookmarkGroupSymbol = ""
  @State var bookmarkGroupEmoji = ""
  @State var bookmarkGroupName = ""
  @State var isCreatingNewGroup = false
  @State var is_watchOS9 = false
  var body: some View {
    NavigationStack {
      Group {
        if !bookmarkLibrary.isEmpty {
          List {
            ForEach(0..<bookmarkLibrary.count, id: \.self) { groupIndex in
              NavigationLink(destination: {
                BookmarksGroupInfosView(bookmarkGroupIsEmoji: $bookmarkGroupIsEmoji, bookmarkGroupSymbol: $bookmarkGroupSymbol, bookmarkGroupEmoji: $bookmarkGroupEmoji, bookmarkGroupName: $bookmarkGroupName)
                //Get Bookmark Group Infos
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
                //Save Modified Infos or Discard
                  .onDisappear {
                    if !bookmarkGroupName.isEmpty || is_watchOS9 {
                      bookmarkLibrary[groupIndex] = (bookmarkGroupIsEmoji, bookmarkGroupIsEmoji ? bookmarkGroupEmoji : bookmarkGroupSymbol, bookmarkGroupName, bookmarkLibrary[groupIndex].3)
                    } else {
                      showTip("Bookmark.edit.discard", symbol: "exclamationmark.circle")
                    }
                  }
                  .navigationTitle(bookmarkGroupName)
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
            .onDelete(perform: { index in
              bookmarkLibrary.remove(atOffsets: index)
              updateBookmarkLibrary(bookmarkLibrary)
            })
            .onMove(perform: { oldIndex, newIndex in
              bookmarkLibrary.move(fromOffsets: oldIndex, toOffset: newIndex)
              updateBookmarkLibrary(bookmarkLibrary)
            })
            if #unavailable(watchOS 10) {
              Button(action: {
                bookmarkLibrary.append((false, "books.vertical", String(localized: "Bookmark.group.new.title"), []))
                updateBookmarkLibrary(bookmarkLibrary)
              }, label: {
                Label("Bookmark.group.new", systemImage: "plus")
              })
            }
          }
        } else {
          if #available(watchOS 10, *) {
            ContentUnavailableView {
              Label("Bookmark.group.edit.empty", systemImage: "pencil")
            } description: {
              Text("Bookmark.group.edit.empty.description")
            }
          } else {
            List {
              Button(action: {
                bookmarkLibrary.append((false, "books.vertical", String(localized: "Bookmark.group.new.title"), []))
                updateBookmarkLibrary(bookmarkLibrary)
              }, label: {
                Label("Bookmark.group.new", systemImage: "plus")
              })
            }
          }
        }
      }
      .navigationTitle("Bookmark.group.edit")
      .toolbar {
        if #available(watchOS 10, *) {
          ToolbarItemGroup(placement: .bottomBar, content: {
            HStack {
              Spacer()
              Button(action: {
                isCreatingNewGroup = true
              }, label: {
                Image(systemName: "plus")
              })
            }
          })
        }
      }
      .sheet(isPresented: $isCreatingNewGroup, content: {
        NavigationStack {
          BookmarksGroupInfosView(bookmarkGroupIsEmoji: $bookmarkGroupIsEmoji, bookmarkGroupSymbol: $bookmarkGroupSymbol, bookmarkGroupEmoji: $bookmarkGroupEmoji, bookmarkGroupName: $bookmarkGroupName)
            .onAppear {
              bookmarkGroupIsEmoji = false
              bookmarkGroupSymbol = "books.vertical"
              bookmarkGroupEmoji = "📚"
              bookmarkGroupName = ""
            }
            .navigationTitle("Bookmark.group.new")
            .toolbar {
              if #available(watchOS 10, *) {
                ToolbarItem(placement: .topBarTrailing, content: {
                  DismissButton(action: {
                    bookmarkLibrary.append((bookmarkGroupIsEmoji, bookmarkGroupIsEmoji ? bookmarkGroupEmoji : bookmarkGroupSymbol, bookmarkGroupName, []))
                    updateBookmarkLibrary(bookmarkLibrary)
                  }, label: {
                    Image(systemName: "plus")
                  })
                  .disabled(bookmarkGroupName.isEmpty)
                })
              }
            }
        }
      })
    }
    .onAppear {
      if #unavailable(watchOS 10) {
        is_watchOS9 = true
      }
    }
  }
}

struct BookmarksGroupInfosView: View {
  @Binding var bookmarkGroupIsEmoji: Bool
  @Binding var bookmarkGroupSymbol: String
  @Binding var bookmarkGroupEmoji: String
  @Binding var bookmarkGroupName: String
  @State var tintColorValues: [Any] = defaultColor as [Any]
  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
  var body: some View {
    List {
      Button(action: {
        bookmarkGroupIsEmoji.toggle()
      }, label: {
        HStack {
          Text("Bookmark.icon.symbol")
            .foregroundColor(bookmarkGroupIsEmoji ? .secondary : .primary)
            .lineLimit(1)
          Text(verbatim: "|").fontDesign(.rounded)
          Text("Bookmark.icon.emoji")
            .foregroundColor(bookmarkGroupIsEmoji ? .primary : .secondary)
            .lineLimit(1)
        }
      })
      if bookmarkGroupIsEmoji {
        PictorEmojiPicker(emoji: $bookmarkGroupEmoji, presentAsSheet: true, label: {
          HStack {
            Text("Bookmark.group.emoji")
            Spacer()
            Text($bookmarkGroupEmoji.wrappedValue)
              .font(.title3)
          }
        })
      } else {
        PictorSymbolPicker(symbol: $bookmarkGroupSymbol, presentAsSheet: true, selectionColor: tintColor, label: {
          HStack {
            Text("Bookmark.group.symbol")
            Spacer()
            Image(systemName: $bookmarkGroupSymbol.wrappedValue)
          }
        })
      }
      CepheusKeyboard(input: $bookmarkGroupName, prompt: "Bookmark.group.name")
      if bookmarkGroupName.isEmpty {
        Label("Bookmark.group.name.empty", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
    }
    .onAppear {
      if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
        UserDefaults.standard.set(defaultColor, forKey: "tintColor")
      }
      tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? (defaultColor as [Any])
      tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
    }
  }
}

struct BookmarksItemEditingView: View {
  @Binding var bookmarkGroup: [(Bool, String, String, String)]
  @State var bookmarkItemIsEmoji = false
  @State var bookmarkItemSymbol = ""
  @State var bookmarkItemEmoji = ""
  @State var bookmarkItemName = ""
  @State var bookmarkItemLink = ""
  @State var isCreatingNewBookmark = false
  @State var is_watchOS9 = false
  var body: some View {
    NavigationStack {
      Group {
        if !bookmarkGroup.isEmpty {
          List {
            ForEach(0..<bookmarkGroup.count, id: \.self) { bookmarkIndex in
              NavigationLink(destination: {
                BookmarksItemInfosView(bookmarkItemIsEmoji: $bookmarkItemIsEmoji, bookmarkItemSymbol: $bookmarkItemSymbol, bookmarkItemEmoji: $bookmarkItemEmoji, bookmarkItemName: $bookmarkItemName, bookmarkItemLink: $bookmarkItemLink)
                  .onAppear {
                    bookmarkItemIsEmoji = bookmarkGroup[bookmarkIndex].0
                    if bookmarkItemIsEmoji {
                      bookmarkItemEmoji = bookmarkGroup[bookmarkIndex].1
                      bookmarkItemSymbol = "bookmark"
                    } else {
                      bookmarkItemSymbol = bookmarkGroup[bookmarkIndex].1
                      bookmarkItemEmoji = "🔖"
                    }
                    bookmarkItemName = bookmarkGroup[bookmarkIndex].2
                    bookmarkItemLink = bookmarkGroup[bookmarkIndex].3
                  }
                  .onDisappear {
                    if (!bookmarkItemName.isEmpty && !bookmarkItemLink.isEmpty && bookmarkItemLink.isURL()) || is_watchOS9 {
                      bookmarkGroup[bookmarkIndex] = (bookmarkItemIsEmoji, bookmarkItemIsEmoji ? bookmarkItemEmoji : bookmarkItemSymbol, bookmarkItemName, bookmarkItemLink)
                    } else {
                      showTip("Bookmark.edit.discard", symbol: "exclamationmark.circle")
                    }
                  }
                  .navigationTitle(bookmarkItemName)
              }, label: {
                HStack {
                  if bookmarkGroup[bookmarkIndex].0 { //isEmoji
                    Text(bookmarkGroup[bookmarkIndex].1)
                      .font(.title3)
                  } else {
                    Image(systemName: bookmarkGroup[bookmarkIndex].1)
                  }
                  Text(bookmarkGroup[bookmarkIndex].2)
                  Spacer()
                }
              })
            }
            .onDelete(perform: { index in
              bookmarkGroup.remove(atOffsets: index)
            })
            .onMove(perform: { oldIndex, newIndex in
              bookmarkGroup.move(fromOffsets: oldIndex, toOffset: newIndex)
            })
            if #unavailable(watchOS 10) {
              Button(action: {
                bookmarkGroup.append((false, "bookmark", String(localized: "Bookmark.item.new.title"), "example.com"))
              }, label: {
                Label("Bookmark.item.new", systemImage: "plus")
              })
            }
          }
        } else {
          if #available(watchOS 10, *) {
            ContentUnavailableView {
              Label("Bookmark.item.edit.empty", systemImage: "pencil")
            } description: {
              Text("Bookmark.item.edit.empty.description")
            }
          } else {
            List {
              Button(action: {
                bookmarkGroup.append((false, "bookmark", String(localized: "Bookmark.item.new.title"), "example.com"))
              }, label: {
                Label("Bookmark.item.new", systemImage: "plus")
              })
            }
          }
        }
      }
      .navigationTitle("Bookmark.item.edit")
      .toolbar {
        if #available(watchOS 10, *) {
          ToolbarItemGroup(placement: .bottomBar, content: {
            HStack {
              Spacer()
              Button(action: {
                isCreatingNewBookmark = true
              }, label: {
                Image(systemName: "plus")
              })
            }
          })
        }
      }
      .sheet(isPresented: $isCreatingNewBookmark, content: {
        NavigationStack {
          BookmarksItemInfosView(bookmarkItemIsEmoji: $bookmarkItemIsEmoji, bookmarkItemSymbol: $bookmarkItemSymbol, bookmarkItemEmoji: $bookmarkItemEmoji, bookmarkItemName: $bookmarkItemName, bookmarkItemLink: $bookmarkItemLink)
            .onAppear {
              bookmarkItemIsEmoji = false
              bookmarkItemSymbol = "bookmark"
              bookmarkItemEmoji = "🔖"
              bookmarkItemName = ""
              bookmarkItemLink = ""
            }
            .navigationTitle("Bookmark.item.new")
            .toolbar {
              if #available(watchOS 10, *) {
                ToolbarItem(placement: .topBarTrailing, content: {
                  DismissButton(action: {
                    bookmarkGroup.append((bookmarkItemIsEmoji, bookmarkItemIsEmoji ? bookmarkItemEmoji : bookmarkItemSymbol, bookmarkItemName, bookmarkItemLink))
                  }, label: {
                    Image(systemName: "plus")
                  })
                  .disabled(!(!bookmarkItemName.isEmpty && !bookmarkItemLink.isEmpty && bookmarkItemLink.isURL()))
                })
              }
            }
        }
      })
    }
    .onAppear {
      if #unavailable(watchOS 10) {
        is_watchOS9 = true
      }
    }
  }
}

struct BookmarksItemInfosView: View {
  @Binding var bookmarkItemIsEmoji: Bool
  @Binding var bookmarkItemSymbol: String
  @Binding var bookmarkItemEmoji: String
  @Binding var bookmarkItemName: String
  @Binding var bookmarkItemLink: String
  @State var tintColorValues: [Any] = defaultColor
  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
  var body: some View {
    List {
      Button(action: {
        bookmarkItemIsEmoji.toggle()
      }, label: {
        HStack {
          Text("Bookmark.icon.symbol")
            .foregroundColor(bookmarkItemIsEmoji ? .secondary : .primary)
            .lineLimit(1)
          Text(verbatim: "|").fontDesign(.rounded)
          Text("Bookmark.icon.emoji")
            .foregroundColor(bookmarkItemIsEmoji ? .primary : .secondary)
            .lineLimit(1)
        }
      })
      if bookmarkItemIsEmoji {
        PictorEmojiPicker(emoji: $bookmarkItemEmoji, presentAsSheet: true, label: {
          HStack {
            Text("Bookmark.item.emoji")
            Spacer()
            Text($bookmarkItemEmoji.wrappedValue)
              .font(.title3)
          }
        })
      } else {
        PictorSymbolPicker(symbol: $bookmarkItemSymbol, presentAsSheet: true, selectionColor: tintColor, label: {
          HStack {
            Text("Bookmark.item.symbol")
            Spacer()
            Image(systemName: $bookmarkItemSymbol.wrappedValue)
          }
        })
      }
      CepheusKeyboard(input: $bookmarkItemName, prompt: "Bookmark.item.name")
      CepheusKeyboard(input: $bookmarkItemLink, prompt: "Bookmark.item.link", autoCorrectionIsEnabled: false)
      if bookmarkItemName.isEmpty {
        Label("Bookmark.item.name.empty", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
      if bookmarkItemLink.isEmpty {
        Label("Bookmark.item.link.empty", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
      if !bookmarkItemLink.isEmpty && !bookmarkItemLink.isURL() {
        Label("Bookmark.item.link.invalid", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
    }
    .onAppear {
      if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
        UserDefaults.standard.set(defaultColor, forKey: "tintColor")
      }
      tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? (defaultColor as [Any])
      tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
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
//    jsonEncoder.outputFormatting = .withoutEscapingSlashes
    let jsonData = try jsonEncoder.encode(encodedBookmarkLibrary)
    if let jsonString = String(data: jsonData, encoding: .utf8) {
      do {
        try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
        //        showTip(LocalizedStringResource(stringLiteral: jsonString), debug: true)
        //                showTip("Debug.succeed", debug: true)
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

struct BookmarkPickerView: View {
  @Binding var editorSheetIsDisaplying: Bool
  @Binding var seletedGroup: Int
  @Binding var selectedBookmark: Int
  var groupIndexEqualingGoal: Int
  var bookmarkIndexEqualingGoal: Int
  var action: () -> Void
  @State var bookmarks: [(Bool, String, String, [(Bool, String, String, String)])] = []
  var body: some View {
    Group {
      if #available(watchOS 10, *) {
        Group {
          if !bookmarks.isEmpty {
            List {
              ForEach(0..<bookmarks.count, id: \.self) { groupIndex in
                NavigationLink(destination: {
                  Group {
                    if !bookmarks[groupIndex].3.isEmpty {
                      List {
                        ForEach(0..<bookmarks[groupIndex].3.count, id: \.self) { bookmarkIndex in
                          Button(action: {
                            seletedGroup = groupIndex
                            selectedBookmark = bookmarkIndex
                            action()
                            editorSheetIsDisaplying = false
                          }, label: {
                            HStack {
                              if bookmarks[groupIndex].3[bookmarkIndex].0 { //isEmoji
                                Text(bookmarks[groupIndex].3[bookmarkIndex].1)
                                  .font(.title3)
                              } else {
                                Image(systemName: bookmarks[groupIndex].3[bookmarkIndex].1)
                              }
                              Text(bookmarks[groupIndex].3[bookmarkIndex].2)
                              Spacer()
                              if groupIndex == groupIndexEqualingGoal && bookmarkIndex == bookmarkIndexEqualingGoal {
                                Image(systemName: "checkmark")
                              }
                            }
                          })
                        }
                      }
                    } else {
                      ContentUnavailableView {
                        Label("Bookmark.item.empty", systemImage: "bookmark")
                      } description: {
                        Text("Bookmark.item.empty.description")
                      }
                    }
                  }
                  .navigationTitle(bookmarks[groupIndex].2)
                }, label: {
                  HStack {
                    if bookmarks[groupIndex].0 { //isEmoji
                      Text(bookmarks[groupIndex].1)
                        .font(.title3)
                    } else {
                      Image(systemName: bookmarks[groupIndex].1)
                    }
                    Text(bookmarks[groupIndex].2)
                    Spacer()
                  }
                })
              }
            }
          } else {
            ContentUnavailableView {
              Label("Bookmark.group.empty", systemImage: "books.vertical")
            } description: {
              Text("Bookmark.group.empty.description")
            }
          }
        }
        .navigationTitle("Bookmark.select")
      }
    }
    .onAppear {
      bookmarks = getBookmarkLibrary()
    }
  }
}

struct NewBookmarkView: View {
  var bookmarkLink: String
  @Binding var bookmarkIsAdded: Bool
  @State var bookmarkGroup: Int = -1
  @State var bookmarkItemIsEmoji: Bool = false
  @State var bookmarkItemSymbol: String = "bookmark"
  @State var bookmarkItemEmoji: String = "🔖"
  @State var bookmarkItemName: String = ""
  @State var bookmarkItemLink: String = ""
  @State var tintColorValues: [Any] = defaultColor
  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
  
  @State var bookmarkGroupPickerIsDisplaying = false
  @State var bookmarkLibrary: [(Bool, String, String, [(Bool, String, String, String)])] = []
  var body: some View {
    List {
      Button(action: {
        bookmarkGroupPickerIsDisplaying = true
      }, label: {
        HStack {
          VStack(alignment: .leading) {
            Text("Bookmark.group")
            if bookmarkGroup != -1 {
              Text(bookmarkLibrary[bookmarkGroup].2)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
          Spacer()
          if bookmarkGroup != -1 {
            if bookmarkLibrary[bookmarkGroup].0 { //isEmoji
              Text(bookmarkLibrary[bookmarkGroup].1)
                .font(.title3)
            } else {
              Image(systemName: bookmarkLibrary[bookmarkGroup].1)
            }
          }
        }
      })
      .sheet(isPresented: $bookmarkGroupPickerIsDisplaying, content: {
        if !bookmarkLibrary.isEmpty {
          List {
            ForEach(0..<bookmarkLibrary.count, id: \.self) { groupIndex in
              DismissButton(action: {
                bookmarkGroup = groupIndex
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
                  if bookmarkGroup == groupIndex {
                    Image(systemName: "checkmark")
                  }
                }
              })
            }
          }
          .navigationTitle("Bookmark.group.select")
        } else {
          if #available(watchOS 10, *) {
            ContentUnavailableView {
              Label("Bookmark.group.empty", systemImage: "books.vertical")
            } description: {
              Text("Bookmark.group.empty.description")
            }
          } else {
            List {
              Text("Bookmark.group.empty")
                .bold()
                .foregroundStyle(.secondary)
            }
          }
        }
      })
      if #available(watchOS 10, *) {
        Button(action: {
          bookmarkItemIsEmoji.toggle()
        }, label: {
          HStack {
            Text("Bookmark.icon.symbol")
              .foregroundColor(bookmarkItemIsEmoji ? .secondary : .primary)
            Text(verbatim: "|").fontDesign(.rounded)
            Text("Bookmark.icon.emoji")
              .foregroundColor(bookmarkItemIsEmoji ? .primary : .secondary)
          }
        })
        if bookmarkItemIsEmoji {
          PictorEmojiPicker(emoji: $bookmarkItemEmoji, presentAsSheet: true, label: {
            HStack {
              Text("Bookmark.item.emoji")
              Spacer()
              Text($bookmarkItemEmoji.wrappedValue)
                .font(.title3)
            }
          })
        } else {
          PictorSymbolPicker(symbol: $bookmarkItemSymbol, presentAsSheet: true, selectionColor: tintColor, label: {
            HStack {
              Text("Bookmark.item.symbol")
              Spacer()
              Image(systemName: $bookmarkItemSymbol.wrappedValue)
            }
          })
        }
      }
      TextField("Bookmark.item.name", text: $bookmarkItemName)
      TextField("Bookmark.item.link", text: $bookmarkItemLink)
        .autocorrectionDisabled()
      if bookmarkGroup == -1 {
        Label("Bookmark.item.group.empty", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
      if bookmarkItemName.isEmpty {
        Label("Bookmark.item.name.empty", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
      if bookmarkItemLink.isEmpty {
        Label("Bookmark.item.link.empty", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
      if !bookmarkItemLink.isEmpty && !bookmarkItemLink.isURL() {
        Label("Bookmark.item.link.invalid", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
      if #unavailable(watchOS 10) {
        DismissButton(action: {
          bookmarkLibrary[bookmarkGroup].3.append((bookmarkItemIsEmoji, bookmarkItemIsEmoji ? bookmarkItemEmoji : bookmarkItemSymbol, bookmarkItemName, bookmarkItemLink))
          updateBookmarkLibrary(bookmarkLibrary)
          bookmarkIsAdded = true
        }, label: {
          Label("Bookmark.add", systemImage: "plus")
        })
        .disabled(!(!bookmarkItemName.isEmpty && !bookmarkItemLink.isEmpty && bookmarkItemLink.isURL() && bookmarkGroup != -1))
      }
      if #unavailable(watchOS 10) {
        Text("Bookmark.added")
      }
    }
    .navigationTitle("Bookmark.item.new.title")
    .onAppear {
      bookmarkItemLink = bookmarkLink
      bookmarkLibrary = getBookmarkLibrary()
      if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
        UserDefaults.standard.set(defaultColor, forKey: "tintColor")
      }
      tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? (defaultColor as [Any])
      tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
    }
    .toolbar {
      if #available(watchOS 10, *) {
        ToolbarItem(placement: .topBarTrailing, content: {
          DismissButton(action: {
            bookmarkLibrary[bookmarkGroup].3.append((bookmarkItemIsEmoji, bookmarkItemIsEmoji ? bookmarkItemEmoji : bookmarkItemSymbol, bookmarkItemName, bookmarkItemLink))
            updateBookmarkLibrary(bookmarkLibrary)
            bookmarkIsAdded = true
          }, label: {
            Image(systemName: "plus")
          })
          .disabled(!(!bookmarkItemName.isEmpty && !bookmarkItemLink.isEmpty && bookmarkItemLink.isURL() && bookmarkGroup != -1))
        })
      }
    }
  }
}
