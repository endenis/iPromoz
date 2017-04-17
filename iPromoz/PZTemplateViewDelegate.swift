//
//  PZTemplateViewDelegate.swift
//  iPromoz
//
//  Created by Denis Engels on 17/04/2017.
//  Copyright © 2017 endenis. All rights reserved.
//

import Cocoa

protocol PZTemplateViewDelegate {
    func nothingToDoState()
    func workingWithATemplateState(_ templateUrl: URL)
    func updateLabelPositionRatio(_ point: CGPoint)
}
