class GerbilSchemeClang < Formula
  # This .rb file is tangled (AKA generated) from README.org
  desc "Opinionated dialect of Scheme designed for Systems Programming"
  homepage "https://cons.io"
  url "https://github.com/mighty-gerbils/gerbil.git",
      using: :git, revision: "92b1a2f642d6ebbcd3bd223ccc0af7ec0d9a42ad"
  version "0.18.1"
  license any_of: ["LGPL-2.1-or-later", "Apache-2.0"]
  # revision 0
  head "https://github.com/mighty-gerbils/gerbil.git", using: :git, branch: "master"

  depends_on "coreutils" => :build
  depends_on "pkg-config" => :build
  depends_on "openssl@3"
  depends_on "sqlite"
  depends_on "zlib"
  on_macos do
    depends_on "llvm"
  end
  on_linux do
    depends_on "llvm"
  end
  fails_with :gcc do
    cause "this is a clang build"
  end
  fails_with :clang do
    cause "this is an llvm build"
  end
  def install
    nproc = `nproc`.to_i - 1

    if OS.mac?
      ENV.prepend_path("PATH", "/usr/local/opt/llvm/bin")
      ENV.prepend_path("PATH", "/opt/homebrew/opt/llvm/bin")
    end

    if OS.linux?
      ENV.prepend_path("PATH", "/home/linuxbrew/.linuxbrew/bin")
      ENV.prepend_path("PATH", "/home/linuxbrew/.linuxbrew/sbin")
    end

    ENV["GERBIL_GCC"] = ENV.cc.to_s
    ENV["CC"] = ENV.cc.to_s

    system ENV.cc.to_s, "--version"
    system "./configure", "--prefix=#{prefix}", "--enable-march="
    system "make", "-j#{nproc}"
    system "make", "install"

    # We get rid of all the non-LFSH stuff

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
