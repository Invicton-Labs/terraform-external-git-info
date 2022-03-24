locals {
  // Each separator uses a UUID which, in theory, should be universally unique
  // and shoule never appear in a command output
  command_separator = "__TF_SEPARATOR_a3a67b67efd6496f816b2c2489d409da"
  command_terminator = "__TF_SEPARATOR_b09cf9eeadda4e0e8ce634c64be5df9a"
  kv_separator = "__TF_SEPARATOR_97cf63bc81af4dc6942c69a6ccbc3dc2"

  // Commands that are used on both Unix and Windows
  commands_common = [
    var.pull ? [null, "git pull"] : (var.fetch ?  [null, "git fetch"] : null),
    var.get_current_branch ? ["current_branch", "git rev-parse --abbrev-ref HEAD"] : null,
    var.get_local_branches ? ["local_branches", "git branch --format='%(refname:short)' --no-color"] : null,
    var.get_remote_branches ? ["remote_branches", "git branch --no-color --remote"] : null,
    var.get_commit_hash ? ["commit_hash", "git rev-parse HEAD"] : null,
    var.get_current_tags ? ["current_tags", "git tag --points-at HEAD"] : null,
    var.get_remotes ? ["remotes", "git remote -v"] : null,
  ]

  commands_unix = [
    var.get_tags ? ["tags", "git show-ref --tags || (exitcode=$?; if [ $exitcode != 1 ]; then exit $exitcode; fi;)"] : null,
  ]

  commands_windows = [
    var.get_tags ? ["tags", "$output = git show-ref --tags; if (($LASTEXITCODE -ne 0) -and ($LASTEXITCODE -ne 1)) { $ErrorActionPreference = \"Continue\"; Exit $LASTEXITCODE }; Write-Output $output; $ErrorActionPreference = \"Stop\";"] : null,
  ]

  unix_wrapped_commands = [
    for command in [for v in concat(local.commands_common, local.commands_unix): v if v != null]:
    command[0] == null ? "${command[1]} >/dev/null 2>&1" : "echo -n \"${local.command_separator}${command[0]}${local.kv_separator}$(${command[1]})${local.command_terminator}\""
  ]

  windows_wrapped_commands = [
    for command in [for v in concat(local.commands_common, local.commands_windows): v if v != null]:
    command[0] == null ? "${command[1]} >$null 2>&1" : "Write-Output \"${local.command_separator}${command[0]}${local.kv_separator}$($(${command[1]}) | Out-String)${local.command_terminator}\""
  ]

  git_missing_exit_code = 201
  not_git_dir_exit_code = 202

  unix_script = <<EOF
set -e

if ! command -v git &> /dev/null; then exit ${local.git_missing_exit_code}; fi

set +e
git rev-parse --git-dir >/dev/null 2>&1
if [ $? != 0 ] ; then exit ${local.not_git_dir_exit_code}; fi
set -e

${join("\n", local.unix_wrapped_commands)}

exit 0
EOF

  windows_script = <<EOF
$ErrorActionPreference = "Stop"

if (-Not [bool](Get-Command -Name "git" -ErrorAction SilentlyContinue)) { Exit ${local.git_missing_exit_code} }

$ErrorActionPreference = "SilentlyContinue"
git rev-parse --git-dir >$null 2>&1
if ($LASTEXITCODE -ne 0) { Exit ${local.not_git_dir_exit_code} }
$ErrorActionPreference = "Stop"

${join("\n", local.windows_wrapped_commands)}

Exit 0
EOF
}

module "shell_script" {
  source  = "Invicton-Labs/shell-data/external"
  version = "~> 0.3.1"
  working_dir = var.working_dir != null ? var.working_dir : path.root
  command_unix = local.unix_script
  command_windows = local.windows_script
  fail_on_nonzero_exit_code = false
  fail_on_stderr = true
}

module "assert_git_available" {
  source  = "Invicton-Labs/assertion/null"
  version = "~> 0.2.1"
  condition = module.shell_script.exit_code != local.git_missing_exit_code
  error_message = "The `git` command is unavailable in this shell."
}

module "assert_valid_ext_code" {
  source  = "Invicton-Labs/assertion/null"
  version = "~> 0.2.1"
  depends_on = [
    module.assert_git_available
  ]
  condition = contains([0, local.not_git_dir_exit_code], module.shell_script.exit_code)
  error_message = "Failed to load git data: ${module.shell_script.stderr}"
}

locals {
  git_installed = module.assert_git_available.checked && module.assert_valid_ext_code.checked
  is_git_directory = local.git_installed ? module.shell_script.exit_code != local.not_git_dir_exit_code : null

  segments = split(local.command_separator, module.shell_script.stdout)
  command_kv_outputs = slice(local.segments, 1, length(local.segments))

  command_outputs = {
    for output in local.command_kv_outputs:
    replace(replace(trimspace(split(local.kv_separator, output)[0]), "\r", ""), "\r\n", "\n") => replace(replace(trimspace(split(local.command_terminator, split(local.kv_separator, output)[1])[0]), "\r", ""), "\r\n", "\n")
  }

  output_keys = [
    "current_branch",
    "local_branches",
    "remote_branches",
    "commit_hash",
    "current_tags",
    "tags",
    "remotes",
  ]

  output_values = {
    for k in local.output_keys:
    k => local.git_installed && local.is_git_directory == true ? lookup(local.command_outputs, k, null) : null
  }

  git_current_branch = local.output_values.current_branch
  git_branches_local = local.output_values.local_branches != null ? [for r in split("\n", local.output_values.local_branches): trimspace(r) if length(trimspace(r)) > 0] : null
  git_branches_remote = local.output_values.remote_branches != null ? [for r in split("\n", local.output_values.remote_branches): trimspace(r) if length(trimspace(r)) > 0 && length(split("->", r)) <= 1] : []

  remote_branch_remotes = distinct([for b in local.git_branches_remote: split("/", b)[0]])
  git_branches_remote_by_origin = local.output_values.remote_branches != null ? {
    for r in local.remote_branch_remotes:
    r => [
      for b in local.git_branches_remote:
      trimprefix(b, "${r}/")
      if length(trimprefix(b, "${r}/")) != length(b)
    ]
  } : null

  git_hash = local.output_values.commit_hash
  git_hash_short = local.output_values.commit_hash != null ? substr(local.output_values.commit_hash, 0, 7) : null
  git_current_tags = local.output_values.current_tags != null ? [for r in split("\n", local.output_values.current_tags): trimspace(r) if length(trimspace(r)) > 0] : null

  git_tag_rows = local.output_values.tags != null ? [for r in split("\n", local.output_values.tags): trimspace(r) if length(trimspace(r)) > 0] : []
  git_tags = local.output_values.tags != null ? {
    for r in local.git_tag_rows:
    trimspace(trimprefix(split(" ", r)[1], "refs/tags/")) => trimspace(split(" ", r)[0])
  } : null
}

locals {
  git_remotes_rows = local.output_values.remotes != null ? [for r in split("\n", local.output_values.remotes): trimspace(r) if length(trimspace(r)) > 0] : []
  git_remotes_row_parts = [
    for remote in local.git_remotes_rows :
    compact(split("\t", replace(remote, " ", "\t")))
  ]
  git_remote_names = distinct(local.git_remotes_row_parts[*][0])
  git_remotes = local.output_values.remotes != null ? {
    for name in local.git_remote_names :
    name => {
      fetch_url = lookup({
        for parts in local.git_remotes_row_parts :
        "found" => parts[1]
        if parts[0] == name && parts[2] == "(fetch)"
      }, "found", null)
      push_url = lookup({
        for parts in local.git_remotes_row_parts :
        "found" => parts[1]
        if parts[0] == name && parts[2] == "(push)"
      }, "found", null)
    }
  } : null
}
