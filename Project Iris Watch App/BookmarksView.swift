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
    @State var bookmarkTitles: [Any] = []
    @State var bookmarkLinks: [Any] = []
    @State var isNewBookmarkPresenting = false
    @State var isEditBookmarkPresenting = false
    @State var bookmarkTitle = ""
    @State var bookmarkLink = ""
    var body: some View {
        NavigationStack {
            if bookmarkLinks.count > 0 {
                List {
                    Section(content: {
                        ForEach(0..<bookmarkLinks.count, id: \.self) {bookmark in
                            Button(action: {
                                let session = ASWebAuthenticationSession(
                                    url: URL(string: ((bookmarkLinks[bookmark] as! String).hasPrefix("https://") || (bookmarkLinks[bookmark] as! String).hasPrefix("http://") ? (bookmarkLinks[bookmark] as! String) : "http://".appending(bookmarkLinks[bookmark] as! String)).urlEncoded())!,
                                    callbackURLScheme: nil
                                ) { _, _ in
                                    
                                }
                                session.prefersEphemeralWebBrowserSession = !isCookiesAllowed && !isPrivateModeOn
                                session.start()
                            }, label: {
                                Text(bookmarkTitles[bookmark] as! String)
                            })
                            .onLongPressGesture {
                                isEditBookmarkPresenting = true
                            }
                            .sheet(isPresented: $isEditBookmarkPresenting, content: {
                                List {
                                    TextField("Bookmark.title", text: $bookmarkTitle)
                                    TextField("Bookmark.link", text: $bookmarkLink)
                                    Button(action: {
                                        UserDefaults.standard.set(bookmarkTitles, forKey: "BookmarkTitle")
                                        UserDefaults.standard.set(bookmarkLinks, forKey: "BookmarkLink")
                                        isEditBookmarkPresenting = false
                                    }, label: {
                                        Label("Bookmarks.apply", systemImage: "checkmark")
                                    })
                                }
                                .onAppear {
                                    bookmarkTitle = bookmarkTitles[bookmark] as! String
                                    bookmarkLink = bookmarkLinks[bookmark] as! String
                                }
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
            } else {
                Text("Bookmarks.nothing")
                    .bold()
                    .foregroundStyle(.secondary)
                    .font(.title3)
            }
        }
        .navigationTitle("Bookmarks")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                    Button(action: {
                        isNewBookmarkPresenting = true
                    }, label: {
                        Image(systemName: "plus")
                    })
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
                TextField("Bookmark.link", text: $bookmarkLink)
                Button(action: {
                    bookmarkTitles.append(bookmarkTitle)
                    bookmarkLinks.append(bookmarkLink)
                    UserDefaults.standard.set(bookmarkTitles, forKey: "BookmarkTitle")
                    UserDefaults.standard.set(bookmarkLinks, forKey: "BookmarkLink")
                    isNewBookmarkPresenting = false
                }, label: {
                    Label("Bookmarks.add", systemImage: "plus")
                })
            }
            .onAppear {
                bookmarkTitle = ""
                bookmarkLink = ""
            }
        })
    }
}

#Preview {
    BookmarksView()
}
