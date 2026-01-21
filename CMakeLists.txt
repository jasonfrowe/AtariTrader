cmake_minimum_required(VERSION 3.20)
project(Astrowing
    VERSION 1.0.0
    DESCRIPTION "Atari 7800 Space Fighter Game (Astrowing) using 7800basic"
    LANGUAGES NONE
)


# Set 7800basic installation directory
if(NOT DEFINED BASIC7800_DIR)
    set(BASIC7800_DIR "/Users/rowe/Software/Atari7800/7800basic" CACHE PATH "7800basic installation directory")
endif()

# Find 7800basic tools
find_program(BASIC7800 
    NAMES 7800basic.sh 7800bas.bat
    HINTS ${BASIC7800_DIR}
    NO_DEFAULT_PATH
    DOC "7800basic compiler executable"
)

if(NOT BASIC7800)
    message(FATAL_ERROR "7800basic compiler not found in ${BASIC7800_DIR}. Please verify the installation path.")
endif()

message(STATUS "Found 7800basic: ${BASIC7800}")
message(STATUS "7800basic directory: ${BASIC7800_DIR}")

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(BUILD_OUTPUT_DIR ${CMAKE_BINARY_DIR}/output)

# Create output directory
file(MAKE_DIRECTORY ${BUILD_OUTPUT_DIR})

# Function to compile 7800basic source files
function(add_7800basic_target TARGET_NAME SOURCE_FILE)
    get_filename_component(SOURCE_NAME ${SOURCE_FILE} NAME_WE)
    get_filename_component(SOURCE_DIR ${SOURCE_FILE} DIRECTORY)
    get_filename_component(SOURCE_FILENAME ${SOURCE_FILE} NAME)
    
    set(SOURCE_FULL_PATH ${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE_FILE})
    set(SOURCE_WORK_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${SOURCE_DIR})
    set(OUTPUT_A78 ${BUILD_OUTPUT_DIR}/${SOURCE_NAME}.a78)
    set(OUTPUT_BIN ${BUILD_OUTPUT_DIR}/${SOURCE_NAME}.bin)
    
    add_custom_command(
        OUTPUT ${OUTPUT_A78} ${OUTPUT_BIN}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${BUILD_OUTPUT_DIR}
        COMMAND ${CMAKE_COMMAND} -E env bas7800dir=${BASIC7800_DIR} 
                ${BASIC7800} ${SOURCE_FILENAME}
        COMMAND ${CMAKE_COMMAND} -E copy ${SOURCE_FILENAME}.a78 ${OUTPUT_A78}
        COMMAND ${CMAKE_COMMAND} -E copy ${SOURCE_FILENAME}.bin ${OUTPUT_BIN}
        WORKING_DIRECTORY ${SOURCE_WORK_DIR}
        DEPENDS ${SOURCE_FULL_PATH}
        COMMENT "Compiling 7800basic: ${SOURCE_FILE}"
        VERBATIM
    )
    
    add_custom_target(${TARGET_NAME} ALL
        DEPENDS ${OUTPUT_A78} ${OUTPUT_BIN}
    )
    
    # Set properties for easy access
    set_target_properties(${TARGET_NAME} PROPERTIES
        OUTPUT_A78 ${OUTPUT_A78}
        OUTPUT_BIN ${OUTPUT_BIN}
        SOURCE_FILE ${SOURCE_FILE}
    )
endfunction()

# Add main game target
# (Removed - Legacy moved to archive)

# Add astrowing target
if(EXISTS ${CMAKE_SOURCE_DIR}/src/astrowing.bas)
    add_7800basic_target(astrowing src/astrowing.bas)
endif()


# Add sample programs
# (Removed - Samples are reference only)

# Custom target to clean 7800basic generated files
add_custom_target(clean-7800
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${BUILD_OUTPUT_DIR}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${BUILD_OUTPUT_DIR}
    COMMENT "Cleaning 7800basic build artifacts"
)

# Installation rules
install(DIRECTORY ${BUILD_OUTPUT_DIR}/
    DESTINATION bin
    FILES_MATCHING 
    PATTERN "*.a78"
    PATTERN "*.bin"
)

# CPack configuration for packaging
set(CPACK_PACKAGE_NAME "Astrowing")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${PROJECT_DESCRIPTION})
set(CPACK_RESOURCE_FILE_README "${CMAKE_SOURCE_DIR}/README.md")
include(CPack)
