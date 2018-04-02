//
//  UpdateViewDelegate.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 4. 2..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import Foundation

protocol UpdateViewDelegate: class {
    func updateSuperview(of cardView: CardView, and cardViewsBelow: [CardView]?, to endLocation: Location?)
    func updateModel(of cardView: CardView, and cardViewsBelow: [CardView]?, to endLocation: Location?)
}
