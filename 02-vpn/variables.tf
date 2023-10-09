variable "project_name" {
  default = "roboshop"
}

variable "env" {
  default = "dev"
}

variable "common_tags" {
    default = {
      Project = "Roboshop"
      Component ="vpc"
      Environment = "DEV"
      terraform = "true"
    }
}