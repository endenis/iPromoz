//
//  PZTemplateView.swift
//  iPromoz
//

import Cocoa

protocol PZTemplateViewDelegate {
    func nothingToDoState()
    func workingWithATemplateState(_ templateUrl: URL)
}

class PZTemplateView: NSImageView {

    var delegate: PZTemplateViewDelegate?
    var surroundingLineWidth: CGFloat = 4.2
    
    override func draw(_ dirtyRect: NSRect) {
        let patternImage: NSImage! = NSImage(named: "wave_pattern")
        let backgroundColor = NSColor(patternImage: patternImage)

        super.draw(dirtyRect)
        
        layer?.backgroundColor = backgroundColor.cgColor

        if isDragging {
            NSColor.selectedControlColor.set()
            let path = NSBezierPath(rect: bounds)
            path.lineWidth = surroundingLineWidth
            path.stroke()
        }
    }

    override func awakeFromNib() {
        setup()
    }

    let draggingOptions = [NSPasteboardURLReadingContentsConformToTypesKey:NSImage.imageTypes()]

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
                delegate?.nothingToDoState()
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
        delegate?.nothingToDoState()
        if let templateUrl = extractTemplateUrl(draggingInfo) {
            delegate?.workingWithATemplateState(templateUrl)
            return true
        }
        return false
    }

    func extractTemplateUrl(_ draggingInfo: NSDraggingInfo) -> URL? {
        if let imageUrls = draggingInfo.draggingPasteboard().readObjects(forClasses: [NSURL.self], options:draggingOptions) as? [URL] {
            if imageUrls.count > 0 {
                return imageUrls.first
            }
        }
        return nil
    }

}