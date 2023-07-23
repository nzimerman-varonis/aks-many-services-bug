# AKS Windows Many Services Issue

To reproduce the issue -

1. Edit `config.sh` to change parameters, if needed. Parameters that might require changing -
   * SUBSCRIPTION - to use a subscription other than the current one.
   * RESOURCE_GROUP - to change the resource group name.
   * CLUSTER_NAME - to change the AKS cluster name.
   * LOCATION - to change location of the resource group and cluster.

2. Run `create-resource-group.sh` to create a resource group for the test.

3. Run `create-cluster.sh` to create the test cluster.

4. Run `reproduce.sh` to create 3,000 deployments and services.

5. Once all deployments and services are applied, observe the cluster state. It won't be stable. Nodes will become unready from time to time, pods will fail and restart with various errors.

6. Eventually, run `destroy-cluster.sh` and `destroy-resource-group.sh` to destroy everything.
