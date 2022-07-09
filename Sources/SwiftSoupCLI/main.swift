import Foundation
import FoundationNetworking
import ArgumentParser
import SwiftSoup

struct SwiftSoupCLI: ParsableCommand {
	static var configuration = CommandConfiguration(
		commandName: "swiftsoup",
		abstract: "A command line tool for SwiftSoup.",
		version: "0.1.0"
	)

	private enum OutputTypes: String, ExpressibleByArgument {
		case html
		case outerHtml = "outerhtml"
		case text
		case untrimmedText = "untrimmedtext"
	}

	private enum CLIError: Error {
		case noInput
		case invalidOutputType(String)
	}

	@Argument(help: "The CSS selector to use.")
	private var selector: String

	@Argument(help: "The HTML to parse. If -, read from stdin.")
	private var html: String?

	@Option(name: .shortAndLong, help: "The URL to fetch HTML content from.")
	private var url: String?

	@Option(name: .shortAndLong, help: "Extract attribute from selected elements")
	private var attribute: String?

	@Flag(name: .long, help: "Decode HTML entities")
	private var decode: Bool = false

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
				throw CLIError.invalidOutputType(str)
			}
		}
	)
	private var outputType: OutputTypes = .outerHtml

	func inputHtml() throws -> String {
		let ret: String
		if html == nil,
		   let urlstr = url,
		   let url = URL(string: urlstr),
		   let str = try? String(contentsOf: url, encoding: .utf8) {	
			ret = str
		} else if html == nil || html == "-", 
			   let data = try? FileHandle.standardInput.readToEnd(),
			   let str = String(data: data, encoding: .utf8) {
			ret = str
		} else if let html = html {
			ret = html
		} else {
			throw CLIError.noInput
		}
		return ret
	}

	mutating func run() throws {
		do {
			let elements = try SwiftSoup.parse(try inputHtml(), url ?? "").select(selector)
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
