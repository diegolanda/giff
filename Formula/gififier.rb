# Homebrew formula. Publish it in a tap repository (for example homebrew-tap) and
# update url and sha256 for each release:
#   curl -L https://github.com/diegolanda/gififier/archive/refs/tags/v0.2.0.tar.gz | shasum -a 256
class Gififier < Formula
  desc "Record a window, region, or screen to GIF on macOS"
  homepage "https://github.com/diegolanda/gififier"
  url "https://github.com/diegolanda/gififier/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "fabf76fe13acf0efa251526c942c24d84685afa066251e2424d998fd5e1568ff"
  license "MIT"

  depends_on "ffmpeg"
  depends_on :macos

  def install
    system "swiftc", "-O", "-o", "windows", "helpers/windows.swift"
    (libexec/"libexec").install "windows"
    libexec.install "helpers"
    (libexec/"bin").install "bin/gififier"
    (libexec/"skills").install Dir["skills/*"]
    libexec.install "examples", "install-skill.sh"
    bin.install_symlink libexec/"bin/gififier"
  end

  def caveats
    <<~EOS
      Screen Recording permission is required for the app that runs your terminal.
      Run `gififier doctor --fix` to request it.
      Example PR upload script: #{opt_libexec}/examples/attach-to-pr.sh
      Install the agent skill with: #{opt_libexec}/install-skill.sh claude
    EOS
  end

  test do
    assert_match "gififier", shell_output("#{bin}/gififier --version")
  end
end
