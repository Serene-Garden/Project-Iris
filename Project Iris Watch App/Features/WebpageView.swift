//
//  WebpageView.swift
//  Project Iris
//
//  Created by ThreeManager785 on 9/7/24.
//


import AuthenticationServices
import Cepheus
import Dynamic
import SaltUICore
import SwiftUI
import UIKit

let desktopUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Safari/605.1.15 Iris/\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).\(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)"
let mobileUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1 Iris/\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).\(Bundle.main.infoDictionary?["CFBundleVersion"] as! String)"

struct SwiftWebView: View {
  var webView: WKWebView
  @Environment(\.presentationMode) var presentationMode
  @AppStorage("HideDigitalTime") var hideDigitalTime = true
  @AppStorage("ToolbarTintColor") var toolbarTintColor = 1
  @AppStorage("UseNavigationGestures") var useNavigationGestures = true
  @AppStorage("DelayedHistoryRecording") var delayedHistoryRecording = true
  @AppStorage("DismissAfterAction") var dismissAfterAction = true
  @AppStorage("RequestDesktopWebsite") var requestDesktopWebsiteAsDefault = false
  @AppStorage("dimmingAtSpecificPeriod") var dimmingAtSpecificPeriod = false
  @AppStorage("AppearanceSchedule") var appearanceSchedule = 0
  @State var estimatedProgress: Double = 0
  @State var tintColorValues: [Any] = defaultColor
  @State var tintColor: Color = .blue
  @State var toolbarColor: Color = .blue
  @State var webpageDetailsSheetIsDisplaying = false
  @State var desktopWebsiteIsRequested = false
  @State var addBookmarkSheetIsDisplaying = false
  @State var currentLinkCache = ""
  
  
  //URL Edit
  @State var urlIsEditing = false
  @State var editingURL = ""
  @State var pickersSheetIsDisplaying = false
  @State var bookmarkPickerIsDisplaying = false
  @State var historyPickerIsDisplaying = false
  @State var historyLink = ""
  @State var historyID = 0
  @State var selectedGroup = 0
  @State var selectedBookmark = 0
  @State var groupEqualIndex = -1
  @State var itemEqualIndex = -1
  @AppStorage("lockHistory") var lockHistory = false
  @AppStorage("lockBookmarks") var lockBookmarks = false
  
  //Archive
  @AppStorage("LastArchiveID") var lastArchiveID = -1
  @State var archiveIDs: [Int] = []
  @State var archiveTitles: [String: String] = [:]
  @State var archiveURLs: [String: String] = [:]
  @State var archiveDates: [String: String] = [:]
  @State var archiveSheetIsDisplaying = false
  @State var archiveIsCreating = false
  @State var archiveData: Data?
  @State var archiveCurrentTitle = ""
  @State var archiveSucceed = false
  @State var archiveUpdated = false
  
  //Extensions
  @State var extensionIIDs: [Int] = []
  @State var runningScripts = 0
  var body: some View {
    ZStack {
      WebView(webView: webView)
        .ignoresSafeArea()
      if estimatedProgress != 1 {
        VStack {
          HStack {
            withAnimation {
              toolbarColor
                .frame(width: screenWidth*estimatedProgress, height: 5)
                .animation(.linear)
            }
            Spacer(minLength: .zero)
          }
          Spacer()
        }
        .ignoresSafeArea()
      }
//        .foregroundColor(toolbarColor)
      DimmingView()
    }
    .onReceive(webView.publisher(for: \.estimatedProgress), perform: { _ in
      estimatedProgress = webView.estimatedProgress
    })
    .onReceive(webView.publisher(for: \.url), perform: { _ in
      if _fastPath(webView.url != nil) {
        currentLinkCache = "\(webView.url!)"
        runningScripts = 0
        excuteExtensions()
        
        if _fastPath(delayedHistoryRecording) { //Delayed History-Recording
          if _fastPath(webView.url?.absoluteString != nil) { //If link isn't `nil`
            Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in //Wait 2s
              if _fastPath(webView.url != nil) { //If link isn't `nil`
                if webView.url?.absoluteString == currentLinkCache { //If webLink's the same
                    recordHistory(webView.url!.absoluteString) //Record
                }
              }
            }
          }
        } else { //Immediate history-recording
          if webView.url?.absoluteString != nil { //If link isn't `nil`
            recordHistory(webView.url!.absoluteString) //Record
          }
        }
      }
    })
    ._statusBarHidden(hideDigitalTime)
    .toolbar(.hidden)
    .sheet(isPresented: $webpageDetailsSheetIsDisplaying, content: {
      ZStack {
        List {
          VStack(alignment: .leading) {
            Text((webpageIsArchive && webpageArchiveTitle != nil) ? webpageArchiveTitle! : "\(webView.title ?? (webView.url?.absoluteString ?? String(localized: "Webpage.unknown")))")
              .bold()
              .lineLimit(2)
            if webView.url != nil {
              Text("\(webView.url!)")
                .font(.footnote)
                .lineLimit(2)
            }
            if webpageIsArchive && webView.url?.absoluteString == webpageArchiveURL {
              HStack {
                Image(systemName: "archivebox")
                Text("Webpage.is-archive")
                Spacer()
              }
              .foregroundColor(.secondary)
              .font(.footnote)
            }
            if runningScripts > 0 {
              HStack {
                Image(systemName: "puzzlepiece.extension")
                Text("Webpage.active-extensions.\(runningScripts)")
                Spacer()
              }
              .foregroundColor(.secondary)
              .font(.footnote)
            }
          }
          .listRowBackground(Color.clear)
          .onTapGesture {
            if !webpageIsArchive {
              urlIsEditing = true
            }
          }
          .sheet(isPresented: $urlIsEditing, content: {
            List {
              TextField("Webpage.go-to.url", text: $editingURL)
                .autocorrectionDisabled()
              Text(editingURL)
                .font(.caption)
              if #unavailable(watchOS 10) {
                DismissButton(action: {
                  let webpageURLRequest = URLRequest(url: URL(string: editingURL)!)
                  webView.load(webpageURLRequest)
                }, label: {
                  Label("Webpage.go-to.go", systemImage: "arrow.up.right.circle")
                })
              }
            }
            .navigationTitle("Webpage.go-to")
            .toolbar {
              if #available(watchOS 10, *) {
                ToolbarItem(placement: .topBarTrailing, content: {
                  DismissButton(action: {
                    let webpageURLRequest = URLRequest(url: URL(string: editingURL)!)
//                    webView.navigationDelegate = WebViewNavigationDelegate.shared
//                    webView.uiDelegate = WebViewUIDelegate.shared
                    webView.load(webpageURLRequest)
                  }, label: {
                    Image(systemName: "arrow.up.right")
                  })
                })
                ToolbarItemGroup(placement: .bottomBar, content: {
                  HStack {
                    Spacer()
                    Button(action: {
                      pickersSheetIsDisplaying = true
                    }, label: {
                      Image(systemName: "book")
                    })
                    .sheet(isPresented: $pickersSheetIsDisplaying, content: {
                      NavigationStack {
                        List {
                          if #available(watchOS 10, *) {
                            NavigationLink(destination: {
                              PasscodeView(destination: {
                                BookmarkPickerView(editorSheetIsDisaplying: $bookmarkPickerIsDisplaying, seletedGroup: $selectedGroup, selectedBookmark: $selectedBookmark, groupIndexEqualingGoal: groupEqualIndex, bookmarkIndexEqualingGoal: itemEqualIndex, action: {
                                  editingURL = getBookmarkLibrary()[selectedGroup].3[selectedBookmark].3
                                })
                              }, title: "Bookmark.picker", directPass: !lockBookmarks)
                            }, label: {
                              HStack {
                                Label("Webpage.go-to.bookmark", systemImage: "bookmark")
                                Spacer()
                                if lockBookmarks {
                                  LockIndicator(destination: "bookmarks")
                                }
                              }
                            })
                          }
                          NavigationLink(destination: {
                            PasscodeView(destination: {
                              HistoryPickerView(pickerSheetIsDisplaying: $historyPickerIsDisplaying, historyLink: $historyLink, historyID: $historyID, acceptNonLinkHistory: false, action: {
                                editingURL = historyLink
                              })
                            }, title: "History.picker", directPass: !lockHistory)
                          }, label: {
                            HStack {
                              Label("Webpage.go-to.history", systemImage: "clock")
                              Spacer()
                              if lockHistory {
                                LockIndicator(destination: "history")
                              }
                            }
                          })
                        }
                      }
                    })
                  }
                })
              }
            }
            .onAppear {
              if webView.url != nil {
                editingURL = "\(webView.url!)"
              } else {
                editingURL = ""
              }
            }
          })
          Section {
            if webView.canGoBack {
              DismissButton(action: {
                webView.goBack()
              }, label: {
                Label("Webpage.back", systemImage: "chevron.backward")
              }, doDismiss: dismissAfterAction)
            }
            if webView.canGoForward {
              DismissButton(action: {
                webView.goForward()
              }, label: {
                Label("Webpage.forward", systemImage: "chevron.forward")
              }, doDismiss: dismissAfterAction)
            }
            if webView.isLoading {
              Button(action: {
                webView.stopLoading()
              }, label: {
                Label("Webpage.stop-loading", systemImage: "xmark")
              })
            } else {
              DismissButton(action: {
                webView.reload()
              }, label: {
                Label("Webpage.reload", systemImage: "arrow.clockwise")
              })
            }
          }
          Section {
            if desktopWebsiteIsRequested {
              Button(action: {
                desktopWebsiteIsRequested.toggle()
                webView.customUserAgent = mobileUserAgent
                webView.reload()
              }, label: {
                Label("Webpage.request-mobile", systemImage: "applewatch")
              })
            } else {
              Button(action: {
                desktopWebsiteIsRequested.toggle()
                webView.customUserAgent = desktopUserAgent
                webView.reload()
              }, label: {
                Label("Webpage.request-desktop", systemImage: "desktopcomputer")
              })
            }
            if webView.url != nil && !webpageIsArchive {
              Button(action: {
                addBookmarkSheetIsDisplaying = true
              }, label: {
                HStack {
                  Label("Webpage.add-to-bookmarks", systemImage: "bookmark")
                  Spacer()
                  LockIndicator(destination: "bookmarks")
                }
              })
              .sheet(isPresented: $addBookmarkSheetIsDisplaying, content: {
                PasscodeView(destination: {
                  NewBookmarkView(bookmarkLink: "\(webView.url!)")
                }, directPass: !lockBookmarks)
              })
              if archiveURLs.values.contains(webView.url?.absoluteString ?? "") {
                Button(action: {
                  var targetID = -1
                  for (key, value) in archiveURLs {
                    if value == webView.url?.absoluteString ?? "" {
                      targetID = Int(key)!
                    }
                  }
                  updateArchive(id: targetID)
                  archiveUpdated = true
                }, label: {
                  Label("Webpage.update-archive", systemImage: "archivebox")
                })
                .sheet(isPresented: $archiveUpdated, content: {
                  Group {
                    if #available(watchOS 10, *) {
                      ContentUnavailableView {
                        Label("Webpage.update-archive.succeed", systemImage: "archivebox")
                      } description: {
                        Text("Webpage.update-archive.succeed.description")
                      }
                      
                    } else {
                      List {
                        Text("Webpage.update-archive.succeed")
                          .bold()
                          .foregroundStyle(.secondary)
                      }
                    }
                  }
                })
              } else {
                Button(action: {
                  archiveIsCreating = true
                  archiveData = nil
                  archiveCurrentTitle = ""
                  webView.createWebArchiveData(completionHandler: { data, error in
                    archiveIsCreating = false
                    if data != nil {
                      archiveData = data
                      archiveCurrentTitle = webView.title ?? (webView.url?.absoluteString ?? "")
                      archiveSheetIsDisplaying = true
                    } else {
                      showTip("Webpage.archive.failure", symbol: "xmark")
                    }
                  })
                }, label: {
                  HStack {
                    Label("Webpage.archive", systemImage: "archivebox")
                    Spacer()
                    if archiveIsCreating {
                      ProgressView()
                        .frame(width: 25)
                    }
                  }
                })
                .sheet(isPresented: $archiveSheetIsDisplaying, content: {
                  Group {
                    if archiveData != nil {
                      List {
                        Text("Webpage.archive.instruction")
                        TextField("Webpage.archive.textfield", text: $archiveCurrentTitle)
                        if #unavailable(watchOS 10) {
                          DismissButton(action: {
                            //MARK: FOLLOW THE TOOLBAR ONE
                            lastArchiveID += 1
                            archiveIDs.reverse()
                            archiveIDs.append(lastArchiveID)
                            archiveIDs.reverse()
                            archiveTitles.updateValue(archiveCurrentTitle, forKey: String(lastArchiveID))
                            archiveURLs.updateValue(webView.url?.absoluteString ?? "", forKey: String(lastArchiveID))
                            archiveDates.updateValue(String(Int(Date.now.timeIntervalSince1970)), forKey: String(lastArchiveID))
                            UserDefaults.standard.set(archiveIDs, forKey: "ArchiveIDs")
                            UserDefaults.standard.set(archiveTitles, forKey: "ArchiveTitles")
                            UserDefaults.standard.set(archiveURLs, forKey: "ArchiveURLs")
                            UserDefaults.standard.set(archiveDates, forKey: "ArchiveDates")
                            writeDataFile(archiveData!, to: "Archive#\(lastArchiveID)")
//                            showTip("Webpage.archive.succeed", symbol: "archivebox")
                            archiveSucceed = true
                            //MARK: FOLLOW THE TOOLBAR ONE
                          }, label: {
                            Label("Webpage.archive.save", systemImage: "square.and.arrow.down")
                          })
                        }
                      }
                      .toolbar {
                        if #available(watchOS 10, *) {
                          ToolbarItem(placement: .topBarTrailing, content: {
                            DismissButton(action: {
                              lastArchiveID += 1
                              archiveIDs.reverse()
                              archiveIDs.append(lastArchiveID)
                              archiveIDs.reverse()
                              archiveTitles.updateValue(archiveCurrentTitle, forKey: String(lastArchiveID))
                              archiveURLs.updateValue(webView.url?.absoluteString ?? "", forKey: String(lastArchiveID))
                              archiveDates.updateValue(String(Int(Date.now.timeIntervalSince1970)), forKey: String(lastArchiveID))
                              UserDefaults.standard.set(archiveIDs, forKey: "ArchiveIDs")
                              UserDefaults.standard.set(archiveTitles, forKey: "ArchiveTitles")
                              UserDefaults.standard.set(archiveURLs, forKey: "ArchiveURLs")
                              UserDefaults.standard.set(archiveDates, forKey: "ArchiveDates")
                              writeDataFile(archiveData!, to: "Archive#\(lastArchiveID)")
//                              showTip("Webpage.archive.succeed", symbol: "archivebox")
                              archiveSucceed = true
                            }, label: {
                              Label("Webpage.archive.save", systemImage: "square.and.arrow.down")
                            })
                          })
                        }
                      }
                    } else {
                      if #available(watchOS 10, *) {
                        ContentUnavailableView {
                          Label("Webpage.archive.data-missing", systemImage: "questionmark.text.page")
                        } description: {
                          Text("Webpage.archive.data-missing.description")
                        }
                      } else {
                        Image(systemName: "questionmark.text.page")
                          .bold()
                          .font(.largeTitle)
                      }
                    }
                  }
                  .navigationTitle("Webpage.archive.title")
                })
                .sheet(isPresented: $archiveSucceed, content: {
                  if #available(watchOS 10, *) {
                    ContentUnavailableView {
                      Label("Webpage.archive.succeed", systemImage: "archivebox")
                    } description: {
                      Text("Webpage.archive.succeed.description")
                    }
                  } else {
                    List {
                      Text("Webpage.archive.succeed")
                        .bold()
                        .foregroundStyle(.secondary)
                    }
                  }
                })
              }
              Button(action: {
                let session = ASWebAuthenticationSession(
                  url: webView.url!,
                  callbackURLScheme: nil
                ) { _, _ in
                  
                }
                session.start()
              }, label: {
                Label("Webpage.legacy-engine", systemImage: "macwindow.and.cursorarrow")
              })
            }
            
          }
          if #unavailable(watchOS 10) {
            Section {
              Button(role: .destructive, action: {
                webpageIsDisplaying = false
              }, label: {
                Label("Webpage.close", systemImage: "escape")
                  .foregroundStyle(.red)
              })
            }
          }
        }
        if estimatedProgress != 1 {
          VStack {
            HStack {
              withAnimation {
                toolbarColor
                  .frame(width: screenWidth*estimatedProgress, height: 5)
                  .animation(.linear)
              }
              Spacer(minLength: .zero)
            }
            Spacer()
          }
          .ignoresSafeArea()
        }
        DimmingView()
      }
      .toolbar {
        if #available(watchOS 10, *) {
          ToolbarItem(placement: .topBarTrailing, content: {
            Button(role: .destructive, action: {
              webpageIsDisplaying = false
            }, label: {
              Label("Webpage.close", systemImage: "escape")
                .foregroundStyle(.red)
            })
          })
        }
      }
      //      .navigationTitle("\(webView.title ?? "\(webView.url as? String? ?? String(localized: "Webpage"))")")
    })
    .onAppear {
      //Toolbar Color
      if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
        UserDefaults.standard.set(defaultColor, forKey: "tintColor")
      }
      tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? (defaultColor as [Any])
      tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100*2, brightness: (tintColorValues[2] as! Double)/100)
      if toolbarTintColor == 0 {
        toolbarColor = tintColor
      } else if toolbarTintColor == 1 {
        toolbarColor = .blue
      }
      
      //Render Button
      Dynamic(webView).addSubview(SUICButton(systemImage: "ellipsis.circle", frame: .init(x: 10, y: 10, width: 30, height: 30), action: {
        webpageDetailsSheetIsDisplaying = true
      }).tintColor(toolbarColor).button())
      
      //Config Webview
      webView.allowsBackForwardNavigationGestures = useNavigationGestures
      desktopWebsiteIsRequested = requestDesktopWebsiteAsDefault
      webView.customUserAgent = desktopWebsiteIsRequested ? desktopUserAgent : mobileUserAgent
      if shouldDimScreen(globalDimming: true, isGlobalCaller: true, dimmingAtSpecificPeriod: dimmingAtSpecificPeriod, lightMode: appearanceSchedule == 0) {
        webView.underPageBackgroundColor = .black
      }
      webView.reload()
      
      //Initialize Data
      if (UserDefaults.standard.array(forKey: "ArchiveIDs") ?? []).isEmpty {
        UserDefaults.standard.set([], forKey: "ArchiveIDs")
        UserDefaults.standard.set([:], forKey: "ArchiveTitles")
        UserDefaults.standard.set([:], forKey: "ArchiveURLs")
        UserDefaults.standard.set([:], forKey: "ArchiveDates")
      }
      archiveIDs = (UserDefaults.standard.array(forKey: "ArchiveIDs") ?? []) as! [Int]
      archiveTitles = (UserDefaults.standard.dictionary(forKey: "ArchiveTitles") ?? [:]) as! [String: String]
      archiveURLs = (UserDefaults.standard.dictionary(forKey: "ArchiveURLs") ?? [:]) as! [String: String]
      archiveDates = (UserDefaults.standard.dictionary(forKey: "ArchiveDates") ?? [:]) as! [String: String]
      
      //Extensions
      if (UserDefaults.standard.array(forKey: "ExtensionIIDs") ?? []).isEmpty {
        UserDefaults.standard.set([], forKey: "ExtensionIIDs")
        UserDefaults.standard.set([:], forKey: "ExtensionTitles")
        UserDefaults.standard.set([:], forKey: "ExtensionGIDs")
      }
      excuteExtensions()
    }
  }
  func excuteExtensions() {
    extensionIIDs = (UserDefaults.standard.array(forKey: "ExtensionIIDs") ?? []) as! [Int]
    var extensionCode = ""
    for extensionIndex in 0..<extensionIIDs.count {
      extensionCode = UserDefaults.standard.string(forKey: "Extension#\(extensionIIDs[extensionIndex])") ?? ""
      if shouldScriptBeRun(extensionCode, currentURL: (webView.url?.absoluteString ?? "")) {
        webView.evaluateJavaScript(extensionCode)
        runningScripts += 1
      }
    }
  }
}


//UIKit Element Renderer
private struct WebView: _UIViewRepresentable {
  var webView: NSObject
  func makeUIView(context: Context) -> some NSObject {
    webView
    //    Dynamic(webView).addSubview(button)
  }
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
}

func shouldScriptBeRun(_ script: String, currentURL: String) -> Bool {
  //Get headers, seperate in lines
  let scriptInLines = script.components(separatedBy: "==/UserScript==")[0].components(separatedBy: "\n")
  var regexLines: [String] = []
  //Get all lines with regex
  for lineIndex in 0..<scriptInLines.count {
    if scriptInLines[lineIndex].hasPrefix("// @match") {
      regexLines.append(scriptInLines[lineIndex])
    }
  }
  
  var output = false
  for regexIndex in 0..<regexLines.count {
    //Replace Special Characters
    regexLines[regexIndex] = regexLines[regexIndex].replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "/", with: "\\/").replacingOccurrences(of: "$", with: "\\$").replacingOccurrences(of: ".", with: "\\.").replacingOccurrences(of: "^", with: "\\^").replacingOccurrences(of: "{", with: "\\{").replacingOccurrences(of: "[", with: "\\[").replacingOccurrences(of: "?", with: "\\?").replacingOccurrences(of: "+", with: "\\+")
    if doesRegexMatch(regexLines[regexIndex], text: currentURL) {
      output = true
    }
  }
  return output
}

func doesRegexMatch(_ regexPattern: String, text: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: regexPattern)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        let match = regex.firstMatch(in: text, options: [], range: range)
        return match != nil
    } catch {
        print("Invalid regular expression: \(error.localizedDescription)")
        return false
    }
}
