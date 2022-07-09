import Foundation
import ArgumentParser
import SwiftSoup

struct SwiftSoupCLI: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "swiftsoup",
		abstract: "A command line tool for SwiftSoup.",
		version: "0.1.0",
	)

	private enum OutputTypes: String, ExpressibleByArgument {
		case html
		case outerHtml = "outerhtml"
		case text
		case untrimmedText = "untrimmedtext"
	}

	private enum CLIError: Error {
		case invalidOutputType(String)
	}

	@Argument(help: "The CSS selector to use.")
	private var selector: String

	@Argument(help: "The HTML to parse. If not provided, or the HTML is \"-\", the HTML will be read from stdin.")
	private var html: String = "-"

	@Option(name: .shortAndLong, help: "Extract attribute from selected elements")
	private var attribute: String?

	@Flag(name: .long, help: "Decode HTML entities")
	private var decode: Bool = false

	@Option(
		name: .shortAndLong,
		help: "Output type",
		transform: {
			str in
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
				throw CLIError.invalidOutputType(str)
			}
		}
	)
	private var outputType: OutputTypes = .outerHtml

	mutating func run() throws {
		if html == "-" {
			let file = FileHandle.standardInput
			if let data = try? file.readToEnd() {
				if let html = String(data: data, encoding: .utf8) {
					self.html = html
				} else {
					print("Error: No input given.")
					_exit(1)
				}
			} else {
				print("Error: Could not read from stdin.")
				_exit(1)
			}
		}

		do {
			let elements = try SwiftSoup.parse(html).select(selector)
			for element in elements.array() {
				var output: String?;
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
					if decode && outputType == .text || outputType == .untrimmedText {
						print((try? Entities.unescape(output)) ?? output)
					} else {
						print(output)
					}
				}
			}
		} catch Exception.Error(_, let message) {
			print("Error: Could not parse HTML: \(message)")
			_exit(1)
		} catch {
			print("Error: Could not parse HTML.")
			_exit(1)
		}
	}
}

SwiftSoupCLI.main()
