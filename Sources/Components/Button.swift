//
//  Button.swift
//  Portal
//
//  Created by Guido Marucci Blas on 12/18/16.
//  Copyright © 2016 Guido Marucci Blas. All rights reserved.
//

import Foundation

public struct ButtonProperties<MessageType> {
    
    public var text: String?
    public var isActive: Bool
    public var icon: Image?
    public var onTap: MessageType?
    
    fileprivate init(
        text: String? = .none,
        isActive: Bool = false,
        icon: Image? = .none,
        onTap: MessageType? = .none) {
        self.text = text
        self.isActive = isActive
        self.icon = icon
        self.onTap = onTap
    }
    
}

public extension ButtonProperties {
    
    public func map<NewMessageType>(_ transform: (MessageType) -> NewMessageType) -> ButtonProperties<NewMessageType> {
        return ButtonProperties<NewMessageType>(
            text: self.text,
            isActive: self.isActive,
            icon: self.icon,
            onTap: self.onTap.map(transform)
        )
    }
    
}

public func button<MessageType>(
    text: String,
    onTap: MessageType,
    style: StyleSheet<ButtonStyleSheet> = ButtonStyleSheet.defaultStyleSheet,
    layout: Layout = layout()) -> Component<MessageType> {
    return .button(ButtonProperties<MessageType>(text: text, onTap: onTap), style, layout)
}

public func button<MessageType>(
    properties: ButtonProperties<MessageType> = ButtonProperties<MessageType>(),
    style: StyleSheet<ButtonStyleSheet> = ButtonStyleSheet.defaultStyleSheet,
    layout: Layout = layout()) -> Component<MessageType> {
    return .button(properties, style, layout)
}

public func properties<MessageType>(configure: (inout ButtonProperties<MessageType>) -> ()) -> ButtonProperties<MessageType> {
    var properties = ButtonProperties<MessageType>()
    configure(&properties)
    return properties
}

// MARK:- Style sheet

public struct ButtonStyleSheet {
    
    public static let defaultStyleSheet = StyleSheet<ButtonStyleSheet>(component: ButtonStyleSheet())
    
    public var textColor: Color
    public var textFont: Font
    public var textSize: UInt
    
    public init(
        textColor: Color = .black,
        textFont: Font = defaultFont,
        textSize: UInt = defaultButtonFontSize) {
        self.textColor = textColor
        self.textFont = textFont
        self.textSize = textSize
    }
    
}

public func buttonStyleSheet(configure: (inout BaseStyleSheet, inout ButtonStyleSheet) -> ()) -> StyleSheet<ButtonStyleSheet> {
    var base = BaseStyleSheet()
    var custom = ButtonStyleSheet()
    configure(&base, &custom)
    return StyleSheet(component: custom, base: base)
}
