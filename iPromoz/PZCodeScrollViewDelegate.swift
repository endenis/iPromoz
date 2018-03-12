//
//  PZCodeScrollViewDelegate.swift
//  iPromoz
//
//  Created by Denis Engels on 12/03/2018.
//  Copyright © 2018 Denis Engels. All rights reserved.
//

import Cocoa

protocol PZCodeScrollViewDelegate {
    func importCodesFromCsvUrl(_ csvUrl: URL)
}
