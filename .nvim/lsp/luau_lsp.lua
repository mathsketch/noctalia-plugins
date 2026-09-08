return {
    cmd = {
        "luau-lsp",
        "lsp",
        "--definitions:@noctalia=" .. _G.EXRC_ROOT_DIR .. "/noctalia.d.luau",
    },
    settings = {
        ["luau-lsp"] = {
            ignoreGlobs = { "**/*.d.luau" },
            platform = {
                type = "standard",
            },
            sourcemap = {
                enabled = false,
            },
        },
    },
}
