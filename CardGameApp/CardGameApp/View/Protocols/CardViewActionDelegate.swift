//
//  CardViewActionDelegate.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 2. 13..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

protocol CardViewActionDelegate: class {
    func onSpareViewTapped(tappedView: CardView)

    func onCardViewDoubleTapped(tappedView: CardView)

    func onCardViewDragBegan(gesture: UIPanGestureRecognizer)

    func onCardViewDragChanged(gesture: UIPanGestureRecognizer)

    func onCardViewDragEnded(gesture: UIPanGestureRecognizer)

    func onCardViewDragCancelled(gesture: UIPanGestureRecognizer)

    func canMove(_ cardViewModel: CardViewModel?, to location: Location?) -> Bool
}
