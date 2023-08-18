include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)

# The `rustup` tool version extraction regex.
set(Rustup_VERSION_REGEX "rustup[ \t\n\r]+(${CxxAutoCMake_VERSION_COMPONENT_REGEX})")
set(Rustup_VERSION_TOTAL_MATCH 1)
set(Rustup_VERSION_MAJOR_MATCH 2)
set(Rustup_VERSION_MINOR_MATCH 4)
set(Rustup_VERSION_PATCH_MATCH 6)
set(Rustup_VERSION_TWEAK_MATCH 8)
set(Rustup_VARIANT_MATCH IGNORE)

# The `rustup` tool validation function.
function(validator result candidate)
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
  )
  CxxAutoCMake_extract_and_validate_executable_version(Rustup
    Rustup_VERSION_REGEX
    Rustup_VERSION_TOTAL_MATCH
    Rustup_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
endfunction()

# Find the `rustup` tool.
CxxAutoCMake_find_program(Rustup rustup
  VALIDATOR validator
  NO_CACHE
)

# Extract the `rustup` tool version components.
if(CxxAutoCMake_Rustup_EXECUTABLE)
  block()
    # Obtain the `rustup` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_Rustup_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
      ERROR_QUIET
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `rustup` tool `--version` command failed.")
    endif()
    # Parse the `rustup` tool `--version` output.
    if(${command_output} MATCHES ${Rustup_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(Rustup)
    endif()
  endblock()
endif()

# Configure the `rustup` tool package variables.
find_package_handle_standard_args(Rustup
  REQUIRED_VARS
    CxxAutoCMake_Rustup_EXECUTABLE
  VERSION_VAR Rustup_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_Rustup_FOUND ${Rustup_FOUND})

# Define the `rustup` tool package targets.
if(${Rustup_FOUND} AND NOT TARGET CxxAutoCMake::Rustup)
  CxxAutoCMake_define_target_executable(Rustup)
endif()
