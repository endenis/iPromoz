//
//  PZCodeTableView.swift
//  iPromoz
//
//  Created by Denis Engels on 21/07/2017.
//  Copyright © 2017 Denis Engels. All rights reserved.
//

import Cocoa
import CSwiftV

class PZCodeScrollView: NSScrollView {

    override func awakeFromNib() {
        setup()
    }

    let draggingOptions = [NSPasteboardURLReadingContentsConformToTypesKey:["public.comma-separated-values-text"]]

    func setup() {
        register(forDraggedTypes: [NSURLPboardType])
    }

    func isDropAcceptable(_ draggingInfo: NSDraggingInfo) -> Bool {
        let pasteBoard = draggingInfo.draggingPasteboard()
        return pasteBoard.canReadObject(forClasses: [NSURL.self], options: draggingOptions)
    }

    var isDragging = false {
        didSet {
            if !isDragging {
                // delegate?.nothingToDoState()
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
        // delegate?.nothingToDoState()
        if let fileUrl = extractFileUrl(draggingInfo) {
            Swift.print(fileUrl)
            let codes = extractCodesFromUrl(fileUrl)
            // delegate?.workingWithATemplateState(templateUrl)
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

    func extractCodesFromUrl(_ fileUrl: URL) -> [String] {
        do {
            let csvString = try String(contentsOf: fileUrl, encoding: String.Encoding.utf8)
            let csv = CSwiftV(with: csvString)
            let codes = csv.rows.filter { $0.count == 1 && $0.first != nil }.map { $0.first! }
            Swift.print(codes)
            return codes
        }
        catch {
            Swift.print("Error while reading the CSV file")
            return []
        }
    }
}
