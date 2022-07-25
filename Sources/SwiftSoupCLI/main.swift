import Foundation
import ArgumentParser
import SwiftSoup

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

@main
struct SwiftSoupCLI: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "swiftsoup",
		abstract: "A command line tool for SwiftSoup.",
		version: "0.2.0"
	)

	private enum OutputTypes: String, ExpressibleByArgument {
		case html
		case outerHtml = "outerhtml"
		case text
		case untrimmedText = "untrimmedtext"
	}

	@Argument(help: "The CSS selector to use.")
	private var selector: String

	@Argument(help: "The HTML to parse. If -, read from stdin.")
	private var html: String?

	@Option(
		name: .shortAndLong,
		help: "The URL to fetch HTML content from.",
		transform: { url in
			guard let url = URL(string: url) else {
				fatalError("Invalid URL: \(url)")
			}
			return url
		})
	private var url: URL?

	@Option(name: .shortAndLong, help: "Extract attribute from selected elements")
	private var attribute: String?

	@Option(
		name: .shortAndLong,
		help: "Output type",
		transform: { str in
			switch str.lowercased() {
			case "html":
				return OutputTypes.html
			case "outerhtml":
				return OutputTypes.outerHtml
			case "text":
				return OutputTypes.text
			case "untrimmedtext":
				return OutputTypes.untrimmedText
			default:
				fatalError("Unknown output type: \(str)")
			}
		}
	)
	private var outputType: OutputTypes = .outerHtml

	func inputHtml() throws -> String {
		let ret: String
		if html == nil,
		   let url = url,
		   let str = try? String(contentsOf: url, encoding: .utf8) {
			ret = str
		} else if html == nil || html == "-",
			   let data = try? FileHandle.standardInput.readToEof(),
			   let str = String(data: data, encoding: .utf8) {
			ret = str
		} else if let html = html {
			ret = html
		} else {
			fatalError("No HTML input given.")
		}
		return ret
	}

	mutating func run() throws {
		do {
			let elements = try SwiftSoup.parse(try inputHtml(), url?.absoluteString ?? "").select(selector)
			for element in elements.array() {
				var output: String?
				if let attribute = attribute {
					output = try? element.attr(attribute)
				} else {
					switch outputType {
					case .html:
						output = try? element.html()
					case .outerHtml:
						output = try? element.outerHtml()
					case .text:
						output = try? element.text()
					case .untrimmedText:
						output = try? element.text(trimAndNormaliseWhitespace: false)
					}
				}
				if let output = output {
					print(output)
				}
			}
		} catch Exception.Error(_, let message) {
			fatalError("Error: Could not parse HTML: \(message)")
		} catch {
			fatalError("Error: Could not parse HTML.")
		}
	}
}
