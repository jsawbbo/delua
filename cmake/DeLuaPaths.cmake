function(delua_path_to_dir outvar pathstring)
	# replace ! with CMAKE_INSTALL_PREFIX
	if(WIN32 AND NOT UNIX)
		string(REGEX REPLACE "^[!]" "${CMAKE_INSTALL_PREFIX}" pathstring "${pathstring}")
	endif() 
	
	# replace LUA_*, etc with "@LUA_*@"
	string(REGEX REPLACE "(LUA_[A-Z]*)" "@\\1@/" pathstring "${pathstring}")

	# remove quotes, duplicates of /
	string(REGEX REPLACE "[ \"]" "" pathstring "${pathstring}")

	# configure string
	string(CONFIGURE "${pathstring}" pathstring)

	# sanity check
	if("${pathstring}" MATCHES "@")
		message(FATAL_ERROR "Lua path '${outvar}' contains unknown path elements: ${pathstring}.")
	endif()

	# remove duplicates of /
	string(REGEX REPLACE "([/\\])[/\\]*" "\\1" pathstring "${pathstring}")
	string(REGEX REPLACE "[/\\]+$" "" pathstring "${pathstring}")

	# remove installation prefix
	string(REGEX REPLACE "^${CMAKE_INSTALL_PREFIX}[/*]" "" pathstring "${pathstring}")
	
	# assign
	set(${outvar} "${pathstring}" PARENT_SCOPE)
endfunction()