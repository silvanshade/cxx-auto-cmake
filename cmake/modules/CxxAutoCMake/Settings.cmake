# NOTE: Setting either the `*_MIN` or `*_MAX` version to `IGNORE` will disable version checking.

set(CxxAutoCMake_LLVM_VERSION_MIN 15 CACHE STRING "Expected minimum LLVM version")
set(CxxAutoCMake_LLVM_VERSION_MAX 17 CACHE STRING "Expected maximum LLVM version")

set(CxxAutoCMake_Clang_VERSION_MIN ${CxxAutoCMake_LLVM_VERSION_MIN} CACHE STRING "Expected minimum Clang version")
set(CxxAutoCMake_Clang_VERSION_MAX ${CxxAutoCMake_LLVM_VERSION_MAX} CACHE STRING "Expected maximum Clang version")

set(CxxAutoCMake_ClangCC_VERSION_MIN ${CxxAutoCMake_LLVM_VERSION_MIN} CACHE STRING "Expected minimum `clang` version")
set(CxxAutoCMake_ClangCC_VERSION_MAX ${CxxAutoCMake_LLVM_VERSION_MAX} CACHE STRING "Expected maximum `clang` version")

set(CxxAutoCMake_ClangCXX_VERSION_MIN ${CxxAutoCMake_LLVM_VERSION_MIN} CACHE STRING "Expected minimum `clang++` version")
set(CxxAutoCMake_ClangCXX_VERSION_MAX ${CxxAutoCMake_LLVM_VERSION_MAX} CACHE STRING "Expected maximum `clang++` version")

set(CxxAutoCMake_ClangD_VERSION_MIN ${CxxAutoCMake_LLVM_VERSION_MIN} CACHE STRING "Expected minimum `clangd` version")
set(CxxAutoCMake_ClangD_VERSION_MAX ${CxxAutoCMake_LLVM_VERSION_MAX} CACHE STRING "Expected maximum `clangd` version")

set(CxxAutoCMake_ClangFormat_VERSION_MIN ${CxxAutoCMake_LLVM_VERSION_MIN} CACHE STRING "Expected minimum `clang-format` version")
set(CxxAutoCMake_ClangFormat_VERSION_MAX ${CxxAutoCMake_LLVM_VERSION_MAX} CACHE STRING "Expected maximum `clang-format` version")

set(CxxAutoCMake_ClangTidy_VERSION_MIN ${CxxAutoCMake_LLVM_VERSION_MIN} CACHE STRING "Expected minimum `clang-tidy` version")
set(CxxAutoCMake_ClangTidy_VERSION_MAX ${CxxAutoCMake_LLVM_VERSION_MAX} CACHE STRING "Expected maximum `clang-tidy` version")

set(CxxAutoCMake_CodeChecker_VERSION_MIN IGNORE CACHE STRING "Expected minimum `CodeChecker` version")
set(CxxAutoCMake_CodeChecker_VERSION_MAX IGNORE CACHE STRING "Expected maximum `CodeChecker` version")

set(CxxAutoCMake_Homebrew_VERSION_MIN IGNORE CACHE STRING "Expected minimum Homebrew version")
set(CxxAutoCMake_Homebrew_VERSION_MAX IGNORE CACHE STRING "Expected maximum Homebrew version")

set(CxxAutoCMake_IncludeWhatYouUse_VERSION_MIN IGNORE CACHE STRING "Expected minimum IncludeWhatYouUse version")
set(CxxAutoCMake_IncludeWhatYouUse_VERSION_MAX IGNORE CACHE STRING "Expected maximum IncludeWhatYouUse version")

set(CxxAutoCMake_LLVMConfig_VERSION_MIN ${CxxAutoCMake_LLVM_VERSION_MIN} CACHE STRING "Expected minimum `llvm-config` version")
set(CxxAutoCMake_LLVMConfig_VERSION_MAX ${CxxAutoCMake_LLVM_VERSION_MAX} CACHE STRING "Expected maximum `llvm-config` version")

set(CxxAutoCMake_Python3_VERSION_MIN IGNORE CACHE STRING "Expected minimum `python3` version")
set(CxxAutoCMake_Python3_VERSION_MAX IGNORE CACHE STRING "Expected minimum `python3` version")

set(CxxAutoCMake_RustC_VERSION_MIN IGNORE CACHE STRING "Expected minimum `rustc` version")
set(CxxAutoCMake_RustC_VERSION_MAX IGNORE CACHE STRING "Expected minimum `rustc` version")

set(CxxAutoCMake_Rustup_VERSION_MIN IGNORE CACHE STRING "Expected minimum `rustup` version")
set(CxxAutoCMake_Rustup_VERSION_MAX IGNORE CACHE STRING "Expected minimum `rustup` version")

set(CxxAutoCMake_Sccache_VERSION_MIN IGNORE CACHE STRING "Expected minimum `sccache` version")
set(CxxAutoCMake_Sccache_VERSION_MAX IGNORE CACHE STRING "Expected minimum `sccache` version")

set(CxxAutoCMake_Scoop_VERSION_MIN IGNORE CACHE STRING "Expected minimum Scoop version")
set(CxxAutoCMake_Scoop_VERSION_MAX IGNORE CACHE STRING "Expected maximum Scoop version")

set(CxxAutoCMake_Swift_VERSION_MIN 5.8.1 CACHE STRING "Expected minimum Swift version")
set(CxxAutoCMake_Swift_VERSION_MAX 5.9.0 CACHE STRING "Expected minimum Swift version")

set(CxxAutoCMake_Valgrind_VERSION_MIN IGNORE CACHE STRING "Expected minimum `valgrind` version")
set(CxxAutoCMake_Valgrind_VERSION_MAX IGNORE CACHE STRING "Expected minimum `valgrind` version")

option(CxxAutoCMake_ENABLE_ADDRESS_SANITIZER "Enable Clang's AddressSanitizer")
option(CxxAutoCMake_ENABLE_LEAK_SANITIZER "Enable Clang's LeakSanitizer")
option(CxxAutoCMake_ENABLE_MEMORY_SANITIZER "Enable Clang's MemorySanitizer")
option(CxxAutoCMake_ENABLE_THREAD_SANITIZER "Enable Clang's ThreadSanitizer")
option(CxxAutoCMake_ENABLE_UNDEFINED_BEHAVIOR_SANITIZER "Enable Clang's UndefinedBehaviorSanitizer")

# set(CxxAutoCMake_CONTEXT_COMPILE_DEFINITIONS
#   -D_LIBCPP_ENABLE_THREAD_SAFETY_ANNOTATIONS)
# set(CxxAutoCMake_CONTEXT_COMPILE_OPTIONS
#   -fno-rtti
#   -std=gnu++20
#   -Wall
#   -Werror
#   -Wextra
#   -pedantic
#   -Wno-ambiguous-reversed-operator
#   -Wno-deprecated-anon-enum-enum-conversion
#   -Wno-deprecated-builtins
#   -Wno-dollar-in-identifier-extension
#   -Wno-nested-anon-types
#   -Wno-unused-parameter
#   -Wthread-safety
#   -Wthread-safety-beta)
