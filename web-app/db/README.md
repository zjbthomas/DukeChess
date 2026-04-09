# Step 1: Install PostgreSQL
sudo apt update
sudo apt install postgresql

# Step 2: Create Database
sudo -u postgres psql

CREATE DATABASE {gamedb};
CREATE USER {gameuser} WITH PASSWORD '{strongpassword}';
ALTER DATABASE {gamedb} OWNER TO {gameuser};

\q

# Step 3: Run Schema Script
psql -U {gameuser} -d {gamedb} -f init.sql