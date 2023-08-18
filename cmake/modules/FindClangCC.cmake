include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)
include(modules/Clang/Support)

# The `clang` tool version extraction regex.
set(ClangCC_VERSION_REGEX ${Clang_VERSION_REGEX})
set(ClangCC_VERSION_TOTAL_MATCH 2)
set(ClangCC_VERSION_MAJOR_MATCH 3)
set(ClangCC_VERSION_MINOR_MATCH 5)
set(ClangCC_VERSION_PATCH_MATCH 7)
set(ClangCC_VERSION_TWEAK_MATCH 9)
set(ClangCC_VARIANT_MATCH 1)

# The `clang` tool validation function.
function(validator result candidate)
  # Obtain the `clang` tool `--version` output.
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `clang` tool `--version` output.
  CxxAutoCMake_extract_and_validate_executable_version(ClangCC
    ClangCC_VERSION_REGEX
    ClangCC_VERSION_TOTAL_MATCH
    ClangCC_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
  # Validate the `clang` tool `--version` output (for toolchain variant).
  CxxAutoCMake_validate_llvm_toolchain_variant(ClangCC_VARIANT_MATCH result)
endfunction()

# Recover variables from `LLVMConfig` target properties.
set(LLVMConfig_BINARY_DIR)
if(TARGET CxxAutoCMake::LLVMConfig)
  get_target_property(LLVMConfig_BINARY_DIR CxxAutoCMake::LLVMConfig BINARY_DIR)
endif()

# Find the `clang` tool.
CxxAutoCMake_find_program(ClangCC clang
  HINTS ${LLVMConfig_BINARY_DIR}
  VALIDATOR validator
  NO_CACHE
)

# Extract the `clang` tool version components.
if(CxxAutoCMake_ClangCC_EXECUTABLE)
  block()
    # Obtain the `clang` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_ClangCC_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `clang` tool `--version` command failed.")
    endif()
    # Parse the `clang` tool `--version` output.
    if(${command_output} MATCHES ${ClangCC_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(ClangCC)
      if(NOT ${CMAKE_MATCH_${ClangCC_VARIANT_MATCH}} STREQUAL "")
        set(ClangCC_VARIANT ${CMAKE_MATCH_${ClangCC_VARIANT_MATCH}} PARENT_SCOPE)
      endif()
    endif()
  endblock()
endif()

# Configure the `clang` tool package variables.
find_package_handle_standard_args(ClangCC
  REQUIRED_VARS
    CxxAutoCMake_ClangCC_EXECUTABLE
  VERSION_VAR ClangCC_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_ClangCC_FOUND ${ClangCC_FOUND})

# Define the `clang` tool package targets.
if(${ClangCC_FOUND} AND NOT TARGET CxxAutoCMake::ClangCC)
  CxxAutoCMake_define_target_executable(ClangCC)
endif()
