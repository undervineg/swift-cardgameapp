//
//  Movable.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 4. 2..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import Foundation

protocol Movable {
    var cardView: CardView { get }
    var cardViewsBelow: [CardView]? { get }
}
