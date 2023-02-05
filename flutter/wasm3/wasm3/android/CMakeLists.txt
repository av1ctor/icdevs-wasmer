cmake_minimum_required(VERSION 3.11)

project(m3)

# Detect MinGW
if(WIN32 AND CMAKE_C_COMPILER_ID MATCHES "GNU")
  set(MINGW             1)
endif()

# Set options

if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "set build type to Release")
endif()

set(BUILD_WASI "simple" CACHE STRING "WASI implementation")
set_property(CACHE BUILD_WASI PROPERTY STRINGS none simple uvwasi metawasi)

option(BUILD_NATIVE "Build with machine-specific optimisations" ON)

# Configure the toolchain

if(CLANG OR CLANG_SUFFIX)
  set(CMAKE_C_COMPILER   "clang${CLANG_SUFFIX}")
  set(CMAKE_CXX_COMPILER "clang++${CLANG_SUFFIX}")
endif()

if(CLANG_CL)
  set(CMAKE_C_COMPILER   "clang-cl")
  set(CMAKE_CXX_COMPILER "clang-cl")
  set(CMAKE_LINKER       "lld-link")
endif()

if(BUILD_32BIT)
  set(CMAKE_C_FLAGS      "${CMAKE_C_FLAGS}   -m32")
endif()

message("Generator:  ${CMAKE_GENERATOR}")
message("Compiler:   ${CMAKE_C_COMPILER_ID}")
message("Build Type: ${CMAKE_BUILD_TYPE}")


set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED YES)
set(CMAKE_C_EXTENSIONS NO)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED YES)
set(CMAKE_CXX_EXTENSIONS NO)

#-fno-optimize-sibling-calls

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DDEBUG=1")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Dd_m3HasTracer") #-Dd_m3FixedHeap=1048576
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wparentheses -Wundef -Wpointer-arith -Wstrict-aliasing=2")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Werror=implicit-function-declaration") # -Werror=cast-align
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-function -Wno-unused-variable -Wno-unused-parameter -Wno-missing-field-initializers")
if (CMAKE_C_COMPILER_ID MATCHES "Clang")
	# TODO: Place clang-specific options here
elseif(CMAKE_C_COMPILER_ID MATCHES "Intel")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fp-model precise")
elseif(CMAKE_C_COMPILER_ID MATCHES "GNU")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wjump-misses-init")
endif()
set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -ggdb -O0")

set(CMAKE_C_FLAGS_RELEASE "-O3 -Wfatal-errors -fomit-frame-pointer -fno-stack-check -fno-stack-protector") #-fno-inline

if(BUILD_NATIVE)
	if(APPLE AND CMAKE_C_COMPILER_ID MATCHES "Clang" AND CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm64")
		set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -mcpu=native")
	else()
		set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -march=native")
	endif()
endif()

set(CMAKE_EXE_LINKER_FLAGS_DEBUG "-O0")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-O3")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Dd_m3HasWASI -DWASM_SIMPLE")

add_subdirectory(../ios/Classes/wasm3/source ./bin)

message("Flags:         ${CMAKE_C_FLAGS}")
message("Debug flags:   ${CMAKE_C_FLAGS_DEBUG}")
message("Release flags: ${CMAKE_C_FLAGS_RELEASE}")

