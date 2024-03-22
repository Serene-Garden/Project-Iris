//
//  BookmarksView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/1.
//

import SwiftUI
import AuthenticationServices

struct BookmarksView: View {
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("isBookmarkCounterDisplayed") var isBookmarkCounterDisplayed = false
  @State var bookmarkTitles: [Any] = []
  @State var bookmarkLinks: [Any] = []
  @State var isNewBookmarkPresenting = false
  @State var isSortBookmarkPresenting = false
  @State var isStartingToAddBookmark = false
  @State var bookmarkTitle = ""
  @State var bookmarkLink = ""
  var body: some View {
    NavigationStack {
      if bookmarkLinks.count > 0 {
        List {
          if #available(watchOS 10.0, *) {} else {
            Button(action: {
              isSortBookmarkPresenting = true
            }, label: {
              Label("Bookmarks.edit", systemImage: "list.triangle")
            })
            Button(action: {
              isNewBookmarkPresenting = true
            }, label: {
              Label("Bookmarks.add", systemImage: "plus")
            })
          }
          Section(content: {
            ForEach(0..<bookmarkLinks.count, id: \.self) {bookmark in
              Button(action: {
                bookmarkOpenAction(link: bookmarkLinks[bookmark])
              }, label: {
                Text(bookmarkTitles[bookmark] as! String)
                //                Text(bookmarkTitles[bookmark] as! String)
              })
            }
            /* .onDelete(perform: { bookmark in
             bookmarkTitles.remove(atOffsets: bookmark)
             bookmarkLinks.remove(atOffsets: bookmark)
             UserDefaults.standard.set(bookmarkTitles, forKey: "BookmarkTitle")
             UserDefaults.standard.set(bookmarkLinks, forKey: "BookmarkLink")
             })
             .onMove(perform: { bookmarks, bookmark  in
             bookmarkTitles.move(fromOffsets: bookmarks, toOffset: bookmark)
             bookmarkLinks.move(fromOffsets: bookmarks, toOffset: bookmark)
             UserDefaults.standard.set(bookmarkTitles, forKey: "BookmarkTitle")
             UserDefaults.standard.set(bookmarkLinks, forKey: "BookmarkLink")
             }) */
          })
        }
      } else {
        if #available(watchOS 10.0, *) {
          Text("Bookmarks.nothing")
            .bold()
            .foregroundStyle(.secondary)
            .font(.title3)
        } else {
          List {
            Button(action: {
              isNewBookmarkPresenting = true
            }, label: {
              Label("Bookmarks.add", systemImage: "plus")
            })
          }
        }
      }
    }
    .navigationTitle("Bookmarks")
    .toolbar {
      if #available(watchOS 10.0, *) {
        ToolbarItem(placement: .bottomBar) {
          HStack {
            Button(action: {
              isSortBookmarkPresenting = true
            }, label: {
              Image(systemName: "list.triangle")
            })
            Spacer()
            if isBookmarkCounterDisplayed {
              Label("\(bookmarkLinks.count)", systemImage: "bookmark")
//                Text("Bookmarks.count.\(bookmarkTitles.count)")
//                .font(.system(size: 15))
//                .multilineTextAlignment(.center)
//                  .blendMode(.destinationOver)
//                .font(.caption)
//                  .shadow(radius: 30)
//                  .mask(Rectangle().background(.ultraThickMaterial))
            }
            Spacer()
            Button(action: {
              isNewBookmarkPresenting = true
            }, label: {
              Image(systemName: "plus")
            })
          }
          
        }
      }
    }
    .onAppear {
      bookmarkTitles = UserDefaults.standard.array(forKey: "BookmarkTitle") ?? []
      bookmarkLinks = UserDefaults.standard.array(forKey: "BookmarkLink") ?? []
    }
    .sheet(isPresented: $isNewBookmarkPresenting, content: {
      List {
        TextField("Bookmark.title", text: $bookmarkTitle)
          .autocorrectionDisabled()
        TextField("Bookmark.link", text: $bookmarkLink)
          .autocorrectionDisabled()
        Button(action: {
          bookmarkTitles.append(bookmarkTitle)
          bookmarkLinks.append(bookmarkLink)
          UserDefaults.standard.set(bookmarkTitles, forKey: "BookmarkTitle")
          UserDefaults.standard.set(bookmarkLinks, forKey: "BookmarkLink")
          isNewBookmarkPresenting = false
          isStartingToAddBookmark = false
        }, label: {
          Label("Bookmarks.add", systemImage: "plus")
        })
      }
      .onAppear {
        if !isStartingToAddBookmark {
          isStartingToAddBookmark = true
          bookmarkTitle = ""
          bookmarkLink = ""
        }
      }
    })
    .sheet(isPresented: $isSortBookmarkPresenting, content: {
      NavigationStack {
        if bookmarkTitles.isEmpty {
          Text("Bookmarks.nothing")
            .bold()
            .foregroundStyle(.secondary)
            .font(.title3)
        } else {
          List {
            Section(content: {
              ForEach(0..<bookmarkLinks.count, id: \.self) {bookmark in
                NavigationLink(destination: {
                  List {
                    TextField("Bookmark.title", text: $bookmarkTitle)
                      .autocorrectionDisabled()
                    TextField("Bookmark.link", text: $bookmarkLink)
                      .autocorrectionDisabled()
                  }
                  .onAppear {
                    bookmarkTitle = bookmarkTitles[bookmark] as! String
                    bookmarkLink = bookmarkLinks[bookmark] as! String
                  }
                  .onDisappear {
                    bookmarkTitles[bookmark] = bookmarkTitle
                    bookmarkLinks[bookmark] = bookmarkLink
                    UserDefaults.standard.set(bookmarkTitles, forKey: "BookmarkTitle")
                    UserDefaults.standard.set(bookmarkLinks, forKey: "BookmarkLink")
                  }
                  .toolbar {
                    if #available(watchOS 10.0, *) {
                      ToolbarItem(placement: .bottomBar) {
                        Label("Bookmark.edit.auto-saving", systemImage: "pencil.line")
                      }
                    }
                  }
                }, label: {
                  Text(bookmarkTitles[bookmark] as! String)
                })
              }
              .onDelete(perform: { bookmark in
                bookmarkTitles.remove(atOffsets: bookmark)
                bookmarkLinks.remove(atOffsets: bookmark)
                UserDefaults.standard.set(bookmarkTitles, forKey: "BookmarkTitle")
                UserDefaults.standard.set(bookmarkLinks, forKey: "BookmarkLink")
              })
              .onMove(perform: { bookmarks, bookmark  in
                bookmarkTitles.move(fromOffsets: bookmarks, toOffset: bookmark)
                bookmarkLinks.move(fromOffsets: bookmarks, toOffset: bookmark)
                UserDefaults.standard.set(bookmarkTitles, forKey: "BookmarkTitle")
                UserDefaults.standard.set(bookmarkLinks, forKey: "BookmarkLink")
              })
            }, footer: {
              Text("Bookmark.description")
            })
          }
        }
      }
    })
    
  }
  func bookmarkOpenAction(link: Any) {
    let session = ASWebAuthenticationSession(
      url: URL(string: ((link as! String).hasPrefix("https://") || (link as! String).hasPrefix("http://") ? (link as! String) : "http://".appending(link as! String)).urlEncoded())!,
      callbackURLScheme: nil
    ) { _, _ in
      
    }
    session.prefersEphemeralWebBrowserSession = !isCookiesAllowed && !isPrivateModeOn
    session.start()
  }
}

#Preview {
  BookmarksView()
}
