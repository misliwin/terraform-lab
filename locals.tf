locals {
  name_tag = "terraform-${var.company_tag}-lab"
  username = "misliwin"
  password = "C1sco12345"

  common_tags = {
    company      = var.company
    project      = "${var.company}-${var.project}"
    billing_code = var.billing_code
  }

  azure_blob_storage_name = "${local.name_tag}-storage-${random_integer.int_number.result}"
}

resource "random_integer" "int_number" {
  min = 1
  max = 50000
}