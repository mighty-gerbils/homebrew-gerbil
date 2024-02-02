class GerbilScheme < Formula
  # This .rb file is tangled (AKA generated) from README.org
  desc "Opinionated dialect of Scheme designed for Systems Programming"
  homepage "https://cons.io"
  url "https://github.com/mighty-gerbils/gerbil.git",
      using: :git, revision: "92b1a2f642d6ebbcd3bd223ccc0af7ec0d9a42ad"
  version "0.18.1"
  license any_of: ["LGPL-2.1-or-later", "Apache-2.0"]
  # revision 2
  head "https://github.com/mighty-gerbils/gerbil.git", using: :git, branch: "master"

  bottle do
    root_url "https://github.com/mighty-gerbils/homebrew-gerbil/releases/download/gerbil-scheme-0.18.1"
    sha256 arm64_sonoma: "fa7caae13279a320aa99f636f9de78fe5fb348bac414a1f3673486dc977e0318"
    sha256 ventura:      "0cea003f38d23d06b650dc033183d91a03bf6adafdb4b049f5f8081af322952e"
    sha256 x86_64_linux: "525c66ccab46a2f5494f2a0c38dc7588ef63b0733b8be3029f1e58e794d06fd0"
  end

  depends_on "pkg-config" => :build
  depends_on "coreutils"
  depends_on "openssl@3"
  depends_on "sqlite"
  depends_on "zlib"

  on_macos do
    depends_on "llvm"
  end

  on_linux do
    depends_on "gcc"
  end

  def install
    nproc = `nproc`.to_i - 1

    if OS.mac?
      ENV.prepend_path("PATH", "/usr/local/opt/llvm/bin")
      ENV.prepend_path("PATH", "/opt/homebrew/opt/llvm/bin")
      ENV["GERBIL_GCC"] = ENV.cc.to_s
      ENV["CC"] = ENV.cc.to_s
    end

    system ENV.cc.to_s, "--version"
    system "./configure", "--prefix=#{prefix}", "--enable-march=\"\""
    system "make", "-j#{nproc}"
    system "make", "install"

    rm prefix/"bin"
    rm prefix/"lib"
    rm prefix/"share"
    mkdir prefix/"bin"

    cd prefix/"current/bin" do
      ln "gerbil", prefix/"bin", verbose: true
      cp %w[gxc gxensemble gxi gxpkg gxprof gxtags gxtest], prefix/"bin"
    end
  end
  test do
    assert_equal "0123456789", shell_output("#{bin}/gxi -e \"(for-each write '(0 1 2 3 4 5 6 7 8 9))\"")
  end
end
