// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import IBDecodable
import Files
import SwiftyTextTable
import Rainbow
import ArgumentParser

@main
struct XibMigrationHelper: AsyncParsableCommand {
    @Argument(help: "Path to folder to analyze.")
    var folderPath: String = "."

    mutating func run() async throws {
        let folder = try Folder(path: folderPath)

        let xibDocuments = try xibFiles(folder: folder).map { ($0.pathString, $0.document) }
        let storyboardDocuments = try storyboardFiles(folder: folder).map { ($0.pathString, $0.document) }
        let allDocuments = (xibDocuments as [(String, InterfaceBuilderDocument & IBElement)]) + (storyboardDocuments as [(String, InterfaceBuilderDocument & IBElement)])
        let allDocumentsWithNamedColors = allDocuments.filter { $0.1.hasNamedColors }

        try infoCollectionFor(allDocumentsWithNamedColors)
    }

    var separator = "==================================================================\n"
    var smallSeperator: String {
        String(separator.replacingOccurrences(of: "=", with: "-").prefix(separator.count - 5))
    }
    
    func xibFiles(folder: Folder) throws -> [XibFile] {
        let xibFiles = folder.files.recursive.filter { $0.path.lowercased().hasSuffix("xib") }
        return try xibFiles.map { try XibFile(path: $0.path) }
    }

    func storyboardFiles(folder: Folder) throws -> [StoryboardFile] {
        let files = folder.files.recursive.filter { $0.path.lowercased().hasSuffix("storyboard") }
        return try files.map { try StoryboardFile(path: $0.path) }
    }

    func infoCollectionFor(_ documents: [(path: String, (InterfaceBuilderDocument & IBElement))]) throws {
        try documents.forEach { (path, document) in
            let colorUsages: String = " 🟩 " + document.namedColors.map { $0.name }.joined(separator: ", ")

            print(separator)
            print(path.bold)
            print(colorUsages)

            let view = TextTableColumn(header: "View")
            let outlet = TextTableColumn(header: "IBOutlet")
            let colorType = TextTableColumn(header: "Color Type")
            let colorName = TextTableColumn(header: "Color Name")

            var table = TextTable(columns: [view, outlet, colorType, colorName])

            let rows = try fileInfo(document)
            table.addRows(values: rows)
            print(table.render())

            print("\n\n")
        }
    }

    func createDocument<File: InterfaceBuilderFile>(_ path: String, _ type: File.Type) throws -> File.Document {
        let fileUrl = URL(fileURLWithPath: path)
        let file = try File(url: fileUrl)
        return file.document
    }

    func fileInfo(_ document: (InterfaceBuilderDocument & IBElement)) throws -> [[String]] {
        let allIBOutletsFromOwner = document.flattened.compactMap { $0 as? IBConnectionOwner }.compactMap { $0.allConnections }.flatMap { $0 }.compactMap { $0.connection as? Outlet }
        let allIBOutletsFromPlaceholder = document.flattened.compactMap { $0 as? Placeholder }.compactMap { $0.connections }.flatMap { $0 }.compactMap { $0.connection as? Outlet }
        let allIBOutlets = allIBOutletsFromOwner + allIBOutletsFromPlaceholder

        let viewViews = document.flattened.compactMap { $0 as? AnyView} // TODO: AnyView ist schlecht, kann auch UIViewControlelr sein oder placeholder mit connections...
        let viewControllerViews = document.flattened.compactMap { $0 as? AnyViewController}.map { $0.viewController.rootView?.flattened.compactMap { $0 as? AnyView } }.compactMap { $0 }.flatMap { $0 }
        let views = viewViews + viewControllerViews

        let namedColorsViews = views.filter { anyView in
            anyView.view.hasNamedColor
        }

        return namedColorsViews.map {
            let hasOutlet = $0.view.ibOutlet(allIBOutlets) != nil

            var elementClass = $0.view.elementClass
            elementClass = hasOutlet ? elementClass.green : elementClass.red

            let outlet = if let property = $0.view.ibOutlet(allIBOutlets) {
                "var " + property
            } else {
                ""
            }

            let colorTypes = $0.view.namedColors.compactMap { $0.namedColor }.map { "\($0.key ?? "")" }.joined(separator: ", ")
            let colorNames = $0.view.namedColors.compactMap { $0.namedColor }.map { "\($0.name)" }.joined(separator: ", ")
            return [elementClass, outlet, colorTypes, colorNames]
        }
    }
}
