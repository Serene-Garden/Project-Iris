//
//  AboutView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/2/2.
//
import SwiftUI

struct AboutView: View {
  var body: some View {
    NavigationStack {
      if #available(watchOS 10.0, *) {
        TabView {
          AboutApp()
            .navigationTitle("About")
          AboutCredits()
            .navigationTitle("About.credits")
          AboutVersions()
            .navigationTitle("About.logs")
        }
        .tabViewStyle(.verticalPage)
      } else {
        TabView {
          AboutApp()
            .navigationTitle("About")
          AboutCredits()
            .navigationTitle("About.credits")
          AboutVersions()
            .navigationTitle("About.logs")
        }
      }
    }
  }
}

struct AboutApp: View {
  @State var isEasterEggDisplayed = false
  let AppIconLength: CGFloat = 70
  var body: some View {
    VStack(alignment: .center) {
      Image("AppIconImage")
        .resizable()
        .frame(width: AppIconLength, height: AppIconLength)
        .mask(Circle())
      Text("Project Iris")
        .bold()
        .font(.title3)
      Group {
        Text("ThreeManager785")
        if !isOpenSource {
          Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)").monospaced()
        } else {
          Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)+").monospaced() + Text(" · ") + Text("GPL-3.0").monospaced()
        }
      }
      .font(.caption)
      .foregroundStyle(.secondary)
    }
    .onTapGesture(count: 3) {
      isEasterEggDisplayed = true
    }
    .sheet(isPresented: $isEasterEggDisplayed, content: {
      VStack {
        if !isOpenSource {
          Image("DarockBrowserImage")
            .resizable()
            .frame(width: AppIconLength, height: AppIconLength)
            .mask(Circle())
        }
        Text("About.easter-egg")
          .multilineTextAlignment(.center)
        Text(isOpenSource ? "About.easter-egg.image-footer.no-image" : "About.easter-egg.image-footer")
          .font(.caption2)
          .foregroundStyle(.secondary)
          .multilineTextAlignment(.center)
      }
    })
  }
}

struct AboutCredits: View {
  @Environment(\.dismiss) var dismiss
  @State var isEasterEgg1Presented = false
  @State var isGenshin = false
  @State var genshinOverlayTextOpacity: CGFloat = 0.0
  var body: some View {
    NavigationStack {
      List {
        Section(content: {
          NavigationLink(destination: {
            List {
              VStack(alignment: .leading) {
                Text("ThreeManager785")
                  .bold()
                Group {
                  Label("About.785.develop", systemImage: "hammer")
                  Label("About.785.internationalization", systemImage: "globe")
                  Label("About.785.design", systemImage: "paintbrush.pointed")
                  Label("About.785.degree", systemImage: "graduationcap")
                  Label("About.785.mail", systemImage: "envelope")
                }
                  .font(.footnote)
                Text("About.785.Atlantic75.description")
                  .font(.footnote)
                  .foregroundStyle(.secondary)
              }
            }
            .navigationTitle("Atlantic75")
          }, label: {
            Text("ThreeManager785")
          })
          NavigationLink(destination: {
            List {
              VStack(alignment: .leading) {
                Text("WindowsMEMZ")
                  .bold()
                Group {
                  Label("About.MEMZ.support", systemImage: "bubble.left.and.text.bubble.right")
                  Label("About.MEMZ.debug", systemImage: "apple.terminal")
                  Label("About.MEMZ.distribute", systemImage: "app.gift")
                  Label("About.MEMZ.mail", systemImage: "envelope")
                }
                  .font(.footnote)
              }
            }
            .navigationTitle("WindowsMEMZ")
          }, label: {
            Text("WindowsMEMZ")
          })
          
          NavigationLink(destination: {
            List {
              VStack(alignment: .leading) {
                Text("Iris Users")
                  .bold()
                Group {
                  Label("About.users.support", systemImage: "person.3.sequence")
                  Label("About.users.feedbacks", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                  Text("About.users.appreciate")
                }
                  .font(.footnote)
              }
//              Text("About.dear-user.content")
//                .navigationTitle("About.dear-user")
            }
          }, label: {Text("And You")})
        }, footer: {
          Text("About.credit.footer")
        })
      }
    }
  }
}

struct AboutVersions: View {
  var body: some View {
    NavigationStack {
      List {
        Section(content: {
          NavigationLink(destination: AboutVersions1_2(), label: {Text("1.2")})
          NavigationLink(destination: AboutVersions1_1(), label: {Text("1.1")})
        }, footer: {
          Text("About.version.footer")
        })
      }
    }
  }
}

struct AboutVersions1_2: View {
  var body: some View {
    NavigationStack {
      List {
        Section(content: {
          VStack(alignment: .leading) {
            Text("1.2.2")
              .bold()
            Text("About.version.1.2.2.details")
          }
          VStack(alignment: .leading) {
            Text("1.2.1")
              .bold()
            Text("About.version.1.2.1.details")
          }
          VStack(alignment: .leading) {
            Text("1.2.0")
              .bold()
            Text("About.version.1.2.0.details")
          }
        })
      }
      .multilineTextAlignment(.leading)
      .navigationTitle("About.logs")
    }
  }
}

struct AboutVersions1_1: View {
  var body: some View {
    NavigationStack {
      List {
        Section(content: {
          VStack(alignment: .leading) {
            Text("1.1.5")
              .bold()
            Text("About.version.1.1.5.details")
          }
          VStack(alignment: .leading) {
            Text("1.1.4")
              .bold()
            Text("About.version.1.1.4.details")
          }
          VStack(alignment: .leading) {
            Text("1.1.3")
              .bold()
            Text("About.version.1.1.3.details")
          }
          VStack(alignment: .leading) {
            Text("1.1.2")
              .bold()
            Text("About.version.1.1.2.details")
          }
          VStack(alignment: .leading) {
            Text("1.1.1")
              .bold()
            Text("About.version.1.1.1.details")
          }
          VStack(alignment: .leading) {
            Text("1.1.0")
              .bold()
            Text("About.version.1.1.0.details")
          }
        })
      }
      .multilineTextAlignment(.leading)
      .navigationTitle("About.logs")
    }
  }
}
