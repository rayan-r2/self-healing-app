CREATE DATABASE IF NOT EXISTS self_healing_db;

USE self_healing_db;

-- 1. Table for Administrator accounts
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'admin',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Table for Registered API settings
CREATE TABLE IF NOT EXISTS apis (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    base_url VARCHAR(500) NOT NULL,
    timeout INT DEFAULT 5,
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, FAILING, DEGRADED
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Table for Request metrics
CREATE TABLE IF NOT EXISTS api_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    api_id INT NOT NULL,
    response_time FLOAT NOT NULL, -- Latency in seconds
    http_status INT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (api_id) REFERENCES apis (id) ON DELETE CASCADE
);

-- 4. Table for Failure incidents
CREATE TABLE IF NOT EXISTS failures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    error_type VARCHAR(100) NOT NULL, -- HTTP_500, TIMEOUT, INVALID_JSON, HTTP_429
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'UNRESOLVED',
    FOREIGN KEY (request_id) REFERENCES api_requests (id) ON DELETE CASCADE
);

-- 5. Table for Recovery audit trail
CREATE TABLE IF NOT EXISTS recovery_actions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    failure_id INT NOT NULL,
    action_type VARCHAR(100) NOT NULL, -- RETRY, CACHE_FALLBACK, BACKUP_API
    result VARCHAR(50) NOT NULL, -- SUCCESS, FAILED
    duration FLOAT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (failure_id) REFERENCES failures (id) ON DELETE CASCADE
);

-- 6. Table for Cached API responses
CREATE TABLE IF NOT EXISTS api_cache (
    id INT AUTO_INCREMENT PRIMARY KEY,
    api_id INT NOT NULL,
    cache_key VARCHAR(255) NOT NULL,
    response_data TEXT NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    FOREIGN KEY (api_id) REFERENCES apis (id) ON DELETE CASCADE
);