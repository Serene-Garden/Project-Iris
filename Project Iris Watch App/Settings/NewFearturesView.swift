//
//  NewFearturesView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/7/7.
//

import SwiftUI

let votesAvailable = true

struct NewFearturesView: View {
  let showDetails = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).hasSuffix(".0")
  var body: some View {
    if #available(watchOS 10, *) {
      TabView {
        NewFeaturesTitleView()
        if showDetails || votesAvailable {
          NewFeaturesListView()
        }
      }
      .tabViewStyle(.verticalPage)
    } else {
      ScrollView {
        NewFeaturesTitleView()
        if showDetails {
          NewFeaturesListView()
        }
      }
    }
  }
}

struct NewFeaturesTitleView: View {
  let showDetails = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).hasSuffix(".0")
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text("New.title.\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
          .bold()
          .font(.largeTitle)
        Group {
          if showDetails {
            if #available(watchOS 10, *) {
              Label("New.title.scroll", systemImage: "chevron.down")
            }
          } else if votesAvailable {
            Label("New.title.votes", systemImage: "bell.and.waves.left.and.right")
          } else {
            Label("New.title.minor", systemImage: "ellipsis.circle")
          }
        }
      }
    }
    /*.toolbar {
      if votesAvailable {
        if #available(watchOS 10, *) {
          ToolbarItemGroup(placement: .bottomBar, content: {
            HStack {
              Spacer()
              NavigationLink(destination: {
                VoteView()
              }, label: {
                Image(systemName: "arrow.right")
              })
            }
          })
        }
      }
    }*/
  }
}

struct NewFeaturesListView: View {
  let showDetails = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).hasSuffix(".0")
  var body: some View {
    if showDetails {
      List {
        SingleNewFeature(symbol: "bookmark", title: "New.webpage", description: "New.webpage.description")
        SingleNewFeature(symbol: "chevron.up.chevron.down", title: "New.vote", description: "New.vote.description")
        SingleNewFeature(symbol: "document.badge.plus", title: "New.attach-files", description: "New.attach-files.description")
        SingleNewFeature(symbol: "sun.min", title: "New.dimming", description: "New.dimming.description")
        SingleNewFeature(symbol: "lock", title: "New.security", description: "New.security.description")
      }
    } else {
      if #available(watchOS 10, *) {
        if votesAvailable {
          ContentUnavailableView {
            Label("New.vote", systemImage: "chevron.up.chevron.down")
          } description: {
            NavigationLink(destination: {
              VoteView()
            }, label: {
              Text("New.vote.description")
            })
            .buttonStyle(.plain)
          }
          .toolbar {
            ToolbarItem(placement: .bottomBar, content: {
              NavigationLink(destination: {
                VoteView()
              }, label: {
                HStack {
                  Spacer()
                  Text("New.vote.go")
                  Image(systemName: "arrow.right")
                  Spacer()
                }
              })
            })
          }
        } else {
          ContentUnavailableView {
            Label("New.unavailable", systemImage: "list.bullet")
          } description: {
            Text("New.unavailable.description")
          }
        }
      } else {
        List {
          Text("New.unavailable")
            .bold()
            .foregroundStyle(.secondary)
        }
      }
    }
  }
}

struct SingleNewFeature: View {
  @State var tintColorValues: [Any] = defaultColor
  @State var tintColor = Color(hue: defaultColor[0]/359, saturation: defaultColor[1]/100, brightness: defaultColor[2]/100)
  var symbol: String
  var title: LocalizedStringKey
  var description: LocalizedStringKey
  var body: some View {
    HStack {
      Image(systemName: symbol)
        .foregroundStyle(tintColor)
      VStack(alignment: .leading) {
        Text(title)
          .bold()
        Text(description)
          .font(.footnote)
      }
    }
    .multilineTextAlignment(.leading)
    .onAppear {
      if (UserDefaults.standard.array(forKey: "tintColor") ?? []).isEmpty {
        UserDefaults.standard.set(defaultColor, forKey: "tintColor")
      }
      tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? (defaultColor as [Any])
      tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
    }
  }
}

#Preview {
  NewFearturesView()
}
