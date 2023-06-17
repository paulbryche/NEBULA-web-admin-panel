# Use an official PostgreSQL image as the base
FROM postgres:latest

# Set the environment variables
ENV POSTGRES_USER=myuser
ENV POSTGRES_PASSWORD=mypassword
ENV POSTGRES_DB=mydatabase

# Copy SQL initialization script to the container
COPY init.sql /docker-entrypoint-initdb.d/