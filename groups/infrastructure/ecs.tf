/*
* Provisions an ECS Cluster for running the Dependency Track services.
*/

resource "aws_ecs_cluster" "cluster" {
  name = "${local.name_prefix}-stack"
}
