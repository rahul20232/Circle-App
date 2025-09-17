import psycopg
from decouple import config

def create_database():
    # Database connection parameters - connect to default 'postgres' database first
    db_params = {
        'host': 'localhost',
        'user': 'timeleft_user',
        'password': 'timeleft_password123',
        'port': 5432,
        'dbname': 'postgres'  # Use 'dbname' instead of 'database' for psycopg3
    }
    
    database_name = 'timeleft_clone_db'
    
    try:
        # Connect to PostgreSQL server (to postgres database)
        conn = psycopg.connect(**db_params)
        conn.autocommit = True  # psycopg3 syntax
        cursor = conn.cursor()
        
        # Check if database exists
        cursor.execute(f"SELECT 1 FROM pg_catalog.pg_database WHERE datname = '{database_name}'")
        exists = cursor.fetchone()
        
        if not exists:
            # Create database
            cursor.execute(f'CREATE DATABASE {database_name}')
            print(f"Database '{database_name}' created successfully!")
        else:
            print(f"Database '{database_name}' already exists.")
            
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"Error creating database: {e}")

if __name__ == "__main__":
    create_database()