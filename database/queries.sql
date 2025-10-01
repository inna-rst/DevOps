
CREATE DATABASE itca;
CREATE USER student WITH SUPERUSER PASSWORD 'student_password_123';
CREATE SCHEMA devops4;

GRANT ALL PRIVILEGES ON SCHEMA devops4 TO student;
GRANT ALL PRIVILEGES ON DATABASE itca TO student;

SET search_path TO devops4;

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INTEGER,
    hire_date DATE DEFAULT CURRENT_DATE,
    salary DECIMAL(10,2)
);

CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    budget DECIMAL(12,2)
);

ALTER TABLE employees ADD CONSTRAINT fk_department 
    FOREIGN KEY (department_id) REFERENCES departments(id);

INSERT INTO departments (name, description) VALUES
    ('DevOps', 'Development and Operations team'),
    ('Development', 'Software development team'),
    ('QA', 'Quality Assurance team'),
    ('Management', 'Management team');

INSERT INTO employees (first_name, last_name, email, department_id, salary) VALUES
    ('Ivan', 'Petrov', 'ivan.petrov@itca.com', 1, 75000.00),
    ('Maria', 'Sidorova', 'maria.sidorova@itca.com', 2, 65000.00),
    ('Alexey', 'Kozlov', 'alexey.kozlov@itca.com', 1, 80000.00),
    ('Elena', 'Volkova', 'elena.volkova@itca.com', 3, 60000.00),
    ('Dmitry', 'Smirnov', 'dmitry.smirnov@itca.com', 4, 95000.00);

INSERT INTO projects (name, description, start_date, budget) VALUES
    ('Web Platform', 'Main company web platform', '2024-01-15', 500000.00),
    ('Mobile App', 'Customer mobile application', '2024-03-01', 300000.00),
    ('Infrastructure Upgrade', 'Server infrastructure modernization', '2024-02-01', 200000.00);

SELECT * FROM departments;
SELECT * FROM employees;
SELECT * FROM projects;

CREATE USER mentor WITH PASSWORD 'mentor_password_456';

GRANT CONNECT ON DATABASE itca TO mentor;

GRANT USAGE ON SCHEMA devops4 TO mentor;

GRANT SELECT ON ALL TABLES IN SCHEMA devops4 TO mentor;

ALTER DEFAULT PRIVILEGES IN SCHEMA devops4 GRANT SELECT ON TABLES TO mentor;

