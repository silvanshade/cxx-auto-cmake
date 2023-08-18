include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)

# The `Homebrew` tool version extraction regex.
set(Homebrew_VERSION_REGEX "^Homebrew (${CxxAutoCMake_VERSION_COMPONENT_REGEX})")
set(Homebrew_VERSION_TOTAL_MATCH 1)
set(Homebrew_VERSION_MAJOR_MATCH 2)
set(Homebrew_VERSION_MINOR_MATCH 4)
set(Homebrew_VERSION_PATCH_MATCH 6)
set(Homebrew_VERSION_TWEAK_MATCH 8)
set(Homebrew_VARIANT_MATCH IGNORE)

# The `Homebrew` tool validation function.
function(validator result candidate)
  # Obtain the `Homebrew` tool `--version` output.
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Validate the `Homebrew` tool `--version` output.
  CxxAutoCMake_extract_and_validate_executable_version(Homebrew
    Homebrew_VERSION_REGEX
    Homebrew_VERSION_TOTAL_MATCH
    Homebrew_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
endfunction()

# Find the `Homebrew` tool.
CxxAutoCMake_find_program(Homebrew brew
  VALIDATOR validator
  NO_CACHE
)

# Extract the `Homebrew` tool version components.
if(CxxAutoCMake_Homebrew_EXECUTABLE)
  block()
    # Obtain the `Homebrew` tool `--version` output.
    execute_process(COMMAND ${CxxAutoCMake_Homebrew_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `brew` tool `--version` command failed.")
    endif()
    # Parse the `Homebrew` tool `--version` output.
    if(${command_output} MATCHES ${Homebrew_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(Homebrew)
    endif()
  endblock()

  # Obtain the `Homebrew` tool `--prefix` output.
  block()
    execute_process(COMMAND ${CxxAutoCMake_Homebrew_EXECUTABLE} --prefix
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    # Error on non-zero exit code.
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `brew` tool `--prefix` command failed.")
    endif()
    # Store the `Homebrew` tool `--prefix` output.
    set(Homebrew_PREFIX ${command_output} PARENT_SCOPE)
  endblock()
endif()

# Configure the `Homebrew` tool package variables.
find_package_handle_standard_args(Homebrew
  REQUIRED_VARS
    CxxAutoCMake_Homebrew_EXECUTABLE
  VERSION_VAR Homebrew_VERSION
  HANDLE_VERSION_RANGE)
set_property(GLOBAL PROPERTY CxxAutoCMake_Homebrew_FOUND ${Homebrew_FOUND})

# Define the `Homebrew` tool package targets.
if(${Homebrew_FOUND} AND NOT TARGET CxxAutoCMake::Homebrew)
  CxxAutoCMake_define_target_executable(Homebrew)
  set_target_properties(CxxAutoCMake::Homebrew
    PROPERTIES Homebrew_PREFIX ${Homebrew_PREFIX})
endif()
