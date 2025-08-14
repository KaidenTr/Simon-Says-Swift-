//
//  ContentView.swift
//  KaidenTran-FinalProject
//
//  Created by macOS on 12/17/24.
//


import SwiftUI

struct ContentView: View {
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var currentStep = 0
    @State private var isUserTurn = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var highestStep = UserDefaults.standard.integer(forKey: "HighestStep")
    @State private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    @State private var currentScore = 0
    @State private var difficulty: Difficulty = .normal
    @State private var flashIndex: Int? = nil
    @State private var showCustomization = false
    @State private var selectedTileSet: TileSet = .default

    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case normal = "Normal"
        case hard = "Hard"
        
        var colors: [Color] {
            switch self {
            case .easy:
                return [.red, .green, .blue]
            case .normal:
                return [.red, .green, .blue, .yellow]
            case .hard:
                return [.red, .green, .blue, .yellow, .purple]
            }
        }
    }

    var body: some View {
        VStack {
            Text("Simon Says")
                .font(.largeTitle)
                .padding()

            ForEach(0..<3) { row in
                HStack {
                    ForEach(0..<2) { col in
                        if row * 2 + col < difficulty.colors.count {
                            Button(action: {
                                if isUserTurn {
                                    userTapped(row * 2 + col)
                                }
                            }) {
                                if selectedTileSet == .default {
                                    // Show color rectangles for the default tile set
                                    Rectangle()
                                        .fill(flashIndex == row * 2 + col ? difficulty.colors[row * 2 + col].opacity(0.5) : difficulty.colors[row * 2 + col])
                                        .frame(width: 100, height: 100)
                                        .padding(10)
                                } else {
                                    // Show images for the custom tile set
                                    Image(selectedTileSet.imageNames[row * 2 + col])
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .padding(10)
                                        .opacity(flashIndex == row * 2 + col ? 0.5 : 1.0)
                                }
                            }
                        }
                    }
                }
            }


            Text("Current Score: \(currentScore)")
                .padding()
            
            Text("Highest Step: \(highestStep)")
                .padding()
            
            Text("High Score: \(highScore)")
                .padding()

            Picker("Difficulty", selection: $difficulty) {
                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Button(action: startGame) {
                Text("Start Game")
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Button(action: {
                showCustomization = true
            }) {
                Text("Go to Customization")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .sheet(isPresented: $showCustomization) {
            CustomizationView(selectedTileSet: $selectedTileSet)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Game Over"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func startGame() {
        sequence = []
        userSequence = []
        currentStep = 0
        currentScore = 0
        isUserTurn = false
        addStep()
    }

    func addStep() {
        sequence.append(Int.random(in: 0..<difficulty.colors.count))
        playSequence()
    }

    func playSequence() {
        isUserTurn = false
        currentStep = 0

        for (index, step) in sequence.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.6) {
                flashColor(step)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(sequence.count) * 0.6) {
            isUserTurn = true
        }
    }





    func flashColor(_ index: Int) {
        flashIndex = index
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            flashIndex = nil
        }
    }


    func userTapped(_ index: Int) {
        userSequence.append(index)

        if userSequence[currentStep] != sequence[currentStep] {
            gameOver()
            return
        }

        currentStep += 1
        currentScore += 1

        if currentStep == sequence.count {
            userSequence = []

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                addStep()
            }
        }
    }


    func gameOver() {
        let score = sequence.count - 1
        if score > highestStep {
            highestStep = score
            UserDefaults.standard.set(highestStep, forKey: "HighestStep")
        }
        if currentScore > highScore {
            highScore = currentScore
            UserDefaults.standard.set(highScore, forKey: "HighScore")
        }
        alertMessage = "You reached \(score) steps!"
        showAlert = true
        isUserTurn = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


