locals {
  first_filename = "first.txt"
  # name = "first"
}

# variable "first_filename" {
#   type = string
# }

terraform {
    required_providers {
      local = {
        source = "hashicorp/local"
        # version constraint for local provider
        version = "~> 2.3.0"
      }
      github = {
        source = "integrations/github"
        version = "~> 5.18.0"
      }
      random = {
        source = "hashicorp/random"
        version = "~> 3.4"
      }
    }
}

# registry.terraform.io --> search for "local" --> get info on provider
provider "local" {

}

provider "github" {
  token = file("./gh-token")
  owner = "annbailey"
}

# Resources: essentially inputs and outputs (almost like params and return values).
resource "local_file" "first" {
    filename = local.first_filename
    content = "this is a file"
}

resource "local_file" "second" {
    filename = "first_id.txt"
    content = local_file.first.filename
}

resource "github_repository" "demo" {
  name = "tf-demo-march-2023"
  description = "isn't this really cool wow"

  visibility = "public"
}

resource "github_repository_file" "first" {
  repository = github_repository.demo.name
  file = local_file.first.filename
  content = local_file.first.content
}

data "github_repository_file" "hi" {
  repository = github_repository.demo.name
  file = "hi.txt"
}

resource "github_repository_file" "new" {
  repository = github_repository.demo.name
  file = "new.txt"
  content = data.github_repository_file.hi.content

  # depends_on = [
  #   data.github_repository_file.hi
  # ]
}

resource "random_pet" "pets" {
  count = 5
}

output "pet_name" {
  value = random_pet.pets[*].id
}

# resource "github_repository_file" "pets" {
#   count = length(random_pet.pets)
#   repository = github_repository.demo.name
#   file = "pet${count.index}.txt"
#   content = random_pet.pets[count.index].id
# }

resource "github_repository_file" "pets_map" {
  # for_each = {
  #   "first_pet" = "something_cool"
  #   "second_pet" = "another_cool_pet"
  # }
  for_each = { for p in random_pet.pets : p.id => p.id }

  repository = github_repository.demo.name
  file = "${each.key}.txt"
  content = each.value
}

module "more_pet_names1" {
  source = "./modules/pet_files"
  num_pets = 2
  github_repository_name = github_repository.demo.name
}

output "more_pet_names1_files" {
  value = module.more_pet_names1.all_files
}

# To run:
# 1. terraform init --> pulls in whatever proivders it needs, creates lock file (.terraform.lock.hcl)
# 2. terraform plan --> inspects source code, the file that it's acting on, and compare changes
# 3. terraform apply --> makes the changes laid out in the plan

# Other notes:
# Generally, placement (order in file, which file) of Terraform code does not matter.
# Terraform will run whatever Terraform files are in your current directory.
# Resources: Terraform will manage the existence of a thing (can be acted on -- read and write permissions, essentially)
# Data: Terraform will get info from a thing (cannot be acted on -- just read permissions, essentially)