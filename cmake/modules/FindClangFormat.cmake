include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)
include(modules/LLVM/Support)

# The `clang-format` tool version extraction regex.
set(ClangFormat_VERSION_REGEX "([^ \t\r\n]*)[ \t\r\n]*clang-format${LLVM_TOOL_VERSION_REGEX}")
set(ClangFormat_VERSION_TOTAL_MATCH 2)
set(ClangFormat_VERSION_MAJOR_MATCH 3)
set(ClangFormat_VERSION_MINOR_MATCH 5)
set(ClangFormat_VERSION_PATCH_MATCH 7)
set(ClangFormat_VERSION_TWEAK_MATCH 9)
set(ClangFormat_VARIANT_MATCH 1)

# The `clang-format` tool validation function.
function(validator result candidate)
  # Obtain the `clang-format` tool `--version` output.
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `clang-format` tool `--version` output.
  CxxAutoCMake_extract_and_validate_executable_version(ClangFormat
    ClangFormat_VERSION_REGEX
    ClangFormat_VERSION_TOTAL_MATCH
    ClangFormat_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
  # Validate the `clang-format` tool `--version` output (for toolchain variant).
  CxxAutoCMake_validate_llvm_toolchain_variant(ClangFormat_VARIANT_MATCH result)
endfunction()

# Recover variables from `LLVMConfig` target properties.
set(LLVMConfig_BINARY_DIR)
if(TARGET CxxAutoCMake::LLVMConfig)
  get_target_property(LLVMConfig_BINARY_DIR CxxAutoCMake::LLVMConfig BINARY_DIR)
endif()

# Find the `clang-format` tool.
CxxAutoCMake_find_program(ClangFormat clang-format
  HINTS ${LLVMConfig_BINARY_DIR}
  VALIDATOR validator
  NO_CACHE
)

# Extract the `clang-format` tool version components.
if(CxxAutoCMake_ClangFormat_EXECUTABLE)
  block()
    # Obtain the `clang-format` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_ClangFormat_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `clang-format` tool `--version` command failed.")
    endif()
    # Parse the `clang-format` tool `--version` output.
    if(${command_output} MATCHES ${ClangFormat_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(ClangFormat)
      if(NOT ${CMAKE_MATCH_${ClangFormat_VARIANT_MATCH}} STREQUAL "")
        set(ClangFormat_VARIANT ${CMAKE_MATCH_${ClangFormat_VARIANT_MATCH}} PARENT_SCOPE)
      endif()
    endif()
  endblock()
endif()

# Configure the `clang-format` tool package variables.
find_package_handle_standard_args(ClangFormat
  REQUIRED_VARS
    CxxAutoCMake_ClangFormat_EXECUTABLE
  VERSION_VAR ClangFormat_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_ClangFormat_FOUND ${ClangFormat_FOUND})

# Define the `clang-format` tool package targets.
if(${ClangFormat_FOUND} AND NOT TARGET CxxAutoCMake::ClangFormat)
  CxxAutoCMake_define_target_executable(ClangFormat)
endif()
