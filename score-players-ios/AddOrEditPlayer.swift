//
//  AddOrEditPlayer.swift
//  score-players-ios
//
//  Created by mgarciate on 29/10/24.
//

import SwiftUI

struct AddOrEditPlayer: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var player: PlayerInfo
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nombre del jugador", text: $player.name)
                    Picker("Valoración", selection: $player.score) {
                        ForEach(PlayerScoreType.allCases, id: \.self) { score in
                            Text(score.string)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section("Goles") {
                    ForEach($player.goals) { goal in
                        HStack {
                            Picker(goal.wrappedValue.key.string, selection: goal.value) {
                                ForEach(0...9, id: \.self) {
                                    Text("\($0)")
                                }
                            }
                        }
                    }
                }
                Section("Otras puntuaciones") {
                    Picker("Asistencias", selection: $player.assists) {
                        ForEach(0...9, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    Picker("Penaltis parados por portero", selection: $player.penaltySavesGoalkeeper) {
                        ForEach(0...9, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    Picker("Penalti fallado por jugador", selection: $player.missedPenaltyPlayer) {
                        ForEach(0...9, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    Toggle("Portería a cero portero (tiene que jugar todo el partido)", isOn: $player.cleanSheetGoalkeeper)
                    Toggle("Expulsión por doble amarilla", isOn: $player.yellowCardRedCardExpulsion)
                    Toggle("Expulsión por tarjeta roja", isOn: $player.redCardExpulsion)
                }
                Section("Más información") {
                    TextField("Comentarios", text: $player.comments, axis: .vertical)
                        .lineLimit(5...10)
                }
            }
            .navigationTitle("Datos jugador")
        }
    }
    
    private func delete(at offsets: IndexSet) {
        player.goals.remove(atOffsets: offsets)
    }
}

#Preview {
    AddOrEditPlayer(player: .constant(PlayerInfo.dummyData[0]))
}
