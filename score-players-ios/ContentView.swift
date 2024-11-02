//
//  ContentView.swift
//  score-players-ios
//
//  Created by mgarciate on 29/10/24.
//

import SwiftUI

enum PlayerScoreType: Int, CaseIterable {
    case s00_45 = -4
    case s46_49 = -3
    case s50_57 = -2
    case s58_59 = -1
    case s60_61 = 0
    case s62_63 = 1
    case s64_65 = 2
    case s66_67 = 3
    case s68_69 = 4
    case s70_71 = 5
    case s72_73 = 6
    case s74_75 = 7
    case s76_77 = 8
    case s78_79 = 9
    case s80_84 = 10
    case s85_89 = 11
    case s90_94 = 12
    case s95_99 = 13
    case s10 = 14
    
    var string: String {
        switch self {
        case .s00_45:
            "0.0 – 4.5"
        case .s46_49:
            "4.6 – 4.9"
        case .s50_57:
            "5.0 – 5.7"
        case .s58_59:
            "5.8 – 5.9"
        case .s60_61:
            "6.0 – 6.1"
        case .s62_63:
            "6.2 – 6.3"
        case .s64_65:
            "6.4 – 6.5"
        case .s66_67:
            "6.6 – 6.7"
        case .s68_69:
            "6.8 – 6.9"
        case .s70_71:
            "7.0 – 7.1"
        case .s72_73:
            "7.2 – 7.3"
        case .s74_75:
            "7.4 – 7.5"
        case .s76_77:
            "7.6 – 7.7"
        case .s78_79:
            "7.8 – 7.9"
        case .s80_84:
            "8.0 – 8.4"
        case .s85_89:
            "8.5 – 9.4"
        case .s90_94:
            "9.0 – 9.4"
        case .s95_99:
            "9.5 – 9.9"
        case .s10:
            "10.0"
        }
    }
}

enum GoalType: Int, CaseIterable {
    case ownGoal = -2
    case forwardOrPenalty = 3
    case midfielder = 4
    case defender = 5
    case goalkeeper = 6
    
    var string: String {
        switch self {
        case .ownGoal:
            "Propia puerta"
        case .forwardOrPenalty:
            "Delantero o penalty"
        case .midfielder:
            "Centrocampista"
        case .defender:
            "Defensa"
        case .goalkeeper:
            "Portero"
        }
    }
}

struct Goal: Identifiable, Hashable {
    let id = UUID()
    var key: GoalType
    var value: Int
}

struct PlayerInfo: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var score: PlayerScoreType
    var goals: [Goal]
    var assists: Int
    var penaltySavesGoalkeeper: Int
    var missedPenaltyPlayer: Int
    var cleanSheetGoalkeeper: Bool
    var yellowCardRedCardExpulsion: Bool
    var redCardExpulsion: Bool
    var comments: String
    
    static func buildEmpty() -> PlayerInfo {
        PlayerInfo(name: "", score: .s00_45, goals: GoalType.allCases.map { Goal(key: $0, value: 0) }, assists: 0, penaltySavesGoalkeeper: 0, missedPenaltyPlayer: 0, cleanSheetGoalkeeper: false, yellowCardRedCardExpulsion: false, redCardExpulsion: false, comments: "")
    }
}

extension PlayerInfo {
    var goalPoints: Int {
        var points = 0
        goals.forEach {
            points += $0.key.rawValue * $0.value
        }
        return points
    }
    
    static var dummyData: [PlayerInfo] {
        let goals = GoalType.allCases.map {
            let goals = $0 == .forwardOrPenalty ? 2 : 0
            return Goal(key: $0, value: goals)
        }
        return [
            PlayerInfo(name: "Player 1", score: .s62_63, goals: goals, assists: 1, penaltySavesGoalkeeper: 0, missedPenaltyPlayer: 1, cleanSheetGoalkeeper: false, yellowCardRedCardExpulsion: false, redCardExpulsion: false, comments: ""),
            PlayerInfo(name: "Player 2", score: .s62_63, goals: goals, assists: 1, penaltySavesGoalkeeper: 0, missedPenaltyPlayer: 1, cleanSheetGoalkeeper: false, yellowCardRedCardExpulsion: false, redCardExpulsion: false, comments: "")
        ]
    }
}

struct ContentView: View {
    @State var players: [PlayerInfo]
    @State private var csvInfo: String = ""
    @State private var isSettingsPresented = false
    @AppStorage("promptPrefix") var promptPrefix: String = SettingsView.prompt
    
    var body: some View {
        NavigationView {
            ZStack {
                if players.isEmpty {
                    ContentUnavailableView("No hay jugadores", systemImage: "figure.soccer", description: Text("Puedes añadir jugadores pulsando sobre el icono + arriba a la derecha"))
                        .padding()
                } else {
                    VStack {
                        List($players, editActions: .delete) { player in
                            NavigationLink(destination: AddOrEditPlayer(player: player),
                                           label: {
                                Text(!player.wrappedValue.name.isEmpty ? player.wrappedValue.name : "Añadir información o eliminar")
                            })
                        }
                        .listStyle(.inset)
                        Text(csvInfo)
                        ShareLink(item: csvInfo) {
                            Label("Generate prompt", systemImage: "bolt.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                    }
                }
            }
            .navigationTitle("Jugadores")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        players.append(PlayerInfo.buildEmpty())
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Button {
                        isSettingsPresented.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .onChange(of: players) { oldValue, newValue in
                let players = players.filter { !$0.name.isEmpty }
                csvInfo = "\(promptPrefix)\n\("Nombre del jugador;Valoración;Puntos por goles;Asistencias;Penaltis parados por el portero;Penaltis fallados;Portero no encaja goles;Expulsión por doble amarilla;Expulsión por roja directa")\n"
                players.forEach { player in
                    let csvLine: String = [
                        player.name,
                        "\(player.score.rawValue)",
                        "\(player.goalPoints)",
                        "\(player.assists)",
                        "\(player.penaltySavesGoalkeeper)",
                        "\(player.missedPenaltyPlayer)",
                        "\(player.cleanSheetGoalkeeper)",
                        "\(player.yellowCardRedCardExpulsion)",
                        "\(player.redCardExpulsion)",
                        player.comments,
                    ].joined(separator: ";")
                    csvInfo += "\(csvLine)\n"
                }
            }
            .fullScreenCover(isPresented: $isSettingsPresented) {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView(players: PlayerInfo.dummyData)
}
