output "is_git" {
  description = "Whether the directory is a Git repository."
  value       = local.is_git_directory
}
output "current_branch" {
  description = "The branch that is currently checked out. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_current_branch
}
output "local_branches" {
  description = "A list of local branch names. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_branches_local
}
output "remote_branches" {
  description = "A map of remote names to a list of branches on that remote. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_branches_remote_by_origin
}
output "commit_hash" {
  description = "The commit hash that is currently checked out. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_hash
}
output "commit_hash_short" {
  description = "The commit hash (short version, first 7 characters) that is currently checked out. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_hash_short
}
output "current_tags" {
  description = "All tags associated with the currently checked out commit. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_current_tags
}
output "tags" {
  description = "A map of tags for this repository. Keys are tag names, values are the corresponding hashes (hashes of the tags, not the commits they were created from). If the working directory is not a Git directory, this will be `null`."
  value       = local.git_tags
}
output "remotes" {
  description = "A map of remotes. The keys are the remote names (e.g. \"origin\"), and the values are maps with `fetch_url` and `push_url` fields. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_remotes
}

/*
// Used for debugging
output "shell_result" {
  value = module.shell_script
}
output "unix_script" {
  value = local.unix_script
}
output "windows_script" {
  value = local.windows_script
}
output "command_outputs" {
  value = jsonencode(local.command_outputs)
}
*/
