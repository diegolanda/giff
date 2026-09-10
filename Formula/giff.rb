# Homebrew formula. Publish it in a tap repository (for example homebrew-tap) and
# update url and sha256 for each release:
#   curl -L https://github.com/diegolanda/giff/archive/refs/tags/v0.3.2.tar.gz | shasum -a 256
class Giff < Formula
  desc "Record a window, region, or screen to GIF on macOS"
  homepage "https://github.com/diegolanda/giff"
  url "https://github.com/diegolanda/giff/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "51e541e0b73f6de06873601ea1f7e256b9dcf20e37e33ffe8f36e540490f21a4"
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
