//
//  ArchivesView.swift
//  Project Iris Watch App
//
//  Created by ThreeManager785 on 9/30/24.
//

import SwiftUI

struct ArchivesView: View {
  @AppStorage("LastArchiveID") var lastArchiveID = -1
  @State var archiveIDs: [Int] = []
  @State var archiveTitles: [String: String] = [:]
  @State var archiveURLs: [String: String] = [:]
  @State var archiveDates: [String: String] = [:]
  @State var archiveDetailsSheetIsDisplaying = false
  @State var focusingID = 0
  @State var displayingArchiveIDs: [Int] = []
  @State var displayingCacheTitles: [String: String] = [:]
  @State var displayingCacheURL: [String: String] = [:]
  @State var detailsAreReady = false
  
  @State var displayingIDsAreSyncingWithStorage = true
  @State var filterSheetIsDisplaying = false
  @State var searchingKeyword = ""
  @State var sortType = 0
  @AppStorage("SubtitleType") var subtitleType = 0
  @State var searchURL = false
  @State var updated = false
  var body: some View {
    NavigationStack {
      if !displayingArchiveIDs.isEmpty {
        List {
          ForEach(0..<displayingArchiveIDs.count, id: \.self) { archiveIDIndex in
            Button(action: {
              openArchive(displayingArchiveIDs[archiveIDIndex], archiveTitles: archiveTitles, archiveURLs: archiveURLs)
            }, label: {
              VStack(alignment: .leading) {
                Text(archiveTitles[String(displayingArchiveIDs[archiveIDIndex])] ?? "Unknown")
                  .lineLimit(2)
                Group {
                  if subtitleType == 1 {
                    Text(archiveURLs[String(displayingArchiveIDs[archiveIDIndex])] ?? String(localized: "Archive.info.unknown"))
                  } else if subtitleType == 2 {
                    ArchiveDateText(id: displayingArchiveIDs[archiveIDIndex])
                  }
                }
                .lineLimit(1)
                .font(.footnote)
                .foregroundStyle(.secondary)
              }
            })
            .swipeActions(edge: .trailing, content: {
              Button(role: .destructive, action: {
                archiveTitles.removeValue(forKey: String(displayingArchiveIDs[archiveIDIndex]))
                archiveDates.removeValue(forKey: String(displayingArchiveIDs[archiveIDIndex]))
                archiveURLs.removeValue(forKey: String(displayingArchiveIDs[archiveIDIndex]))
                archiveIDs.remove(at: archiveIDIndex)
                UserDefaults.standard.set(archiveURLs, forKey: "ArchiveURLs")
                UserDefaults.standard.set(archiveDates, forKey: "ArchiveDates")
              }, label: {
                Image(systemName: "trash")
              })
              Button(action: {
                focusingID = displayingArchiveIDs[archiveIDIndex]
                archiveDetailsSheetIsDisplaying = true
                detailsAreReady = false
              }, label: {
                Image(systemName: "info.circle")
              })
              
            })
            .swipeActions(edge: .leading, content: {
              Button(action: {
                updateArchive(id: displayingArchiveIDs[archiveIDIndex])
                showTip("Archive.updated", symbol: "arrowshape.up")
                filterDisplayingArchiveList()
              }, label: {
                Image(systemName: "arrowshape.up")
              })
            })
          }
          .onMove(perform: { oldIndex, newIndex in
            archiveIDs.move(fromOffsets: oldIndex, toOffset: newIndex)
          })
          .moveDisabled(!displayingIDsAreSyncingWithStorage)
        }
      } else {
        if archiveIDs.isEmpty {
          if #available(watchOS 10, *) {
            ContentUnavailableView {
              Label("Archive.empty", systemImage: "archivebox")
            } description: {
              Text("Archive.empty.description")
            }
          } else {
            List {
              Text("Archive.empty")
                .bold()
                .foregroundStyle(.secondary)
            }
          }
        } else {
          if #available(watchOS 10, *) {
            ContentUnavailableView {
              Label("Archive.filtered-empty", systemImage: "magnifyingglass")
            } description: {
              Text("Archive.filtered-empty.description")
            }
          } else {
            List {
              Text("Archive.filtered-empty")
                .bold()
                .foregroundStyle(.secondary)
            }
          }
        }
      }
    }
    .sheet(isPresented: $archiveDetailsSheetIsDisplaying, onDismiss: {
      filterDisplayingArchiveList()
    }, content: {
      Group {
        if detailsAreReady {
          ScrollView {
            VStack(alignment: .leading) {
              Group {
                Text("Archive.info.title")
                  .bold()
                Text(archiveTitles[String(focusingID)] ?? String(localized: "Archive.info.unknown"))
                  .font(.caption)
              }
              Spacer()
                .frame(height: 10)
              Group {
                Text("Archive.info.url")
                  .bold()
                Text(archiveURLs[String(focusingID)] ?? String(localized: "Archive.info.unknown"))
                  .font(.caption)
              }
              Spacer()
                .frame(height: 10)
              Group {
                Text("Archive.info.date")
                  .bold()
                Text(Date.init(timeIntervalSince1970: Double(Int(archiveDates[String(focusingID)] ?? "0") ?? 0)).formatted(.dateTime))
                  .font(.caption)
              }
              Spacer()
                .frame(height: 10)
              Group {
                TextFieldLink(label: {
                  Label("Archive.info.rename", systemImage: "pencil.line")
                }, onSubmit: { submittion in
                  archiveTitles[String(focusingID)] = submittion
                  UserDefaults.standard.set(archiveTitles, forKey: "ArchiveTitles")
                })
              }
            }
          }
        } else {
          ProgressView()
            .onAppear {
              detailsAreReady = true
            }
        }
      }
      .navigationTitle("Archive.info")
      //      ArchiveDetailsView(id: focusingID, title: , url: )
    })
    .toolbar {
      if #available(watchOS 10.0, *) {
        ToolbarItem(placement: .topBarTrailing, content: {
          Button(action: {
            filterSheetIsDisplaying = true
          }, label: {
            Image(systemName: displayingIDsAreSyncingWithStorage ? "ellipsis" : "rectangle.and.text.magnifyingglass")
          })
          .sheet(isPresented: $filterSheetIsDisplaying, content: {
            List {
              Section("Archive.filter") {
                TextField("Archive.filter.search", text: $searchingKeyword)
                  .onSubmit {
                    filterDisplayingArchiveList()
                  }
                Picker("Archive.filter.sort", selection: $sortType, content: {
                  Text("Archive.filter.sort.default").tag(0)
                  Text("Archive.filter.sort.title").tag(1)
                  Text("Archive.filter.sort.time").tag(2)
                })
                Toggle("Archive.filter.search-url", isOn: $searchURL)
                  .onChange(of: sortType, perform: { value in
                    filterDisplayingArchiveList()
                  })
              }
              Section("Archive.subtitle") {
                Picker("Archive.subtitle.content", selection: $subtitleType, content: {
                  Text("Archive.subtitle.content.none").tag(0)
                  Text("Archive.subtitle.content.url").tag(1)
                  Text("Archive.subtitle.content.date").tag(2)
                })
              }
            }
          })
        })
      }
    }
    .navigationTitle("Archive")
    .onAppear {
      archiveStorageInit()
      archiveIDs = (UserDefaults.standard.array(forKey: "ArchiveIDs") ?? []) as! [Int]
      archiveTitles = (UserDefaults.standard.dictionary(forKey: "ArchiveTitles") ?? [:]) as! [String: String]
      archiveURLs = (UserDefaults.standard.dictionary(forKey: "ArchiveURLs") ?? [:]) as! [String: String]
      archiveDates = (UserDefaults.standard.dictionary(forKey: "ArchiveDates") ?? [:]) as! [String: String]
      displayingArchiveIDs = archiveIDs
    }
    .onChange(of: archiveIDs, perform: { value in
      UserDefaults.standard.set(archiveIDs, forKey: "ArchiveIDs")
      if displayingIDsAreSyncingWithStorage {
        displayingArchiveIDs = archiveIDs
      }
    })
    .onChange(of: archiveTitles, perform: { value in
      UserDefaults.standard.set(archiveTitles, forKey: "ArchiveTitles")
    })
//        .onChange(of: archiveURLs, perform: { value in
//          UserDefaults.standard.set(archiveURLs, forKey: "ArchiveURLs")
//        })
//        .onChange(of: archiveDates, perform: { value in
//          UserDefaults.standard.set(archiveDates, forKey: "ArchiveDates")
//        })
  }
  func filterDisplayingArchiveList() {
    displayingCacheTitles = archiveTitles
    displayingCacheURL = archiveURLs
    if !searchingKeyword.isEmpty {
      for (key, value) in displayingCacheTitles {
        if !value.lowercased().contains(searchingKeyword.lowercased()) {
          displayingCacheTitles.removeValue(forKey: key)
        }
      }
      if searchURL {
        for (key, value) in displayingCacheURL {
          if !value.lowercased().contains(searchingKeyword.lowercased()) {
            displayingCacheURL.removeValue(forKey: key)
          }
        }
      } else {
        displayingCacheURL = [:]
      }
    }
    
    displayingArchiveIDs = Array(Set((Array(displayingCacheTitles.keys)) + (Array(displayingCacheURL.keys)))).compactMap { Int($0) }
    
    var sortedArchiveIDs: [Int] = []
    if sortType == 0 {
      displayingArchiveIDs = sortArrayByArray(displayingArchiveIDs, by: archiveIDs)
    } else if sortType == 1 {
      sortedArchiveIDs = archiveTitles.keys.sorted(by: { lhs, rhs in archiveTitles[lhs]! < archiveTitles[rhs]! }).compactMap { Int($0) }
      displayingArchiveIDs = sortArrayByArray(displayingArchiveIDs, by: sortedArchiveIDs)
    } else if sortType == 2 {
      sortedArchiveIDs = archiveDates.keys.sorted(by: { lhs, rhs in Int(archiveDates[lhs]!)! < Int(archiveDates[rhs]!)! }).compactMap { Int($0) }
      displayingArchiveIDs = sortArrayByArray(displayingArchiveIDs, by: sortedArchiveIDs)
    }
    
    displayingIDsAreSyncingWithStorage = (sortType == 0 && searchingKeyword.isEmpty)
  }
}

@MainActor func openArchive(_ index: Int, archiveTitles: [String: String], archiveURLs: [String: String]) {
  let webpageConfig = WKWebView()
  webpageConfig.uiDelegate = WebViewUIDelegate.shared
  webpageConfig.load(readDataFile("Archive#\(index)")!, mimeType: "application/x-webarchive", characterEncodingName: "utf-8", baseURL: URL(string: archiveURLs[String(index)] ?? "")!)
  webpageContent = webpageConfig
  webpageIsArchive = true
  webpageArchiveURL = archiveURLs[String(index)]
  webpageArchiveTitle = archiveTitles[String(index)]
  webpageIsDisplaying = true
}

@MainActor func updateArchive(id: Int) {
  WKWebView().createWebArchiveData(completionHandler: { data, error in
    if data != nil {
      writeDataFile(data, to: "Archive#\(id)")
      var archiveDatas = ((UserDefaults.standard.dictionary(forKey: "ArchiveDates") ?? [:]) as! [String: String])
      archiveDatas.updateValue(String(Int(Date.now.timeIntervalSince1970)), forKey: "\(id)")
      UserDefaults.standard.set(archiveDatas, forKey: "ArchiveDates")
    } else {
      showTip("Archive.update.failure", symbol: "xmark")
    }
  })
}

func sortArrayByArray<T: Equatable>(_ arrayToSort: [T], by orderArray: [T]) -> [T] {
  return arrayToSort.sorted { (first, second) -> Bool in
    let firstIndex = orderArray.firstIndex(of: first) ?? orderArray.count
    let secondIndex = orderArray.firstIndex(of: second) ?? orderArray.count
    return firstIndex < secondIndex
  }
}

func archiveStorageInit() {
  if (UserDefaults.standard.array(forKey: "ArchiveIDs") ?? []).isEmpty {
    UserDefaults.standard.set([], forKey: "ArchiveIDs")
    UserDefaults.standard.set([:], forKey: "ArchiveTitles")
    UserDefaults.standard.set([:], forKey: "ArchiveURLs")
    UserDefaults.standard.set([:], forKey: "ArchiveDates")
  }
//  let archiveIDs = (UserDefaults.standard.array(forKey: "ArchiveIDs") ?? []) as! [Int]
//  var archiveURLs = (UserDefaults.standard.dictionary(forKey: "ArchiveURLs") ?? [:]) as! [String: String]
//  var archiveDates = (UserDefaults.standard.dictionary(forKey: "ArchiveDates") ?? [:]) as! [String: String]
//  for (key, value) in archiveDates {
//    if !archiveIDs.contains(Int(key) ?? -1) {
//      archiveDates.removeValue(forKey: key)
//    }
//  }
//  for (key, value) in archiveURLs {
//    if !archiveIDs.contains(Int(key) ?? -1) {
//      archiveURLs.removeValue(forKey: key)
//    }
//  }
//  UserDefaults.standard.set(archiveURLs, forKey: "ArchiveURLs")
//  UserDefaults.standard.set(archiveDates, forKey: "ArchiveDates")
}

struct ArchiveDateText: View {
  var id: Int
  @State var archiveDates: [String: String] = [:]
  var body: some View {
    Text(Date.init(timeIntervalSince1970: Double(Int(archiveDates[String(id)] ?? "0") ?? 0)).formatted(.dateTime))
      .onAppear {
        archiveDates = (UserDefaults.standard.dictionary(forKey: "ArchiveDates") ?? [:]) as! [String: String]
      }
  }
}


