# Homebrew formula. Publish it in a tap repository (for example homebrew-tap) and
# update url and sha256 for each release:
#   curl -L https://github.com/diegolanda/giff/archive/refs/tags/v0.3.0.tar.gz | shasum -a 256
class Giff < Formula
  desc "Record a window, region, or screen to GIF on macOS"
  homepage "https://github.com/diegolanda/giff"
  url "https://github.com/diegolanda/giff/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "ab2b8efba56507700df668ce1f1dae1fad00ae4c0a2787688952879a5a52bd3f"
  license "MIT"

  depends_on "ffmpeg"
  depends_on :macos

  def install
    system "swiftc", "-O", "-o", "windows", "helpers/windows.swift"
    (libexec/"libexec").install "windows"
    libexec.install "helpers"
    (libexec/"bin").install "bin/giff"
    (libexec/"skills").install Dir["skills/*"]
    libexec.install "examples", "install-skill.sh"
    bin.install_symlink libexec/"bin/giff"
  end

  def caveats
    <<~EOS
      Screen Recording permission is required for the app that runs your terminal.
      Run `giff doctor --fix` to request it.
      Example PR upload script: #{opt_libexec}/examples/attach-to-pr.sh
      Install the agent skill with: #{opt_libexec}/install-skill.sh claude
    EOS
  end

  test do
    assert_match "giff", shell_output("#{bin}/giff --version")
  end
end
