//
//  GameViewController.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 2. 12..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    private(set) var gameView: GameView! {
        didSet {
            gameView.delegate = self
            gameView.refreshDelegate = self
            view.addSubview(gameView)
        }
    }
    private var gameViewModel: GameViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        gameViewModel = GameViewModel()
        gameView = GameView(frame: view.frame, game: gameViewModel)
        gameViewModel.initialize()
        gameView.initialize()
    }
}

extension GameViewController: CardViewActionDelegate, RefreshActionDelegate {
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            gameViewModel.initialize()
            gameView.newGame(with: gameViewModel)
        }
    }

    func onCardViewDoubleTapped(tappedView: CardView) {
        moveToSuitableLocation(tappedView, toLocation: nil, shouldTurnOverFaceTo: .up)
    }

    func onSpareViewTapped(tappedView: CardView) {
        moveToSuitableLocation(tappedView, toLocation: nil, shouldTurnOverFaceTo: .up)
    }

    func onRefreshButtonTapped() {
        for card in gameView.wasteView.reversed() {
            moveToSuitableLocation(card, toLocation: .spare, shouldTurnOverFaceTo: .down)
        }
    }

    // MARK: - PRIVATE

    private func moveToSuitableLocation(_ cardView: CardView, toLocation: Location?, shouldTurnOverFaceTo faceState: FaceState) {
        guard let cardViewModel = cardView.viewModel else { return }
        cardViewModel.turnOver(to: faceState)

        // 탭한 뷰의 적정 위치 찾은 후
        if let suitableLocation =
            (toLocation == nil) ? gameViewModel.suitableLocation(for: cardViewModel) : toLocation {
            guard gameViewModel.canMove(cardViewModel, to: suitableLocation) else { return }
            cardView.bringToFront()
            let cardViewsBelow = getCardViewsBelowIfNeeded(below: cardView, toLocation: suitableLocation)
            // 뷰 업데이트
            let movableCardView = MovableCardView(cardView: cardView,
                                                  cardViewsBelow: cardViewsBelow,
                                                  endLocation: suitableLocation)
            movableCardView.delegate = self
            gameView.move(movableCardView)
        }
    }

    private func getCardViewsBelowIfNeeded(below tappedCardView: CardView, toLocation: Location) -> [CardView]? {
        guard let fromLocation = tappedCardView.viewModel?.location.value else { return nil }
        var cardViewsBelow: [CardView]?
        if case let Location.tableau(index) = fromLocation {
            guard case Location.tableau = toLocation else { return nil }
            let tableauView = gameView.tableauViewContainer.at(index)
            cardViewsBelow = tableauView.below(cardView: tappedCardView)
        }
        return cardViewsBelow
    }

}

extension GameViewController: UpdateModelDelegate {
    func refreshWaste() {
        gameViewModel.refreshWaste()
    }

    func move(cardViewModel: CardViewModel, from startLocation: Location, to endLocation: Location) {
        let fromLocation = cardViewModel.location.value
        gameViewModel.move(cardViewModel: cardViewModel, from: fromLocation, to: endLocation)
    }

    func update(cardViewModel: CardViewModel, to endLocation: Location) {
        cardViewModel.location.value = endLocation
    }

}
