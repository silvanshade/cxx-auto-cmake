include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)
include(modules/LLVM/Support)

# The `clang-tidy` tool version extraction regex.
set(ClangTidy_VERSION_REGEX "([^ \t\r\n]*)[ \t\r\n]*LLVM${LLVM_TOOL_VERSION_REGEX}")
set(ClangTidy_VERSION_TOTAL_MATCH 2)
set(ClangTidy_VERSION_MAJOR_MATCH 3)
set(ClangTidy_VERSION_MINOR_MATCH 5)
set(ClangTidy_VERSION_PATCH_MATCH 7)
set(ClangTidy_VERSION_TWEAK_MATCH 9)
set(ClangTidy_VARIANT_MATCH 1)

# The `clang-tidy` tool validation function.
function(validator result candidate)
  # Obtain the `clang-tidy` tool `--version` output.
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `clang-tidy` tool `--version` output.
  CxxAutoCMake_extract_and_validate_executable_version(ClangTidy
    ClangTidy_VERSION_REGEX
    ClangTidy_VERSION_TOTAL_MATCH
    ClangTidy_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
  # Validate the `clang-tidy` tool `--version` output (for toolchain variant).
  CxxAutoCMake_validate_llvm_toolchain_variant(ClangTidy_VARIANT_MATCH result)
endfunction()

# Recover variables from `LLVMConfig` target properties.
set(LLVMConfig_BINARY_DIR)
if(TARGET CxxAutoCMake::LLVMConfig)
  get_target_property(LLVMConfig_BINARY_DIR CxxAutoCMake::LLVMConfig BINARY_DIR)
endif()

# Find the `clang-tidy` tool.
CxxAutoCMake_find_program(ClangTidy clang-tidy
  HINTS ${LLVMConfig_BINARY_DIR}
  VALIDATOR validator
  NO_CACHE
)

# Extract the `clang-tidy` tool version components.
if(CxxAutoCMake_ClangTidy_EXECUTABLE)
  block()
    # Obtain the `clang-tidy` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_ClangTidy_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `clang-tidy` tool `--version` command failed.")
    endif()
    # Parse the `clang-tidy` tool `--version` output.
    if(${command_output} MATCHES ${ClangTidy_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(ClangTidy)
      if(NOT ${CMAKE_MATCH_${ClangTidy_VARIANT_MATCH}} STREQUAL "")
        set(ClangTidy_VARIANT ${CMAKE_MATCH_${ClangTidy_VARIANT_MATCH}} PARENT_SCOPE)
      endif()
    endif()
  endblock()
endif()

# Configure the `clang-tidy` tool package variables.
find_package_handle_standard_args(ClangTidy
  REQUIRED_VARS
    CxxAutoCMake_ClangTidy_EXECUTABLE
  VERSION_VAR ClangTidy_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_ClangTidy_FOUND ${ClangTidy_FOUND})

# Define the `clang-tidy` tool package target.
if(${ClangTidy_FOUND} AND NOT TARGET CxxAutoCMake::ClangTidy)
  CxxAutoCMake_define_target_executable(ClangTidy)
endif()
