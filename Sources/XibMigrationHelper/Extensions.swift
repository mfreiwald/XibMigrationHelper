import IBDecodable

extension ViewProtocol {
    var hasNamedColor: Bool {
        !namedColors.isEmpty
    }

    var namedColors: [IBDecodable.Color] {
        var result: [IBDecodable.Color] = []

        func add<Comp>(_ type: Comp.Type, _ keypath: KeyPath<Comp, Color?>) {
            if let comp = (self as? Comp), let color = comp[keyPath: keypath], color.isNamedColor {
                result.append(color)
            }
        }

        if let tintColor, tintColor.isNamedColor {
            result.append(tintColor)
        }
        if let backgroundColor, backgroundColor.isNamedColor {
            result.append(backgroundColor)
        }

        if let button = self as? Button, let states = button.state {
            let colors = states.compactMap { $0.color }.filter { $0.isNamedColor }
            let titleColors = states.compactMap { $0.titleColor }.filter { $0.isNamedColor }
            let titleShadowColors = states.compactMap { $0.titleShadowColor }.filter { $0.isNamedColor }
            let results = colors + titleColors + titleShadowColors
            result.append(contentsOf: results)
        }

        add(SegmentedControl.self, \.selectedSegmentTintColor)
        
        add(Slider.self, \.thumbTintColor)
        add(Slider.self, \.minimumTrackTintColor)
        add(Slider.self, \.maximumTrackTintColor)
        
        add(Switch.self, \.onTintColor)
        add(Switch.self, \.thumbTintColor)

        add(TextField.self, \.textColor)
        
        add(TextView.self, \.textColor)

        add(ActivityIndicatorView.self, \.color)

        add(Label.self, \.textColor)

        add(ProgressView.self, \.progressTintColor)
        add(ProgressView.self, \.trackTintColor)

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

    var isNamedColor: Bool {
        namedColor != nil
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
