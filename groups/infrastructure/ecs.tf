/*
* Provisions an ECS Cluster for running the Dependency Track services.
*/

resource "aws_ecs_cluster" "rand" {
  name = "${local.name_prefix}-stack"
}
