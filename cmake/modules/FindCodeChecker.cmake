include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)

# The `CodeChecker` tool version extraction regex.
set(CodeChecker_VERSION_REGEX "CodeChecker analyzer version:.*\nBase package version[ \t\r\n]*\\|[ \t\r\n]*(${CxxAutoCMake_VERSION_COMPONENT_REGEX})")
set(CodeChecker_VERSION_TOTAL_MATCH 1)
set(CodeChecker_VERSION_MAJOR_MATCH 2)
set(CodeChecker_VERSION_MINOR_MATCH 4)
set(CodeChecker_VERSION_PATCH_MATCH 6)
set(CodeChecker_VERSION_TWEAK_MATCH 8)
set(CodeChecker_VARIANT_MATCH IGNORE)

set(ClangCC_VARIANT_MATCH 1)

# The `CodeChecker` tool validation function.
function(validator result candidate)
  # Obtain the `CodeChecker` tool `version` output.
  execute_process(COMMAND ${candidate} version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `CodeChecker` tool `version` output.
  CxxAutoCMake_extract_and_validate_executable_version(CodeChecker
    CodeChecker_VERSION_REGEX
    CodeChecker_VERSION_TOTAL_MATCH
    ClangCC_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
endfunction()

# Find the `CodeChecker` tool.
CxxAutoCMake_find_program(CodeChecker CodeChecker
  NAMES codechecker
  VALIDATOR validator
  NO_CACHE
)

# Extract the `CodeChecker` tool version components.
if(CxxAutoCMake_CodeChecker_EXECUTABLE)
  block()
    # Obtain the `CodeChecker` tool `version` output.
    execute_process(COMMAND ${CxxAutoCMake_CodeChecker_EXECUTABLE} version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `CodeChecker` tool `version` command failed.")
    endif()
    # Parse the `CodeChecker` tool `version` output.
    if(${command_output} MATCHES ${CodeChecker_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(CodeChecker)
    endif()
  endblock()
endif()

# Configure the `CodeChecker` tool package variables.
find_package_handle_standard_args(CodeChecker
  REQUIRED_VARS
    CxxAutoCMake_CodeChecker_EXECUTABLE
  VERSION_VAR CodeChecker_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_CodeChecker_FOUND ${CodeChecker_FOUND})

# Define the `CodeChecker` tool package targets.
if(${CodeChecker_FOUND} AND NOT TARGET CxxAutoCMake::CodeChecker)
  CxxAutoCMake_define_target_executable(CodeChecker)
endif()
