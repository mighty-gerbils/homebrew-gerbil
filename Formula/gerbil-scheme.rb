class GerbilScheme < Formula
  # This .rb file is tangled (AKA generated) from README.org
  desc "Opinionated dialect of Scheme designed for Systems Programming"
  homepage "https://cons.io"
  url "https://github.com/mighty-gerbils/gerbil.git",
      using: :git, revision: "92b1a2f642d6ebbcd3bd223ccc0af7ec0d9a42ad"
  version "0.18.1"
  license any_of: ["LGPL-2.1-or-later", "Apache-2.0"]
  revision 3
  head "https://github.com/mighty-gerbils/gerbil.git", using: :git, branch: "master"

  bottle do
    root_url "https://github.com/mighty-gerbils/homebrew-gerbil/releases/download/gerbil-scheme-0.18.1_3"
    sha256 arm64_sonoma: "56b13b3e8862a0d08f647d1708c5311e1dccc9862b10dab38bdf0ebff0dc538e"
    sha256 ventura:      "2bc2c1f15877a980027181c95fb090c50240c3a132b54b06835723b2ff267686"
    sha256 monterey:     "fcc12990f5d936e593cfffaba95846926d4638917c66fdfc2b1d73bcb96ece1c"
  end
  depends_on "coreutils" => :build
  depends_on "pkg-config" => :build
  depends_on "openssl@3"
  depends_on "sqlite"
  depends_on "zlib"
  on_macos do
    depends_on "gcc@13"
  end
  on_linux do
    depends_on "gcc@13"
  end
  fails_with :gcc do
    version "12" # Select new gcc
    cause "Make it easy with all the same"
  end

  fails_with :clang do
    cause "Must be GCC"
  end

  def install
    nproc = `nproc`.to_i - 1

    # if OS.mac?
    #   ENV.prepend_path("PATH", "/usr/local/opt/llvm/bin")
    #   ENV.prepend_path("PATH", "/opt/homebrew/opt/llvm/bin")
    # end

    # if OS.linux?
    #   ENV.prepend_path("PATH", "/home/linuxbrew/.linuxbrew/bin")
    #   ENV.prepend_path("PATH", "/home/linuxbrew/.linuxbrew/sbin")
    # end

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
