# Scan include directories for headers and generate an umbrella .cxx file that includes them all.
# This umbrella file is then compiled as a library by CMake. This serves as an additional sanity
# check for the overall build system, as it ensures that all headers in the source tree have been
# checked together at least once, regardless of whether they have been included in a cxx bridge.

foreach(include_dir ${TARGET_UMBRELLA_INCLUDE_DIRS})
  file(GLOB_RECURSE headers
    RELATIVE ${include_dir}
    ${include_dir}/**/*.[hH]
    ${include_dir}/**/*.[hH][pP]
    ${include_dir}/**/*.[hH][pP][pP]
    ${include_dir}/**/*.[hH][xX][xX]
    ${include_dir}/**/*.[hH]++)
  foreach(header ${headers})
    string(APPEND content "#include \"${TARGET_UMBRELLA_INCLUDE_PREFIX}${header}\"\n")
  endforeach()
endforeach()

cmake_path(GET TARGET_UMBRELLA_PATH
  PARENT_PATH target_umbrella_parent_path)
file(MAKE_DIRECTORY ${target_umbrella_parent_path})
file(WRITE ${TARGET_UMBRELLA_PATH} ${content})
