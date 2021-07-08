output "is_git" {
  description = "Whether the directory is a Git repository."
  value       = local.is_git
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
  description = "A list of remote branch names. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_branches_remote
}
output "commit_hash" {
  description = "The commit hash that is currently checked out. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_hash
}
output "commit_hash_short" {
  description = "The commit hash (short version, first 7 characters) that is currently checked out. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_hash_short
}
output "current_tag" {
  description = "The currently checked out tag. If the working directory is not a Git directory, or if the currently checked out commit does not exactly match the commit of a known tag, this will be `null`."
  value       = local.current_tag
}
output "tags" {
  description = "A map of tags for this repository. Keys are tag names, values are the corresponding hashes. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_tags
}
output "remotes" {
  description = "A map of remotes. The keys are the remote names (e.g. \"origin\"), and the values are maps with `fetch_url` and `push_url` fields. If the working directory is not a Git directory, this will be `null`."
  value       = local.git_remotes
}
