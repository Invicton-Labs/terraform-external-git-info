# Terraform - Git Info

Retrieves Git info for a given repository. It can retrieve:
- Whether the given directory is a Git repository
- The hash of the currently checked out commit (both full length and short version)
- The currently checked out branch
- A list of all local branches
- A list of all remote branches
- The currently checked out tag (if the currently checked out commit was tagged)
- A list of all tags
- A list of all remotes, along with their fetch and push URLs

Additionally, it can optionally fetch or pull from the remote prior to getting this metadata (so you can be sure the results are always up-to-date).

Each of these features can be optionally disabled with an input variable (each one defaults to being enabled) if you want to disable a feature that may not work for your particular use case or if you want to speed up the module (on Windows it can be slow).

Usage:

```
module "git_info" {
  source       = "Invicton-Labs/git-info/external"

  // The directory to check
  working_dir = "../terraform-null-deepmerge"

  // Whether to fetch from the remote prior to getting the other data
  fetch = true

  // Whether to pull from the remote
  pull = false

  // None of these are required because they all default to `true` anyways,
  // but this shows the options
  get_commit_hash     = true
  get_current_branch  = true
  get_current_tag     = true
  get_local_branches  = true
  get_remote_branches = true
  get_remotes         = true
  get_tags            = true
}

output "git_info" {
  value = module.git_info
}

```

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

git_info = {
  "commit_hash" = "f07e7849204a6c7702860a602cbc0b1a55934a17"
  "commit_hash_short" = "f07e784"
  "current_branch" = "main"
  "current_tag" = "v0.1.2"
  "is_git" = true
  "local_branches" = [
    "main",
  ]
  "remote_branches" = [
    "origin/main",
  ]
  "remotes" = {
    "origin" = {
      "fetch_url" = "https://github.com/Invicton-Labs/terraform-null-deepmerge.git"
      "push_url" = "https://github.com/Invicton-Labs/terraform-null-deepmerge.git"
    }
  }
  "tags" = {
    "v0.1.0" = "6e31ec16d50c86b4a4ea8f6730fffba60254890c"
    "v0.1.1" = "20353b59a73c4a356e4ff703b0a33a06050dfdd1"
    "v0.1.2" = "f07e7849204a6c7702860a602cbc0b1a55934a17"
  }
}
```