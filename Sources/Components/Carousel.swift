//
//  Carousel.swift
//  PortalView
//
//  Created by Cristian Ames on 4/17/17.
//  Copyright © 2017 Guido Marucci Blas. All rights reserved.
//

import Foundation
import UIKit

public enum ZipListShiftOperation {
    
    case left(count: UInt)
    case right(count: UInt)
    
}

public extension ZipList {
    
    func execute(shiftOperation: ZipListShiftOperation) -> ZipList<Element>? {
        switch shiftOperation {
        case .left(let count):
            return self.shiftLeft(count: count)
        case .right(let count):
            return self.shiftRight(count: count)
        }
    }
    
}

public struct CarouselProperties<MessageType> {
    
    public var items: ZipList<CarouselItemProperties<MessageType>>?
    public var showsScrollIndicator: Bool
    public var isSnapToCellEnabled: Bool
    public var onSelectionChange: (ZipListShiftOperation) -> MessageType?
    
    // Layout properties
    public var itemsWidth: UInt
    public var itemsHeight: UInt
    public var minimumInteritemSpacing: UInt
    public var minimumLineSpacing: UInt
    public var sectionInset: SectionInset
    
    fileprivate init(
        items: ZipList<CarouselItemProperties<MessageType>>?,
        showsScrollIndicator: Bool = false,
        isSnapToCellEnabled: Bool = false,
        itemsWidth: UInt,
        itemsHeight: UInt,
        minimumInteritemSpacing: UInt = 0,
        minimumLineSpacing: UInt = 0,
        sectionInset: SectionInset = .zero,
        selected: UInt = 0,
        onSelectionChange: @escaping (ZipListShiftOperation) -> MessageType? = { _ in .none }) {
        self.items = items
        self.showsScrollIndicator = showsScrollIndicator
        self.isSnapToCellEnabled = isSnapToCellEnabled
        self.itemsWidth = itemsWidth
        self.itemsHeight = itemsHeight
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.sectionInset = sectionInset
        self.onSelectionChange = onSelectionChange
    }
    
    public func map<NewMessageType>(_ transform: @escaping (MessageType) -> NewMessageType) -> CarouselProperties<NewMessageType> {
        return CarouselProperties<NewMessageType>(
            items: self.items.map { $0.map { $0.map(transform) } },
            showsScrollIndicator: self.showsScrollIndicator,
            isSnapToCellEnabled: self.isSnapToCellEnabled,
            itemsWidth: self.itemsWidth,
            itemsHeight: self.itemsHeight,
            minimumInteritemSpacing: self.minimumInteritemSpacing,
            minimumLineSpacing: self.minimumLineSpacing,
            sectionInset: self.sectionInset,
            onSelectionChange: { self.onSelectionChange($0).map(transform) }
        )
    }
    
}

public struct CarouselItemProperties<MessageType> {
    
    public typealias Renderer = () -> Component<MessageType>
    
    public let onTap: MessageType?
    public let renderer: Renderer
    public let identifier: String
    
    fileprivate init(
        onTap: MessageType?,
        identifier: String,
        renderer: @escaping Renderer) {
        self.onTap = onTap
        self.renderer = renderer
        self.identifier = identifier
    }
    
}

extension CarouselItemProperties {
    
    public func map<NewMessageType>(_ transform: @escaping (MessageType) -> NewMessageType) -> CarouselItemProperties<NewMessageType> {
        
        return CarouselItemProperties<NewMessageType>(
            onTap: self.onTap.map(transform),
            identifier: self.identifier,
            renderer: { self.renderer().map(transform) }
        )
    }
    
}

public func carousel<MessageType>(
    properties: CarouselProperties<MessageType>,
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.default,
    layout: Layout = layout()) -> Component<MessageType> {
    return .carousel(properties, style, layout)
}

public func carouselItem<MessageType>(
    onTap: MessageType? = .none,
    identifier: String,
    renderer: @escaping CarouselItemProperties<MessageType>.Renderer) -> CarouselItemProperties<MessageType> {
    return CarouselItemProperties(onTap: onTap, identifier: identifier, renderer: renderer)
}

public func properties<MessageType>(itemsWidth: UInt, itemsHeight: UInt, items: ZipList<CarouselItemProperties<MessageType>>?, configure: (inout CarouselProperties<MessageType>) -> ()) -> CarouselProperties<MessageType> {
    var properties = CarouselProperties<MessageType>(items: items, itemsWidth: itemsWidth, itemsHeight: itemsHeight)
    configure(&properties)
    return properties
}
