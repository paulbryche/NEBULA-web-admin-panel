CREATE TABLE nebula_user (
    user_id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    user_type VARCHAR(100) NOT NULL,
    team VARCHAR(100) NOT NULL,
    sub_type VARCHAR(100) NOT NULL
);

CREATE TABLE nebula_subscription (
    name VARCHAR(100) PRIMARY KEY,
    price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE nebula_team_subscriptions (
    name VARCHAR(100) PRIMARY KEY,
    quantity INT NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);