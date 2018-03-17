//
//  PZTemplateView.swift
//  iPromoz
//

import Cocoa

class PZTemplateView: NSImageView {

    var delegate: PZTemplateViewDelegate?
    var surroundingLineWidth: CGFloat = 4.2
    let backgroundImageName = "wave_pattern"

    override func draw(_ dirtyRect: NSRect) {
        let patternImage: NSImage! = NSImage(named: self.backgroundImageName)
        let backgroundColor = NSColor(patternImage: patternImage)

        super.draw(dirtyRect)
        
        layer?.backgroundColor = backgroundColor.cgColor

        if isDragging {
            drawBlueInsideBorders()
        }
    }

    func drawBlueInsideBorders() {
        NSColor.selectedControlColor.set()
        let path = NSBezierPath(rect: bounds)
        path.lineWidth = surroundingLineWidth
        path.stroke()
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
                // it's possible to reset some state here. Not sure if needed.
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
        if let templateUrl = extractTemplateUrl(draggingInfo) {
            delegate?.nothingToDoState()
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

    func imageResizeRatio() -> CGFloat? {
        if let imageSize = image?.size {
            if (NSWidth(bounds) > imageSize.width && NSHeight(bounds) > imageSize.height) {
                return 1.0
            }
            else {
                let xRatio = NSWidth(bounds)  / imageSize.width
                let yRatio = NSHeight(bounds) / imageSize.height
                return [xRatio, yRatio].min()
            }
        }
        return nil
    }

    func imageRectangle() -> NSRect? {
        if let imageSize = image?.size, let ratio = imageResizeRatio() {
            var rect: NSRect = NSRect.init()
            rect.size.width  = round(imageSize.width  * ratio)
            rect.size.height = round(imageSize.height * ratio)
            let preciseX = round((bounds.size.width  - rect.size.width)  / 2.0)
            let preciseY = round((bounds.size.height - rect.size.height) / 2.0)
            rect.origin.x = (preciseX >= 0) ? preciseX : 0
            rect.origin.y = (preciseY >= 0) ? preciseY : 0
            return rect
        }
        return nil
    }

}
