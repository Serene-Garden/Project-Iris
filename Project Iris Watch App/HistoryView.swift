//
//  HistoryView.swift
//  Project Iris Watch App
//
//  Created by 雷美淳 on 2023/10/21.
//

import SwiftUI
import Foundation
import Cepheus

struct HistoryView: View {
  @State var history: [(String, Date, Int)] = []
  @State var showVisitingTime = false
  @State var actionsSheetIsDisplaying = false
  @State var searchContent = ""
  @State var historyInDate: [String: [(String, Date, Int)]] = [:]
  @State var historyDates: [String] = []
  @State var historyDatesAreExpanded: [String: Bool] = [:]
  @State var date: String = ""
  @State var tempArray: [(String, Date, Int)] = []
  @State var expansionCount = 0
  @State var clearTimeframe = -3600
  @State var isAlertPresented = false
  @State var lastHistoryID = UserDefaults.standard.integer(forKey: "lastHistoryID")
  let dateFormatter = DateFormatter()
  let timeFormatter = DateFormatter()
  let displayFormatter = DateFormatter()
  
  //For web accessing
  @AppStorage("isCookiesAllowed") var isCookiesAllowed = false
  @AppStorage("currentEngine") var currentEngine = 0
  @AppStorage("isPrivateModeOn") var isPrivateModeOn = false
  @State var engineLinks: [String] = defaultSearchEngineLinks as! [String]
  
  var body: some View {
    NavigationStack {
      if !historyDates.isEmpty {
        List {
          ForEach(0..<historyDates.count, id: \.self) { dateIndex in
            Section(content: {
              if historyDatesAreExpanded[historyDates[dateIndex]]! {
                ForEach(0..<historyInDate[historyDates[dateIndex]]!.count, id: \.self) { historyIndex in
                  Button(action: {
                    searchButtonAction(isPrivateModeOn: isPrivateModeOn, searchField: historyInDate[historyDates[dateIndex]]![historyIndex].0, isCookiesAllowed: isCookiesAllowed, searchEngine: engineLinks[currentEngine])
                  }, label: {
                    HStack {
                      Image(systemName: historyInDate[historyDates[dateIndex]]![historyIndex].0.isURL() ? "network" : "magnifyingglass")
                      Text(historyInDate[historyDates[dateIndex]]![historyIndex].0)
                        .lineLimit(2)
                      Spacer()
                      if showVisitingTime {
                        Text(timeFormatter.string(from: historyInDate[historyDates[dateIndex]]![historyIndex].1))
                          .foregroundStyle(.secondary)
                          .lineLimit(1)
                      }
                    }
                  })
                }
                .onDelete { deleteIndex in
                  for repeatIndex in 0..<history.count {
                    if historyInDate[historyDates[dateIndex]]![deleteIndex.first!].2 == history[repeatIndex].2 {
                      history.remove(at: repeatIndex)
                      break
                    }
                  }
                  updateHistory(history)
                  
                  //MARK: Updator
                  historyDates = []
                  historyInDate = [:]
                  historyDatesAreExpanded = [:]
                  var date: String = ""
                  var tempArray: [(String, Date, Int)] = []
                  var expansionCount = 0
                  for singleHistory in history {
                    date = dateFormatter.string(from: singleHistory.1)
                    tempArray = historyInDate[date] ?? []
                    tempArray.append((singleHistory.0, singleHistory.1, singleHistory.2))
            //        print(tempArray)
                    historyInDate.updateValue(tempArray, forKey: date)
                    if !historyDates.contains(date) {
                      historyDates.append(date)
                      historyDatesAreExpanded.updateValue((expansionCount < 3), forKey: date)
                      if expansionCount < 3 {
                        expansionCount += 1
                      }
                    }
                  }
                }
              }
            }, header: {
              HStack {
                Text(displayFormatter.string(from: dateFormatter.date(from: historyDates[dateIndex]) ?? Date.now))
                Spacer()
                Image(systemName: "chevron.forward")
                  .rotationEffect(Angle(degrees: historyDatesAreExpanded[historyDates[dateIndex]]! ? 90 : 0))
                  .overlay {
                    Rectangle()
                      .opacity(0.02)
                      .onTapGesture {
                        withAnimation {
                          historyDatesAreExpanded[historyDates[dateIndex]]!.toggle()
                        }
                      }
                  }
              }
              .font(.caption)
              .fontWeight(.medium)
            })
          }
        }
      } else {
        if #available(watchOS 10, *) {
          if history.isEmpty {
            ContentUnavailableView {
              Label("History.empty", systemImage: "clock")
            } description: {
              Text("History.empty.description")
            }
          } else {
            ContentUnavailableView {
              Label("History.search.empty", systemImage: "magnifyingglass")
            } description: {
              Text("History.search.empty.description")
            }
          }
        } else {
          Text("History.empty")
            .bold()
            .foregroundStyle(.secondary)
        }
      }
    }
    .navigationTitle("History")
    .onAppear {
      history = getHistory()
      engineLinks = (UserDefaults.standard.array(forKey: "engineLinks") ?? defaultSearchEngineLinks) as! [String]
      timeFormatter.dateFormat = "HH:mm"
      dateFormatter.dateFormat = "YYYY-MM-DD"
      displayFormatter.dateStyle = .medium
      displayFormatter.timeStyle = .none
      
      //MARK: Updator
      var date: String = ""
      var tempArray: [(String, Date, Int)] = []
      var expansionCount = 0
      for singleHistory in history {
        date = dateFormatter.string(from: singleHistory.1)
        tempArray = historyInDate[date] ?? []
        tempArray.append((singleHistory.0, singleHistory.1, singleHistory.2))
//        print(tempArray)
        historyInDate.updateValue(tempArray, forKey: date)
        if !historyDates.contains(date) {
          historyDates.append(date)
          historyDatesAreExpanded.updateValue((expansionCount < 3), forKey: date)
          if expansionCount < 3 {
            expansionCount += 1
          }
        }
      }
      
      if let legacyHistories = UserDefaults.standard.array(forKey: "HistoryLink") as? [String] {
        print("Legacy History Handling Program Toggled")
        for singleHistory in legacyHistories {
          history.insert((singleHistory, Date.now, lastHistoryID+1), at: 0)
          lastHistoryID += 1
          UserDefaults.standard.set(lastHistoryID, forKey: "lastHistoryID")
        }
        updateHistory(history)
        UserDefaults.standard.removeObject(forKey: "HistoryLink")
      }
    }
    .toolbar {
      if #available(watchOS 10, *) {
        ToolbarItem(placement: .topBarTrailing, content: {
          Button(action: {
            actionsSheetIsDisplaying = true
          }, label: {
            Image(systemName: searchContent.isEmpty ? "ellipsis": "rectangle.and.text.magnifyingglass")
          })
        })
      }
    }
    .sheet(isPresented: $actionsSheetIsDisplaying, content: {
      NavigationStack {
        List {
          Section("History.action-sheet.search") {
            CepheusKeyboard(input: $searchContent, prompt: "History.action-sheet.search.content")
          }
          .onChange(of: searchContent, perform: { value in
            //MARK: Updator
            historyDates = []
            historyInDate = [:]
            historyDatesAreExpanded = [:]
            for singleHistory in history {
              if searchContent.isEmpty ? true : (singleHistory.0.lowercased().contains(searchContent.lowercased())) {
                print(searchContent)
                date = dateFormatter.string(from: singleHistory.1)
                tempArray = historyInDate[date] ?? []
                tempArray.append((singleHistory.0, singleHistory.1, singleHistory.2))
                //        print(tempArray)
                historyInDate.updateValue(tempArray, forKey: date)
                if !historyDates.contains(date) {
                  historyDates.append(date)
                  historyDatesAreExpanded.updateValue((expansionCount < 3), forKey: date)
                  if expansionCount < 3 {
                    expansionCount += 1
                  }
                }
              }
            }
          })
          Section("History.action-sheet.time") {
            Toggle(isOn: $showVisitingTime, label: {
              Label("History.action-sheet.time.show", systemImage: "clock")
            })
          }
          Section("History.action-sheet.delete") {
            Picker("History.action-sheet.delete.timeframe", selection: $clearTimeframe, content: {
              Text("History.action-sheet.delete.timeframe.last-hour").tag(-3600)
              Text("History.action-sheet.delete.timeframe.today").tag(-86400)
              Text("History.action-sheet.delete.timeframe.today-and-yesterday").tag(-172800)
              Text("History.action-sheet.delete.timeframe.all").tag(Int32.min)
            })
            Button(action: {
              isAlertPresented = true
            }, label: {
              Label("History.action-sheet.delete.action", systemImage: "trash")
            })
            .foregroundStyle(.red)
            .alert("History.action-sheet.delete.alert", isPresented: $isAlertPresented, actions: {
              Button(role: .destructive, action: {
                var index = 0
                while index < history.count {
                  if Int(history[index].1.timeIntervalSinceNow) >= clearTimeframe {
                    history.remove(at: index)
                    updateHistory(history)
                  } else {
                    index += 1
                  }
                }
                if clearTimeframe == Int32.min {
                  UserDefaults.standard.set(0, forKey: "lastHistoryID")
                  lastHistoryID = 0
                }
              }, label: {
                HStack {
                  Text("History.action-sheet.delete.alert.confirm")
                  Spacer()
                }
              })
              Button(role: .cancel, action: {}, label: {
                Text("History.action-sheet.delete.alert.cancel")
              })
            }, message: {
              Text("History.action-sheet.delete.alert.message")
            })
          }
        }
      }
    })
  }
}

struct HistoryStructure: Codable {
  var content: String
  var time: Date
  var id: Int
}

@MainActor @discardableResult func updateHistory(_ history: [(String, Date, Int)]) -> Bool {
  let fileURL = getDocumentsDirectory().appendingPathComponent("historyData.txt")
  let historyStructures = history.map { HistoryStructure(content: $0.0, time: $0.1, id: $0.2) }
  
  do {
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted
    jsonEncoder.dateEncodingStrategy = .iso8601
    let jsonData = try jsonEncoder.encode(historyStructures)
    
    try jsonData.write(to: fileURL, options: .atomic)
    return true
  } catch {
    showTip(LocalizedStringResource(stringLiteral: error.localizedDescription), debug: true)
    return false
  }
}

@MainActor func getHistory() -> [(String, Date, Int)] {
  do {
    let fileURL = getDocumentsDirectory().appendingPathComponent("historyData.txt")
    let fileData = try Data(contentsOf: fileURL)
    
    let jsonDecoder = JSONDecoder()
    jsonDecoder.dateDecodingStrategy = .iso8601
    let historyStructures = try jsonDecoder.decode([HistoryStructure].self, from: fileData)
    
    let historyArray: [(String, Date, Int)] = historyStructures.map { ($0.content, $0.time, $0.id) }
    
    // 打印结果以确认
    return historyArray
  } catch {
    showTip(LocalizedStringResource(stringLiteral: error.localizedDescription), debug: true)
    return []
  }
}

struct HistoryPickerView: View {
  @Binding var pickerSheetIsDisplaying: Bool
  @Binding var historyLink: String
  @Binding var historyID: Int
  var acceptNonLinkHistory: Bool = true
  var action: () -> Void
  @State var history: [(String, Date, Int)] = []
  @State var historyInDate: [String: [(String, Date, Int)]] = [:]
  @State var historyDates: [String] = []
  @State var historyDatesAreExpanded: [String: Bool] = [:]
  @State var date: String = ""
  @State var tempArray: [(String, Date, Int)] = []
  @State var expansionCount = 0
  @State var clearTimeframe = -3600
  @State var isAlertPresented = false
  @State var lastHistoryID = UserDefaults.standard.integer(forKey: "lastHistoryID")
  let dateFormatter = DateFormatter()
  let timeFormatter = DateFormatter()
  let displayFormatter = DateFormatter()
  var body: some View {
    Group {
      if !historyDates.isEmpty {
        List {
          ForEach(0..<historyDates.count, id: \.self) { dateIndex in
            Section(content: {
              if historyDatesAreExpanded[historyDates[dateIndex]]! {
                ForEach(0..<historyInDate[historyDates[dateIndex]]!.count, id: \.self) { historyIndex in
                  Button(action: {
                    historyID = historyInDate[historyDates[dateIndex]]![historyIndex].2
                    historyLink = historyInDate[historyDates[dateIndex]]![historyIndex].0
                    action()
                    pickerSheetIsDisplaying = false
                  }, label: {
                    HStack {
                      Image(systemName: historyInDate[historyDates[dateIndex]]![historyIndex].0.isURL() ? "network" : "magnifyingglass")
                      Text(historyInDate[historyDates[dateIndex]]![historyIndex].0)
                        .lineLimit(2)
                      Spacer()
                      if historyID == historyInDate[historyDates[dateIndex]]![historyIndex].2 {
                        Image(systemName: "checkmark")
                      }
                    }
                  })
                  .disabled(!historyInDate[historyDates[dateIndex]]![historyIndex].0.isURL() && !acceptNonLinkHistory)
                }
              }
            }, header: {
              HStack {
                Text(displayFormatter.string(from: dateFormatter.date(from: historyDates[dateIndex]) ?? Date.now))
                Spacer()
                Image(systemName: "chevron.forward")
                  .rotationEffect(Angle(degrees: historyDatesAreExpanded[historyDates[dateIndex]]! ? 90 : 0))
                  .overlay {
                    Rectangle()
                      .opacity(0.02)
                      .onTapGesture {
                        withAnimation {
                          historyDatesAreExpanded[historyDates[dateIndex]]!.toggle()
                        }
                      }
                  }
              }
              .font(.caption)
              .fontWeight(.medium)
            })
          }
        }
      } else {
        if #available(watchOS 10, *) {
          if history.isEmpty {
            ContentUnavailableView {
              Label("History.empty", systemImage: "clock")
            } description: {
              Text("History.empty.description")
            }
          } else {
            ContentUnavailableView {
              Label("History.search.empty", systemImage: "magnifyingglass")
            } description: {
              Text("History.search.empty.description")
            }
          }
        } else {
          Text("History.empty")
            .bold()
            .foregroundStyle(.secondary)
        }
      }
    }
    .navigationTitle("History")
    .onAppear {
      history = getHistory()
      timeFormatter.dateFormat = "HH:mm"
      dateFormatter.dateFormat = "YYYY-MM-DD"
      displayFormatter.dateStyle = .medium
      displayFormatter.timeStyle = .none
      
      //MARK: Updator
      var date: String = ""
      var tempArray: [(String, Date, Int)] = []
      var expansionCount = 0
      for singleHistory in history {
        date = dateFormatter.string(from: singleHistory.1)
        tempArray = historyInDate[date] ?? []
        tempArray.append((singleHistory.0, singleHistory.1, singleHistory.2))
        //        print(tempArray)
        historyInDate.updateValue(tempArray, forKey: date)
        if !historyDates.contains(date) {
          historyDates.append(date)
          historyDatesAreExpanded.updateValue((expansionCount < 3), forKey: date)
          if expansionCount < 3 {
            expansionCount += 1
          }
        }
      }
    }
  }
}
