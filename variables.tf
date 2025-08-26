variable "server_port" {
  description = "The port that the server will uie to handle Http requests"
  default = 8080 // if not provided it will ask for a value
  type = number // if not mention he will take any type
  
  

  validation {
    condition = var.server_port > 0 && var.server_port < 65536
    error_message = "The port number must be between 1 and 65535."
  }

  sensitive = true // if true it will not show in the plan output hide sensative
}
