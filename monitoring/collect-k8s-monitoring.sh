#!/bin/bash

# Kubernetes Monitoring Evidence Collector
# Collects cluster, application, resource, storage, and event information.

set +e

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUTPUT_DIR="$(dirname "$0")/reports/$TIMESTAMP"

mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo " Kubernetes Monitoring Evidence Collector"
echo "=========================================="
echo "Output directory: $OUTPUT_DIR"
echo ""

collect() {
    local filename="$1"
    local description="$2"
    shift 2

    echo "Collecting: $description"

    {
        echo "=========================================="
        echo "$description"
        echo "Date: $(date)"
        echo "=========================================="
        echo ""

        "$@"

    } > "$OUTPUT_DIR/$filename" 2>&1
}

# Cluster information
collect "nodes.txt" "Kubernetes Nodes" \
    kubectl get nodes -o wide

collect "cluster-info.txt" "Cluster Information" \
    kubectl cluster-info

collect "all-pods.txt" "All Kubernetes Pods" \
    kubectl get pods -A -o wide

collect "all-services.txt" "All Kubernetes Services" \
    kubectl get services -A

collect "deployments.txt" "Deployments" \
    kubectl get deployments -A

collect "statefulsets.txt" "StatefulSets" \
    kubectl get statefulsets -A

collect "daemonsets.txt" "DaemonSets" \
    kubectl get daemonsets -A

collect "persistent-volumes.txt" "Persistent Volumes" \
    kubectl get pv

collect "persistent-volume-claims.txt" "Persistent Volume Claims" \
    kubectl get pvc -A

collect "events.txt" "Kubernetes Events" \
    kubectl get events -A --sort-by=.metadata.creationTimestamp

collect "resource-usage-nodes.txt" "Node Resource Usage" \
    kubectl top nodes

collect "resource-usage-pods.txt" "Pod Resource Usage" \
    kubectl top pods -A

collect "namespace-resources.txt" "MyDiary Namespace Resources" \
    kubectl get all -n mydiary

collect "mydiary-pods-details.txt" "MyDiary Pod Details" \
    kubectl describe pods -n mydiary

collect "mydiary-configmaps.txt" "MyDiary ConfigMaps" \
    kubectl get configmaps -n mydiary

collect "mydiary-secrets.txt" "MyDiary Secrets Metadata" \
    kubectl get secrets -n mydiary

collect "helm-releases.txt" "Helm Releases" \
    helm list -A

collect "helm-mydiary-values.txt" "MyDiary Helm Values" \
    helm get values mydiary -n mydiary -a

# Application logs
for POD in $(kubectl get pods -n mydiary -o name); do

    POD_NAME="${POD#pod/}"

    echo "Collecting logs from: $POD_NAME"

    kubectl logs "$POD_NAME" -n mydiary \
        --all-containers=true \
        --timestamps=true \
        > "$OUTPUT_DIR/logs-${POD_NAME}.txt" 2>&1

done

# Node system information
for NODE in $(kubectl get nodes -o name | cut -d/ -f2); do

    echo "Collecting node details for: $NODE"

    kubectl describe node "$NODE" \
        > "$OUTPUT_DIR/node-${NODE}.txt" 2>&1

done

# System information from the machine running this script
collect "system-disk.txt" "Disk Usage" \
    df -h

collect "system-memory.txt" "Memory Usage" \
    free -h

collect "system-uptime.txt" "System Uptime" \
    uptime

collect "system-processes.txt" "System Processes" \
    ps aux

echo ""
echo "=========================================="
echo "Monitoring collection completed!"
echo "=========================================="
echo ""
echo "Reports saved in:"
echo "$OUTPUT_DIR"
echo ""
echo "Files generated:"
ls -lh "$OUTPUT_DIR"
