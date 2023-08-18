include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)
include(modules/Clang/Support)

# The `clang++` tool version extraction regex.
set(ClangCXX_VERSION_REGEX ${Clang_VERSION_REGEX})
set(ClangCXX_VERSION_TOTAL_MATCH 2)
set(ClangCXX_VERSION_MAJOR_MATCH 3)
set(ClangCXX_VERSION_MINOR_MATCH 5)
set(ClangCXX_VERSION_PATCH_MATCH 7)
set(ClangCXX_VERSION_TWEAK_MATCH 9)
set(ClangCXX_VARIANT_MATCH 1)

# The `clang++` tool validation function.
function(validator result candidate)
  # Obtain the `clang++` tool `--version` output.
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `clang++` tool `--version` output.
  CxxAutoCMake_extract_and_validate_executable_version(ClangCXX
    ClangCXX_VERSION_REGEX
    ClangCXX_VERSION_TOTAL_MATCH
    ClangCXX_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
  # Validate the `clang++` tool `--version` output (for toolchain variant).
  CxxAutoCMake_validate_llvm_toolchain_variant(ClangCXX_VARIANT_MATCH result)
endfunction()

# Recover variables from `LLVMConfig` target properties.
set(LLVMConfig_BINARY_DIR)
if(TARGET CxxAutoCMake::LLVMConfig)
  get_target_property(LLVMConfig_BINARY_DIR CxxAutoCMake::LLVMConfig BINARY_DIR)
endif()

# Find the `clang++` tool.
CxxAutoCMake_find_program(ClangCXX clang++
  HINTS ${LLVMConfig_BINARY_DIR}
  VALIDATOR validator
  NO_CACHE
)

# Extract the `clang++` tool version components.
if(CxxAutoCMake_ClangCXX_EXECUTABLE)
  block()
    # Obtain the `clang++` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_ClangCXX_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `clang++` tool `--version` command failed.")
    endif()
    # Parse the `clang++` tool `--version` output.
    if(${command_output} MATCHES ${ClangCXX_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(ClangCXX)
      if(NOT ${CMAKE_MATCH_${ClangCXX_VARIANT_MATCH}} STREQUAL "")
        set(ClangCXX_VARIANT ${CMAKE_MATCH_${ClangCXX_VARIANT_MATCH}} PARENT_SCOPE)
      endif()
    endif()
  endblock()
endif()

# Configure the `clang++` tool package variables.
find_package_handle_standard_args(ClangCXX
  REQUIRED_VARS
    CxxAutoCMake_ClangCXX_EXECUTABLE
  VERSION_VAR ClangCXX_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_ClangCXX_FOUND ${ClangCXX_FOUND})

# Define the `clang++` tool package targets.
if(${ClangCXX_FOUND} AND NOT TARGET CxxAutoCMake::ClangCXX)
  CxxAutoCMake_define_target_executable(ClangCXX)
endif()
