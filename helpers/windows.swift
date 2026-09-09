// Prints on-screen windows and screen geometry as TSV.
// Usage: windows [list|screens|preflight|request]
import AppKit
import CoreGraphics
import Foundation

let mode = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "list"

if mode == "request" {
    // Asks macOS to show the Screen Recording permission dialog for this process's
    // responsible app, which also adds the app to the list in System Settings.
    exit(CGRequestScreenCaptureAccess() ? 0 : 1)
}

if mode == "preflight" {
    // Exit 0 when this process may record the screen, 1 otherwise.
    exit(CGPreflightScreenCaptureAccess() ? 0 : 1)
}

func fmt(_ v: Double) -> String { String(Int(v.rounded())) }

if mode == "screens" {
    // index \t x,y,w,h (points, top-left origin, global coordinates) \t scale
    // NSScreen frames use a bottom-left origin, so flip y against the main screen height.
    let mainHeight = NSScreen.screens.first?.frame.height ?? 0
    for (i, s) in NSScreen.screens.enumerated() {
        let f = s.frame
        let top = mainHeight - (f.origin.y + f.height)
        print("\(i)\t\(fmt(f.origin.x)),\(fmt(top)),\(fmt(f.width)),\(fmt(f.height))\t\(s.backingScaleFactor)")
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
