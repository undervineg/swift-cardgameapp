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
    private var gameViewModel: GameViewModel! {
        didSet {
            gameViewModel.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        gameViewModel = GameViewModel()
        gameView = GameView(frame: view.frame, game: gameViewModel)
        gameViewModel.initialize()
        gameView.initialize()
    }

    var draggableCard: DraggableCard?

}

extension GameViewController: CardViewActionDelegate, RefreshActionDelegate {
    func canMove(_ cardViewModel: CardViewModel?, to location: Location?) -> Bool {
        if let cardViewModel = cardViewModel, let location = location {
            return gameViewModel.canMove(cardViewModel, to: location)
        }
        return false
    }

    func onCardViewDragBegan(gesture: UIPanGestureRecognizer) {
        guard let tappedView = gesture.view as? CardView else { return }
        self.draggableCard = DraggableCard(cardView: tappedView)
        if let belowCards = gameView.getCardViewsBelowIfNeeded(below: tappedView) {
            draggableCard?.setCardViewsBelow(belowCards)
        }
        tappedView.bringToFront()
        draggableCard?.cardViewsBelow?.forEach {
            $0.bringToFront()
        }
    }

    func onCardViewDragChanged(gesture: UIPanGestureRecognizer) {
        draggableCard?.translateCardViews(about: gesture.translation(in: gameView))
        gesture.setTranslation(.zero, in: gameView)
    }

    func onCardViewDragEnded(gesture: UIPanGestureRecognizer) {
        guard let tappedView = gesture.view as? CardView,
            let dropLocation = gameView.dropLocation(of: tappedView) else {
                onCardViewDragCancelled(gesture: gesture)
                return
        }

        let dropPosition = gameView.position(of: dropLocation)
        draggableCard?.drop(at: dropPosition)

        updateSuperview(of: tappedView, and: draggableCard?.cardViewsBelow, to: dropLocation)
        updateModel(of: tappedView, and: draggableCard?.cardViewsBelow, to: dropLocation)
    }

    func onCardViewDragCancelled(gesture: UIPanGestureRecognizer) {
        draggableCard?.reset()
    }

    func onCardViewDoubleTapped(tappedView: CardView) {
        guard let cardViewModel = tappedView.viewModel,
            let toLocation = gameViewModel.suitableLocation(for: cardViewModel) else { return }
        move(tappedView, to: toLocation, with: .up, animated: true)
    }

    func onSpareViewTapped(tappedView: CardView) {
        guard let cardViewModel = tappedView.viewModel,
            let toLocation = gameViewModel.suitableLocation(for: cardViewModel) else { return }
        move(tappedView, to: toLocation, with: .up, animated: true)
    }

    func onRefreshButtonTapped() {
        for card in gameView.wasteView.reversed() {
            move(card, to: .spare, with: .down, animated: true)
        }
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            gameViewModel.initialize()
            gameView.newGame(with: gameViewModel)
        }
    }

    // MARK: - PRIVATE

    private func move(_ cardView: CardView, to toLocation: Location, with faceState: FaceState, animated: Bool) {
        guard let cardViewModel = cardView.viewModel else { return }
        cardViewModel.turnOver(to: faceState)
        cardView.bringToFront()

        // tableau인 경우, 아래 붙어있는 카드들이 있으면 가져옴
        let cardViewsBelow = gameView.getCardViewsBelowIfNeeded(below: cardView) //, toLocation: toLocation)

        // 뷰 업데이트
        let animatableCardView = AnimatableCardView(cardView: cardView,
                                              cardViewsBelow: cardViewsBelow,
                                              endLocation: toLocation)
        animatableCardView.delegate = self
        animatableCardView.viewDelegate = self
        gameView.addSubview(animatableCardView)
        gameView.move(animatableCardView)
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

}

extension GameViewController: UpdateViewDelegate {
    func updateSuperview(of cardView: CardView, and cardViewsBelow: [CardView]?, to endLocation: Location?) {
        guard let endLocation = endLocation else { return }
        // 카드뷰가 속한 상위뷰 업데이트 (실제로는 gameView의 subview 임)
        var endView: CanLayCards?
        switch endLocation {
        case .spare: endView = gameView.spareView
        case .waste: endView = gameView.wasteView
        case .foundation(let index): endView = gameView.foundationViewContainer.at(index)
        case .tableau(let index): endView = gameView.tableauViewContainer.at(index)
        }
        cardView.move(toView: endView)
        cardViewsBelow?.forEach {
            $0.move(toView: endView)
        }
    }

    func updateModel(of cardView: CardView, and cardViewsBelow: [CardView]?, to endLocation: Location?) {
        guard let endLocation = endLocation else { return }
        // 모델 업데이트
        guard let fromLocation = cardView.viewModel?.location.value else { return }
        let prevEndLocation = endLocation
        switch endLocation {
        case .spare: refreshWaste()
        default:
            // 모델변경은 tableau인 경우 아래 카드까지 함께 처리하므로 클릭한 카드만 처리해주면 됨
            move(cardViewModel: cardView.viewModel!, from: fromLocation, to: endLocation)
        }
        // 모델 업데이트 후, 카드 뷰모델의 Location 데이터 업데이트
        cardView.viewModel?.updateLocation(to: prevEndLocation)
        cardViewsBelow?.forEach {
            $0.viewModel?.updateLocation(to: prevEndLocation)
        }
    }
}

extension GameViewController: GameCompleteDelegate {
    func showCompleteMessage() {
        print("done")
    }

}
