//
//  VoteView.swift
//  Project Iris Watch App
//
//  Created by ThreeManager785 on 9/15/24.
//

import SwiftUI

struct VoteView: View {
  @AppStorage("tintVoteViolet") var tintVoteViolet = false
  @AppStorage("tintVoteGreen") var tintVoteGreen = false
  @State var violetTotal = -1
  @State var greenTotal = -1
  let violet = Color(hue: 275/359, saturation: 40/100, brightness: 100/100)
  let green = Color(hue: 140/359, saturation: 39/100, brightness: 100/100)
  var body: some View {
    if #available(watchOS 10, *) {
      List {
        Section(content: {
          VStack(alignment: .leading) {
            Text("Vote.tint.title")
              .bold()
              .font(.title3)
            Text("Vote.tint.subtitle")
              .font(.caption)
          }
          .listRowBackground(Color.clear)
          Button(action: {
            if !tintVoteViolet {
              tintVoteViolet = true
              fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/add/garden_iris_vote_tint_violet_positives/\(Date.now.timeIntervalSince1970)") { result in
                switch result {
                  case .success(let content):
                    violetTotal += 1
                  case .failure(let error):
                    showTip("Vote.unsuccessful")
                }
              }
              if tintVoteGreen {
                fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/add/garden_iris_vote_tint_green_negatives/\(Date.now.timeIntervalSince1970)") { result in
                  switch result {
                    case .success(let content):
                      greenTotal -= 1
                    case .failure(let error):
                      showTip("Vote.unsuccessful")
                  }
                }
                tintVoteGreen = false
              }
            }
          }, label: {
            HStack {
              Circle()
                .frame(width: 10)
                .foregroundStyle(violet)
              VStack(alignment: .leading) {
                HStack {
                  Text("Vote.tint.violet")
                }
                if violetTotal >= 0 && (violetTotal+greenTotal) > 0 {
                  Text("Vote.stats.total.\(violetTotal)").foregroundStyle(.secondary)  + Text(verbatim: " - ").foregroundStyle(.secondary) + Text(verbatim: "\(Int((Double(violetTotal)/Double(violetTotal+greenTotal))*100))%").foregroundStyle(.secondary)
                }
              }
              Spacer()
              if tintVoteViolet {
                Image(systemName: "checkmark")
              }
            }
          })
          .swipeActions(content: {
            Button(action: {
              UserDefaults.standard.set([violet.HSB_values().0, violet.HSB_values().1, violet.HSB_values().2], forKey: "tintColor")
            }, label: {
              Image(systemName: "arrow.down.circle")
            })
          })
          
          Button(action: {
            if !tintVoteGreen {
              tintVoteGreen = true
              fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/add/garden_iris_vote_tint_green_positives/\(Date.now.timeIntervalSince1970)") { result in
                switch result {
                  case .success(let content):
                    greenTotal += 1
                  case .failure(let error):
                    showTip("Vote.unsuccessful")
                }
              }
              if tintVoteViolet {
                fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/add/garden_iris_vote_tint_violet_negatives/\(Date.now.timeIntervalSince1970)") { result in
                  switch result {
                    case .success(let content):
                      violetTotal -= 1
                    case .failure(let error):
                      showTip("Vote.unsuccessful")
                  }
                }
                tintVoteViolet = false
              }
            }
          }, label: {
            HStack {
              Circle()
                .frame(width: 10)
                .foregroundStyle(green)
              VStack(alignment: .leading) {
                HStack {
                  Text("Vote.tint.green")
                }
                if greenTotal >= 0 && (violetTotal+greenTotal) > 0 {
                    Text("Vote.stats.total.\(greenTotal)").foregroundStyle(.secondary)  + Text(verbatim: " - ").foregroundStyle(.secondary) + Text(verbatim: "\(Int((Double(greenTotal)/Double(violetTotal+greenTotal))*100))%").foregroundStyle(.secondary)
                  }
              }
              Spacer()
              if tintVoteGreen {
                Image(systemName: "checkmark")
              }
            }
          })
          .swipeActions(content: {
            Button(action: {
              UserDefaults.standard.set([green.HSB_values().0, green.HSB_values().1, green.HSB_values().2], forKey: "tintColor")
            }, label: {
              Image(systemName: "arrow.down.circle")
            })
          })
        }, footer: {
          VStack(alignment: .leading) {
            Text("Vote.tint.footer")
            Text("Vote.tint.own-voice")
          }
        })
      }
      .navigationTitle("Vote")
      .containerBackground(tintVoteViolet ? violet.gradient : (tintVoteGreen ? green.gradient : Color.black.gradient), for: .navigation)
      .onAppear {
        var violetPositives = -1
        var violetNegatives = -1
        var greenPositives = -1
        var greenNegatives = -1
        fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/get/garden_iris_vote_tint_violet_positives") { result in
          switch result {
            case .success(let content):
              violetPositives = content.numberOfOccurrencesOf("\\n")
              fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/get/garden_iris_vote_tint_violet_negatives") { result in
                switch result {
                  case .success(let content):
                    violetNegatives = content.numberOfOccurrencesOf("\\n")
                    fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/get/garden_iris_vote_tint_green_positives") { result in
                      switch result {
                        case .success(let content):
                          greenPositives = content.numberOfOccurrencesOf("\\n")
                          fetchWebPageContent(urlString: "https://fapi.darock.top:65535/analyze/get/garden_iris_vote_tint_green_negatives") { result in
                            switch result {
                              case .success(let content):
                                greenNegatives = content.numberOfOccurrencesOf("\\n")
                                if violetPositives != -1 && violetNegatives != -1 && greenPositives != -1 && greenNegatives != -1 {
                                  violetTotal = violetPositives - violetNegatives
                                  greenTotal = greenPositives - greenNegatives
                                }
                              case .failure(let error):
                                greenNegatives = -1
                            }
                          }
                        case .failure(let error):
                          greenPositives = -1
                      }
                    }
                  case .failure(let error):
                    violetNegatives = -1
                }
              }
            case .failure(let error):
              violetPositives = -1
          }
        }
      }
    }
  }
}
