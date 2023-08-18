# FIXME: express dependency on `FindRustup` somehow.

include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)
include(modules/Clang/Support)

# The `rustc` tool version extraction regex.
set(RustC_VERSION_REGEX "^rustc[ \t\r\n]+(${CxxAutoCMake_VERSION_COMPONENT_REGEX})")
set(RustC_VERSION_TOTAL_MATCH 1)
set(RustC_VERSION_MAJOR_MATCH 2)
set(RustC_VERSION_MINOR_MATCH 4)
set(RustC_VERSION_PATCH_MATCH 6)
set(RustC_VERSION_TWEAK_MATCH 8)
set(RustC_VARIANT_MATCH IGNORE)

# The `rustc` tool version extraction regex for its corresponding `LLVM` version.
set(RustC_LLVM_VERSION_REGEX ".*\nLLVM[ \t\r\n]+version:[ \t\r\n]+(${CxxAutoCMake_VERSION_COMPONENT_REGEX})")
set(RustC_LLVM_VERSION_TOTAL_MATCH 1)
set(RustC_LLVM_VERSION_MAJOR_MATCH 2)
set(RustC_LLVM_VERSION_MINOR_MATCH 4)
set(RustC_LLVM_VERSION_PATCH_MATCH 6)
set(RustC_LLVM_VERSION_TWEAK_MATCH 8)
set(RustC_LLVM_VARIANT_MATCH IGNORE)

# The `rustc` tool validation function.
function(validator result candidate)
  execute_process(COMMAND ${candidate} --version --verbose
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `rustc` tool `--version` output.
  CxxAutoCMake_extract_and_validate_executable_version(RustC
    RustC_VERSION_REGEX
    RustC_VERSION_TOTAL_MATCH
    RustC_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
  # Parse the `rustc` tool `--version` output (for LLVM toolchain).
  if(NOT ${command_output} MATCHES ${RustC_LLVM_VERSION_REGEX})
    message(WARNING "regex `RustC_LLVM_VERSION_REGEX` failed to parse version for `${candidate}`")
    set(${result} FALSE PARENT_SCOPE)
    return()
  endif()
  if(DEFINED ClangCC_VERSION)
    # Check if the toolchain variant is major-version compatible with the already found `clang`.
    if(NOT ${CMAKE_MATCH_${RustC_LLVM_VERSION_MAJOR_MATCH}} VERSION_GREATER_EQUAL ${ClangCC_VERSION_MAJOR})
      message(WARNING "`RustC_LLVM_VERSION_MAJOR` does not match `ClangCC_VERSION_MAJOR`: ${CMAKE_MATCH_${RustC_LLVM_VERSION_MAJOR_MATCH}} != ${ClangCC_VERSION_MAJOR}")
      set(${result} FALSE PARENT_SCOPE)
      return()
    endif()
  endif()
  if(DEFINED ClangCXX_VERSION_MAJOR)
    # Check if the toolchain variantis major-version compatible with the already found `clang++`.
    if(NOT ${CMAKE_MATCH_${RustC_LLVM_VERSION_MAJOR_MATCH}} VERSION_GREATER_EQUAL ${ClangCXX_VERSION_MAJOR})
    message(WARNING "`RustC_LLVM_VERSION_MAJOR` does not match `ClangCXX_VERSION_MAJOR`: ${CMAKE_MATCH_${RustC_LLVM_VERSION_MAJOR_MATCH}} != ${ClangCXX_VERSION_MAJOR}")
      set(${result} FALSE PARENT_SCOPE)
      return()
    endif()
  endif()
endfunction()

# Find the `rustc` tool.
CxxAutoCMake_find_program(RustC rustc
  VALIDATOR validator
  NO_CACHE
)

# Extract the `rustc` tool version components.
if(CxxAutoCMake_RustC_EXECUTABLE)
  block()
    # Obtain the `rustc` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_RustC_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `rustc` tool `--version` command failed.")
    endif()
    # Parse the `rustc` tool `--version` output.
    if(${command_output} MATCHES ${RustC_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(RustC)
    endif()
    # Parse the `rustc` tool `--version` output (for toolchain variant).
    if(${command_output} MATCHES ${RustC_LLVM_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(RustC_LLVM)
      if(NOT ${CMAKE_MATCH_${RustC_LLVM_VARIANT_MATCH}} STREQUAL "")
        set(RustC_LLVM_VARIANT ${CMAKE_MATCH_${RustC_LLVM_VARIANT_MATCH}} PARENT_SCOPE)
      endif()
    endif()
  endblock()
endif()

# Configure the `rustc` tool package variables.
find_package_handle_standard_args(RustC
  REQUIRED_VARS
    CxxAutoCMake_RustC_EXECUTABLE
  VERSION_VAR RustC_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_RustC_FOUND ${RustC_FOUND})

# Define the `rustc` tool package targets.
if(${RustC_FOUND} AND NOT TARGET CxxAutoCMake::RustC)
  CxxAutoCMake_define_target_executable(RustC)
endif()
