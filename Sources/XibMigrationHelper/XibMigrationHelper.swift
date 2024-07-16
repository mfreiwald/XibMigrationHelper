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

    @Option(name: [.short, .customLong("file")], help: "Filter for specific files")
    var fileFilter: String?

    @Flag(name: [.customShort("a"), .long], help: "Show all files at once")
    var showAll: Bool = false

    @Flag(name: [.customShort("e"), .customLong("emptys")], help: "Show only files which have a NamedColor reference but didn't uses it.")
    var showNoColorUsagesOnly: Bool = false

    mutating func run() async throws {
        let folder = try Folder(path: folderPath)

        let xibDocuments = try xibFiles(folder: folder).map { ($0.pathString, $0.document) }
        let storyboardDocuments = try storyboardFiles(folder: folder).map { ($0.pathString, $0.document) }
        let allDocuments = (xibDocuments as [(String, InterfaceBuilderDocument & IBElement)]) + (storyboardDocuments as [(String, InterfaceBuilderDocument & IBElement)])
        var allDocumentsWithNamedColors = allDocuments.filter { $0.1.hasNamedColors }
        if let fileFilter {
            allDocumentsWithNamedColors = allDocumentsWithNamedColors.filter { $0.0.lowercased().contains(fileFilter.lowercased())}
        }

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
        try documents.enumerated().forEach { (index, value) in
            let (path, document) = value
            let colorUsages: String = " 🟩 " + document.namedColors.map { $0.name }.joined(separator: ", ")

            let rows = try fileInfo(document)

            let hasOutput = if showNoColorUsagesOnly { rows.isEmpty } else { true }

            guard hasOutput else { return  }

            func printOutput() {
                print(path.bold)
                print(colorUsages)

                let view = TextTableColumn(header: "View")
                let outlet = TextTableColumn(header: "IBOutlet")
                let colorType = TextTableColumn(header: "Color Type")
                let colorName = TextTableColumn(header: "Color Name")

                var table = TextTable(columns: [view, outlet, colorType, colorName])

                if !rows.isEmpty {
                    table.addRows(values: rows)
                    print(table.render())
                }

                print("")
            }

            if showAll {
                printOutput()
            } else {
                TerminalHelper.clear()
                let current = index + 1
                let total = documents.count
                print("Progress [\(String(current).bold)/\(total)]")
                printOutput()
                if current == total {
                    print("Press Enter or Space to quit.")
                } else {
                    print("Press Enter or Space to continue, Ctrl+C to quit.")
                }
                TerminalHelper.waitAndContinue()
            }
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

        let viewViews = document.flattened.compactMap { $0 as? AnyView }
        let viewControllerViews = document.flattened.compactMap { $0 as? AnyViewController}.map { $0.viewController.rootView?.flattened.compactMap { $0 as? AnyView } }.compactMap { $0 }.flatMap { $0 }

        let allViews = (viewViews + viewControllerViews).map { $0.view }

        let collectionCells = allViews.compactMap { $0 as? CollectionViewCell }.map { $0.contentView as ViewProtocol }
        let tableCells = allViews.compactMap { $0 as? TableViewCell }.map { $0.contentView as ViewProtocol }

        let views = allViews + collectionCells + tableCells

        let namedColorsViews = views.filter { anyView in
            anyView.hasNamedColor
        }

        return namedColorsViews.map {
            let hasOutlet = $0.ibOutlet(allIBOutlets) != nil

            var elementClass = $0.elementClass
            elementClass = hasOutlet ? elementClass.green : elementClass.red

            let outlet = if let property = $0.ibOutlet(allIBOutlets) {
                "var " + property
            } else {
                ""
            }

            let colorTypes = $0.namedColors.compactMap { $0.namedColor }.map { "\($0.key ?? "")" }.joined(separator: ", ")
            let colorNames = $0.namedColors.compactMap { $0.namedColor }.map { "\($0.name)" }.joined(separator: ", ")
            return [elementClass, outlet, colorTypes, colorNames]
        }
    }
}
