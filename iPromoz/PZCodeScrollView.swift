//
//  PZCodeTableView.swift
//  iPromoz
//
//  Created by Denis Engels on 21/07/2017.
//  Copyright © 2017 Denis Engels. All rights reserved.
//

import Cocoa

class PZCodeScrollView: NSScrollView {

    var delegate: PZCodeScrollViewDelegate?
    @IBOutlet var controller: PZTemplateViewController?

    override func awakeFromNib() {
        setup()
    }

    let draggingOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:["public.comma-separated-values-text"]]

    func setup() {
        let NSURLPboardType = NSPasteboard.PasteboardType(kUTTypeURL as String) // workaround for swift 4
        registerForDraggedTypes([NSURLPboardType])
        delegate = controller
    }

    func isDropAcceptable(_ draggingInfo: NSDraggingInfo) -> Bool {
        let pasteBoard = draggingInfo.draggingPasteboard()
        return pasteBoard.canReadObject(forClasses: [NSURL.self], options: draggingOptions)
    }

    var isDragging = false {
        didSet {
            if !isDragging {
                // change state?
            }
            needsDisplay = true
        }
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let accepting = isDropAcceptable(sender)
        self.isDragging = accepting
        return accepting ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.isDragging = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return isDropAcceptable(sender)
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        self.isDragging = false
        if let fileUrl = extractFileUrl(draggingInfo) {
            Swift.print(fileUrl)
            delegate?.importCodesFromCsvUrl(fileUrl)
            return true
        }
        return false
    }

    func extractFileUrl(_ draggingInfo: NSDraggingInfo) -> URL? {
        if let fileUrls = draggingInfo.draggingPasteboard().readObjects(forClasses: [NSURL.self], options:draggingOptions) as? [URL] {
            if fileUrls.count > 0 {
                return fileUrls.first
            }
        }
        return nil
    }

}
