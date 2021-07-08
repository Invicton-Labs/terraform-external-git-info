variable "working_dir" {
  description = "The working directory to use for determining Git information. Defaults to `path.root`."
  type        = string
  default     = null
}

variable "fetch" {
  description = "Whether to run `git fetch` prior to reading the Git metadata."
  type        = bool
  default     = false
}

variable "pull" {
  description = "Whether to run `git pull` prior to reading the Git metadata."
  type        = bool
  default     = false
}

variable "get_current_branch" {
  description = "Whether to get the currently checked out branch."
  type        = bool
  default     = true
}

variable "get_local_branches" {
  description = "Whether to get a list of all local branches."
  type        = bool
  default     = true
}

variable "get_remote_branches" {
  description = "Whether to get a list of all remote branches."
  type        = bool
  default     = true
}

variable "get_commit_hash" {
  description = "Whether to get the hash of the currently checked out commit."
  type        = bool
  default     = true
}

variable "get_current_tag" {
  description = "Whether to get the currently checked out tag."
  type        = bool
  default     = true
}

variable "get_tags" {
  description = "Whether to get a list of all tags in the repository."
  type        = bool
  default     = true
}

variable "get_remotes" {
  description = "Whether to get a list of all available remotes and their fetch/push URLs."
  type        = bool
  default     = true
}
