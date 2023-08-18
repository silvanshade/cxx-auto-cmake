include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)

# Recover variables from `LLVMConfig` target properties.
if(TARGET CxxAutoCMake::LLVMConfig)
  get_target_property(LLVMConfig_EXECUTABLE CxxAutoCMake::LLVMConfig IMPORTED_LOCATION)
  get_target_property(LLVM_CMAKE_DIR CxxAutoCMake::LLVMConfig CMAKE_DIR)
endif()

# Expect that we haven't found Homebrew `LLVM` by default.
set(Homebrew_LLVM_DIR_FOUND FALSE)

# Determine if we found `${LLVM_DIR}` or `llvm-config` within the Homebrew prefix. If so, we will
# adjust the `CMAKE_PREFIX_PATH` so we also prioritize searching for the other libraries LLVM needs
# under the Homebrew prefix first, before checking other system locations.
if(TARGET CxxAutoCMake::Homebrew)
  block()

    # Recover variables from `Homebrew` target properties.
    get_target_property(Homebrew_PREFIX CxxAutoCMake::Homebrew Homebrew_PREFIX)

    # Check if `LLVM_DIR` or `llvm-config` executable path is a prefix of the Homebrew prefix path.
    set(prefix_index -1)
    if(DEFINED LLVM_DIR)
      string(FIND ${LLVM_DIR} ${Homebrew_PREFIX} prefix_index)
    elseif(TARGET CxxAutoCMake::LLVMConfig)
      get_filename_component(LLVMConfig_EXECUTABLE_DIR ${LLVMConfig_EXECUTABLE} DIRECTORY)
      string(FIND ${LLVMConfig_EXECUTABLE_DIR} ${Homebrew_PREFIX} prefix_index)
    endif()

    # `LLVM_DIR` *is* contained within `Homebrew_PREFIX`.
    if(${prefix_index} EQUAL 0)
      message(VERBOSE "Considering LLVM variant Homebrew")
      set(Homebrew_LLVM_DIR_FOUND TRUE PARENT_SCOPE)

      # Adjust `CMAKE_PREFIX_PATH` to priorize searching for related dependencies within Homebrew.
      LIST(PREPEND CMAKE_PREFIX_PATH ${Homebrew_PREFIX})
      set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)
    endif()
  endblock()
endif()

# If `LLVM_DIR` is not already defined, use the CMake directory reported from `llvm-config`.
if(NOT DEFINED LLVM_DIR)
  set(LLVM_DIR)
  if(TARGET CxxAutoCMake::LLVMConfig)
    set(LLVM_DIR "${LLVM_CMAKE_DIR}")
  endif()
else()
  message(NOTICE "Using -DLLVM_DIR=${LLVM_DIR}")
endif()

if(TARGET CxxAutoCMake::Homebrew)
  # Set properties on the `Homebrew` target detailing whether Homebrew `LLVM` was found.
  set_target_properties(CxxAutoCMake::Homebrew PROPERTIES
    LLVM_DIR_FOUND ${Homebrew_LLVM_DIR_FOUND}
  )
  if(${Homebrew_LLVM_DIR_FOUND})
    set_target_properties(CxxAutoCMake::Homebrew PROPERTIES
      LLVM_DIR ${LLVM_DIR}
    )
  endif()
endif()

# Find the `LLVM` CMake package.
#
# NOTE: The find procedure for `LLVM` appears recursive as we invoke `find_package(LLVM)` from
# within `FindLLVM.cmake`. However, the procedure will not recurse because we specify `CONFIG` mode,
# triggering a search for `LLVMConfig.cmake` module at the specified path.
CxxAutoCMake_find_package(LLVM
  CONFIG
  PATHS ${LLVM_DIR}
  NO_DEFAULT_PATH
)

# Configure the LLVM package variables.
find_package_handle_standard_args(LLVM
  REQUIRED_VARS
    LLVM_VERSION
    LLVM_DIR
    LLVM_CMAKE_DIR
    LLVM_DEFINITIONS
    LLVM_INCLUDE_DIRS
    LLVM_LIBRARY_DIRS
  VERSION_VAR LLVM_VERSION
  HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_LLVM_FOUND ${LLVM_FOUND})

if(${LLVM_FOUND})
  set_property(GLOBAL PROPERTY CxxAutoCMake_LLVM_DIR ${LLVM_DIR})
endif()
