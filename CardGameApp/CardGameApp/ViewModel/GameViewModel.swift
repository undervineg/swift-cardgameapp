//
//  GameViewModel.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 2. 12..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import Foundation

class GameViewModel: GameCompleteDelegate {
    weak var delegate: GameCompleteDelegate?
    private var game: Game
    private(set) var spareViewModel: CardStackPresentable
    private(set) var wasteViewModel: CardStackPresentable
    private(set) var foundationViewModels: FoundationViewModels
    private(set) var tableauViewModels: TableauViewModels

    init() {
        game = Game()
        spareViewModel = SpareViewModel()
        wasteViewModel = WasteViewModel()
        foundationViewModels = FoundationViewModels()
        tableauViewModels = TableauViewModels()
        foundationViewModels.delegate = self
    }

    // MARK: - Update Models

    func initialize() {
        game.new()
        initializeViewModels()
        bindModels()
    }

    func isGameDone() -> Bool {
        return game.isGameDone()
    }

    func refreshWaste() {
        game.refreshWaste()
    }

    func suitableLocation(for cardViewModel: CardViewModel) -> Location? {
        if case Location.spare = cardViewModel.location.value {
            return .waste
        }
        guard let suitableLocation = game.suitableLocation(for: cardViewModel.card) else { return nil }
        // 만약 목적지의 마지막 카드가 뒤집힌 카드라면 전달하지 않는다.
        if case let Location.tableau(index) = suitableLocation {
            if let lastCard = tableauViewModels.at(index).cardViewModels.last, lastCard.status.value == .down {
                return nil
            }
        }
        return suitableLocation
    }

    func canMove(_ cardViewModel: CardViewModel, to endLocation: Location) -> Bool {
        return game.canMove(cardViewModel.card, to: endLocation)
    }

    func move(cardViewModel: CardViewModel, from startLocation: Location, to endLocation: Location) {
        game.move(cardsFrom: cardViewModel.card, from: startLocation, to: endLocation)
    }

    // MARK: - Private Methods

    private func initializeViewModels() {
        spareViewModel = SpareViewModel(game.spare)
        wasteViewModel = WasteViewModel(game.waste)
        foundationViewModels = FoundationViewModels(game.foundations)
        tableauViewModels = TableauViewModels(game.tableaus)
    }

    private func bindModels() {
        foundationViewModels.bind(with: game.foundations)
        game.spare.cards.bind { [unowned self] in
            self.game.spare.isAdded ? self.spareViewModel.append($0) : self.spareViewModel.remove()
        }
        game.waste.cards.bind { [unowned self] in
            self.game.waste.isAdded ? self.wasteViewModel.append($0) : self.wasteViewModel.remove()
        }
        tableauViewModels.bind(with: game.tableaus)
    }

    func showCompleteMessage() {
        delegate?.showCompleteMessage()
    }

}
