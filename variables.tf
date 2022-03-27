variable "aws_region" {
  type = string
  description = "The region where your resources should be created."
}

variable "api_name" {
  type        = string
  description = "The name of the rest api where you configure the routes."
}

variable "http_method" {
  type    = string
  default = "GET"
  validation {
    condition     = contains(["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"], var.http_method)
    error_message = "Only valid HTTP VERBS are allowed (GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD)."
  }
}

variable "artifact_folder" {
  type        = string
  description = "The folder where the built binaries of your lambda reside."
  default     = "./.artifacts"
}

variable "name" {
  type        = string
  description = "The name of your operation. This must match the name of the binary."
}

variable "prefix" {
  type        = string
  description = "Adds a prefix to the function name."
  default     = ""
}

variable "suffix" {
  type        = string
  description = "Adds a suffix to the function name."
  default     = ""
}

variable "memory" {
  type        = number
  description = "The memory you wish to assign to the lambda function."
  default     = 256
}

variable "timeout" {
  type        = number
  description = "The maximum amount of time (in seconds) your function is allowed to run."
  default     = 3
}

variable "environment_vars" {
  type        = map(string)
  description = "Environment variables you want to set in the lambda environment."
  default     = {}
}

variable "lambda_managed_policies" {
  type        = set(string)
  description = "A set of managed policies, referenced by arn, which will be attached to the created role of the lambda function."
  default     = []
}

variable "lambda_policies" {
  type        = list(string)
  description = "A list of policy statements, in json, which will be set on the created role of the lambda function."
  default     = []
}

variable "log_level" {
  type        = string
  description = "Sets the log level of the rest resource in api gateway. Allowed values are OFF, ERROR, INFO."
  default     = "INFO"
  validation {
    condition     = contains(["OFF", "ERROR", "INFO"], var.log_level)
    error_message = "Allowed values are {OFF, ERROR, INFO}."
  }
}

variable "stage_name" {
  type        = string
  description = "The name of the stage e.g. to set method settings."
}

variable "authorization" {
  type = object({
    auth_type = string
    allow_for = optional(
      list(object({
        operation = string
        variable  = string
        values    = list(string)
      }))
    )
    authorizer = optional(
      object({
        arn        = string
        invoke_arn = string
      })
    )
  })

  description = "All information that is required for authorization. Currently only NONE and AWS_IAM are supported."
  default = {
    auth_type  = "NONE"
    allow_for  = null
    authorizer = null
  }
  validation {
    condition     = contains(["NONE", "AWS_IAM", "CUSTOM"], var.authorization.auth_type)
    error_message = "Only NONE, AWS_IAM and CUSTOM are currently supported."
  }
  validation {
    condition     = contains(["NONE", "CUSTOM"], var.authorization.auth_type) ? var.authorization.allow_for == null : true
    error_message = "When choosing NONE as authorization type, you cannot attach any permissions."
  }

  validation {
    condition     = var.authorization.auth_type == "CUSTOM" ? var.authorization.authorizer != null : true
    error_message = "When choosing as authorization type, you also have to specify the authorizer properties."
  }
}

variable "resource" {
  type = object({
    existing = optional(object({
      path = string
    }))
    new_path = optional(object({
      parent_resource_id = string
      last_path_part     = string
    }))
  })

  description = "The REST resource that you want to create or an existing resource that you want to attach the new operation."
  validation {
    condition     = (var.resource.existing == null && var.resource.new_path != null) || (var.resource.existing != null && var.resource.new_path == null)
    error_message = "You either have to reference the existing path or supply values for a new path."
  }
}
