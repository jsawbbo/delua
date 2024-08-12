--[=[
        Project settings.

        This table contains two required entries:

            NAME            Project name.
            VERSION         Project version ({major, minor[, patch[, tweak]]}).

        as well as 

            USES            List of tools in use.

        Users are free to add additional entries.
    ]=]
PROJECT = {
    DATE = "13 Jun 2024",
    NAME = "DeLua",
    TWEAK = 1,
    USES = {
        "GIT"
    },
    VERSION = "5.4.7"
}

--[=[
        Amend configuration.

    ]=]
CONFIG = {
    EXTENSIONS = {},
    LANG = {}
}

--[=[
        Tools.
    ]=]
TOOLS = {
    ["git"] = auto
}

--[=[
        Package paths.

        Here, additional Lua paths may be listed, if necessary.
    ]=]
PATHS = {}
