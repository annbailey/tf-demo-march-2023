variable "num_pets" {
    type = number
    default = 2
}

resource "random_pet" "pets" {
  count = var.num_pets
}

variable "github_repository_name" {
    type = string
}

# output "pet_name" {
#   value = random_pet.pets[*].id
# }

output "all_files" {
    value = github_repository_file.pets[*].file
}

resource "github_repository_file" "pets" {
  count = length(random_pet.pets)
  repository = var.github_repository_name
  file = "_pet${count.index + 1}.txt"
  content = random_pet.pets[count.index].id
}

# resource "github_repository_file" "pets_map" {
#   # for_each = {
#   #   "first_pet" = "something_cool"
#   #   "second_pet" = "another_cool_pet"
#   # }
#   for_each = { for p in random_pet.pets : p.id => p.id }

#   repository = var.github_repository_name
#   file = "${each.key}.txt"
#   content = each.value
# }