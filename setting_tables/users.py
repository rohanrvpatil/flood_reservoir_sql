import mysql.connector
from faker import Faker
import random

fake = Faker()
import os
from dotenv import load_dotenv
load_dotenv()


db_config = {
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD'),
    'host': os.getenv('DB_HOST'),
    'database': os.getenv('DB_NAME')
}

def generate_random_user():
    mobile_number = str(random.randint(7000000000, 9999999999))
    return {
        'tenant_id': 'nagpur_001',
        'user_id': fake.uuid4(),
        'user_name': fake.first_name(),
        'middle_name': fake.first_name(),
        'last_name': fake.last_name(),
        'email': fake.email(),
        'mobile_prefix': '+91',
        'mobile': mobile_number,
        'password': fake.password(),
        'user_image': fake.image_url(),
        'country': fake.country(),
        'state': fake.state(),
        'district': fake.city(),
        'city': fake.city(),
        'bloodgroup': random.choice(['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-']),
        'dateofbirth': fake.date_of_birth(minimum_age=18, maximum_age=90),
        'address': fake.address(),
        'pin_code': fake.zipcode(),
        'emergency_contact_name': fake.name(),
        'emergency_contact_mobile': mobile_number,
        'relationship': random.choice(['Father', 'Mother', 'Brother', 'Sister', 'Cousin', 'Uncle', 'Friend']),
        'user_role': random.choice(['Yatri', 'Host', 'Volunteer']),
        'create_on': fake.date_time_this_year(),
        'last_modified_on': fake.date_time_this_year(),
        'deactivated_on': None,
        'sign_privacy_policy': random.choice([0, 1]),
        'policy_version': 1.0,
        'doc_type': 'Aadhar',
        'doc_front': fake.file_path(),
        'doc_back': fake.file_path()
    }


def insert_users_to_db(users):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    insert_query = """
    INSERT INTO users (
        tenant_id, user_id, user_name, middle_name, last_name, email, mobile_prefix, mobile, 
        password, user_image, country, state, district, city, bloodgroup, dateofbirth, 
        address, pin_code, emergency_contact_name, emergency_contact_mobile, relationship, 
        user_role, create_on, last_modified_on, deactivated_on, sign_privacy_policy, 
        policy_version, doc_type, doc_front, doc_back
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
    """

    for user in users:
        cursor.execute(insert_query, (
            user['tenant_id'], user['user_id'], user['user_name'], user['middle_name'], 
            user['last_name'], user['email'], user['mobile_prefix'], user['mobile'], 
            user['password'], user['user_image'], user['country'], user['state'], 
            user['district'], user['city'], user['bloodgroup'], user['dateofbirth'], 
            user['address'], user['pin_code'], user['emergency_contact_name'], 
            user['emergency_contact_mobile'], user['relationship'], user['user_role'], 
            user['create_on'], user['last_modified_on'], user['deactivated_on'], 
            user['sign_privacy_policy'], user['policy_version'], user['doc_type'], 
            user['doc_front'], user['doc_back']
        ))

    conn.commit()
    cursor.close()
    conn.close()

if __name__ == "__main__":
    users = [generate_random_user() for _ in range(10)]
    insert_users_to_db(users)
