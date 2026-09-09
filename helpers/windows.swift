// Prints on-screen windows and screen geometry as TSV.
// Usage: windows [list|screens]
import AppKit
import CoreGraphics
import Foundation

let mode = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "list"

func fmt(_ v: Double) -> String { String(Int(v.rounded())) }

if mode == "screens" {
    // index \t x,y,w,h (Cocoa origin, bottom-left) \t scale
    for (i, s) in NSScreen.screens.enumerated() {
        let f = s.frame
        print("\(i)\t\(fmt(f.origin.x)),\(fmt(f.origin.y)),\(fmt(f.width)),\(fmt(f.height))\t\(s.backingScaleFactor)")
    }
    exit(0)
}

let opts: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
guard let raw = CGWindowListCopyWindowInfo(opts, kCGNullWindowID) as? [[String: Any]] else {
    FileHandle.standardError.write("cannot list windows\n".data(using: .utf8)!)
    exit(1)
}
for w in raw {
    let layer = w[kCGWindowLayer as String] as? Int ?? 0
    if layer != 0 { continue }
    guard let id = w[kCGWindowNumber as String] as? Int,
          let b = w[kCGWindowBounds as String] as? [String: Double] else { continue }
    let wd = b["Width"] ?? 0, ht = b["Height"] ?? 0
    if wd < 50 || ht < 50 { continue }
    let owner = w[kCGWindowOwnerName as String] as? String ?? ""
    let name = w[kCGWindowName as String] as? String ?? ""
    let pid = w[kCGWindowOwnerPID as String] as? Int ?? 0
    // id \t pid \t owner \t title \t x,y,w,h (top-left origin, points)
    print("\(id)\t\(pid)\t\(owner)\t\(name)\t\(fmt(b["X"] ?? 0)),\(fmt(b["Y"] ?? 0)),\(fmt(wd)),\(fmt(ht))")
}
