//
//  NewFearturesView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2024/7/7.
//

import SwiftUI

struct NewFearturesView: View {
  var body: some View {
    if #available(watchOS 10, *) {
      TabView {
        NewFeaturesTitleView()
        NewFeaturesListView()
      }
      .tabViewStyle(.verticalPage)
    } else {
      ScrollView {
        NewFeaturesTitleView()
        NewFeaturesListView()
      }
    }
  }
}

struct NewFeaturesTitleView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text("New.title.\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)")
          .bold()
          .font(.largeTitle)
        Label("New.title.scroll", systemImage: "chevron.down")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
    }
  }
}

struct NewFeaturesListView: View {
  var body: some View {
    List {
      SingleNewFeature(symbol: "doc.text.image", title: "New.2.0.0.a.customization.title", description: "New.2.0.0.a.customization.description")
      SingleNewFeature(symbol: "lock.shield", title: "New.2.0.0.a.passcode.title", description: "New.2.0.0.a.passcode.description")
      SingleNewFeature(symbol: "gear", title: "New.2.0.0.a.settings.title", description: "New.2.0.0.a.settings.description")
      SingleNewFeature(symbol: "magnifyingglass", title: "New.2.0.0.a.search.title", description: "New.2.0.0.a.search.description")
      SingleNewFeature(symbol: "fleuron", title: "New.2.0.0.a.credit.title", description: "New.2.0.0.a.credit.description")
      SingleNewFeature(symbol: "globe.europe.africa", title: "New.2.0.0.a.globalization.title", description: "New.2.0.0.a.globalization.description")
      SingleNewFeature(symbol: "sparkles", title: "New.2.0.0.a.easter-egg.title", description: "New.2.0.0.a.easter-egg.description")
      Text("New.2.0.0.b.tip")
      if #available(watchOS 11, *) {
        Text("New.2.0.0.a.tip.os11")
      }
    }
  }
}

struct SingleNewFeature: View {
  @State var tintColorValues: [Any] = [275, 40, 100]
  @State var tintColor = Color(hue: 275/359, saturation: 40/100, brightness: 100/100)
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
        UserDefaults.standard.set([275, 40, 100], forKey: "tintColor")
      }
      tintColorValues = UserDefaults.standard.array(forKey: "tintColor") ?? [275, 40, 100]
      tintColor = Color(hue: (tintColorValues[0] as! Double)/359, saturation: (tintColorValues[1] as! Double)/100, brightness: (tintColorValues[2] as! Double)/100)
    }
  }
}

#Preview {
  NewFearturesView()
}
