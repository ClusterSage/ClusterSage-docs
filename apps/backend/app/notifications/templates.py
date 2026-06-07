def cluster_connected_subject() -> str:
    return "KubeSage: Cluster connected successfully"

def cluster_connected_body(cluster_name: str) -> str:
    return (
        f"Hello, your Kubernetes cluster {cluster_name} was successfully connected to KubeSage. "
        "You can now view resources, logs, incidents, and AI suggestions from your dashboard."
    )
