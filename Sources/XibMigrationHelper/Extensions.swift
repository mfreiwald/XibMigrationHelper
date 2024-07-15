import IBDecodable

extension ViewProtocol {
    var hasNamedColor: Bool {
        if case .name = tintColor {
            return true
        }
        if case .name = backgroundColor {
            return true
        }
        return false
    }

    var namedColors: [IBDecodable.Color] {
        var result: [IBDecodable.Color] = []
        if let tintColor {
            if case .name = tintColor {
                result.append(tintColor)
            }
        }
        if let backgroundColor {
            if case .name = backgroundColor {
                result.append(backgroundColor)
            }
        }
        return result
    }

    func hasConnection(_ connections: [Outlet]) -> Bool {
        guard let id = self as? IBIdentifiable else { return false }
        return connections.contains(where: { $0.destination == id.id })
    }

    func ibOutlet(_ connections: [Outlet]) -> String? {
        guard let id = self as? IBIdentifiable else { return nil }
        return connections.first(where: { $0.destination == id.id })?.property
    }
}

extension IBDecodable.Color {
    var namedColor: IBDecodable.Color.Named? {
        switch self {
        case let .name(named):
            return named
        default: return nil
        }
    }
}

extension InterfaceBuilderDocument {
    var namedColors: [IBDecodable.NamedColor] {
        resources?.compactMap({ resource -> IBDecodable.NamedColor? in
            resource.resource as? IBDecodable.NamedColor
        }) ?? []
    }

    var hasNamedColors: Bool {
        !namedColors.isEmpty
    }
}
