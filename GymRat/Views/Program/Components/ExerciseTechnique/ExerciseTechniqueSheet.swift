//
//  ExerciseTechniqueSheet.swift
//  GymRat
//
//  Created by Alik on 3/29/26.
//

import SwiftUI

struct ExerciseTechniqueSheet: View {
    let seed: ExerciseStore.ExerciseSeed
    @Environment(\.dismiss) var dismiss

    private func imageURL(_ index: Int) -> URL? {
        guard let key = seed.exerciseDBKey else { return nil }
        let base = "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises"
        return URL(string: "\(base)/\(key)/\(index).jpg")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if seed.exerciseDBKey != nil {
                        // Две картинки
                        VStack(spacing: 12) {
                            AsyncImage(url: imageURL(0)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray5))
                                    .overlay(ProgressView())
                            }

                            AsyncImage(url: imageURL(1)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(12)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemGray5))
                                    .overlay(ProgressView())
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        // Нет картинок — показываем иконку
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "figure.run")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                            )
                            .padding(.horizontal)
                    }

                    // Мышцы
                    VStack(alignment: .leading, spacing: 8) {
                        Text("muscles_section")
                            .font(.headline)
                        HStack(spacing: 8) {
                            ForEach(seed.muscles, id: \.self) { muscle in
                                Text(MuscleGroupDisplay.localizedLabel(for: muscle))
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor.opacity(0.15))
                                    .foregroundColor(.accentColor)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(seed.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("done_button") { dismiss() }
                }
            }
        }
    }
}
