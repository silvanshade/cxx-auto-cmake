include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)

# The `llvm-config` tool version extraction regex.
set(LLVMConfig_VERSION_REGEX ${CxxAutoCMake_VERSION_COMPONENT_REGEX})
set(LLVMConfig_VERSION_TOTAL_MATCH 0)
set(LLVMConfig_VERSION_MAJOR_MATCH 1)
set(LLVMConfig_VERSION_MINOR_MATCH 3)
set(LLVMConfig_VERSION_PATCH_MATCH 5)
set(LLVMConfig_VERSION_TWEAK_MATCH 7)
set(LLVMConfig_VARIANT_MATCH IGNORE)

iF(NOT DEFINED LLVMConfig_DIR)
  set(LLVMConfig_DIR)
else()
  message(NOTICE "Using -DLLVMConfig_DIR=${LLVMConfig_DIR}")
endif()

set(LLVMConfig_FIND_VERSION_MAJOR 0)
set(Homebrew_LLVM_FORMULA_VERSION)
set(Homebrew_LLVM_FORMULA_BINARY_DIR)

# If Homebrew is available, try to find the LLVM formula binary directory to use as an additional
# path to check for `llvm-config`. This is mainly useful on macOS, where Homebrew is the most common
# way to install LLVM, but on macOS the formula binary directory is not linked into the system
# `PATH` by default, so as not to clash with the Xcode-bundled Apple clang toolchain.
if(TARGET CxxAutoCMake::Homebrew)
  block()
    # FIXME: scan descending
    if(${LLVMConfig_FIND_VERSION_MAJOR} GREATER 0)
      set(Homebrew_LLVM_FORMULA_VERSION "@${LLVMConfig_FIND_VERSION_MAJOR}")
    endif()

    get_target_property(Homebrew_EXECUTABLE CxxAutoCMake::Homebrew IMPORTED_LOCATION)

    execute_process(COMMAND ${Homebrew_EXECUTABLE} --prefix "llvm${Homebrew_LLVM_FORMULA_VERSION}"
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(${command_result} EQUAL 0)
      set(Homebrew_LLVM_FORMULA_BINARY_DIR "${command_output}/bin" PARENT_SCOPE)
    endif()
  endblock()
endif()

# The `llvm-config` tool validation function.
function(validator result candidate)
  execute_process(COMMAND ${candidate} --version
    RESULT_VARIABLE command_result
    OUTPUT_VARIABLE command_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  CxxAutoCMake_extract_and_validate_executable_version(LLVMConfig
    LLVMConfig_VERSION_REGEX
    LLVMConfig_VERSION_TOTAL_MATCH
    LLVMConfig_VARIANT_MATCH
    candidate
    command_result
    command_output
    result
  )
  # FIXME: does `llvm-config` ever report a variant in `--version` output?
  # CxxAutoCMake_validate_llvm_toolchain_variant(LLVMConfig_VARIANT_MATCH result)
endfunction()

# Find the `llvm-config` tool.
CxxAutoCMake_find_program(LLVMConfig llvm-config
  HINTS ${LLVMConfig_DIR}
  PATHS ${Homebrew_LLVM_FORMULA_BINARY_DIR}
  VALIDATOR validator
  NO_CACHE
)
unset(Homebrew_LLVM_FORMULA_BINARY_DIR)

if(CxxAutoCMake_LLVMConfig_EXECUTABLE)
  # Extract the `llvm-config` tool version components.
  block()
    execute_process(COMMAND ${CxxAutoCMake_LLVMConfig_EXECUTABLE} --version
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `llvm-config` tool `--version` command failed.")
    endif()
    if(${command_output} MATCHES ${LLVMConfig_VERSION_REGEX})
      CxxAutoCMake_extract_and_set_executable_version_variables(LLVMConfig)
      # FIXME: does `llvm-config` ever report a variant in `--version` output?
      # if(NOT CMAKE_MATCH_${LLVMConfig_VARIANT_MATCH} STREQUAL "")
      #   set(LLVMConfig_VARIANT ${CMAKE_MATCH_${LLVMConfig_VARIANT_MATCH}} PARENT_SCOPE)
      # endif()
    endif()
  endblock()

  # Query the `llvm-config` tool for the LLVM executables directory. This directory will be used as
  # hints for calls to `find_program` for other LLVM tools (clang, clang++, etc). Again, this is
  # mainly useful on macOS where these tools will not be linked into the system `PATH` by default.
  block()
    execute_process(COMMAND ${CxxAutoCMake_LLVMConfig_EXECUTABLE} --bindir
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `llvm-config` tool `--bindir` command failed.")
    endif()
    file(TO_CMAKE_PATH "${command_output}" command_output)
    set(LLVMConfig_BINARY_DIR "${command_output}" PARENT_SCOPE)
  endblock()

  # Query the `llvm-config` tool for the LLVM CMake directory.
  block()
    execute_process(COMMAND ${CxxAutoCMake_LLVMConfig_EXECUTABLE} --cmakedir
      RESULT_VARIABLE command_result
      OUTPUT_VARIABLE command_output
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NOT ${command_result} EQUAL 0)
      message(FATAL_ERROR "The `llvm-config` tool `--cmakedir` command failed.")
    endif()
    file(TO_CMAKE_PATH "${command_output}" command_output)
    set(LLVMConfig_CMAKE_DIR "${command_output}" PARENT_SCOPE)
  endblock()
endif()

# Configure the `llvm-config` tool package variables.
find_package_handle_standard_args(LLVMConfig
  REQUIRED_VARS
    CxxAutoCMake_LLVMConfig_EXECUTABLE
  VERSION_VAR LLVMConfig_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_LLVMConfig_FOUND ${LLVMConfig_FOUND})

# Define the `llvm-config` tool package targets.
if(${LLVMConfig_FOUND} AND NOT TARGET CxxAutoCMake::LLVMConfig)
  CxxAutoCMake_define_target_executable(LLVMConfig)
  set_target_properties(CxxAutoCMake::LLVMConfig PROPERTIES
    BINARY_DIR "${LLVMConfig_BINARY_DIR}"
    CMAKE_DIR "${LLVMConfig_CMAKE_DIR}"
  )
endif()
