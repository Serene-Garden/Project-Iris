//
//  NewFearturesView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/7/7.
//

import SwiftUI

let alwaysShowDetailsVersion = "0.0.0"
let showDetails = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).hasSuffix(".0") || (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String) == alwaysShowDetailsVersion

struct NewFearturesView: View {
  var body: some View {
    if #available(watchOS 10, *) {
      TabView {
        NewFeaturesTitleView()
        if showDetails {
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
//  let showDetails = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).hasSuffix(".0")
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
//  let showDetails = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String).hasSuffix(".0")
  var body: some View {
    if showDetails {
      List {
        SingleNewFeature(symbol: "archivebox", title: "New.archive", description: "New.archive.description")
        SingleNewFeature(symbol: "puzzlepiece.extension", title: "New.extension", description: "New.extension.description")
        SingleNewFeature(symbol: "exclamationmark.bubble", title: "New.carina", description: "New.carina.description")
        SingleNewFeature(symbol: "sun.horizon", title: "New.appearance", description: "New.appearance.description")
        SingleNewFeature(symbol: "lock", title: "New.architecture", description: "New.architecture.description")
        SingleNewFeature(symbol: "megaphone", title: "New.bulletin", description: "New.bulletin.description")
      }
    } else {
      if #available(watchOS 10, *) {
        ContentUnavailableView {
          Label("New.unavailable", systemImage: "list.bullet")
        } description: {
          Text("New.unavailable.description")
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
