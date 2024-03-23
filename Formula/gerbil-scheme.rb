class GerbilScheme < Formula
  # This .rb file is tangled (AKA generated) from README.org
  desc "Opinionated dialect of Scheme designed for Systems Programming"
  homepage "https://cons.io"
  url "https://github.com/mighty-gerbils/gerbil.git",
      using: :git, revision: "c5546da0bfdc3aa17c66fe1307038bc727ed0816"
  version "0.18.1"
  license any_of: ["LGPL-2.1-or-later", "Apache-2.0"]
  revision 1
  head "https://github.com/mighty-gerbils/gerbil.git", using: :git, branch: "master"

  bottle do
    root_url "https://github.com/mighty-gerbils/homebrew-gerbil/releases/download/gerbil-scheme-0.18.1_1"
    sha256 arm64_sonoma: "882f379d132dcab6476ff116cff75912d5ce3b253634f779f2ffc8eeb2ff680e"
    sha256 ventura:      "e1ccb020a5fa90bdeb763bf3d842a27cbae610adbe80379c2508a9161afcd89d"
    sha256 x86_64_linux: "4b30975596af96ea8e78ff7c352ba7dd6bbac91ad9df34b3e95e83d2ae1861c5"
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

    if OS.mac?
      ENV.prepend_path("PATH", "/usr/local/opt/gcc/bin")
      ENV.prepend_path("PATH", "/opt/homebrew/opt/gcc/bin")
      ENV["LDFLAGS"] = "-Wl,-ld_classic"
    end
    if OS.linux?
      ENV.prepend_path("PATH", "/home/linuxbrew/.linuxbrew/bin")
      ENV.prepend_path("PATH", "/home/linuxbrew/.linuxbrew/sbin")
    end

    ENV["GERBIL_GCC"] = ENV.cc.to_s
    ENV["CC"] = ENV.cc.to_s
    ENV["CXX"] = ENV.cxx.to_s
    ENV["GERBIL_BUILD_CORES"] = nproc.to_s

    system "echo", ENV.cc.to_s
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
