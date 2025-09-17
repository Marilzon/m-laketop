#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

start_services() {
    echo "Starting all services"
    cd "$SCRIPT_DIR"

    # Start lake services
    echo "Starting lake services..."
    docker compose -f docker-compose-lake.yaml up -d
    sleep 5

    # Start Trino services
    echo "Starting Trino services..."
    docker compose -f docker-compose-trino.yaml up -d 
    sleep 30

    # Start Airflow services - fixed the command
    echo "Starting Airflow services..."
    docker compose -f docker-compose-airflow.yaml up -d
    sleep 5 

    echo "All services started successfully"

    init_trino
    # TODO: Add dbt seed data loading
}

init_trino() {
    echo "Initializing Trino schema..."
    if docker exec -it trino-coordinator trino --catalog iceberg --file /etc/trino/init.sql; then
        echo "Schema Landing, Staging, Curated are created in Trino Iceberg Catalog"
    else
        echo "Failed to initialize Trino schema" >&2
        return 1
    fi
}

stop_services() {
    echo "Stopping all services..."
    cd "$SCRIPT_DIR"
    
    # Stop services in reverse order
    docker compose -f docker-compose-airflow.yaml down -v
    docker compose -f docker-compose-trino.yaml down -v
    docker compose -f docker-compose-lake.yaml down -v

    echo "All services stopped"
}

case "${1:-help}" in
    "start")
        start_services
        ;;
    "stop")
        stop_services
        ;;
    "help"|"")
        echo "Usage: $0 [start|stop]"
        echo "Examples:"
        echo "  $0 start    # Start all services"
        echo "  $0 stop     # Stop all services"
        ;;
    *)
        echo "Error: Unknown command '$1'" >&2
        echo "Usage: $0 [start|stop]" >&2
        exit 1
        ;;
esac