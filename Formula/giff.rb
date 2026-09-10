# Homebrew formula. Publish it in a tap repository (for example homebrew-tap) and
# update url and sha256 for each release:
#   curl -L https://github.com/diegolanda/giff/archive/refs/tags/v0.3.1.tar.gz | shasum -a 256
class Giff < Formula
  desc "Record a window, region, or screen to GIF on macOS"
  homepage "https://github.com/diegolanda/giff"
  url "https://github.com/diegolanda/giff/archive/refs/tags/v0.3.1.tar.gz"
  sha256 "fd130f9024a210d49ca4e9c6d5b30a1485e91e20e967def439cc3c4e6f631855"
  license "MIT"

  depends_on "ffmpeg"
  depends_on :macos

  def install
    system "swiftc", "-O", "-o", "windows", "helpers/windows.swift"
    (libexec/"libexec").install "windows"
    libexec.install "helpers"
    (libexec/"bin").install "bin/giff"
    (libexec/"skills").install Dir["skills/*"]
    libexec.install "install-skill.sh"
    bin.install_symlink libexec/"bin/giff"
  end

  def caveats
    <<~EOS
      Screen Recording permission is required for the app that runs your terminal.
      Run `giff doctor --fix` to request it.
      Install the agent skill with: #{opt_libexec}/install-skill.sh claude
    EOS
  end

  test do
    assert_match "giff", shell_output("#{bin}/giff --version")
  end
end
