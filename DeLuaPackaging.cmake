include(My/Package)

my_package(
	ARCHITECTURE all
    NAME "delua-${DeLua_RELEASE}"
    CONTACT "Jürgen 'George' Sawinski <juergen.sawinski@mpinb.mpg.de>"
    VENDOR "MPI f. Neurobiol. of Behavior — caesar, Bonn, Germany"
    DESCRIPTION {
		SUMMARY "Simple, extensible, embeddable programming language."
		FULL "\
This is Lua ${Lua_VERSION}, released on ${Lua_Date}.

> Lua is a powerful, efficient, lightweight, embeddable scripting language.  
> It supports procedural programming, object-oriented programming, functional  
> programming, data-driven programming, and data description.

Delua is the CMake'ified version of the Lua (http://www.lua.org) sources. It 
may be used to build Lua binaries and packages on all major operating systems, 
or can be embedded in other projects.

Minor adaptions to the original Lua sources (such as handling of the search 
path) were made, and, a C++ interface (using exceptions) was added. For a full 
list of modifications, see: https://github.com/jsawbbo/delua
"
	}

    LICENSE "MIT" {
        FILE ${DeLua_SOURCE_DIR}/LICENSE
	}

    URL {
		HOMEPAGE "https://github.com/jsawbbo/delua"
		ABOUT    "https://www.lua.org/about.html"
		HELP     "https://www.lua.org/docs.html"
	}

    ICON         "${DeLua_SOURCE_DIR}/lua/doc/logo.gif"
    
    # PACKAGE {
	#     CATEGORY "Interpreter"
	# }

	# COMPONENTS
	# 	COMPONENT runtime
	# 		DEFAULT
	# 		INSTALL YES
	# 		DISPLAY_NAME "Runtime"
	# 		BEGIN
	# 			# sub-component....
	# 		END
			
	# 	COMPONENT common-development
	# 		INSTALL NO
	# 	    DISPLAY_NAME "Common development files"
	# 	    DEPENDS runtime
	# 		BEGIN
	# 			GROUP something
	# 			DISPLAY_NAME Something
	# 		END
			
	# 	COMPONENT development
	# 		INSTALL NO
	# 	    DISPLAY_NAME "Development files"
	# 	    DEPENDS runtime common-development
			
	# 	COMPONENT documentation
	# 	    INSTALL NO
	# 	    DISPLAY_NAME "Documentation"
	# 	    DEPENDS runtime
)

#my_package(NSIS
#)
#
#my_package(DMG
#)
#
#my_package(RPM
#)

#my_package(DEB
#	RELEASE "0"
#)

my_package(DEB DISTRIBUTION Ubuntu
	MAINTAINER "Juergen \"George\" Sawinski <juergen.sawinski@gmail.com>"	

	RELEASE "${DeLua_VERSION_TWEAK}ubuntu0"
	
	# COMPONENTS {
	# 	COMPONENT runtime 
	# 		SUFFIX OFF
	# 		RECOMMENDS documentation
			
	# 	COMPONENT common-development 
	# 		NAME delua-common
	# 		SUFFIX OFF
	# 		ARCHITECTURE all
				
	# 	COMPONENT development 
	# 		SUFFIX dev
	# 		DEPENDS common-development
	# 		RECOMMENDS documentation
					
	# 	COMPONENT documentation
	# 		SUFFIX doc
	# }
)

include(CPack)
