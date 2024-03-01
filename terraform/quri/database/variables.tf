variable "cluster" {
  type = object({
    id       = string
    user     = string
    password = string
    host     = string
    port     = number
  })
}

variable "name" {
  type = string
}

variable "database" {
  type = string
}

variable "role" {
  type = string
}

variable "pool_size" {
  type = number
}

variable "create" {
  type = bool
}
