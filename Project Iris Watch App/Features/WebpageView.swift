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
    .onChange(of: currentLinkCache, perform: { value in
      if _fastPath(delayedHistoryRecording) {
        if _slowPath(currentLinkCache != "\(webView.url!)") {
          currentLinkCache = "\(webView.url!)"
          Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            if _fastPath(webView.url != nil) {
              if "\(webView.url!)" == currentLinkCache {
                recordHistory("\(webView.url!)")
              }
            }
          }
        }
      } else {
        recordHistory("\(webView.url!)")
      }
    })
    .onReceive(webView.publisher(for: \.estimatedProgress), perform: { _ in
      estimatedProgress = webView.estimatedProgress
    })
    .onReceive(webView.publisher(for: \.url), perform: { _ in
      if _fastPath(webView.url != nil) {
        currentLinkCache = "\(webView.url!)"
      }
    })
    ._statusBarHidden(hideDigitalTime)
    .toolbar(.hidden)
    .sheet(isPresented: $webpageDetailsSheetIsDisplaying, content: {
      ZStack {
        List {
          VStack(alignment: .leading) {
            Text("\(webView.title ?? "\(webView.url as? String? ?? String(localized: "Webpage.unknown"))")")
              .bold()
              .lineLimit(2)
            if webView.url != nil {
              Text("\(webView.url!)")
                .font(.footnote)
                .lineLimit(2)
            }
          }
          .listRowBackground(Color.clear)
          .onTapGesture {
            urlIsEditing = true
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
                  }
                })
              }
            }
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
            if webView.url != nil {
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
      
      Dynamic(webView).addSubview(SUICButton(systemImage: "ellipsis.circle", frame: .init(x: 10, y: 10, width: 30, height: 30), action: {
        webpageDetailsSheetIsDisplaying = true
      }).tintColor(toolbarColor).button())
      
      webView.allowsBackForwardNavigationGestures = useNavigationGestures
      desktopWebsiteIsRequested = requestDesktopWebsiteAsDefault
      webView.customUserAgent = desktopWebsiteIsRequested ? desktopUserAgent : mobileUserAgent
      webView.reload()
    }
  }
}

private struct WebView: _UIViewRepresentable {
  var webView: NSObject
  func makeUIView(context: Context) -> some NSObject {
    webView
    //    Dynamic(webView).addSubview(button)
  }
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
}

//@_effects(readonly)
//func makeUIButton(
//    title: TextOrImage,
//    frame: CGRect,
//    backgroundColor: Color? = nil,
//    tintColor: Color? = nil,
//    cornerRadius: CGFloat = 8,
//    selector: String? = nil
//) -> Dynamic {
//    var resultButton = Dynamic.UIButton.buttonWithType(1)
//    switch title {
//    case .text(let text):
//        resultButton.setTitle(text, forState: 0)
//    case .image(let image):
//        resultButton.setImage(image, forState: 0)
//    }
//    resultButton.setFrame(frame)
//    if let backgroundColor {
//        resultButton.setBackgroundColor(UIColor(backgroundColor))
//    }
//    if let tintColor {
//        resultButton.setTintColor(UIColor(tintColor))
//    }
//    resultButton.layer.cornerRadius = cornerRadius
//    if let selector {
//        resultButton = Dynamic(WebExtension.getBindedButton(withSelector: selector, button: resultButton.asObject!))
//    }
//    return resultButton
//}
//
//enum TextOrImage {
//    case text(String)
//    case image(UIImage)
//}
