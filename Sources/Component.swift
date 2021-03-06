//
//  Component.swift
//  PortalView
//
//  Created by Guido Marucci Blas on 1/27/17.
//
//
import Foundation

public enum RootComponent<MessageType> {

    case simple
    case stack(NavigationBar<MessageType>)
    case tab(TabBar<MessageType>)

}

public enum Gesture<MessageType> {

    case tap(message: MessageType)

}

public extension Gesture {

    public func map<NewMessageType>(_ transform: @escaping (MessageType) -> NewMessageType) -> Gesture<NewMessageType> {
        switch self {

        case .tap(let message):
            return .tap(message: transform(message))

        }
    }

}

public indirect enum Component<MessageType> {

    case button(ButtonProperties<MessageType>, StyleSheet<ButtonStyleSheet>, Layout)
    case label(LabelProperties, StyleSheet<LabelStyleSheet>, Layout)
    case mapView(MapProperties, StyleSheet<EmptyStyleSheet>, Layout)
    case imageView(Image, StyleSheet<EmptyStyleSheet>, Layout)
    case container([Component<MessageType>], StyleSheet<EmptyStyleSheet>, Layout)
    case table(TableProperties<MessageType>, StyleSheet<TableStyleSheet>, Layout)
    case collection(CollectionProperties<MessageType>, StyleSheet<EmptyStyleSheet>, Layout)
    case touchable(gesture: Gesture<MessageType>, child: Component<MessageType>)
    case segmented(ZipList<SegmentProperties<MessageType>>, StyleSheet<SegmentedStyleSheet>, Layout)
    case progress(ProgressCounter, StyleSheet<ProgressStyleSheet>, Layout)
    case textField(TextFieldProperties<MessageType>, StyleSheet<TextFieldStyleSheet>, Layout)
    case custom(componentIdentifier: String, layout: Layout)

    public var layout: Layout {
        switch self {

        case .button(_, _, let layout):
            return layout

        case .label(_, _, let layout):
            return layout

        case .textField(_, _, let layout):
            return layout

        case .mapView(_, _, let layout):
            return layout

        case .imageView(_, _, let layout):
            return layout

        case .container(_, _, let layout):
            return layout

        case .table(_, _, let layout):
            return layout

        case .touchable(_, let child):
            return child.layout

        case .segmented(_, _, let layout):
            return layout
        
        case .progress(_, _, let layout):
            return layout
            
        case .collection(_, _, let layout):
            return layout

        case .custom(_, let layout):
            return layout

        }
    }

}

extension Component {

    public func map<NewMessageType>(_ transform: @escaping (MessageType) -> NewMessageType) -> Component<NewMessageType> {
        switch self {

        case .button(let properties, let style, let layout):
            return .button(properties.map(transform), style, layout)

        case .label(let properties, let style, let layout):
            return .label(properties, style, layout)

        case .textField(let properties, let style, let layout):
            return .textField(properties.map(transform), style, layout)

        case .mapView(let properties, let style, let layout):
            return .mapView(properties, style, layout)

        case .imageView(let image, let style, let layout):
            return .imageView(image, style, layout)

        case .container(let children, let style, let layout):
            return .container(children.map { $0.map(transform) }, style, layout)

        case .table(let properties, let style, let layout):
            return .table(properties.map(transform), style, layout)

        case .touchable(let gesture, let child):
            return .touchable(gesture: gesture.map(transform), child: child.map(transform))

        case .segmented(let segments, let style, let layout):
            return .segmented(segments.map { $0.map(transform) }, style, layout)
            
        case .progress(let progress, let style, let layout):
            return .progress(progress, style, layout)

        case .collection(let properties, let style, let layout):
            return .collection(properties.map(transform), style, layout)

        case .custom(let componentIdentifier, let layout):
            return .custom(componentIdentifier: componentIdentifier, layout: layout)

        }
    }

    public var customComponentIdentifiers: [String] {
        switch self {

        case .container(let children, _, _):
            return children.flatMap { $0.customComponentIdentifiers }

        case .custom(let componentIdentifier, _):
            return [componentIdentifier]

        default:
            return []

        }
    }

}

public func container<MessageType>(
    children: [Component<MessageType>] = [],
    style: StyleSheet<EmptyStyleSheet> = EmptyStyleSheet.`default`,
    layout: Layout = layout()) -> Component<MessageType> {
    return .container(children, style, layout)
}

public func touchable<MessageType>(gesture: Gesture<MessageType>, child: Component<MessageType>) -> Component<MessageType> {
    return .touchable(gesture: gesture, child: child)
}
