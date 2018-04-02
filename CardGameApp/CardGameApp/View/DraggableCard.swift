//
//  DragInfo.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 3. 30..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

class DraggableCard: Movable {
    let cardView: CardView
    private(set) var cardViewsBelow: [CardView]? {
        willSet {
            resetInitialCenters()
            newValue?.forEach {
                $0.bringToFront()
                initialCenters.append($0.center)
            }
        }
    }
    private var initialCenter: CGPoint
    private(set) var initialCenters: [CGPoint] = []

    init(cardView: CardView) {
        self.cardView = cardView
        self.initialCenter = cardView.center
    }

    func drop(at dropPosition: CGPoint) {
        let movedGap = CGPoint(x: dropPosition.x - cardView.frame.origin.x,
                          y: dropPosition.y - cardView.frame.origin.y)
        cardView.frame.origin = dropPosition

        cardViewsBelow?.forEach {
            $0.frame.origin.x += movedGap.x
            $0.frame.origin.y += movedGap.y
        }
    }

    func setCardViewsBelow(_ cardViewsBelow: [CardView]) {
        self.cardViewsBelow = cardViewsBelow
    }

    func resetInitialCenters() {
        self.initialCenters = []
    }

    func reset() {
        cardView.center = initialCenter
        if let cardViewsBelow = self.cardViewsBelow {
            for (initialCenter, cardView) in zip(initialCenters, cardViewsBelow) {
                cardView.center = initialCenter
            }
        }
    }

    func translateCardViews(about translation: CGPoint) {
        cardView.center.x += translation.x
        cardView.center.y += translation.y
        cardViewsBelow?.forEach {
            $0.center.x += translation.x
            $0.center.y += translation.y
        }
    }
}
