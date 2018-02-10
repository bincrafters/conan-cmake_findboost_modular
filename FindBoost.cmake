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
	BOOST_LEVEL5GROUP
	BOOST_LEVEL8GROUP
	BOOST_LEVEL11GROUP
	BOOST_LEVEL14GROUP
)

set(COMPONENT_PROPERTIES 
	INTERFACE_LINK_LIBRARIES 
	INTERFACE_INCLUDE_DIRECTORIES 
	INTERFACE_COMPILE_DEFINITIONS 
	INTERFACE_COMPILE_OPTIONS
)

function(set_name_if_group target_name)
    foreach(group_name ${LEVEL_GROUPS})
		LIST(FIND BOOST_LEVEL5GROUP target_name FOUND_INDEX)
		if(FOUND_INDEX GREATER_EQUAL 0)
			set(target_or_group_name ${group_name} PARENT_SCOPE)
			break()
		endif()
    endforeach()
	set(target_or_group_name ${target_name} PARENT_SCOPE)
endfunction()

foreach(component ${Boost_FIND_COMPONENTS}) 
	set(boost_target Boost::${component})
    if(NOT TARGET boost_target)
	    add_library("${boost_target}" INTERFACE IMPORTED)
		set_name_if_group(${component}) # Creates ${target_or_group_name}
		set(conan_target CONAN_PKG::boost_${target_or_group_name})
		foreach(property_name ${COMPONENT_PROPERTIES})
			if(TARGET  ${conan_target})
				get_property(value TARGET ${conan_target} PROPERTY ${property_name} )
				set_property(TARGET ${boost_target} PROPERTY ${property_name} ${value})
			endif()
		endforeach(property_name)
    endif()
endforeach()
set(Boost_FOUND TRUE)


