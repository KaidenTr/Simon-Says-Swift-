//
//  CustomizationView.swift
//  KaidenTran-FinalProject
//
//  Created by macOS on 12/18/24.
//

import SwiftUI

struct CustomizationView: View {
    @Binding var selectedTileSet: TileSet

    var body: some View {
        VStack {
            Text("Choose Your Tile Set")
                .font(.title)
                .padding()

            ForEach(TileSet.allCases, id: \.self) { tileSet in
                Button(action: {
                    selectedTileSet = tileSet
                }) {
                    HStack {
                        ForEach(tileSet.imageNames, id: \.self) { imageName in
                            Image(imageName)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(5)
                        }
                    }
                }
                .padding()
                .background(selectedTileSet == tileSet ? Color.gray : Color.clear)
                .cornerRadius(10)
                .disabled(tileSet == .custom1 && !CustomizationView.isCustomTileUnlocked())
            }

            if !CustomizationView.isCustomTileUnlocked() {
                Text("Unlock custom tiles by reaching 10 steps!")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding()
            }

            Spacer()
        }
        .padding()
    }

    static func isCustomTileUnlocked() -> Bool {
        let highestStep = UserDefaults.standard.integer(forKey: "HighestStep")
        return highestStep >= 5 // requirement
    }
}

enum TileSet: CaseIterable, Equatable {
    case `default`
    case custom1

    var imageNames: [String] {
        switch self {
        case .default:
            return ["red", "green", "blue", "yellow"]
        case .custom1:
            return ["Eevee", "Lucario", "Magikarp", "PsyDuck", "Snorlax"]
        }
    }
}

struct CustomizationView_Previews: PreviewProvider {
    static var previews: some View {
        CustomizationView(selectedTileSet: .constant(.default))
    }
}





