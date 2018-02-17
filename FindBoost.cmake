# see https://cmake.org/cmake/help/v3.11/module/FindBoost.html

string(REPLACE "," ";" BOOST_LEVEL5GROUP
	"${CONAN_USER_BOOST_LEVEL5GROUP_lib_short_names}"
)

string(REPLACE "," ";" BOOST_LEVEL8GROUP
	"${CONAN_USER_BOOST_LEVEL8GROUP_lib_short_names}"
)

string(REPLACE "," ";" BOOST_LEVEL11GROUP
	"${CONAN_USER_BOOST_LEVEL11GROUP_lib_short_names}"
)

string(REPLACE "," ";" BOOST_LEVEL14GROUP
	"${CONAN_USER_BOOST_LEVEL14GROUP_lib_short_names}"
)

set(LEVEL_GROUPS
	LEVEL5GROUP
	LEVEL8GROUP
	LEVEL11GROUP
	LEVEL14GROUP
)

set(COMPONENT_PROPERTIES 
	INTERFACE_LINK_LIBRARIES 
	INTERFACE_INCLUDE_DIRECTORIES 
	INTERFACE_COMPILE_DEFINITIONS 
	INTERFACE_COMPILE_OPTIONS
)

function(set_name_if_group target_name)
    set(target_or_group_name ${target_name} PARENT_SCOPE)
    foreach(group_name ${LEVEL_GROUPS})
		LIST(FIND BOOST_${group_name} ${target_name} FOUND_INDEX)
		if(${FOUND_INDEX} GREATER_EQUAL 0)
			set(target_or_group_name ${group_name} PARENT_SCOPE)
			break()
		endif()
    endforeach()
endfunction()

message(STATUS "bincrafter's custom FindBoost.cmake")

function(libraries_to_abs libraries libdir libraries_abs_path)
    foreach(_LIBRARY_NAME ${libraries})
        unset(FOUND_LIBRARY CACHE)
        find_library(FOUND_LIBRARY NAME ${_LIBRARY_NAME} PATHS ${libdir}
                     NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
        if (FOUND_LIBRARY)
            set(FULLPATH_LIBS ${FULLPATH_LIBS} ${FOUND_LIBRARY})
        else()
            message(STATUS "library ${_LIBRARY_NAME} wasn't found in ${libdir}")
            set(FULLPATH_LIBS ${FULLPATH_LIBS} ${_LIBRARY_NAME})
        endif()
    endforeach()
    unset(FOUND_LIBRARY CACHE)
    set(${libraries_abs_path} ${FULLPATH_LIBS} PARENT_SCOPE)
endfunction()

foreach(component ${Boost_FIND_COMPONENTS})
    string(TOUPPER ${component} component_upper)
    set_name_if_group(${component}) # Creates ${target_or_group_name}
    string(TOUPPER ${target_or_group_name} target_or_group_name_upper)

    set(conan_target CONAN_PKG::boost_${target_or_group_name})
    set(boost_target Boost::${component})

    if(DEFINED CONAN_LIBS_BOOST_${component_upper})
        libraries_to_abs("${CONAN_LIBS_BOOST_${component_upper}}"
            "${CONAN_LIB_DIRS_BOOST_${component_upper}}"
            CONAN_LIBS_BOOST_${component_upper}_ABS)
        set(Boost_LIBRARIES "${Boost_LIBRARIES};${CONAN_LIBS_BOOST_${component_upper}_ABS}")
    endif()

    if(TARGET ${conan_target})
        set(Boost_${component_upper}_LIBRARY ${conan_target})
	else()
        set(Boost_${component_upper}_LIBRARY ${CONAN_LIBS_BOOST_${component_upper}_ABS})
	endif()
    set(Boost_INCLUDE_DIRS "${Boost_INCLUDE_DIRS};${CONAN_INCLUDE_DIRS_BOOST_${target_or_group_name_upper}}")
    set(Boost_LIBRARY_DIRS "${Boost_LIBRARY_DIRS};${CONAN_LIB_DIRS_BOOST_${target_or_group_name_upper}} (${target_or_group_name_upper})")

    set(Boost_${component_upper}_FOUND TRUE)

    message(STATUS "Boost_${component_upper}_FOUND: ${Boost_${component_upper}_FOUND}")
    message(STATUS "Boost_${component_upper}_LIBRARY: ${Boost_${component_upper}_LIBRARY}")

    if(NOT TARGET ${boost_target})
	    add_library("${boost_target}" INTERFACE IMPORTED)

        if(TARGET ${conan_target})
            set_property(TARGET ${boost_target} PROPERTY INTERFACE_LINK_LIBRARIES ${conan_target})
        else()
            if(DEFINED CONAN_LIBS_BOOST_${component_upper})
                libraries_to_abs("${CONAN_LIBS_BOOST_${component_upper}}"
                    "${CONAN_LIB_DIRS_BOOST_${component_upper}}"
                    CONAN_LIBS_BOOST_${component_upper}_ABS)
            endif()
            if(DEFINED CONAN_LIBS_BOOST_${component_upper}_RELEASE)
                libraries_to_abs("${CONAN_LIBS_BOOST_${component_upper}_RELEASE}"
                    "${CONAN_LIB_DIRS_BOOST_${component_upper}}"
                    CONAN_LIBS_BOOST_${component_upper}_RELEASE_ABS)
            endif()
            if(DEFINED CONAN_LIBS_BOOST_${component_upper}_DEBUG)
                libraries_to_abs("${CONAN_LIBS_BOOST_${component_upper}_DEBUG}"
                    "${CONAN_LIB_DIRS_BOOST_${component_upper}}"
                    CONAN_LIBS_BOOST_${component_upper}_DEBUG_ABS)
            endif()
            set_property(TARGET ${boost_target} PROPERTY INTERFACE_INCLUDE_DIRECTORIES
                ${CONAN_INCLUDE_DIRS_BOOST_${target_or_group_name_upper}}
                $<$<CONFIG:Release>:${CONAN_INCLUDE_DIRS_BOOST_${target_or_group_name_upper}_RELEASE}>
                $<$<CONFIG:RelWithDebInfo>:${CONAN_INCLUDE_DIRS_BOOST_${target_or_group_name_upper}_RELEASE}>
                $<$<CONFIG:MinSizeRel>:${CONAN_INCLUDE_DIRS_BOOST_${target_or_group_name_upper}_RELEASE}>
                $<$<CONFIG:Debug>:${CONAN_INCLUDE_DIRS_LBOOST_${target_or_group_name_upper}_DEBUG}>)

            # NOTE: component_upper instead of target_or_group_name_upper is intentional
            set_property(TARGET ${boost_target} PROPERTY INTERFACE_LINK_LIBRARIES
                ${CONAN_LIBS_BOOST_${component_upper}_ABS} ${CONAN_SHARED_LINKER_FLAGS_BOOST_${component_upper}_LIST} ${CONAN_EXE_LINKER_FLAGS_BOOST_${component_upper}_LIST}
                $<$<CONFIG:Release>:${CONAN_LIBS_BOOST_${component_upper}_RELEASE_ABS} ${CONAN_SHARED_LINKER_FLAGS_BOOST_${component_upper}_RELEASE_LIST}${CONAN_EXE_LINKER_FLAGS_BOOST_${component_upper}_RELEASE_LIST}>
                $<$<CONFIG:RelWithDebInfo>:${CONAN_LIBS_BOOST_${component_upper}_RELEASE_ABS} ${CONAN_SHARED_LINKER_FLAGS_BOOST_${component_upper}_RELEASE_LIST} ${CONAN_EXE_LINKER_FLAGS_BOOST_${component_upper}_RELEASE_LIST}>
                $<$<CONFIG:MinSizeRel>:${CONAN_LIBS_BOOST_${component_upper}_RELEASE_ABS} ${CONAN_SHARED_LINKER_FLAGS_BOOST_${component_upper}_RELEASE_LIST} ${CONAN_EXE_LINKER_FLAGS_BOOST_${component_upper}_RELEASE_LIST}>
                $<$<CONFIG:Debug>:${CONAN_LIBS_BOOST_${component_upper}_DEBUG_ABS} ${CONAN_SHARED_LINKER_FLAGS_BOOST_${component_upper}_DEBUG_LIST} ${CONAN_EXE_LINKER_FLAGS_BOOST_${component_upper}_DEBUG_LIST}>
                )

            set_property(TARGET ${boost_target} PROPERTY INTERFACE_COMPILE_DEFINITIONS
                ${CONAN_COMPILE_DEFINITIONS_BOOST_${target_or_group_name_upper}}
                $<$<CONFIG:Release>:${CONAN_COMPILE_DEFINITIONS_BOOST_${target_or_group_name_upper}_RELEASE}>
                $<$<CONFIG:RelWithDebInfo>:${CONAN_COMPILE_DEFINITIONS_BOOST_${target_or_group_name_upper}_RELEASE}>
                $<$<CONFIG:MinSizeRel>:${CONAN_COMPILE_DEFINITIONS_BOOST_${target_or_group_name_upper}_RELEASE}>
                $<$<CONFIG:Debug>:${CONAN_COMPILE_DEFINITIONS_BOOST_${target_or_group_name_upper}_DEBUG}>)

            set_property(TARGET ${boost_target} PROPERTY INTERFACE_COMPILE_OPTIONS
                ${CONAN_C_FLAGS_BOOST_${target_or_group_name_upper}_LIST} ${CONAN_CXX_FLAGS_BOOST_${target_or_group_name_upper}_LIST}
                $<$<CONFIG:Release>:${CONAN_C_FLAGS_BOOST_${target_or_group_name_upper}_RELEASE_LIST} ${CONAN_CXX_FLAGS_BOOST_${target_or_group_name_upper}_RELEASE_LIST}>
                $<$<CONFIG:RelWithDebInfo>:${CONAN_C_FLAGS_BOOST_${target_or_group_name_upper}_RELEASE_LIST} ${CONAN_CXX_FLAGS_BOOST_${target_or_group_name_upper}_RELEASE_LIST}>
                $<$<CONFIG:MinSizeRel>:${CONAN_C_FLAGS_BOOST_${target_or_group_name_upper}_RELEASE_LIST} ${CONAN_CXX_FLAGS_BOOST_${target_or_group_name_upper}_RELEASE_LIST}>
                $<$<CONFIG:Debug>:${CONAN_C_FLAGS_BOOST_${target_or_group_name_upper}_DEBUG_LIST}  ${CONAN_CXX_FLAGS_BOOST_${target_or_group_name_upper}_DEBUG_LIST}>)
        endif()
    endif()
endforeach()

set(Boost_FOUND TRUE)
set(Boost_MAJOR_VERSION 1)
set(Boost_MINOR_VERSION 66)
set(Boost_SUBMINOR_VERSION 0)

message(STATUS "Boost_FOUND: ${Boost_FOUND}")
message(STATUS "Boost_MAJOR_VERSION: ${Boost_MAJOR_VERSION}")
message(STATUS "Boost_MINOR_VERSION: ${Boost_MINOR_VERSION}")
message(STATUS "Boost_SUBMINOR_VERSION: ${Boost_SUBMINOR_VERSION}")
message(STATUS "Boost_INCLUDE_DIRS: ${Boost_INCLUDE_DIRS}")
message(STATUS "Boost_LIBRARY_DIRS: ${Boost_LIBRARY_DIRS}")
message(STATUS "Boost_LIBRARIES: ${Boost_LIBRARIES}")
