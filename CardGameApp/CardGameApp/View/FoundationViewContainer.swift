//
//  FoundationViewContainer.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 3. 23..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import UIKit

class FoundationViewContainer: UIView, Sequence {
    private var foundationViews: [FoundationView] = []
    private var config: ViewConfig
    let start: Int = 0

    convenience init(frame: CGRect, config: ViewConfig) {
        self.init(frame: frame)
        self.config = config
        configureFoundationViews()
    }

    override init(frame: CGRect) {
        config = ViewConfig(on: UIView())
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        config = ViewConfig(on: UIView())
        super.init(coder: aDecoder)
    }

    func makeIterator() -> ClassIteratorOf<FoundationView> {
        return ClassIteratorOf(self.foundationViews)
    }

    func removeAllCards() {
        foundationViews.forEach { $0.removeAllSubviews() }
    }

    func at(_ index: Int) -> FoundationView {
        return foundationViews[index]
    }

    private func configureFoundationViews() {
        (0..<config.foundationCount).forEach {
            let origin = CGPoint(x: CGFloat($0)*(config.cardSize.width+config.normalSpacing), y: 0)
            let foundationView = FoundationView(frame: CGRect(origin: origin, size: config.cardSize), index: $0)
            foundationViews.append(foundationView)
            addSubview(foundationView)
        }
    }

}
