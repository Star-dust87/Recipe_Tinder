//
//  CardStackView.swift
//  Recipe_Tinder
//
//  Created by Sebastian C on 1/28/26.
//

import SwiftUI

struct CardStackView: View {
    @StateObject var viewModel = CardsViewModel(service: CardService())
    
    var body: some View {
        ZStack {
            ForEach(viewModel.cardModels) { card in
                CardView(viewModel: viewModel, model: card)
            }
        }
        .onChange(of: viewModel.cardModels) { oldValue, newValue in
            print("DEBUG: Old value count is \(oldValue.count)")
            print("DEBUG: New value count is \(newValue.count)")
        }
    }
}

#Preview {
    CardStackView()
}
