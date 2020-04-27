//
//  CanvasItemCellView.swift
//  CanvasDemo macOS
//
//  Created by scchn on 2020/4/26.
//  Copyright © 2020 vitiny. All rights reserved.
//

import AppKit

class CanvasItemCellView: NSTableCellView {
    
    @IBOutlet weak var button: NSButton!
    
    var clickHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.alignment = .left
    }
    
    func setUp(_ shape: Shape) {
        button.title = shape.rawValue.capitalized
    }
    
    @IBAction func buttonClicked(_ sender: NSButton) {
        clickHandler?()
    }
    
}
