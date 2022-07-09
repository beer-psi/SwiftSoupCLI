# SwiftSoupCLI
[SwiftSoup](https://github.com/scinfu/SwiftSoup) from the command line.

### Usage
```
$ swiftsoup --help
OVERVIEW: A command line tool for SwiftSoup.

USAGE: swiftsoup <selector> [<html>] [--attribute <attribute>] [--decode] [--output-type <output-type>]

ARGUMENTS:
  <selector>              The CSS selector to use.
  <html>                  The HTML to parse. If not provided, or the HTML is "-", the HTML will be read from stdin. (default: -)

OPTIONS:
  -a, --attribute <attribute>
                          Extract attribute from selected elements
  --decode                Decode HTML entities
  -o, --output-type <output-type>
                          Output type (default: outerHtml)
  -h, --help              Show help information.
```

### Examples
```
$ curl -sL https://github.com/beerpiss/SwiftSoupCLI | swiftsoup "span[itemprop=author]" -o text
beerpiss
```

### Building on Windows
SwiftSoup depends on pthreads, which doesn't exist on Windows, so we use a DispatchSemaphore instead:
```diff
diff --git a/Sources/Mutex.swift b/Sources/Mutex.swift
index 56e6379..73d6b98 100644
--- a/Sources/Mutex.swift
+++ b/Sources/Mutex.swift
@@ -10,21 +10,21 @@ import Foundation
 
 final class Mutex: NSLocking {
     
-    private var mutex = pthread_mutex_t()
+    private var mutex = DispatchSemaphore(value: 1)
 
     init() {
-        pthread_mutex_init(&mutex, nil)
+        
     }
 
     deinit {
-        pthread_mutex_destroy(&mutex)
+        
     }
 
     func lock() {
-        pthread_mutex_lock(&mutex)
+        mutex.wait()
     }
 
     func unlock() {
-        pthread_mutex_unlock(&mutex)
+        mutex.signal()
     }
 }
```
