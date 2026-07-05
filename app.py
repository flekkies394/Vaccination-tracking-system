
"""
LCSCI7228 AE1 - Vaccination Tracking CLI
Thurrock Community Health Clinic Network
"""

import sqlite3
import re
from datetime import date

DB_NAME  = "AE1 Sql codes.db"

#Database Connection
def connect_db():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row #allow column access by name
    conn.execute("PRAGMA foreign_keys = ON")
    return conn
#Data validation Functions
def validate_name(name):
    return name.strip() != "" #check that a name field has real contents not blank spaces
def validate_gender(gender):
    """Validate gender against allowed values."""
    return gender in ['Male', 'Female', 'Non-binary',
                       'Prefer not to say']
def validate_insurance(status):
    """Validate gender against allowed values."""
    return status in ['Insured', 'Uninsured', 'Not Disclosed']

def validate_date(s):
    try:
        from datetime import datetime
        return datetime.strptime(s, "%Y-%m-%d").date() < date.today()
    except:
        return False

def validate_email(s):
    return bool(re.match(r'^[\w.+-]+@[\w.-]+\.\w{2,}$', s))

def validate_phone(s):
    return len(re.sub(r'[\s\-\+]', '', s)) >= 10

def validate_clinic_id(clinic_id):
    conn = connect_db()
    cursor = conn.execute ("SELECT clinic_id FROM Clinic WHERE clinic_id = ?", (clinic_id,))
    result = cursor.fetchone()
    conn.close()
    return result is not None

#CRUD Operations
#Create
def create_patient():
    first_name = input("Enter first name: ").strip()
    if not first_name:
        print("Error: first_name cannot be empty")
        return

    last_name = input("Last name: ").strip()
    if not last_name:
        print("Error: Last name cannot be empty.")
        return

    dob = input("Date of birth (YYYY-MM-DD): ").strip()
    if not validate_date(dob):
        print("Error: Invalid date format. Use YYYY-MM-DD.")
        return

    gender = input("Male/Female/Non-binary/Prefer not to say: ").strip()
    if not validate_gender(gender):
        print("Error: invalid gender.")
        return

    insurance_status = input("Insurance status (Insured/Uninsured/Not Disclosed): ").strip()
    if not validate_insurance(insurance_status):
        print("Error: Invalid insurance status.")
        return

    clinic_input = input("Primary clinic ID: ").strip()
    try:
        primary_clinic_id = int(clinic_input)
    except ValueError:
        print("Error: Clinic ID must be a number.")
        return

    if not validate_clinic_id(primary_clinic_id):
        print("Error: Clinic ID does not exist.")
        return
    
    street = input("Street: ").strip()
    city = input("City: ").strip()
    postcode = input("Postcode: ").strip()
    neighbourhood = input("Neighbourhood: ").strip()

    phone_number = input("phone_number (optional, press enter to skip): ").strip()
    if phone_number and not validate_phone(phone_number):
        print("Error: invalid phone number.")
        return
    emergency_contact_name = input ("Emergeny contact name( optional, press enter to skip):").strip()
    emergency_contact_number = input ("Emergency contact number(optional, press enter to skip):").strip()
    if emergency_contact_number and not validate_phone(emergency_contact_number):
        print("Error: invalid emergency contact number.")
        return

    registration_date = date.today ().isoformat()

    conn = connect_db()
    #Insert into database
    try:
        cursor = conn.execute(
            """INSERT INTO Patient 
               (primary_clinic_id, first_name, last_name, date_of_birth, gender, 
                street, city, postcode, neighbourhood, insurance_status, registration_date,
                phone_number, emergency_contact_name, emergency_contact_number)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            (primary_clinic_id, first_name, last_name, dob, gender,
             street, city, postcode, neighbourhood, insurance_status, registration_date,
             phone_number, emergency_contact_name, emergency_contact_number)
        )
        conn.commit()
        print(f"Success! Patient registered with ID: {cursor.lastrowid}")
    except sqlite3.IntegrityError as e:
        print(f"Error: Could not register patient. {e}")
    finally:
        conn.close()


#Read
#Read Vaccination Record of Patient
def read_patient():
    id_input = input("Enter patient ID too look up: ").strip()
    try:
        patient_id = int(id_input)
    except ValueError:
        print("Error: Patient ID must be a number. ")
        return

    conn = connect_db()
    patient = conn.execute("SELECT * FROM Patient WHERE patient_id =?", (patient_id,)).fetchone()
    if patient is None:
        print("No patient found with the ID. ")
        conn.close()
        return
    print(f"\nPatient: {patient['first_name']} {patient['last_name']}")
    print(f"Date of Birth: {patient['date_of_birth']}")
    print("\nVaccination History:")
    history = conn.execute(
        """SELECT v.vaccine_name, c.clinic_name, vr.administered_date
            FROM VaccinationRecord vr
            JOIN Vaccine v ON vr.vaccine_id = v.vaccine_id
            JOIN Clinic c ON vr.clinic_id = c.clinic_id
            WHERE vr.patient_id = ?""",
        (patient_id,)
    ).fetchall()

    if not history:
        print("No vaccination record. ")
    else:
        for row in history:
            print(f"- {row['vaccine_name']} at {row['clinic_name']} on {row['administered_date']}")
    conn.close()
                            
#Main Menu
def main_menu():
    while True:
        print("\n--- Vaccination Tracking CLI ---")
        print("1. Register new patient")
        print("2. Look up patient vaccination history")
        print("3. Exit")
        choice = input("Choose an option: ").strip()

        if choice == "1":
            create_patient()
        elif choice == "2":
            read_patient()
        elif choice == "3":
            print("Goodbye.")
            break
        else:
            print("Invalid option. Please choose 1, 2, or 3.")

if __name__ == "__main__":
    main_menu()