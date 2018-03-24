//
//  MovableCardView.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 2. 14..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

class AnimatableCard {
    private(set) var cardView: CardView
    private(set) var startPosition: CGPoint = .zero
    private(set) var endLocation: Location

    init(cardView: CardView, endLocation: Location) {
        self.cardView = cardView
        self.endLocation = endLocation
        cardView.handleCertainView { [unowned self] gameView in
            self.startPosition = cardView.convert(cardView.frame.origin, to: gameView)
        }
    }

    func animateToMove(to endPosition: CGPoint) {
        let translateTransform =
            self.cardView.transform.translatedBy(x: endPosition.x-startPosition.x, y: endPosition.y-startPosition.y)
        // waste->spare 또는 spare->waste 처럼 뒤집어야 하는 경우 옵션 설정
        var option: UIViewAnimationOptions = .curveEaseIn
        if case Location.spare = cardView.viewModel!.location.value {
            option = .transitionFlipFromRight
        } else if case Location.waste = cardView.viewModel!.location.value, case Location.spare = endLocation {
            option = .transitionFlipFromLeft
        }
        UIView.transition(with: cardView, duration: 0.3, options: option, animations: {
            // 현재 이동중인 카드를 맨 앞으로.
            self.cardView.bringToFront()
            self.cardView.transform = translateTransform
        }, completion: { _ in
            self.cardView.handleCertainView(execute: { gameView in
                switch self.endLocation {
                case .spare: self.cardView.move(toView: gameView.spareView)
                case .waste: self.cardView.move(toView: gameView.wasteView)
                case .foundation(let index): self.cardView.move(toView: gameView.foundationViewContainer.at(index))
                case .tableau(let index): self.cardView.move(toView: gameView.tableauViewContainer.at(index))
                }
            })
        })
    }

}
