//
//  TimeGridView.swift
//  GymRat
//
//  Created by Alik on 1/11/26.
//

import SwiftUI

struct TimeGridView: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<24) { hour in
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: hourHeight)
                    .overlay(
                        Text("\(hour):00")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.leading, 2),
                        alignment: .topLeading
                    )
            }
        }
    }
}
