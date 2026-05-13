import Lake
open Lake DSL

package «example» where
  -- package configuration

require "leanprover-community" / "batteries" @ git "v4.30.0-rc2"
require "leanprover-community" / "aesop" @ "4.30.0"

require MD4Lean from git
  "https://github.com/acmepjz/md4lean" @ "main"

require «UnicodeBasic» from git
  "https://github.com/fgdorais/lean4-unicode-basic" @ "v1.0.0"

require Cli from git "https://github.com/leanprover/lean4-cli"

-- require disabled from git "https://example.com/disabled"

require localpkg from "../localpkg"

@[default_target]
lean_lib «Example»
