# SwiftSoupCLI
[SwiftSoup](https://github.com/scinfu/SwiftSoup) from the command line.

### Downloading
Download from [nightly.link](https://nightly.link/beerpiss/SwiftSoupCLI/workflows/build.yaml/trunk).

### Usage
```
$ swiftsoup --help
OVERVIEW: A command line tool for SwiftSoup.

USAGE: swiftsoup <selector> [<html>] [--url <url>] [--attribute <attribute>] [--decode] [--output-type <output-type>]

ARGUMENTS:
  <selector>              The CSS selector to use.
  <html>                  The HTML to parse. If -, read from stdin.

OPTIONS:
  -u, --url <url>         The URL to fetch HTML content from.
  -a, --attribute <attribute>
                          Extract attribute from selected elements
  --decode                Decode HTML entities
  -o, --output-type <output-type>
                          Output type (default: outerHtml)
  --version               Show the version.
  -h, --help              Show help information.
```

### Examples
```sh
$ curl -sL https://github.com/beerpiss/SwiftSoupCLI | swiftsoup "span[itemprop=author]" --output-type text
beerpiss

# or fetch directly
$ swiftsoup "span[itemprop=author]" --url "https://github.com/beerpiss/SwiftSoupCLI" --output-type text
beerpiss

# opt out of fetching by setting html to stdin
$ echo "<a href=\"/help\">Send help</a>" > test.html
$ cat test.html | swiftsoup a - --attribute "abs:href" --url "http://example.com/"
```

### Building on Windows
SwiftSoup depends on pthreads, which doesn't exist on Windows, so we use a DispatchSemaphore instead. Check the [patch](https://github.com/beerpiss/SwiftSoupCLI/blob/trunk/Resources/windows.patch) for details.
