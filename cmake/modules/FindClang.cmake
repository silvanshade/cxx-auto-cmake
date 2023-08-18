include(FindPackageHandleStandardArgs)

include(modules/CxxAutoCMake/Support)

get_property(LLVM_FOUND GLOBAL PROPERTY CxxAutoCMake_LLVM_FOUND)
if(LLVM_FOUND)
  get_property(LLVM_DIR GLOBAL PROPERTY CxxAutoCMake_LLVM_DIR)
endif()

# Prepare to search for `Clang` relative to `LLVM`
if(NOT DEFINED Clang_DIR)
  set(Clang_DIR)
  if(DEFINED LLVM_DIR)
    set(Clang_DIR "${LLVM_DIR}/../llvm/../clang")
  endif()
else()
  message(NOTICE "Using -DClang_DIR=${Clang_DIR}")
endif()

# Recover variables from `LLVMConfig` target properties.
if(TARGET CxxAutoCMake::LLVMConfig)
  get_target_property(LLVMConfig_EXECUTABLE CxxAutoCMake::LLVMConfig IMPORTED_LOCATION)
endif()

# Expect that we haven't found Homebrew `Clang` by default.
set(Homebrew_Clang_DIR_FOUND FALSE)

# Determine if we found `${Clang_DIR}` within the Homebrew prefix. If so, we will adjust the
# `CMAKE_PREFIX_PATH` so we also prioritize searching for the other libraries LLVM needs under the
# Homebrew prefix first, before checking other system locations.
if(TARGET CxxAutoCMake::Homebrew)
  block()
    # Recover variables from `Homebrew` target properties.
    get_target_property(Homebrew_PREFIX CxxAutoCMake::Homebrew Homebrew_PREFIX)
    get_target_property(Homebrew_LLVM_DIR_FOUND CxxAutoCMake::Homebrew LLVM_DIR_FOUND)

    # Check if `Clang_DIR` is a prefix of the Homebrew prefix path.
    set(prefix_index -1)
    string(FIND ${Clang_DIR} ${Homebrew_PREFIX} prefix_index)

    # `Clang_DIR` *is* contained within `Homebrew_PREFIX`.
    if(${prefix_index} EQUAL 0)
      message(VERBOSE "Considering Clang variant Homebrew")
      set(Homebrew_Clang_DIR_FOUND TRUE PARENT_SCOPE)

      # Adjust `CMAKE_PREFIX_PATH` to priorize searching for related dependencies within Homebrew.
      LIST(PREPEND CMAKE_PREFIX_PATH ${Homebrew_PREFIX})
      set(CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH} PARENT_SCOPE)

      # Warn about potential issues with using Homebrew `Clang` with non-Homebrew `LLVM`.
      if(NOT ${Homebrew_LLVM_DIR_FOUND})
        message(WARNING "Using Homebrew Clang with non-Homebrew LLVM. This will likely fail.")
      endif()
    # `Clang_DIR` *is not* contained within but `LLVM_DIR` *is* contained within `Homebrew_PREFIX`.
    else()
      # Warn about potential issues with using non-Homebrew `Clang` with Homebrew `LLVM`.
      if(${Homebrew_LLVM_DIR_FOUND})
        message(WARNING "Using non-Homebrew Clang with Homebrew LLVM. This will likely fail.")
      endif()
    endif()
  endblock()
endif()

if(TARGET CxxAutoCMake::Homebrew)
  # Set properties on the `Homebrew` target detailing whether Homebrew `Clang` was found.
  set_target_properties(CxxAutoCMake::Homebrew PROPERTIES
    Clang_DIR_FOUND ${Homebrew_Clang_DIR_FOUND}
  )
  if(${Homebrew_Clang_DIR_FOUND})
    set_target_properties(CxxAutoCMake::Homebrew PROPERTIES
      Clang_DIR ${Clang_DIR}
  )
  endif()
endif()

# Find the `Clang` CMake package.
#
# NOTE: The find procedure for `Clang` appears recursive as we invoke `find_package(Clang)` from
# within `FindClang.cmake`. However, the procedure will not recurse because we specify `CONFIG`
# mode, triggering a search for `ClangConfig.cmake` module at the specified path.
CxxAutoCMake_find_package(Clang
  CONFIG
  PATHS ${Clang_DIR}
  NO_DEFAULT_PATH
)
mark_as_advanced(Clang_DIR)

# NOTE: This is safe to assume because the local CxxAutoCMake component `FindClang.cmake`
# environment is isolated from the local CxxAutoCMake component `FindLLVM.cmake` environment. Thus,
# if `LLVM_VERSION` is set, it is because it was set by the found `ClangConfig.cmake` module.
if(NOT DEFINED Clang_VERSION AND DEFINED LLVM_VERSION)
  set(Clang_VERSION ${LLVM_VERSION})
endif()

# Configure the `Clang` package variables.
find_package_handle_standard_args(Clang
  REQUIRED_VARS
    Clang_VERSION
    Clang_DIR
    CLANG_CMAKE_DIR
    CLANG_INCLUDE_DIRS
    VERSION_VAR Clang_VERSION
    HANDLE_VERSION_RANGE
)
set_property(GLOBAL PROPERTY CxxAutoCMake_Clang_FOUND ${Clang_FOUND})

if(${Clang_FOUND})
  set_property(GLOBAL PROPERTY CxxAutoCMake_Clang_DIR ${Clang_DIR})
endif()
