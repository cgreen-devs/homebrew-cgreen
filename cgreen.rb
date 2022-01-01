class Cgreen < Formula
  desc "Modern, readable & portable unit testing & mocking for C and C++"
  homepage "https://github.com/cgreen-devs/cgreen"
  url "https://github.com/cgreen-devs/cgreen/archive/refs/tags/1.4.1.tar.gz"
  sha256 "c805679020da8acaea7ca3a3e90314493be215f32c34e5bfe195c2377ee26a5d"
  license "ISC"

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    bin.install "build/tools/cgreen-runner"
    bin.install "build/tools/cgreen-debug"
    include.install Dir["include/cgreen"]
    lib.install "build/src/libcgreen*.so"
    man1.install "doc/man/man1/cgreen-runner.1"
    man1.install "doc/man/man1/cgreen-debug.1"
    man5.install "doc/man/man5/cgreen.5"
    # We should also install the completion scripts...
  end

  test do
    (testpath/"cgreen_tests.c").write <<~EOS
  #include <cgreen/cgreen.h>
  #include <cgreen/mocks.h>
  
  Describe(Cgreen);
  BeforeEach(Cgreen){}
  AfterEach(Cgreen){}
  
  static int mocked_function(char *string) {
      return (int)mock(string);
  }
  
  Ensure(Cgreen, can_mock_a_simple_function) {
      expect(mocked_function, when(string, is_equal_to_string("Hello, Homebrew!")),
             will_return(42));
      assert_that(mocked_function("Hello, Homebrew!"), is_equal_to(42));
  }
    EOS
    system ENV.cc, "-shared", "cgreen_tests.c", "-o", "cgreen_tests.dylib", "-L#{lib}", "-lcgreen"
    system "cgreen-runner", "cgreen_tests.dylib"
  end
end
