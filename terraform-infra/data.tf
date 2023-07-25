data "aws_subnet_ids" "subnets" {
  vpc_id = var.vpc_id
}

data "aws_subnet" "subnets" {
  for_each = data.aws_subnet_ids.subnets.ids
  vpc_id   = var.vpc_id
  id       = each.value
}
