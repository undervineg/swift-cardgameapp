//
//  MovableCardView.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 2. 14..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

class AnimatableCardView: UIView, Movable, CanFindGameView {
    weak var viewDelegate: UpdateViewDelegate?
    weak var delegate: UpdateModelDelegate?
    let cardView: CardView
    let fromLocation: Location
    private(set) var cardViewsBelow: [CardView]?
    private(set) var endLocation: Location?
    private var startPosition: CGPoint = .zero

    convenience init() {
        self.init(cardView: CardView(frame: .zero), cardViewsBelow: nil, endLocation: nil)
    }
    
    convenience init(cardView: CardView, cardViewsBelow: [CardView]?) {
        self.init(cardView: cardView, cardViewsBelow: cardViewsBelow, endLocation: nil)
    }

    convenience init(cardView: CardView, endLocation: Location?) {
        self.init(cardView: cardView, cardViewsBelow: nil, endLocation: endLocation)
    }

    init(cardView: CardView, cardViewsBelow: [CardView]?, endLocation: Location?) {
        self.cardView = cardView
        self.cardViewsBelow = cardViewsBelow
        self.fromLocation = cardView.viewModel!.location.value
        self.endLocation = endLocation
        self.startPosition = cardView.frame.origin

        let wholeHeight = (cardViewsBelow == nil) ? cardView.frame.height : cardView.frame.height+cardView.frame.height*0.3*(CGFloat(cardViewsBelow!.count)-1)
        let wholeSize = CGSize(width: cardView.frame.width, height: wholeHeight)
        super.init(frame: CGRect(origin: startPosition, size: wholeSize))

        addSubview(cardView)
        cardViewsBelow?.forEach { addSubview($0) }
    }

    required init?(coder aDecoder: NSCoder) {
        self.cardView = CardView(frame: .zero)
        self.fromLocation = .spare
        self.endLocation = .spare
        super.init(coder: aDecoder)
    }
}

extension AnimatableCardView {
    override func layoutSubviews() {
        self.cardView.frame.origin = self.frame.origin
        self.cardViewsBelow?.enumerated().forEach {
            $0.element.frame.origin =
                CGPoint(x: self.cardView.frame.origin.x,
                        y: self.cardView.frame.origin.y+CGFloat($0.offset+1)*cardView.frame.height*0.3)
        }

        self.cardView.removeFromSuperview()
        self.superview?.addSubview(self.cardView)
        self.cardViewsBelow?.forEach {
            $0.removeFromSuperview()
            self.superview?.addSubview($0)
        }
        self.removeFromSuperview()

        super.layoutSubviews()
    }

    func animateToMove(to endPosition: CGPoint) {
        let translateTransform = self.transform.translatedBy(x: endPosition.x-startPosition.x,
                                                             y: endPosition.y-startPosition.y)
        UIView.transition(with: self, duration: 0.3, options: .curveEaseOut, animations: {
            self.bringToFront()
            self.transform = translateTransform
            self.layoutIfNeeded()
        }, completion: { _ in
            self.viewDelegate?.updateSuperview(of: self.cardView, and: self.cardViewsBelow, to: self.endLocation)
            self.viewDelegate?.updateModel(of: self.cardView, and: self.cardViewsBelow, to: self.endLocation)
        })
    }

    private func bringToFront() {
        superview?.bringSubviewToFront(self)
    }
}
