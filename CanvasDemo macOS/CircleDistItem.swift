//
//  CircleDistItem.swift
//  CanvasDemo macOS
//
//  Created by Chen on 2020/4/23.
//  Copyright © 2020 vitiny. All rights reserved.
//

import Foundation
import CoreGraphics

import Canvas

class CirdistItem: FixedItem {
    
    private(set) var circles: [Circle] = []
    
    private var line: Line = .zero
    
    required init() {
        super.init(elements: 4, segments: 2)
    }
    
    override func push(_ point: CGPoint) {
        if grid.last == nil { super.push(point) }
        super.push(point)
    }
    
    override func push(toNextSegment point: CGPoint) {
        if grid.last?.count == elements {
            super.push(toNextSegment: point)
            super.push(point)
        }
        else {
            super.push(toNextSegment: point)
        }
    }
    
    func updateCircles() {
        circles = grid
            .filter{ $0.count == elements }
            .enumerated()
            .compactMap { i, points in
                let circle = Circle(points[1], points[2], points[3])
                if let center = circle?.center {
                    super.update(point: center, at: StackIndex(element: 0, segment: i))
                } else {
                    super.update(point: .zero, at: StackIndex(element: 0, segment: i))
                }
                return circle
        }
        if circles.count == 2 {
            line = Line(from: circles[0].center, to: circles[1].center)
        }
    }
    
    override func update(point: CGPoint, at index: StackIndex) {
        if index.element == 0 && isCompleted {
            let old = grid[index.segment][index.element]
            let dx = point.x - old.x, dy = point.y - old.y
            beginBatchUpdate()
            for (i, point) in grid[index.segment][1...].enumerated() {
                let newPoint = CGPoint(x: point.x + dx, y: point.y + dy)
                let index = StackIndex(element: i + 1, segment: index.segment)
                super.update(point: newPoint, at: index)
            }
            commitBatchUpdate()
        } else {
            super.update(point: point, at: index)
        }
    }
    
    override func linePathWrappers() -> [PathWrapper] {
        grid
            .filter { $0.count > 1 }
            .map { Array($0.dropFirst()) }
            .enumerated()
            .map { i, points in
                PathWrapper(method: .dash(lineWidth, 2, [2, 2]), color: strokeColor) { $0.addLines(between: points) }
            }
    }
    
    override func mainPathWrappers() -> [PathWrapper] {
        updateCircles()
        
        let circlePaths = circles.map { circle in
            PathWrapper(method: .stroke(lineWidth), color: strokeColor) { $0.addCircle(circle) }
        }
        let centerPaths = circles.map { circle in
            PathWrapper(method: .fill, color: strokeColor) {
                var circle = circle
                circle.radius = 3
                $0.addCircle(circle)
            }
        }
        let linePaths = (line == .zero ? [] : [PathWrapper(method: .stroke(lineWidth), color: strokeColor) { $0.addLine(line) }])
        
        return circlePaths + centerPaths + linePaths
    }
    
    override func canSelect(by rect: CGRect) -> Bool {
        circles.contains { $0.canSelect(by: rect) } || (line == .zero ? false : line.canSelect(by: rect))
    }
    
}
