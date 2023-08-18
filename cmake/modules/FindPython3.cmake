set(CxxAutoCMake_FindPython3_CALLERS_CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH})
list(REMOVE_ITEM CMAKE_MODULE_PATH
  "${CxxAutoCMake_SOURCE_DIR}/cmake"
  "${CxxAutoCMake_SOURCE_DIR}/cmake/modules"
)

set(CxxAutoCMake_FindPython3_REQUIRED_COMPONENTS)
set(CxxAutoCMake_FindPython3_OPTIONAL_COMPONENTS)

foreach(component ${Python3_FIND_COMPONENTS})
  if(${Python3_FIND_REQUIRED_${component}})
    list(APPEND CxxAutoCMake_FindPython3_REQUIRED_COMPONENTS ${component})
  else()
    list(APPEND CxxAutoCMake_FindPython3_OPTIONAL_COMPONENTS ${component})
  endif()
endforeach()

# Find the `Python3` CMake package.
#
# NOTE: The find procedure for `Python3` appears recursive as we invoke `find_package(Python3)` from
# within `FindPython3.cmake`. However, the procedure will not recurse because we modify
# `CMAKE_MODULE_PATH` before the inner invocation, so this file will not be re-processed.
CxxAutoCMake_find_package(Python3
  QUIET
  COMPONENTS ${CxxAutoCMake_FindPython3_REQUIRED_COMPONENTS}
  OPTIONAL_COMPONENTS ${CxxAutoCMake_FindPython3_OPTIONAL_COMPONENTS}
)
mark_as_advanced(Python3_DIR)

# Configure the Python3 package variables.
find_package_handle_standard_args(Python3
  REQUIRED_VARS
    Python3_VERSION
    VERSION_VAR Python3_VERSION
    HANDLE_VERSION_RANGE
    HANDLE_COMPONENTS
)
set_property(GLOBAL PROPERTY CxxAutoCMake_Python3_FOUND ${Python3_FOUND})

set(CMAKE_MODULE_PATH ${CxxAutoCMake_FindPython3_CALLERS_CMAKE_MODULE_PATH})
unset(CxxAutoCMake_FindPython3_CALLERS_CMAKE_MODULE_PATH)
