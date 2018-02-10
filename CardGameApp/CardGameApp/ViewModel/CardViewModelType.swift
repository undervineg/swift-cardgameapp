//
//  CardViewModelType.swift
//  CardGameApp
//
//  Created by 심 승민 on 2018. 2. 8..
//  Copyright © 2018년 심 승민. All rights reserved.
//

import Foundation
import UIKit

protocol CardViewModelType {
    var image: UIImage { get }
    func turnOver(toFrontFace frontFaceToBeUp: Bool)
}
