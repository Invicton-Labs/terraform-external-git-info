variable "working_dir" {
  description = "The working directory to use for determining Git information. Defaults to `path.root`."
  type        = string
  default     = null
}
locals {
  var_working_dir = var.working_dir
}

variable "fetch" {
  description = "Whether to run `git fetch` prior to reading the Git metadata."
  type        = bool
  default     = false
}
locals {
  var_fetch = var.fetch != null ? var.fetch : false
}

variable "pull" {
  description = "Whether to run `git pull` prior to reading the Git metadata."
  type        = bool
  default     = false
}
locals {
  var_pull = var.pull != null ? var.pull : false
}

variable "get_current_branch" {
  description = "Whether to get the currently checked out branch."
  type        = bool
  default     = true
}
locals {
  var_get_current_branch = var.get_current_branch != null ? var.get_current_branch : true
}

variable "get_local_branches" {
  description = "Whether to get a list of all local branches."
  type        = bool
  default     = true
}
locals {
  var_get_local_branches = var.get_local_branches != null ? var.get_local_branches : true
}

variable "get_remote_branches" {
  description = "Whether to get a list of all remote branches."
  type        = bool
  default     = true
}
locals {
  var_get_remote_branches = var.get_remote_branches != null ? var.get_remote_branches : true
}

variable "get_commit_hash" {
  description = "Whether to get the hash of the currently checked out commit."
  type        = bool
  default     = true
}
locals {
  var_get_commit_hash = var.get_commit_hash != null ? var.get_commit_hash : true
}

variable "get_current_tags" {
  description = "Whether to get the list of tags associated with the currently checked out commit."
  type        = bool
  default     = true
}
locals {
  var_get_current_tags = var.get_current_tags != null ? var.get_current_tags : true
}

variable "get_tags" {
  description = "Whether to get a list of all tags in the repository."
  type        = bool
  default     = true
}
locals {
  var_get_tags = var.get_tags != null ? var.get_tags : true
}

variable "get_remotes" {
  description = "Whether to get a list of all available remotes and their fetch/push URLs."
  type        = bool
  default     = true
}
locals {
  var_get_remotes = var.get_remotes != null ? var.get_remotes : true
}
