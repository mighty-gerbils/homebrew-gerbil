class GerbilScheme < Formula
  # This .rb file is tangled (AKA generated) from README.org
  desc "Opinionated dialect of Scheme designed for Systems Programming"
  homepage "https://cons.io"
  license any_of: ["LGPL-2.1-or-later", "Apache-2.0"]
  url "https://github.com/mighty-gerbils/gerbil.git", using: :git,
      revision: "f7d8efcf4a25014b4b969eb6e21a3006d256f22e"
  head "https://github.com/mighty-gerbils/gerbil.git", using: :git
  version "0.18.1"
  revision 3
  depends_on "openssl@3"
  depends_on "sqlite"
  depends_on "zlib"
  depends_on "llvm"
  depends_on "coreutils"

  

  def install
    nproc = `nproc`.to_i - 1

    ENV.prepend_path("PATH", "/usr/local/opt/llvm/bin")
    ENV.prepend_path("PATH", "/opt/homebrew/opt/llvm/bin")
    ENV["LDFLAGS"] = "-L/opt/homebrew/opt/llvm/lib -L/usr/local/opt/llvm/lib"
    ENV["CPPFLAGS"] = "-I/opt/homebrew/opt/llvm/include -I/usr/local/opt/llvm/include"
    ENV["GERBIL_GCC"] = "clang"
    ENV["CC"] = "clang"

    system "clang", "--version"
    system "./configure", "--prefix=#{prefix}"
    system "make", "-j#{nproc}"
    system "make", "install"
    rm prefix/"bin"
    mkdir prefix/"bin"

    cd prefix/"current/bin" do
       ln "gerbil", prefix/"bin", verbose: true
       cp %w(gxc gxensemble gxi gxpkg gxprof gxtags gxtest), prefix/"bin"
     end
  end
    test do
      assert_equal "0123456789", shell_output("#{bin}/gxi -e \"(for-each write '(0 1 2 3 4 5 6 7 8 9))\"")
    end
end
