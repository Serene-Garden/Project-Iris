//
//  SettingsSearchView.swift
//  Project Iris
//
//  Created by ThreeManager785 on 10/3/24.
//

import Cepheus
import SwiftUI


//MARK: --- Search ---

struct SettingsSearchView: View {
  @State var engineNames: [String] = defaultSearchEngineNames as! [String]
  @State var engineLinks: [String] = defaultSearchEngineLinks as! [String]
  @State var engineNameIsEditable: [Bool] = defaultSearchEngineEditable as! [Bool]
  @AppStorage("currentEngine") var currentEngine = 0
  @AppStorage("secondaryEngine") var secondaryEngine = 1
  @State var showEditTips = true
  @State var displayingURL: AttributedString = ""
  @State var highlightRange: Range<AttributedString.Index>? = nil
  @State var editingEngineLink = ""
  @State var isIrisKeyIncludedInLink = true
  @State var isLinkValid = true
  @State var editingEngineName = ""
  @State var isAddingSearchEngine = false
  var body: some View {
    List {
      ForEach(0..<engineNames.count, id: \.self) { index in
        NavigationLink(destination: {
          List {
            NavigationLink(destination: {
              List {
                CepheusKeyboard(input: engineNameIsEditable[index] ? $engineNames[index] : .constant(String(localized: LocalizedStringResource(stringLiteral: engineNames[index]))), prompt: "Settings.search.edit.name")
                  .disabled(!engineNameIsEditable[index])
                  .foregroundStyle(engineNameIsEditable[index] ? .primary : .secondary)
                CepheusKeyboard(input: $editingEngineLink, prompt: "Settings.search.edit.link", autoCorrectionIsEnabled: false)
                if !isLinkValid {
                  Label("Settings.search.edit.error.invalid-link", systemImage: "exclamationmark.circle")
                    .foregroundStyle(.red)
                }
                if editingEngineLink.isEmpty {
                  Label("Settings.search.edit.tips.iris-required", systemImage: "character.magnify")
                } else if !isIrisKeyIncludedInLink {
                  Label("Settings.search.edit.warning.iris-missing", systemImage: "questionmark.circle")
                    .foregroundStyle(.yellow)
                }
                if engineNames[index].isEmpty {
                  Label("Settings.search.edit.tips.empty-name", systemImage: "questionmark.circle")
                    .foregroundStyle(.yellow)
                }
                if !engineNames[index].isEmpty && isLinkValid && isIrisKeyIncludedInLink {
                  Label("Settings.search.edit.tips.perfect", systemImage: "checkmark.circle")
                    .foregroundStyle(.green)
                }
              }
              .onAppear {
                editingEngineLink = engineLinks[index]
              }
              .onDisappear {
                if isLinkValid {
                  engineLinks[index] = editingEngineLink
                  UserDefaults.standard.set(engineNames, forKey: "engineNames")
                  UserDefaults.standard.set(engineLinks, forKey: "engineLinks")
                  UserDefaults.standard.set(engineNameIsEditable, forKey: "engineNameIsEditable")
                } else {
                  showTip("Settings.interface.home.list.failed-saving", symbol: "exclamationmark.circle")
                }
              }
              .onChange(of: editingEngineLink, perform: { value in
                isIrisKeyIncludedInLink = editingEngineLink.lowercased().contains("\\iris")
                isLinkValid = editingEngineLink.isURL()
              })
              .navigationTitle("Settings.search.edit.title")
            }, label: {
              HStack {
                VStack(alignment: .leading) {
                  Text(engineNameIsEditable[index] ? engineNames[index] : String(localized: LocalizedStringResource(stringLiteral: engineNames[index])))
                    .bold()
                  Text(displayingURL)
                    .font(.caption2)
                    .fontDesign(.monospaced)
                    .onAppear {
                      displayingURL = AttributedString(engineLinks[index].lowercased())
                      highlightRange = displayingURL.range(of: "\\iris")
                      if highlightRange != nil {
                        displayingURL[highlightRange!].inlinePresentationIntent = .stronglyEmphasized
                        displayingURL[highlightRange!].foregroundColor = .blue
                      }
                    }
                }
                Spacer()
                Image(systemName: "pencil")
                  .foregroundStyle(.secondary)
              }
            })
            Button(action: {
              currentEngine = index
            }, label: {
              Label(currentEngine == index ? "Settings.search.edit.default.true" : "Settings.search.edit.default.false", systemImage: currentEngine == index ? "star.fill" : "star")
            })
            Button(action: {
              secondaryEngine = index
            }, label: {
              Label(secondaryEngine == index ? "Settings.search.edit.secondary.true" : "Settings.search.edit.secondary.false", systemImage: "option")
            })
            if !engineLinks[index].lowercased().contains("\\iris") {
              Label("Settings.search.edit.warning.iris-missing", systemImage: "questionmark.circle")
                .foregroundStyle(.yellow)
            }
          }
          .navigationTitle(engineNameIsEditable[index] ? engineNames[index] : String(localized: LocalizedStringResource(stringLiteral: engineNames[index])))
        }, label: {
          HStack {
            Text(engineNameIsEditable[index] ? engineNames[index] : String(localized: LocalizedStringResource(stringLiteral: engineNames[index])))
            Spacer()
            if currentEngine == index {
              Image(systemName: "checkmark")
            } else if secondaryEngine == index {
              Image(systemName: "option")
            }
          }
        })
      }
      .onDelete(perform: { index in
        engineNames.remove(atOffsets: index)
        engineLinks.remove(atOffsets: index)
        engineNameIsEditable.remove(atOffsets: index)
        if currentEngine == (index.first)! {
          currentEngine = 0
        } else if currentEngine > (index.first)! {
          currentEngine -= 1
        }
      })
      .onMove(perform: { oldIndex, newIndex in
        engineNames.move(fromOffsets: oldIndex, toOffset: newIndex)
        engineLinks.move(fromOffsets: oldIndex, toOffset: newIndex)
        engineNameIsEditable.move(fromOffsets: oldIndex, toOffset: newIndex)
      })
    }
    .navigationTitle("Settings.search")
    .toolbar {
      if #available(watchOS 10.0, *) {
        ToolbarItem(placement: .bottomBar) {
          HStack {
            VStack(alignment: .leading) {
              Text("Settings.search.edit-tip.title")
              Text("Settings.search.edit-tip.subtitle")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .opacity(!showEditTips ? 0 : 1)
            .animation(.easeInOut(duration: 0.3))
            .background {
              Color.clear.background(Material.ultraThin)
                .opacity(!showEditTips ? 0 : 0.8)
                .animation(.easeInOut(duration: 0.3))
                .brightness(0.1)
                .saturation(2.5)
                .frame(width: screenWidth+100, height: 100)
                .blur(radius: 10)
                .offset(y: 20)
            }
            Spacer()
            Button(action: {
              isAddingSearchEngine = true
            }, label: {
              Image(systemName: "plus")
            })
          }
        }
      }
    }
    .onAppear {
      //      homeList = UserDefaults.standard.array(forKey: "homeList")!
      engineNames = (UserDefaults.standard.array(forKey: "engineNames") ?? defaultSearchEngineNames) as! [String]
      engineLinks = (UserDefaults.standard.array(forKey: "engineLinks") ?? defaultSearchEngineLinks) as! [String]
      engineNameIsEditable = (UserDefaults.standard.array(forKey: "engineNameIsEditable") ?? defaultSearchEngineEditable) as! [Bool]
      Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
        showEditTips = false
      }
    }
    .onDisappear {
      UserDefaults.standard.set(engineNames, forKey: "engineNames")
      UserDefaults.standard.set(engineLinks, forKey: "engineLinks")
      UserDefaults.standard.set(engineNameIsEditable, forKey: "engineNameIsEditable")
    }
    .sheet(isPresented: $isAddingSearchEngine, content: {
      SettingsSearchNewPresetsView(engineNames: $engineNames, engineLinks: $engineLinks, engineNameIsEditable: $engineNameIsEditable)
    })
  }
}

struct SettingsSearchNewPresetsView: View {
  @Binding var engineNames: [String]
  @Binding var engineLinks: [String]
  @Binding var engineNameIsEditable: [Bool]
  @State var presetAvailable: Bool = false
  @State var foundPreset: Int = 0
  @Environment(\.presentationMode) var presentationMode
  var body: some View {
    NavigationStack {
      if presetAvailable {
        List {
          NavigationLink(destination: {
            List {
              ForEach(0..<defaultSearchEngineLinks.count, id: \.self) { index in
                DismissButton(action: {
                  engineNames.append(defaultSearchEngineNames[index] as! String)
                  engineLinks.append(defaultSearchEngineLinks[index] as! String)
                  engineNameIsEditable.append(false)
                  UserDefaults.standard.set(engineNames, forKey: "engineNames")
                  UserDefaults.standard.set(engineLinks, forKey: "engineLinks")
                  UserDefaults.standard.set(engineNameIsEditable, forKey: "engineNameIsEditable")
                  showTip("Settings.search.new.succeed", symbol: "checkmark")
                  presentationMode.wrappedValue.dismiss()
                }, label: {
                  Text(String(localized: LocalizedStringResource(stringLiteral: defaultSearchEngineNames[index] as! String)))
                })
                .disabled(engineLinks.contains(defaultSearchEngineLinks[index] as! String))
              }
            }
            .navigationTitle("Settings.search.new.presets")
          }, label: {
            Label("Settings.search.new.presets", systemImage: "list.star")
          })
          NavigationLink(destination: {
            SettingsSearchNewCustomizeView(engineNames: $engineNames, engineLinks: $engineLinks, engineNameIsEditable: $engineNameIsEditable)
              .onDisappear {
                presentationMode.wrappedValue.dismiss()
              }
          }, label: {
            Label("Settings.search.new.customize", systemImage: "rectangle.and.pencil.and.ellipsis")
          })
        }
      } else {
        SettingsSearchNewCustomizeView(engineNames: $engineNames, engineLinks: $engineLinks, engineNameIsEditable: $engineNameIsEditable)
      }
    }
    .onAppear {
      for presetLink in defaultSearchEngineLinks {
        for engineLink in engineLinks {
          if engineLink.contains(presetLink as! String) {
            foundPreset += 1
            break
          }
        }
      }
      presetAvailable = (foundPreset < defaultSearchEngineLinks.count)
    }
  }
}

struct SettingsSearchNewCustomizeView: View {
  @Binding var engineNames: [String]
  @Binding var engineLinks: [String]
  @Binding var engineNameIsEditable: [Bool]
  @State var editingEngineName: String = ""
  @State var editingEngineLink: String = ""
  @State var isLinkValid = true
  @State var isIrisKeyIncludedInLink = false
  var body: some View {
    List {
      CepheusKeyboard(input: $editingEngineName, prompt: "Settings.search.edit.name")
      CepheusKeyboard(input: $editingEngineLink, prompt: "Settings.search.edit.link", autoCorrectionIsEnabled: false)
      if editingEngineLink.isEmpty {
        Label("Settings.search.edit.tips.iris-required", systemImage: "character.magnify")
      } else if !isIrisKeyIncludedInLink {
        Label("Settings.search.edit.warning.iris-missing", systemImage: "questionmark.circle")
          .foregroundStyle(.yellow)
      }
      if !isLinkValid {
        Label("Settings.search.edit.error.invalid-link", systemImage: "exclamationmark.circle")
          .foregroundStyle(.red)
      }
      if editingEngineName.isEmpty {
        Label("Settings.search.edit.tips.empty-name", systemImage: "questionmark.circle")
          .foregroundStyle(.yellow)
      }
      if !editingEngineName.isEmpty && isLinkValid && isIrisKeyIncludedInLink {
        Label("Settings.search.edit.tips.perfect", systemImage: "checkmark.circle")
          .foregroundStyle(.green)
      }
    }
    .onAppear {
      editingEngineName = ""
      editingEngineLink = ""
      isLinkValid = false
    }
    .onChange(of: editingEngineLink, perform: { value in
      isIrisKeyIncludedInLink = editingEngineLink.lowercased().contains("\\iris")
      isLinkValid = editingEngineLink.isURL()
    })
    .toolbar {
      if #available(watchOS 10, *) {
        ToolbarItemGroup(placement: .topBarTrailing, content: {
          DismissButton(action: {
            engineNames.append(editingEngineName)
            engineLinks.append(editingEngineLink)
            engineNameIsEditable.append(true)
            UserDefaults.standard.set(engineNames, forKey: "engineNames")
            UserDefaults.standard.set(engineLinks, forKey: "engineLinks")
            UserDefaults.standard.set(engineNameIsEditable, forKey: "engineNameIsEditable")
            showTip("Settings.search.new.succeed", symbol: "checkmark")
          }, label: {
            Label("Settings.interface.home.toolbar.done", systemImage: "checkmark")
            //        Spacer()
            //        Image(systemName: "chevron.backward")
            //          .foregroundStyle(.secondary)
          })
          .disabled(!isLinkValid)
        })
      }
    }
    .navigationTitle("Settings.search.new.title")
  }
}
