import psycopg
from decouple import config

def view_database():
    try:
        conn = psycopg.connect(
            host='localhost',
            user='timeleft_user',
            password='timeleft_password123',
            dbname='timeleft_clone_db'
        )
        cursor = conn.cursor()
        
        # Get all users
        cursor.execute("SELECT * FROM users")
        users = cursor.fetchall()
        
        # Get column names
        cursor.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'users'")
        columns = [row[0] for row in cursor.fetchall()]
        
        print("Users table:")
        print("Columns:", columns)
        print("\nData:")
        for user in users:
            print(user)
            
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    view_database()