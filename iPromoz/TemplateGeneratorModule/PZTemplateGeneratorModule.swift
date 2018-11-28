import Cocoa

struct PZTemplateGenerator {
    typealias Model = PZTemplateGeneratorModelProtocol
    typealias View = PZTemplateGeneratorViewProtocol
    typealias Presenter = PZTemplateGeneratorPresenterProtocol
}

protocol PZTemplateGeneratorModelProtocol: class {

    var originalImageSize: NSSize? { get set }
    var colorSelected: NSColor? { get set }
    var textSizeSelected: CGFloat { get set }
    var templateUrl: URL? { get set }
    var alignmentCoefficientSelected: CGFloat { get set }
    var screenBounds: CGRect { get }
    func getOriginalImageRatio() -> CGFloat?
}

protocol PZTemplateGeneratorViewProtocol: class {

}

protocol PZTemplateGeneratorPresenterProtocol {

    func onImageAdded(templateUrl: URL)
    func onGenerateButtonTapped(hiddenLabel: PZTemplateLabel?, ratioX: CGFloat, ratioY: CGFloat, texts: [String])
    func onColorSelected(color: NSColor)
    func onAlignmentControlSelected(sender: NSSegmentedControl)
    func onDisplayedTextUpdated(fontSize: CGFloat)
}
