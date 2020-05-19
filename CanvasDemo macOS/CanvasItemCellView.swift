//
//  CanvasItemCellView.swift
//  CanvasDemo macOS
//
//  Created by scchn on 2020/4/26.
//  Copyright © 2020 vitiny. All rights reserved.
//

import AppKit

import Canvas

extension CanvasView.BuiltInItemType: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .line:            return "LineItem"
        case .polyline:        return "PolylineItem"
        case .circle:          return "CircleItem"
        case .rect:            return "RectItem"
        case .basicProtractor: return "BasicProtractorItem"
        case .exProtractor:    return "ExProtractorItem"
        case .advProtractor:   return "AdvProtractorItem"
        case .pencil:          return "PencilItem"
        case .pencilSingle:    return "PencilItem2"
        }
    }
    
}

class CanvasItemCellView: NSTableCellView {
    
    @IBOutlet weak var button: NSButton!
    
    var clickHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.alignment = .left
    }
    
    func setUp(_ item: CanvasView.BuiltInItemType) {
        button.title = "\(item)"
    }
    
    @IBAction func buttonClicked(_ sender: NSButton) {
        clickHandler?()
    }
    
}
