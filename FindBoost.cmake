set(LEVEL5GROUP 
	"concept_check"
	"conversion"
	"detail"
	"function"
	"function_types"
	"functional"
	"fusion"
	"iterator"
	"mpl"
	"optional"
	"type_index"
	"typeof"
	"utility"
)

set(LEVEL8GROUP 
	"math"
	"lexical_cast"
)

set(LEVEL11GROUP 
	"date_time"
	"locale"
	"pool"
	"serialization"
	"spirit"
	"thread"
)

set(LEVEL14GROUP 
	"bimap"
	"disjoint_sets"
	"graph"
	"graph_parallel"
	"mpi"
	"property_map"
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

function(add_cloned_imported_target dst_target src_target)
    foreach(property_name ${COMPONENT_PROPERTIES})
        get_property(value TARGET ${src_target} PROPERTY ${property_name} )
        set_property(TARGET ${dst_target} PROPERTY ${property_name} ${value})
    endforeach()
endfunction()

foreach(component ${Boost_FIND_COMPONENTS})
	message("component: ${component}")
	if(NOT TARGET Boost::${component})
		message("Adding library: Boost::${component}")
		add_library(Boost::${component} INTERFACE IMPORTED)
		foreach(group_name ${LEVEL_GROUPS})
			if (DEFINED boost_${component}_found)
				if(${component} INLIST ${group_name})
					message("found ${component} is member of group ${group_name}")
					message("creating vars for ${component} under ${group_name}")
					add_cloned_imported_target(Boost::${component}, CONAN_PKG::boost_${group_name})
					set(boost_${component}_found TRUE)
					message("boost_${component}_found set to ${boost_${component}_found}")
				endif()
			endif()
		endforeach(group_name)
		
		message("boost_${component}_found value is ${boost_${component}_found}")
		if (NOT DEFINED ${boost_${component}_found})
			message("Determined that ${component} is NOT a member of any group")
			add_cloned_imported_target(Boost::${component}, CONAN_PKG::boost_${component})
		endif()
		message("Done Adding library: Boost::${component}")
	endif()
endforeach(component)
