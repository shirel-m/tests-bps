variable "sleep_for" {
  type        = string
  default     = "420s"
}

resource "time_sleep" "wait_for_ingress_alb" {
  create_duration = var.sleep_for
}
