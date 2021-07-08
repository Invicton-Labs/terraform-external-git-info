terraform {
  required_version = ">= 0.13.0"
}

// Ensure that Git is installed
module "git_exists" {
  source                  = "Invicton-Labs/command-exists/external"
  version                 = "0.1.0"
  command_unix            = "git"
  working_dir             = var.working_dir
  fail_if_command_missing = true
}

module "is_git_repo" {
  source  = "Invicton-Labs/shell-data/external"
  version = "0.1.5"
  depends_on = [
    module.git_exists.exists
  ]
  command_unix    = module.git_exists.exists ? "git rev-parse --git-dir >/dev/null 2>&1; echo $?" : null
  command_windows = module.git_exists.exists ? "git rev-parse --git-dir > $null 2>&1; Write-Output $LASTEXITCODE" : null
  working_dir     = var.working_dir != null ? var.working_dir : path.root
  fail_on_error   = true
}

locals {
  is_windows = dirname("/") == "\\"
  is_git     = module.is_git_repo.stdout == "0"
}

module "git_fetch_pull" {
  source  = "Invicton-Labs/shell-data/external"
  version = "0.1.5"
  count   = local.is_git && (var.pull || var.fetch) ? 1 : 0
  depends_on = [
    local.is_git
  ]
  command_unix  = var.pull ? "git pull" : (var.fetch ? "git fetch" : null)
  working_dir   = var.working_dir != null ? var.working_dir : path.root
  fail_on_error = true
}

locals {
  fetch_pull_done = length(module.git_fetch_pull) == 0 ? true : module.git_fetch_pull[0].stdout != null
}

module "git_branch" {
  source  = "Invicton-Labs/shell-data/external"
  version = "0.1.5"
  count   = local.is_git && var.get_current_branch ? 1 : 0
  depends_on = [
    local.fetch_pull_done
  ]
  command_unix  = "git rev-parse --abbrev-ref HEAD"
  working_dir   = var.working_dir != null ? var.working_dir : path.root
  fail_on_error = true
}

locals {
  git_current_branch = length(module.git_branch) > 0 ? module.git_branch[0].stdout : null
}

module "git_branches_local" {
  source  = "Invicton-Labs/shell-data/external"
  version = "0.1.5"
  count   = local.is_git && var.get_local_branches ? 1 : 0
  depends_on = [
    local.fetch_pull_done
  ]
  command_unix  = "git branch --no-color"
  working_dir   = var.working_dir != null ? var.working_dir : path.root
  fail_on_error = true
}
module "git_branches_remote" {
  source  = "Invicton-Labs/shell-data/external"
  version = "0.1.5"
  count   = local.is_git && var.get_remote_branches ? 1 : 0
  depends_on = [
    local.fetch_pull_done
  ]
  command_unix  = "git branch --no-color --remote"
  working_dir   = var.working_dir != null ? var.working_dir : path.root
  fail_on_error = true
}

locals {
  git_branches_local_rows = length(module.git_branches_local) > 0 ? compact(split("\n", replace(module.git_branches_local[0].stdout, "\r", ""))) : []
  git_branches_local_rows_parts = [
    for row in local.git_branches_local_rows :
    compact(split(" ", row))
  ]
  git_branches_local = length(module.git_branches_local) > 0 ? [
    for parts in local.git_branches_local_rows_parts :
    parts[length(parts) - 1]
  ] : null
  git_branches_remote_rows = length(module.git_branches_remote) > 0 ? compact(split("\n", replace(module.git_branches_remote[0].stdout, "\r", ""))) : []
  git_branches_remote_rows_parts = [
    for row in local.git_branches_remote_rows :
    compact(split(" ", row))
    // Eliminate the output row that shows what HEAD is pointing to (lloks like "origin/HEAD -> origin/main")
    if replace(row, "->", "") != row
  ]
  git_branches_remote = length(module.git_branches_remote) > 0 ? [
    for parts in local.git_branches_remote_rows_parts :
    parts[length(parts) - 1]
  ] : null
}

module "git_hash" {
  source  = "Invicton-Labs/shell-data/external"
  version = "0.1.5"
  count   = local.is_git && var.get_commit_hash ? 1 : 0
  depends_on = [
    local.fetch_pull_done
  ]
  command_unix  = "git rev-parse HEAD"
  working_dir   = var.working_dir != null ? var.working_dir : path.root
  fail_on_error = true
}

locals {
  git_hash       = length(module.git_hash) > 0 ? module.git_hash[0].stdout : null
  git_hash_short = length(module.git_hash) > 0 ? substr(module.git_hash[0].stdout, 0, 7) : null
}

module "git_current_tag" {
  source  = "Invicton-Labs/shell-data/external"
  version = "0.1.5"
  count   = local.is_git && var.get_current_tag ? 1 : 0
  depends_on = [
    local.fetch_pull_done
  ]
  command_unix = "git describe --tags --exact-match"
  working_dir  = var.working_dir != null ? var.working_dir : path.root
  // Don't fail on an error because an error signifies that there's no exact tag match for the current commit
  fail_on_error = false
}

// If the git_current_tag module failed, ensure it was an acceptable error code (1), which means there are no tags
module "git_current_tag_acceptable_exitstatus" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.1"
  count         = length(module.git_current_tag)
  error_message = module.git_current_tag[0].stderr
  condition     = module.git_current_tag[0].exitstatus <= 1
}

locals {
  current_tag = length(module.git_current_tag) == 0 ? null : module.git_current_tag[0].exitstatus != 0 ? null : module.git_current_tag[0].stdout
}

module "git_tags" {
  source  = "Invicton-Labs/shell-data/external"
  version = "0.1.5"
  count   = local.is_git && var.get_tags ? 1 : 0
  depends_on = [
    local.fetch_pull_done
  ]
  command_unix = "git show-ref --tags"
  working_dir  = var.working_dir != null ? var.working_dir : path.root
  // Don't fail on an error because an error signifies that there are no tags
  fail_on_error = false
}

// If the git_tags module failed, ensure it was an acceptable error code (1), which means there are no tags
module "git_tags_acceptable_exitstatus" {
  source        = "Invicton-Labs/assertion/null"
  version       = "0.1.1"
  count         = length(module.git_tags)
  error_message = module.git_tags[0].stderr
  condition     = module.git_tags[0].exitstatus <= 1
}

locals {
  git_tag_rows = length(module.git_tags) > 0 ? module.git_tags[0].exitstatus == 0 ? compact(split("\n", replace(module.git_tags[0].stdout, "\r", ""))) : [] : []
  git_tag_row_parts = [
    for row in local.git_tag_rows :
    split(" ", row)
  ]
  git_tags = length(module.git_tags) > 0 ? {
    for parts in local.git_tag_row_parts :
    trimprefix(parts[1], "refs/tags/") => parts[0]
  } : null
}

module "git_remotes" {
  source  = "Invicton-Labs/shell-data/external"
  version = "0.1.5"
  count   = local.is_git && var.get_remotes ? 1 : 0
  depends_on = [
    local.fetch_pull_done
  ]
  command_unix  = "git remote -v"
  working_dir   = var.working_dir != null ? var.working_dir : path.root
  fail_on_error = true
}

locals {
  git_remotes_rows = length(module.git_remotes) > 0 ? compact(split("\n", replace(module.git_remotes[0].stdout, "\r", ""))) : []
  git_remotes_row_parts = [
    for remote in local.git_remotes_rows :
    compact(split("\t", replace(remote, " ", "\t")))
  ]
  git_remote_names = distinct(local.git_remotes_row_parts[*][0])
  git_remotes = length(module.git_remotes) > 0 ? {
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
