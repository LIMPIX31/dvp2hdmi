return {
  includeIndexing = {
    "src/**/*.{v,sv}"
  },
  excludeIndexing = {"src/**/*_pkg.sv", "src/**/*.core.sv"},
  launchConfiguration = "verilator -f lsp-verilator.flags",
  formatCommand = "verible-verilog-format --flagfile verible-format.flags",
}
