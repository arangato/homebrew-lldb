class Chiselmax < Formula
  desc "Collection of LLDB commands to assist debugging iOS apps"
  homepage "https://https://github.com/arangato/chisel"
  url "https://github.com/arangato/chisel/archive/1.8.1.max.tar.gz"
  sha256 "f7c2b6476fa095b42a7a96f2560a377248e361f5e476cc8fb044c73b3ba7a076"
  head "https://github.com/arangato/chisel.git"

  bottle do
    cellar :any
  end

  def install
    libexec.install Dir["*.py", "commands"]

    # == LD_DYLIB_INSTALL_NAME Explanation ==
    # This make invocation calls xcodebuild, which in turn performs ad hoc code
    # signing. Note that ad hoc code signing does not need signing identities.
    # Brew will update binaries to ensure their internal paths are usable, but
    # modifying a code signed binary will invalidate the signature. To prevent
    # broken signing, this build specifies the target install name up front,
    # in which case brew doesn't perform its modifications.
    system "make", "-C", "Chisel", "install", "PREFIX=#{lib}", \
      "LD_DYLIB_INSTALL_NAME=#{opt_prefix}/lib/Chisel.framework/Chisel"
  end

  def caveats; <<~EOS
    Add the following line to ~/.lldbinit to load chisel when Xcode launches:
      command script import #{opt_libexec}/fblldb.py
  EOS
  end

  test do
    xcode_path = `xcode-select --print-path`.strip
    lldb_rel_path = "Contents/SharedFrameworks/LLDB.framework/Resources/Python"
    ENV["PYTHONPATH"] = "#{xcode_path}/../../#{lldb_rel_path}"
    system "python", "#{libexec}/fblldb.py"
  end
end
