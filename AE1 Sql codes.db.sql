BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Appointment" (
	"appointment_id"	INTEGER,
	"patient_id"	INTEGER NOT NULL,
	"clinic_id"	INTEGER NOT NULL,
	"vaccine_id"	INTEGER NOT NULL,
	"worker_id"	INTEGER NOT NULL,
	"appointment_date"	TEXT NOT NULL,
	"appointment_time"	TEXT NOT NULL,
	"appointment_status"	TEXT NOT NULL DEFAULT 'Scheduled' CHECK("appointment_status" IN ('Scheduled', 'Completed', 'Cancelled', 'No-show')),
	"note"	TEXT,
	PRIMARY KEY("appointment_id" AUTOINCREMENT),
	FOREIGN KEY("clinic_id") REFERENCES "Clinic"("clinic_id"),
	FOREIGN KEY("patient_id") REFERENCES "Patient"("patient_id"),
	FOREIGN KEY("vaccine_id") REFERENCES "Vaccine"("vaccine_id"),
	FOREIGN KEY("worker_id") REFERENCES "HealthcareWorker"("worker_id")
);
CREATE TABLE IF NOT EXISTS "Clinic" (
	"clinic_id"	INTEGER,
	"clinic_name"	TEXT NOT NULL,
	"street"	TEXT NOT NULL,
	"city"	TEXT NOT NULL,
	"postcode"	TEXT NOT NULL,
	"neighbourhood"	TEXT NOT NULL,
	"phone_number"	TEXT,
	"email"	TEXT,
	"opening_time"	TEXT NOT NULL,
	"closing_time"	TEXT NOT NULL,
	"is_active"	INTEGER NOT NULL DEFAULT 1 CHECK("is_active" IN (0, 1)),
	PRIMARY KEY("clinic_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "ClinicWorker" (
	"worker_id"	INTEGER NOT NULL,
	"clinic_id"	INTEGER NOT NULL,
	"start_date"	TEXT NOT NULL,
	"end_date"	TEXT,
	"is_primary_clinic"	INTEGER NOT NULL DEFAULT 0 CHECK("is_primary_clinic" IN (0, 1)),
	PRIMARY KEY("worker_id","clinic_id"),
	FOREIGN KEY("clinic_id") REFERENCES "Clinic"("clinic_id"),
	FOREIGN KEY("worker_id") REFERENCES "HealthcareWorker"("worker_id")
);
CREATE TABLE IF NOT EXISTS "HealthcareWorker" (
	"worker_id"	INTEGER,
	"first_name"	TEXT NOT NULL,
	"last_name"	TEXT NOT NULL,
	"email"	TEXT,
	"phone_number"	TEXT,
	"role"	TEXT NOT NULL CHECK("role" IN ('Doctor', 'Nurse', 'Pharmacist')),
	"licence_number"	TEXT NOT NULL UNIQUE,
	"is_active"	INTEGER NOT NULL DEFAULT 1 CHECK("is_active" IN (0, 1)),
	PRIMARY KEY("worker_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "ImmunizationReport" (
	"report_id"	INTEGER,
	"clinic_id"	INTEGER NOT NULL,
	"report_date"	TEXT NOT NULL,
	"reporting_period"	TEXT NOT NULL CHECK("reporting_period" IN ('Monthly', 'Quarterly', 'Annual')),
	"total_vaccinations"	INTEGER NOT NULL DEFAULT 0,
	"total_patients"	INTEGER NOT NULL DEFAULT 0,
	"coverage_percentage"	REAL CHECK("coverage_percentage" BETWEEN 0 AND 100),
	"generated_by"	INTEGER,
	PRIMARY KEY("report_id" AUTOINCREMENT),
	FOREIGN KEY("clinic_id") REFERENCES "Clinic"("clinic_id"),
	FOREIGN KEY("generated_by") REFERENCES "HealthcareWorker"("worker_id")
);
CREATE TABLE IF NOT EXISTS "Patient" (
	"patient_id"	INTEGER,
	"primary_clinic_id"	INTEGER NOT NULL,
	"first_name"	TEXT NOT NULL,
	"last_name"	TEXT NOT NULL,
	"date_of_birth"	TEXT NOT NULL,
	"gender"	TEXT NOT NULL CHECK("gender" IN ('Male', 'Female', 'Non-binary', 'Prefer not to say')),
	"street"	TEXT NOT NULL,
	"city"	TEXT NOT NULL,
	"postcode"	TEXT NOT NULL,
	"neighbourhood"	TEXT NOT NULL,
	"email"	TEXT,
	"phone_number"	TEXT,
	"insurance_status"	TEXT NOT NULL CHECK("insurance_status" IN ('Insured', 'Uninsured', 'Not Disclosed')),
	"insurance_provider"	TEXT,
	"registration_date"	TEXT NOT NULL,
	"emergency_contact_name"	TEXT,
	"emergency_contact_number"	TEXT,
	PRIMARY KEY("patient_id" AUTOINCREMENT),
	FOREIGN KEY("primary_clinic_id") REFERENCES "Clinic"("clinic_id")
);
CREATE TABLE IF NOT EXISTS "VaccinationRecord" (
	"record_id"	INTEGER,
	"patient_id"	INTEGER NOT NULL,
	"vaccine_id"	INTEGER NOT NULL,
	"batch_id"	INTEGER NOT NULL,
	"worker_id"	INTEGER NOT NULL,
	"clinic_id"	INTEGER NOT NULL,
	"appointment_id"	INTEGER,
	"administered_date"	TEXT NOT NULL,
	"administered_time"	TEXT NOT NULL,
	"dose_number"	INTEGER NOT NULL DEFAULT 1 CHECK("dose_number" >= 1),
	"site_of_injection"	TEXT CHECK("site_of_injection" IN ('Left arm', 'Right arm', 'Left thigh', 'Right thigh')),
	"adverse_reaction"	TEXT,
	"next_dose_due"	TEXT,
	PRIMARY KEY("record_id" AUTOINCREMENT),
	FOREIGN KEY("appointment_id") REFERENCES "Appointment"("appointment_id"),
	FOREIGN KEY("batch_id") REFERENCES "VaccineBatch"("batch_id"),
	FOREIGN KEY("clinic_id") REFERENCES "Clinic"("clinic_id"),
	FOREIGN KEY("patient_id") REFERENCES "Patient"("patient_id"),
	FOREIGN KEY("vaccine_id") REFERENCES "Vaccine"("vaccine_id"),
	FOREIGN KEY("worker_id") REFERENCES "HealthcareWorker"("worker_id")
);
CREATE TABLE IF NOT EXISTS "Vaccine" (
	"vaccine_id"	INTEGER,
	"vaccine_name"	TEXT NOT NULL,
	"manufacturer"	TEXT NOT NULL,
	"brand_name"	TEXT,
	"dose_count_required"	INTEGER NOT NULL CHECK("dose_count_required" >= 1),
	"dose_interval_days"	INTEGER,
	"dose_ml"	REAL NOT NULL CHECK("dose_ml" > 0),
	"storage_temp_min"	REAL NOT NULL,
	"storage_temp_max"	REAL NOT NULL,
	"shelf_life_days"	INTEGER NOT NULL CHECK("shelf_life_days" > 0),
	"is_active"	INTEGER NOT NULL DEFAULT 1 CHECK("is_active" IN (0, 1)),
	PRIMARY KEY("vaccine_id" AUTOINCREMENT)
);
CREATE TABLE IF NOT EXISTS "VaccineBatch" (
	"batch_id"	INTEGER,
	"vaccine_id"	INTEGER NOT NULL,
	"clinic_id"	INTEGER NOT NULL,
	"batch_number"	TEXT NOT NULL UNIQUE,
	"manufacture_date"	TEXT NOT NULL,
	"expiry_date"	TEXT NOT NULL,
	"quantity_received"	INTEGER NOT NULL CHECK("quantity_received" > 0),
	"quantity_remaining"	INTEGER NOT NULL CHECK("quantity_remaining" >= 0),
	"received_date"	TEXT NOT NULL,
	"storage_location"	TEXT,
	PRIMARY KEY("batch_id" AUTOINCREMENT),
	FOREIGN KEY("clinic_id") REFERENCES "Clinic"("clinic_id"),
	FOREIGN KEY("vaccine_id") REFERENCES "Vaccine"("vaccine_id"),
	CHECK("quantity_remaining" <= "quantity_received")
);
INSERT INTO "Appointment" VALUES (1,1,1,5,2,'2023-05-02','09:00:00','Completed','Routine flu shot');
INSERT INTO "Appointment" VALUES (2,9,2,12,3,'2023-05-02','10:30:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (3,16,3,1,5,'2023-05-03','11:00:00','Scheduled',NULL);
INSERT INTO "Appointment" VALUES (4,23,4,7,8,'2023-05-03','14:00:00','No-show','Patient did not arrive');
INSERT INTO "Appointment" VALUES (5,31,5,22,11,'2023-05-04','09:15:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (6,38,6,3,14,'2023-05-04','13:45:00','Cancelled','Patient rescheduled');
INSERT INTO "Appointment" VALUES (7,45,1,9,13,'2023-05-05','08:30:00','Scheduled',NULL);
INSERT INTO "Appointment" VALUES (8,52,6,18,15,'2023-05-05','10:00:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (9,59,4,2,7,'2023-05-06','09:00:00','Scheduled',NULL);
INSERT INTO "Appointment" VALUES (10,66,2,14,4,'2023-05-06','15:30:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (11,73,3,20,6,'2023-05-07','11:15:00','No-show',NULL);
INSERT INTO "Appointment" VALUES (12,10,1,4,1,'2023-05-07','16:00:00','Completed','Walk-in, patient traveling for work');
INSERT INTO "Appointment" VALUES (13,90,2,16,1,'2023-05-08','09:30:00','Scheduled',NULL);
INSERT INTO "Appointment" VALUES (14,97,3,6,4,'2023-05-08','13:00:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (15,84,5,11,9,'2023-05-09','10:45:00','Cancelled','Walk-in cancelled — vaccine out of stock');
INSERT INTO "Appointment" VALUES (16,2,1,8,2,'2023-05-10','09:00:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (17,11,2,13,4,'2023-05-10','11:30:00','Scheduled',NULL);
INSERT INTO "Appointment" VALUES (18,18,3,17,5,'2023-05-11','10:00:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (19,25,4,10,9,'2023-05-11','13:30:00','No-show',NULL);
INSERT INTO "Appointment" VALUES (20,33,5,21,10,'2023-05-12','09:45:00','Scheduled',NULL);
INSERT INTO "Appointment" VALUES (21,40,6,15,12,'2023-05-12','14:15:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (22,47,1,7,13,'2023-05-13','08:00:00','Cancelled','Patient felt unwell, rescheduling');
INSERT INTO "Appointment" VALUES (23,54,6,19,14,'2023-05-13','10:30:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (24,61,4,4,8,'2023-05-14','09:00:00','Scheduled',NULL);
INSERT INTO "Appointment" VALUES (25,68,2,2,3,'2023-05-14','15:00:00','Completed','Second dose of COVID vaccine');
INSERT INTO "Appointment" VALUES (26,75,5,6,15,'2023-05-15','11:00:00','No-show',NULL);
INSERT INTO "Appointment" VALUES (27,80,4,9,7,'2023-05-15','13:00:00','Scheduled',NULL);
INSERT INTO "Appointment" VALUES (28,88,6,1,13,'2023-05-16','09:30:00','Completed',NULL);
INSERT INTO "Appointment" VALUES (29,95,3,12,6,'2023-05-16','12:45:00','Cancelled','Clinic rescheduled due to staff shortage');
INSERT INTO "Appointment" VALUES (30,3,2,5,1,'2023-05-17','10:15:00','Completed','Walk-in, insured patient traveling through');
INSERT INTO "Clinic" VALUES (1,'South Ockendon Health Centre','Darenth Lane','South Ockendon','RM15 5LP','South Ockendon','01708000001','sockendon@nelft.nhs.uk','08:00','18:00',1);
INSERT INTO "Clinic" VALUES (2,'Purfleet Care Centre','Tank Hill Road','Purfleet','RM19 1SX','Purfleet','01708000002','purfleet@nelft.nhs.uk','08:00','17:00',1);
INSERT INTO "Clinic" VALUES (3,'Orsett Minor Injury Unit','Rowley Road','Grays','RM16 3EU','Orsett','01708000003','orsett@nelft.nhs.uk','08:30','17:30',1);
INSERT INTO "Clinic" VALUES (4,'Thurrock Health Centre','55-57 High Street','Grays','RM17 6NB','Thurrock','01708000004','thurrock@nelft.nhs.uk','08:00','18:00',1);
INSERT INTO "Clinic" VALUES (5,'Grays Health Centre','Brooke Road','Grays','RM17 5BY','Grays','01708000005','grays@nelft.nhs.uk','08:00','17:00',1);
INSERT INTO "Clinic" VALUES (6,'Tilbury Community Health Centre','Civic Square','Tilbury','RM18 8AD','Tilbury','01708000006','tilbury@nelft.nhs.uk','08:30','18:30',1);
INSERT INTO "ClinicWorker" VALUES (1,1,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (1,2,'2023-06-01',NULL,0);
INSERT INTO "ClinicWorker" VALUES (2,1,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (3,2,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (4,2,'2023-02-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (4,3,'2023-07-01',NULL,0);
INSERT INTO "ClinicWorker" VALUES (5,3,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (6,3,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (7,4,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (8,4,'2023-03-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (9,4,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (9,5,'2023-08-01',NULL,0);
INSERT INTO "ClinicWorker" VALUES (10,5,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (11,5,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (12,6,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (13,6,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (13,1,'2023-09-01',NULL,0);
INSERT INTO "ClinicWorker" VALUES (14,6,'2023-02-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (15,5,'2023-01-01',NULL,1);
INSERT INTO "ClinicWorker" VALUES (15,6,'2023-06-01',NULL,0);
INSERT INTO "HealthcareWorker" VALUES (1,'James','Okafor','j.okafor@nelft.nhs.uk','07700100001','Doctor','GMC1001',1);
INSERT INTO "HealthcareWorker" VALUES (2,'Kemi','Fasola','k.fasola@nelft.nhs.uk','07700100002','Nurse','NMC2001',1);
INSERT INTO "HealthcareWorker" VALUES (3,'Michael','Thompson','m.thompson@nelft.nhs.uk','07700100003','Pharmacist','GPhC3001',1);
INSERT INTO "HealthcareWorker" VALUES (4,'Amina','Hassan','a.hassan@nelft.nhs.uk','07700100004','Nurse','NMC2002',1);
INSERT INTO "HealthcareWorker" VALUES (5,'David','Chen','d.chen@nelft.nhs.uk','07700100005','Doctor','GMC1002',1);
INSERT INTO "HealthcareWorker" VALUES (6,'Grace','Adeyemi','g.adeyemi@nelft.nhs.uk','07700100006','Nurse','NMC2003',1);
INSERT INTO "HealthcareWorker" VALUES (7,'Ann','Robert','a.roberet@nelft.nhs.uk','07700100007','Doctor','GMC1003',1);
INSERT INTO "HealthcareWorker" VALUES (8,'Fatima','Adam','f.adam@nelft.nhs.uk','07700100008','Pharmacist','GPhC3002',1);
INSERT INTO "HealthcareWorker" VALUES (9,'John','Williams','j.williams@nelft.nhs.uk','07700100009','Nurse','NMC2004',1);
INSERT INTO "HealthcareWorker" VALUES (10,'Priya','Sharma','p.sharma@nelft.nhs.uk','07700100010','Doctor','GMC1004',1);
INSERT INTO "HealthcareWorker" VALUES (11,'Emmanuel','Osei','e.osei@nelft.nhs.uk','07700100011','Nurse','NMC2005',1);
INSERT INTO "HealthcareWorker" VALUES (12,'Lucy','Martinez','l.martinez@nelft.nhs.uk','07700100012','Pharmacist','GPhC3003',1);
INSERT INTO "HealthcareWorker" VALUES (13,'Ahmed','Ibrahim','a.ibrahim@nelft.nhs.uk','07700100013','Doctor','GMC1005',1);
INSERT INTO "HealthcareWorker" VALUES (14,'Claire','Johnson','c.johnson@nelft.nhs.uk','07700100014','Nurse','NMC2006',1);
INSERT INTO "HealthcareWorker" VALUES (15,'Ola','Lanre','o.lanre@nelft.nhs.uk','07700100015','Doctor','GMC1006',1);
INSERT INTO "Patient" VALUES (1,1,'Emma','Koffa','1985-03-15','Female','10 Cedar Road','South Ockendon','RM15 5RN','South Ockendon','e.koffa@gmail.com','07509111717','Insured','BUPA','2023-01-10','Tom Wilson','07800200001');
INSERT INTO "Patient" VALUES (2,1,'Liam','Johnson','1990-07-22','Male','25 Oak Street','South Ockendon','RM15 5CD','South Ockendon','l.johnson@gmail.com','07800142822','Uninsured',NULL,'2023-01-11','Mary Johnson','07800200002');
INSERT INTO "Patient" VALUES (3,1,'Sophia','Brown','1978-11-30','Female','8 Elm Avenue','South Ockendon','RM15 5EF','South Ockendon','s.brown@hotmail.com','07800130001','Insured','AXA','2023-01-12','Peter Brown','07800200003');
INSERT INTO "Patient" VALUES (4,1,'isaac','Newthing','2000-05-18','Male','34 Pine Lane','South Ockendon','RM15 5GH','South Ockendon','i.newthing@outlook.com','07511138474','Not Disclosed',NULL,'2023-01-13','Jane Davis','07800200004');
INSERT INTO "Patient" VALUES (5,1,'Olivia','Taylor','1995-09-25','Female','12 Maple Close','South Ockendon','RM15 5IJ','South Ockendon','o.taylor@gmail.com','07800100005','Insured','BUPA','2023-01-14','Mark Taylor','07800200005');
INSERT INTO "Patient" VALUES (6,1,'William','Anderson','1982-12-08','Male','56 Birch Way','South Ockendon','RM15 5KL','South Ockendon','w.anderson@gmail.com','07800100006','Uninsured',NULL,'2023-01-15','Sue Anderson','07800200006');
INSERT INTO "Patient" VALUES (7,1,'Isabella','Martinez','1970-04-14','Female','78 Ash Road','South Ockendon','RM15 5MN','South Ockendon','i.martinez@gmail.com','07534091877','Insured','Vitality','2023-01-16','Carlos Martinez','07800200007');
INSERT INTO "Patient" VALUES (8,1,'James','Thompson','1955-08-27','Male','23 Willow Street','South Ockendon','RM15 5OP','South Ockendon','j.thompson@gmail.com','07800100008','Insured','AXA','2023-01-17','Linda Thompson','07800200008');
INSERT INTO "Patient" VALUES (9,2,'Ava','White','1988-02-19','Female','45 Chestnut Drive','Purfleet','RM19 1AB','Purfleet','a.white@gmail.com','07800100009','Uninsured',NULL,'2023-01-18','Bob White','07800200009');
INSERT INTO "Patient" VALUES (10,2,'Oliver','Harris','1993-06-11','Male','67 Hazel Close','Purfleet','RM19 1CD','Purfleet','o.harris@gmail.com','07800100010','Insured','BUPA','2023-01-19','Sara Harris','07800200010');
INSERT INTO "Patient" VALUES (11,2,'Mia','Clark','1975-10-03','Female','89 Sycamore Lane','Purfleet','RM19 1EF','Purfleet','m.clark@gmail.com','07800100011','Not Disclosed',NULL,'2023-01-20','Alan Clark','07800200011');
INSERT INTO "Patient" VALUES (12,2,'Elijah','Lewis','2001-03-28','Male','12 Poplar Avenue','Purfleet','RM19 1GH','Purfleet','e.lewis@gmail.com','07800100012','Insured','Vitality','2023-01-21','Helen Lewis','07800200012');
INSERT INTO "Patient" VALUES (13,2,'Charlotte','Robinson','1968-07-15','Female','34 Beech Road','Purfleet','RM19 1IJ','Purfleet','c.robinson@gmail.com','07800100013','Uninsured',NULL,'2023-01-22','Paul Robinson','07800200013');
INSERT INTO "Patient" VALUES (14,2,'Benjamin','Walker','1997-11-22','Male','56 Walnut Street','Purfleet','RM19 1KL','Purfleet','b.walker@gmail.com','07800100014','Insured','AXA','2023-01-23','Emma Walker','07800200014');
INSERT INTO "Patient" VALUES (15,2,'Amelia','Hall','1983-05-09','Female','78 Rowan Close','Purfleet','RM19 1MN','Purfleet','a.hall@gmail.com','07800100015','Insured','BUPA','2023-01-24','David Hall','07800200015');
INSERT INTO "Patient" VALUES (16,3,'Lucas','Young','1991-09-16','Male','23 Hornbeam Way','Grays','RM16 3AB','Orsett','l.young@gmail.com','07800100016','Uninsured',NULL,'2023-01-25','Kate Young','07800200016');
INSERT INTO "Patient" VALUES (17,3,'Harper','King','1979-01-04','Female','45 Larch Drive','Grays','RM16 3CD','Orsett','h.king@gmail.com','07800100017','Insured','Vitality','2023-01-26','Mike King','07800200017');
INSERT INTO "Patient" VALUES (18,3,'Henry','Wright','2003-04-21','Male','67 Spruce Road','Grays','RM16 3EF','Orsett','h.wright@gmail.com','07800100018','Not Disclosed',NULL,'2023-01-27','Anne Wright','07800200018');
INSERT INTO "Patient" VALUES (19,3,'Evelyn','Scott','1965-08-13','Female','89 Fir Lane','Grays','RM16 3GH','Orsett','e.scott@gmail.com','07800100019','Insured','AXA','2023-01-28','John Scott','07800200019');
INSERT INTO "Patient" VALUES (20,3,'Alexander','Green','1987-12-30','Male','12 Holly Avenue','Grays','RM16 3IJ','Orsett','a.green@gmail.com','07800100020','Uninsured',NULL,'2023-01-29','Lisa Green','07800200020');
INSERT INTO "Patient" VALUES (21,3,'Abigail','Adams','1994-03-17','Female','34 Ivy Close','Grays','RM16 3KL','Orsett','a.adams@gmail.com','07800100021','Insured','BUPA','2023-01-30','Tom Adams','07800200021');
INSERT INTO "Patient" VALUES (22,3,'Mason','Baker','1972-07-24','Male','56 Juniper Street','Grays','RM16 3MN','Orsett','m.baker@gmail.com','07800100022','Insured','Vitality','2023-01-31','Sue Baker','07800200022');
INSERT INTO "Patient" VALUES (23,4,'Ella','Nelson','1989-11-11','Female','78 Magnolia Road','Grays','RM17 6AB','Thurrock','e.nelson@gmail.com','07800100023','Not Disclosed',NULL,'2023-02-01','Rob Nelson','07800200023');
INSERT INTO "Patient" VALUES (24,4,'Ethan','Carter','1996-02-28','Male','23 Jasmine Way','Grays','RM17 6CD','Thurrock','e.carter@gmail.com','07800100024','Insured','AXA','2023-02-02','Fiona Carter','07800200024');
INSERT INTO "Patient" VALUES (25,4,'Scarlett','Mitchell','1981-06-05','Female','45 Lavender Drive','Grays','RM17 6EF','Thurrock','s.mitchell@gmail.com','07800100025','Uninsured',NULL,'2023-02-03','Neil Mitchell','07800200025');
INSERT INTO "Patient" VALUES (26,4,'Daniel','Perez','1973-09-12','Male','67 Rose Avenue','Grays','RM17 6GH','Thurrock','d.perez@gmail.com','07519470426','Insured','BUPA','2023-02-04','Maria Perez','07800200026');
INSERT INTO "Patient" VALUES (27,4,'Grace','Roberts','1998-01-19','Female','89 Daisy Close','Grays','RM17 6IJ','Thurrock','g.roberts@gmail.com','07500192227','Uninsured',NULL,'2023-02-05','Ian Roberts','07800200027');
INSERT INTO "Patient" VALUES (28,4,'Logan','Turner','1986-05-26','Male','12 Violet Lane','Grays','RM17 6KL','Thurrock','l.turner@gmail.com','07801100028','Insured','Vitality','2023-02-06','Pat Turner','07800200028');
INSERT INTO "Patient" VALUES (29,4,'Chloe','Phillips','1963-10-03','Female','34 Sunflower Road','Grays','RM17 6MN','Thurrock','c.phillips@gmail.com','07800100029','Not Disclosed',NULL,'2023-02-07','Gary Phillips','07800200029');
INSERT INTO "Patient" VALUES (30,4,'Great','Campbell','2002-02-10','Male','56 Bluebell Way','Grays','RM17 6OP','Thurrock','g.campbell@gmail.com','07800100030','Insured','AXA','2023-02-08','Jean Campbell','07800200030');
INSERT INTO "Patient" VALUES (31,5,'Zoe','Parker','1977-06-17','Female','78 Tulip Drive','Grays','RM17 5AB','Grays','z.parker@gmail.com','07800100031','Uninsured',NULL,'2023-02-09','Ray Parker','07800200031');
INSERT INTO "Patient" VALUES (32,5,'Jackson','Evans','1992-10-24','Male','23 Daffodil Street','Grays','RM17 5CD','Grays','j.evans@gmail.com','07811100036','Insured','BUPA','2023-02-10','Ann Evans','07800200032');
INSERT INTO "Patient" VALUES (33,5,'Lily','Edwards','1984-03-01','Female','45 Primrose Close','Grays','RM17 5EF','Grays','l.edwards@gmail.com','07822145333','Insured','AXA','2023-02-11','Tim Edwards','07800200033');
INSERT INTO "Patient" VALUES (34,5,'Aiden','Collins','1969-07-08','Male','67 Orchid Lane','Grays','RM17 5GH','Grays','a.collins@gmail.com','07833100034','Not Disclosed',NULL,'2023-02-12','Bev Collins','07800200034');
INSERT INTO "Patient" VALUES (35,5,'Eleanor','Stewart','1999-11-15','Female','89 Poppy Road','Grays','RM17 5IJ','Grays','e.stewart@gmail.com','07812010055','Insured','Vitality','2023-02-13','Ken Stewart','07800200035');
INSERT INTO "Patient" VALUES (36,5,'Carter','Morris','1980-04-22','Male','12 Lily Avenue','Grays','RM17 5KL','Grays','c.morris@outlook.com','07800100036','Uninsured',NULL,'2023-02-14','Dot Morris','07800200036');
INSERT INTO "Patient" VALUES (37,5,'Penelope','Rogers','1974-08-29','Female','34 Pansy Way','Grays','RM17 5MN','Grays','p.rogers@gmail.com','07800100037','Insured','BUPA','2023-02-15','Fred Rogers','07800200037');
INSERT INTO "Patient" VALUES (38,6,'Iren','Reed','1988-01-05','Male','56 Iris Drive','Tilbury','RM18 8AB','Tilbury','o.iren@gmail.com','07800100038','Insured','AXA','2023-02-16','Gail Reed','07800200038');
INSERT INTO "Patient" VALUES (39,6,'Layla','Cook','1995-05-12','Female','78 Snowdrop Close','Tilbury','RM18 8CD','Tilbury','l.cook@gmail.com','07800100039','Uninsured',NULL,'2023-02-17','Harry Cook','07800200039');
INSERT INTO "Patient" VALUES (40,6,'Ryan','Morgan','1971-09-19','Male','23 Marigold Lane','Tilbury','RM18 8EF','Tilbury','r.morgan@gmail.com','07800100040','Not Disclosed',NULL,'2023-02-18','Ivy Morgan','07800200040');
INSERT INTO "Patient" VALUES (41,6,'Mary','Bell','2004-01-26','Female','45 Foxglove Road','Tilbury','RM18 8GH','Tilbury','m.bell@gmail.com','07800100041','Insured','Vitality','2023-02-19','Jack Bell','07800200041');
INSERT INTO "Patient" VALUES (42,6,'Levi','Murphy','1983-06-03','Male','67 Buttercup Street','Tilbury','RM18 8IJ','Tilbury','l.murphy@gmail.com','07800100042','Uninsured',NULL,'2023-02-20','Kay Murphy','07800200042');
INSERT INTO "Patient" VALUES (43,6,'Hannah','Bailey','1976-10-10','Female','89 Heather Way','Tilbury','RM18 8KL','Tilbury','h.bailey@gmail.com','07800100043','Insured','BUPA','2023-02-21','Lee Bailey','07800200043');
INSERT INTO "Patient" VALUES (44,1,'Caleb','Rivera','1991-02-17','Male','12 Clover Drive','South Ockendon','RM15 5QR','South Ockendon','c.rivera@gmail.com','07800100044','Insured','AXA','2023-02-22','May Rivera','07800200044');
INSERT INTO "Patient" VALUES (45,1,'Stella','Cooper','1967-06-24','Female','34 Thistle Close','South Ockendon','RM15 5ST','South Ockendon','s.cooper@gmail.com','07800100045','Not Disclosed',NULL,'2023-02-23','Ned Cooper','07800200045');
INSERT INTO "Patient" VALUES (46,2,'Miles','Richardson','2005-10-31','Male','56 Fern Lane','Purfleet','RM19 1OP','Purfleet','m.richardson@gmail.com','07800100046','Uninsured',NULL,'2023-02-24','Ora Richardson','07800200046');
INSERT INTO "Patient" VALUES (47,2,'Aurora','Cox','1980-03-08','Female','78 Bracken Road','Purfleet','RM19 1QR','Purfleet','a.cox@gmail.com','07800100047','Insured','BUPA','2023-02-25','Pat Cox','07800200047');
INSERT INTO "Patient" VALUES (48,3,'Ezra','Howard','1993-07-15','Male','23 Heather Street','Grays','RM16 3OP','Orsett','e.howard@gmail.com','0759100048','Insured','Vitality','2023-02-26','Quin Howard','07800200048');
INSERT INTO "Patient" VALUES (49,4,'Violet','Ward','1986-11-22','Female','45 Gorse Way','Grays','RM17 6QR','Thurrock','v.ward@gmail.com','07800100049','Insured','AXA','2023-02-27','Rex Ward','07800200049');
INSERT INTO "Patient" VALUES (50,5,'Leo','Torres','1978-04-01','Male','67 Sedge Drive','Grays','RM17 5OP','Grays','l.torres@gmail.com','07800103455','Uninsured',NULL,'2023-02-28','Sue Torres','07800200050');
INSERT INTO "Patient" VALUES (51,6,'Ada','Coker','1990-03-05','Female','12 Acorn Lane','Tilbury','RM18 8MN','Tilbury','a.coker@gmail.com','07853105551','Insured','BUPA','2023-03-01','Ben Price','07800200051');
INSERT INTO "Patient" VALUES (52,6,'Finn','Bennett','1985-07-12','Male','34 Chestnut Road','Tilbury','RM18 8OP','Tilbury','f.bennett@gmail.com','07800100052','Uninsured',NULL,'2023-03-02','Carol Bennett','07800200052');
INSERT INTO "Patient" VALUES (53,1,'Randy','Wood','1973-11-19','Female','56 Walnut Way','South Ockendon','RM15 5UV','South Ockendon','r.wood@gmail.com','07891100053','Insured','AXA','2023-03-03','Dan Wood','07800200053');
INSERT INTO "Patient" VALUES (54,1,'Oscar','Barnes','1998-04-26','Male','78 Hazel Close','South Ockendon','RM15 5WX','South Ockendon','o.barnes@gmail.com','07831091541','Not Disclosed',NULL,'2023-03-04','Eve Barnes','07800200054');
INSERT INTO "Patient" VALUES (55,2,'Isla','Ross','1966-08-03','Female','23 Linden Street','Purfleet','RM19 1ST','Purfleet','i.ross@gmail.com','07800100055','Insured','Vitality','2023-03-05','Frank Ross','07800200055');
INSERT INTO "Patient" VALUES (56,2,'Hugo','Henderson','1994-12-10','Male','45 Alder Drive','Purfleet','RM19 1UV','Purfleet','h.henderson@gmail.com','0785100056','Uninsured',NULL,'2023-03-06','Greta Henderson','07800200056');
INSERT INTO "Patient" VALUES (57,3,'Freya','Coleman','1981-04-17','Female','67 Cypress Road','Grays','RM16 3QR','Orsett','f.coleman@gmail.com','07510100057','Insured','BUPA','2023-03-07','Harry Coleman','07800200057');
INSERT INTO "Patient" VALUES (58,3,'Theo','Jenkins','1976-08-24','Male','89 Redwood Lane','Grays','RM16 3ST','Orsett','t.jenkins@gmail.com','07800100058','Insured','AXA','2023-03-08','Irene Jenkins','07800200058');
INSERT INTO "Patient" VALUES (59,4,'Iris','Perry','2002-01-01','Female','12 Sequoia Way','Grays','RM17 6ST','Thurrock','i.perry@gmail.com','07800100059','Not Disclosed',NULL,'2023-03-09','Jack Perry','07800200059');
INSERT INTO "Patient" VALUES (60,4,'Jude','Powell','1987-05-08','Male','34 Yew Avenue','Grays','RM17 6UV','Thurrock','j.powell@gmail.com','07800100060','Insured','Vitality','2023-03-10','Karen Powell','07800200060');
INSERT INTO "Patient" VALUES (61,5,'Ivy','Long','1979-09-15','Female','56 Cedar Close','Grays','RM17 5QR','Grays','i.long@gmail.com','07800100061','Uninsured',NULL,'2023-03-11','Len Long','07800200061');
INSERT INTO "Patient" VALUES (62,5,'Rory','Patterson','1992-01-22','Male','78 Beech Street','Grays','RM17 5ST','Grays','r.patterson@gmail.com','07800100062','Insured','BUPA','2023-03-12','Meg Patterson','07800200062');
INSERT INTO "Patient" VALUES (63,6,'Phoebe','Hughes','1984-05-29','Female','23 Elm Drive','Tilbury','RM18 8QR','Tilbury','p.hughes@gmail.com','07800100063','Insured','AXA','2023-03-13','Ned Hughes','07800200063');
INSERT INTO "Patient" VALUES (64,6,'Rex','Flores','1971-10-06','Male','45 Oak Road','Tilbury','RM18 8ST','Tilbury','r.flores@gmail.com','07800100064','Not Disclosed',NULL,'2023-03-14','Ora Flores','07800200064');
INSERT INTO "Patient" VALUES (65,1,'Sage','Washington','1996-02-13','Female','67 Pine Way','South Ockendon','RM15 5YZ','South Ockendon','s.washington@gmail.com','07800100065','Insured','Vitality','2023-03-15','Paul Washington','07800200065');
INSERT INTO "Patient" VALUES (66,2,'Beau','Butler','1968-06-20','Male','89 Maple Close','Purfleet','RM19 1WX','Purfleet','b.butler@gmail.com','07800100066','Uninsured',NULL,'2023-03-16','Quinn Butler','07800200066');
INSERT INTO "Patient" VALUES (67,3,'Nova','Simmons','1983-10-27','Female','12 Birch Lane','Grays','RM16 3UV','Orsett','n.simmons@gmail.com','07800100067','Insured','BUPA','2023-03-17','Rick Simmons','07800200067');
INSERT INTO "Patient" VALUES (68,4,'Zara','Foster','1975-03-05','Female','34 Ash Street','Grays','RM17 6WX','Thurrock','z.foster@gmail.com','07840105068','Insured','AXA','2023-03-18','Sam Foster','07800200068');
INSERT INTO "Patient" VALUES (69,5,'Eli','Gonzalez','1988-07-12','Male','56 Willow Road','Grays','RM17 5UV','Grays','e.gonzalez@gmail.com','078601610069','Not Disclosed',NULL,'2023-03-19','Tina Gonzalez','07800200069');
INSERT INTO "Patient" VALUES (70,6,'Luna','Bryant','2001-11-19','Female','78 Sycamore Drive','Tilbury','RM18 8UV','Tilbury','l.bryant@gmail.com','07822100070','Insured','Vitality','2023-03-20','Uma Bryant','07800200070');
INSERT INTO "Patient" VALUES (71,1,'Jasper','Alexander','1993-04-26','Male','23 Poplar Way','South Ockendon','RM15 6AB','South Ockendon','j.alexander@gmail.com','07800100071','Uninsured',NULL,'2023-03-21','Vera Alexander','07800200071');
INSERT INTO "Patient" VALUES (72,2,'Wren','Russell','1970-08-03','Female','45 Hornbeam Close','Purfleet','RM19 1YZ','Purfleet','w.russell@gmail.com','07800100072','Insured','BUPA','2023-03-22','Walt Russell','07800200072');
INSERT INTO "Patient" VALUES (73,3,'Axel','Griffin','1997-12-10','Male','67 Larch Road','Grays','RM16 3WX','Orsett','a.griffin@gmail.com','07800100073','Insured','AXA','2023-03-23','Xena Griffin','07800200073');
INSERT INTO "Patient" VALUES (74,4,'Skye','Diaz','1982-04-17','Female','89 Spruce Street','Grays','RM17 6YZ','Thurrock','s.diaz@gmail.com','07800100074','Not Disclosed',NULL,'2023-03-24','Yves Diaz','07800200074');
INSERT INTO "Patient" VALUES (75,5,'Blake','Hayes','1977-08-24','Male','12 Fir Lane','Grays','RM17 5WX','Grays','b.hayes@gmail.com','0784110475','Insured','Vitality','2023-03-25','Zoe Hayes','07800200075');
INSERT INTO "Patient" VALUES (76,6,'Willow','Turner','1995-02-14','Female','12 Maplewood Close','Tilbury','RM18 8VW','Tilbury','w.turner@gmail.com','07800100076','Insured','BUPA','2023-03-26','Adam Turner','07800200076');
INSERT INTO "Patient" VALUES (77,1,'Felix','Reed','1980-06-09','Male','34 Rosewood Avenue','South Ockendon','RM15 6CD','South Ockendon','f.reed@gmail.com','07800100077','Uninsured',NULL,'2023-03-27','Beth Reed','07800200077');
INSERT INTO "Patient" VALUES (78,2,'Aria','Cole','1999-09-23','Female','56 Ivy Lane','Purfleet','RM19 1AB','Purfleet','a.cole@gmail.com','07800100078','Not Disclosed',NULL,'2023-03-28','Cody Cole','07800200078');
INSERT INTO "Patient" VALUES (79,3,'Leo','Bishop','1978-01-30','Male','78 Bramble Way','Grays','RM16 3YZ','Orsett','l.bishop@gmail.com','07800100079','Insured','AXA','2023-03-29','Dana Bishop','07800200079');
INSERT INTO "Patient" VALUES (80,4,'Ruby','Marsh','1991-11-05','Female','23 Thistle Road','Grays','RM17 6AB','Thurrock','r.marsh@gmail.com','07800100080','Insured','Vitality','2023-03-30','Evan Marsh','07800200080');
INSERT INTO "Patient" VALUES (81,5,'Max','Fox','1969-03-18','Male','45 Juniper Street','Grays','RM17 5YZ','Grays','m.fox@gmail.com','07800100081','Uninsured',NULL,'2023-03-31','Faye Fox','07800200081');
INSERT INTO "Patient" VALUES (82,6,'Poppy','Sharp','2000-07-22','Female','67 Magnolia Drive','Tilbury','RM18 8WX','Tilbury','p.sharp@gmail.com','07800100082','Insured','BUPA','2023-04-01','Gwen Sharp','07800200082');
INSERT INTO "Patient" VALUES (83,1,'Arthur','Knight','1974-12-11','Male','89 Laurel Close','South Ockendon','RM15 6EF','South Ockendon','a.knight@gmail.com','07800100083','Not Disclosed',NULL,'2023-04-02','Hank Knight','07800200083');
INSERT INTO "Patient" VALUES (84,2,'Daisy','Stone','1986-04-04','Female','12 Hawthorn Lane','Purfleet','RM19 1CD','Purfleet','d.stone@gmail.com','07800100084','Insured','AXA','2023-04-03','Iris Stone','07800200084');
INSERT INTO "Patient" VALUES (85,3,'Oliver','Frost','1996-08-16','Male','34 Blossom Way','Grays','RM16 3AB','Orsett','o.frost@gmail.com','07800100085','Insured','Vitality','2023-04-04','Joel Frost','07800200085');
INSERT INTO "Patient" VALUES (86,4,'Grace','Vale','1972-10-28','Female','56 Fernway','Grays','RM17 6CD','Thurrock','g.vale@gmail.com','07800100086','Uninsured',NULL,'2023-04-05','Kim Vale','07800200086');
INSERT INTO "Patient" VALUES (87,5,'Henry','Wells','1989-02-09','Male','78 Heather Road','Grays','RM17 5AB','Grays','h.wells@gmail.com','07800100087','Insured','BUPA','2023-04-06','Liam Wells','07800200087');
INSERT INTO "Patient" VALUES (88,6,'Ella','Hunt','2003-05-31','Female','23 Clover Street','Tilbury','RM18 8YZ','Tilbury','e.hunt@gmail.com','07800100088','Not Disclosed',NULL,'2023-04-07','Mona Hunt','07800200088');
INSERT INTO "Patient" VALUES (89,1,'George','Pike','1967-09-13','Male','45 Meadow Close','South Ockendon','RM15 6GH','South Ockendon','g.pike@gmail.com','07800100089','Insured','AXA','2023-04-08','Nico Pike','07800200089');
INSERT INTO "Patient" VALUES (90,2,'Mia','Doyle','1993-01-27','Female','67 Orchard Drive','Purfleet','RM19 1EF','Purfleet','m.doyle@gmail.com','07800100090','Insured','Vitality','2023-04-09','Owen Doyle','07800200090');
INSERT INTO "Patient" VALUES (91,3,'Jack','Nash','1979-06-19','Male','89 Primrose Lane','Grays','RM16 3CD','Orsett','j.nash@gmail.com','07800100091','Uninsured',NULL,'2023-04-10','Pia Nash','07800200091');
INSERT INTO "Patient" VALUES (92,4,'Lily','Rowe','1985-11-02','Female','12 Bracken Way','Grays','RM17 6EF','Thurrock','l.rowe@gmail.com','07800100092','Insured','BUPA','2023-04-11','Quinn Rowe','07800200092');
INSERT INTO "Patient" VALUES (93,5,'Noah','Chase','1997-03-24','Male','34 Sorrel Road','Grays','RM17 5CD','Grays','n.chase@gmail.com','07800100093','Not Disclosed',NULL,'2023-04-12','Reid Chase','07800200093');
INSERT INTO "Patient" VALUES (94,6,'Chloe','Lane','1971-08-07','Female','56 Foxglove Close','Tilbury','RM18 8AB','Tilbury','c.lane@gmail.com','07800100094','Insured','AXA','2023-04-13','Sara Lane','07800200094');
INSERT INTO "Patient" VALUES (95,1,'Charlie','Webb','1990-12-15','Male','78 Bluebell Street','South Ockendon','RM15 6IJ','South Ockendon','c.webb@gmail.com','07800100095','Insured','Vitality','2023-04-14','Todd Webb','07800200095');
INSERT INTO "Patient" VALUES (96,2,'Amelia','Grant','1976-04-29','Female','23 Buttercup Lane','Purfleet','RM19 1GH','Purfleet','a.grant@gmail.com','07800100096','Uninsured',NULL,'2023-04-15','Uma Grant','07800200096');
INSERT INTO "Patient" VALUES (97,3,'Thomas','Shaw','2004-10-03','Male','45 Daffodil Drive','Grays','RM16 3EF','Orsett','t.shaw@gmail.com','07800100097','Insured','BUPA','2023-04-16','Val Shaw','07800200097');
INSERT INTO "Patient" VALUES (98,4,'Sophie','Kent','1982-07-21','Female','67 Marigold Way','Grays','RM17 6GH','Thurrock','s.kent@gmail.com','07800100098','Not Disclosed',NULL,'2023-04-17','Wade Kent','07800200098');
INSERT INTO "Patient" VALUES (99,5,'William','Vance','1968-02-25','Male','89 Tulip Close','Grays','RM17 5EF','Grays','w.vance@gmail.com','07800100099','Insured','AXA','2023-04-18','Xander Vance','07800200099');
INSERT INTO "Patient" VALUES (100,6,'Emily','Cross','1994-05-10','Female','12 Rosemary Road','Tilbury','RM18 8CD','Tilbury','e.cross@gmail.com','07800100100','Insured','Vitality','2023-04-19','Yara Cross','07800200100');
INSERT INTO "Patient" VALUES (101,3,'Adefolake','Olanrewaju','1996-04-06','Female','Daiglen drive','South Ockendon','RM15 5RN','Elwick',NULL,NULL,'Insured',NULL,'2026-07-05',NULL,NULL);
INSERT INTO "Patient" VALUES (102,4,'Isaac','Newthing','1997-06-24','Male','Daiglen drive','South Ockendon','RM15 5RN','Tamarisk',NULL,'7538470888','Not Disclosed',NULL,'2026-07-05','Jerry','7566443300');
INSERT INTO "VaccinationRecord" VALUES (1,4,1,1,2,1,NULL,'2024-02-01','09:15:00',1,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (2,12,1,2,3,2,NULL,'2024-02-05','10:00:00',1,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (3,20,2,3,13,1,NULL,'2024-03-01','11:30:00',1,'Left arm',NULL,'2024-03-22');
INSERT INTO "VaccinationRecord" VALUES (4,20,2,3,13,1,NULL,'2024-03-22','11:00:00',2,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (5,35,2,4,5,3,NULL,'2024-03-10','09:00:00',1,'Left thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (6,42,3,5,4,2,NULL,'2024-03-15','13:15:00',1,'Left arm',NULL,'2024-04-12');
INSERT INTO "VaccinationRecord" VALUES (7,42,3,5,4,2,NULL,'2024-04-12','13:00:00',2,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (8,50,4,6,8,4,NULL,'2024-03-01','10:45:00',1,'Right thigh',NULL,'2024-03-29');
INSERT INTO "VaccinationRecord" VALUES (9,50,4,6,9,4,NULL,'2024-03-29','10:30:00',2,'Left thigh','Mild soreness at injection site',NULL);
INSERT INTO "VaccinationRecord" VALUES (10,60,5,7,10,5,NULL,'2024-02-15','09:30:00',1,'Left arm',NULL,'2024-03-16');
INSERT INTO "VaccinationRecord" VALUES (11,60,5,7,11,5,NULL,'2024-03-16','09:00:00',2,'Right arm',NULL,'2024-04-15');
INSERT INTO "VaccinationRecord" VALUES (12,60,5,7,9,5,NULL,'2024-04-15','14:00:00',3,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (13,70,6,8,12,6,NULL,'2024-02-20','11:00:00',1,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (14,5,7,9,1,1,NULL,'2024-02-10','08:45:00',1,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (15,15,8,10,1,2,NULL,'2024-02-18','10:15:00',1,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (16,25,9,11,6,3,NULL,'2024-02-25','09:45:00',1,'Left thigh',NULL,'2024-08-24');
INSERT INTO "VaccinationRecord" VALUES (17,55,10,12,7,4,NULL,'2024-03-05','10:00:00',1,'Right thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (18,65,11,13,15,5,NULL,'2024-02-28','11:15:00',1,'Left arm',NULL,'2024-03-27');
INSERT INTO "VaccinationRecord" VALUES (19,80,12,14,14,6,NULL,'2024-03-08','09:00:00',1,'Right arm',NULL,'2024-05-31');
INSERT INTO "VaccinationRecord" VALUES (20,8,17,15,2,1,NULL,'2024-03-12','10:30:00',1,'Left arm',NULL,'2024-05-11');
INSERT INTO "VaccinationRecord" VALUES (21,6,13,21,3,2,NULL,'2024-03-20','09:00:00',1,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (22,14,14,22,10,5,NULL,'2024-03-01','10:00:00',1,'Right arm',NULL,'2024-03-08');
INSERT INTO "VaccinationRecord" VALUES (23,14,14,22,11,5,NULL,'2024-03-08','10:15:00',2,'Left arm',NULL,'2024-03-15');
INSERT INTO "VaccinationRecord" VALUES (24,14,14,22,9,5,NULL,'2024-03-15','10:30:00',3,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (25,22,15,23,15,5,NULL,'2024-03-25','11:00:00',1,'Left thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (26,30,16,24,12,6,NULL,'2024-03-05','09:15:00',1,'Right thigh',NULL,'2024-03-12');
INSERT INTO "VaccinationRecord" VALUES (27,30,16,24,13,6,NULL,'2024-03-12','09:30:00',2,'Left arm','Mild nausea reported',NULL);
INSERT INTO "VaccinationRecord" VALUES (28,37,1,1,2,1,NULL,'2024-04-01','08:30:00',1,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (29,44,1,2,4,2,NULL,'2024-04-02','09:00:00',1,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (30,51,7,9,13,1,NULL,'2024-04-03','10:00:00',1,'Right thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (31,58,8,10,1,2,NULL,'2024-04-04','11:30:00',1,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (32,63,9,11,5,3,NULL,'2024-04-05','09:45:00',1,'Right arm',NULL,'2024-10-02');
INSERT INTO "VaccinationRecord" VALUES (33,63,9,11,6,3,NULL,'2024-10-02','09:30:00',2,'Left thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (34,71,10,12,8,4,NULL,'2024-04-06','10:15:00',1,'Right thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (35,78,11,13,9,5,NULL,'2024-04-07','13:00:00',1,'Left arm',NULL,'2024-05-05');
INSERT INTO "VaccinationRecord" VALUES (36,78,11,13,11,5,NULL,'2024-05-05','13:15:00',2,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (37,85,12,14,14,6,NULL,'2024-04-08','09:00:00',1,'Left thigh',NULL,'2024-07-01');
INSERT INTO "VaccinationRecord" VALUES (38,85,12,14,12,6,NULL,'2024-07-01','09:15:00',2,'Right thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (39,92,17,15,1,1,NULL,'2024-04-09','10:45:00',1,'Left arm',NULL,'2024-06-08');
INSERT INTO "VaccinationRecord" VALUES (40,99,18,16,3,2,NULL,'2024-04-10','11:00:00',1,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (41,2,17,15,2,1,NULL,'2024-05-01','09:00:00',1,'Left arm',NULL,'2024-06-30');
INSERT INTO "VaccinationRecord" VALUES (42,2,17,15,13,1,NULL,'2024-06-30','09:15:00',2,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (43,9,18,16,3,2,NULL,'2024-05-02','10:00:00',1,'Left thigh',NULL,'2024-05-30');
INSERT INTO "VaccinationRecord" VALUES (44,9,18,16,4,2,NULL,'2024-05-30','10:15:00',2,'Right thigh',NULL,'2024-06-27');
INSERT INTO "VaccinationRecord" VALUES (45,9,18,16,1,2,NULL,'2024-06-27','10:30:00',3,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (46,17,19,17,5,3,NULL,'2024-05-03','11:00:00',1,'Right arm',NULL,'2024-05-31');
INSERT INTO "VaccinationRecord" VALUES (47,17,19,17,6,3,NULL,'2024-05-31','11:15:00',2,'Left arm',NULL,'2024-06-28');
INSERT INTO "VaccinationRecord" VALUES (48,17,19,17,4,3,NULL,'2024-06-28','11:30:00',3,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (49,24,20,18,8,4,NULL,'2024-05-04','09:45:00',1,'Left thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (50,31,21,19,10,5,NULL,'2024-05-05','13:00:00',1,'Right thigh',NULL,'2024-06-30');
INSERT INTO "VaccinationRecord" VALUES (51,31,21,19,11,5,NULL,'2024-06-30','13:15:00',2,'Left thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (52,38,22,20,14,6,NULL,'2024-05-06','09:00:00',1,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (53,45,1,1,2,1,NULL,'2024-05-07','08:30:00',1,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (54,52,1,2,3,2,NULL,'2024-05-08','09:00:00',1,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (55,59,2,3,13,1,NULL,'2024-05-09','10:00:00',1,'Left arm',NULL,'2024-05-30');
INSERT INTO "VaccinationRecord" VALUES (56,59,2,3,1,1,NULL,'2024-05-30','10:15:00',2,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (57,66,2,4,5,3,NULL,'2024-05-10','11:00:00',1,'Left thigh',NULL,'2024-05-31');
INSERT INTO "VaccinationRecord" VALUES (58,66,2,4,6,3,NULL,'2024-05-31','11:15:00',2,'Right thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (59,73,3,5,4,2,NULL,'2024-05-11','13:30:00',1,'Left arm',NULL,'2024-06-08');
INSERT INTO "VaccinationRecord" VALUES (60,73,3,5,3,2,NULL,'2024-06-08','13:45:00',2,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (61,10,4,6,8,4,NULL,'2024-05-12','09:15:00',1,'Left thigh',NULL,'2024-06-09');
INSERT INTO "VaccinationRecord" VALUES (62,10,4,6,9,4,NULL,'2024-06-09','09:30:00',2,'Right thigh','Mild fever reported',NULL);
INSERT INTO "VaccinationRecord" VALUES (63,18,5,7,10,5,NULL,'2024-05-13','10:00:00',1,'Left arm',NULL,'2024-06-12');
INSERT INTO "VaccinationRecord" VALUES (64,18,5,7,11,5,NULL,'2024-06-12','10:15:00',2,'Right arm',NULL,'2024-07-12');
INSERT INTO "VaccinationRecord" VALUES (65,18,5,7,9,5,NULL,'2024-07-12','10:30:00',3,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (66,27,6,8,12,6,NULL,'2024-05-14','11:00:00',1,'Right thigh',NULL,'2024-11-10');
INSERT INTO "VaccinationRecord" VALUES (67,27,6,8,13,6,NULL,'2024-11-10','11:15:00',2,'Left thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (68,34,7,9,1,1,NULL,'2024-05-15','08:45:00',1,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (69,41,8,10,4,2,NULL,'2024-05-16','09:00:00',1,'Right arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (70,48,9,11,5,3,NULL,'2024-05-17','09:30:00',1,'Left thigh',NULL,'2024-11-13');
INSERT INTO "VaccinationRecord" VALUES (71,48,9,11,6,3,NULL,'2024-11-13','09:45:00',2,'Right thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (72,56,10,12,7,4,NULL,'2024-05-18','10:00:00',1,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (73,64,11,13,9,5,NULL,'2024-05-19','10:30:00',1,'Right arm',NULL,'2024-06-16');
INSERT INTO "VaccinationRecord" VALUES (74,64,11,13,15,5,NULL,'2024-06-16','10:45:00',2,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (75,72,12,14,14,6,NULL,'2024-05-20','11:00:00',1,'Right thigh',NULL,'2024-08-12');
INSERT INTO "VaccinationRecord" VALUES (76,72,12,14,12,6,NULL,'2024-08-12','11:15:00',2,'Left thigh',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (77,81,13,21,1,2,NULL,'2024-05-21','09:00:00',1,'Left arm',NULL,NULL);
INSERT INTO "VaccinationRecord" VALUES (78,88,14,22,10,5,NULL,'2024-05-22','13:00:00',1,'Right arm',NULL,'2024-05-29');
INSERT INTO "VaccinationRecord" VALUES (79,88,14,22,11,5,NULL,'2024-05-29','13:15:00',2,'Left arm',NULL,'2024-06-05');
INSERT INTO "VaccinationRecord" VALUES (80,88,14,22,9,5,NULL,'2024-06-05','13:30:00',3,'Right arm',NULL,NULL);
INSERT INTO "Vaccine" VALUES (1,'Influenza','Sanofi','Fluzone',1,NULL,0.5,2.0,8.0,365,1);
INSERT INTO "Vaccine" VALUES (2,'COVID-19 mRNA','Pfizer-BioNTech','Comirnaty',2,21,0.3,-90.0,-60.0,180,1);
INSERT INTO "Vaccine" VALUES (3,'COVID-19 mRNA','Moderna','Spikevax',2,28,0.5,-25.0,-15.0,180,1);
INSERT INTO "Vaccine" VALUES (4,'MMR','Merck','MMR II',2,28,0.5,2.0,8.0,730,1);
INSERT INTO "Vaccine" VALUES (5,'Hepatitis B','GSK','Engerix-B',3,30,1.0,2.0,8.0,540,1);
INSERT INTO "Vaccine" VALUES (6,'Hepatitis A','GSK','Havrix',2,180,1.0,2.0,8.0,365,1);
INSERT INTO "Vaccine" VALUES (7,'Tetanus','Sanofi','Tenivac',1,NULL,0.5,2.0,8.0,730,1);
INSERT INTO "Vaccine" VALUES (8,'Meningococcal','Pfizer','Nimenrix',1,NULL,0.5,2.0,8.0,365,1);
INSERT INTO "Vaccine" VALUES (9,'HPV','Merck','Gardasil 9',2,180,0.5,2.0,8.0,1095,1);
INSERT INTO "Vaccine" VALUES (10,'Pneumococcal','Pfizer','Prevnar 13',1,NULL,0.5,2.0,8.0,730,1);
INSERT INTO "Vaccine" VALUES (11,'Rotavirus','GSK','Rotarix',2,28,1.5,2.0,8.0,540,1);
INSERT INTO "Vaccine" VALUES (12,'Chickenpox','Merck','Varivax',2,84,0.5,-50.0,-15.0,730,1);
INSERT INTO "Vaccine" VALUES (13,'Typhoid','Sanofi','Typhim Vi',1,NULL,0.5,2.0,8.0,365,1);
INSERT INTO "Vaccine" VALUES (14,'Rabies','Sanofi','Imovax',3,7,1.0,2.0,8.0,365,1);
INSERT INTO "Vaccine" VALUES (15,'Yellow Fever','Sanofi','Stamaril',1,NULL,0.5,2.0,8.0,730,1);
INSERT INTO "Vaccine" VALUES (16,'Cholera','Valneva','Dukoral',2,7,3.0,2.0,8.0,365,1);
INSERT INTO "Vaccine" VALUES (17,'Shingles','GSK','Shingrix',2,60,0.5,2.0,8.0,730,1);
INSERT INTO "Vaccine" VALUES (18,'DTaP','Sanofi','Infanrix',3,28,0.5,2.0,8.0,540,1);
INSERT INTO "Vaccine" VALUES (19,'Polio','Sanofi','IPOL',3,28,0.5,2.0,8.0,365,1);
INSERT INTO "Vaccine" VALUES (20,'BCG','SSI','BCG Vaccine SSI',1,NULL,0.1,2.0,8.0,365,1);
INSERT INTO "Vaccine" VALUES (21,'Meningitis B','GSK','Bexsero',2,56,0.5,2.0,8.0,730,1);
INSERT INTO "Vaccine" VALUES (22,'Pertussis','GSK','Boostrix',1,NULL,0.5,2.0,8.0,365,1);
INSERT INTO "VaccineBatch" VALUES (1,1,1,'FLU-2024-001','2024-01-01','2025-01-01',200,150,'2024-01-15','Fridge 1, Shelf A');
INSERT INTO "VaccineBatch" VALUES (2,1,2,'FLU-2024-002','2024-01-01','2025-01-01',150,100,'2024-01-15','Fridge 1, Shelf A');
INSERT INTO "VaccineBatch" VALUES (3,2,1,'COV-2024-001','2024-02-01','2024-08-01',100,60,'2024-02-10','Freezer 1, Shelf A');
INSERT INTO "VaccineBatch" VALUES (4,2,3,'COV-2024-002','2024-02-01','2024-08-01',100,75,'2024-02-10','Freezer 1, Shelf A');
INSERT INTO "VaccineBatch" VALUES (5,3,2,'COV-2024-003','2024-02-01','2024-08-01',100,50,'2024-02-10','Freezer 2, Shelf A');
INSERT INTO "VaccineBatch" VALUES (6,4,4,'MMR-2024-001','2024-01-15','2026-01-15',80,60,'2024-02-01','Fridge 2, Shelf B');
INSERT INTO "VaccineBatch" VALUES (7,5,5,'HEP-2024-001','2024-01-01','2025-07-01',100,80,'2024-01-20','Fridge 1, Shelf B');
INSERT INTO "VaccineBatch" VALUES (8,6,6,'HEPA-2024-001','2024-01-01','2025-01-01',80,65,'2024-01-20','Fridge 2, Shelf A');
INSERT INTO "VaccineBatch" VALUES (9,7,1,'TET-2024-001','2024-01-01','2026-01-01',120,100,'2024-01-15','Fridge 1, Shelf C');
INSERT INTO "VaccineBatch" VALUES (10,8,2,'MEN-2024-001','2024-01-01','2025-01-01',90,70,'2024-01-15','Fridge 2, Shelf B');
INSERT INTO "VaccineBatch" VALUES (11,9,3,'HPV-2024-001','2024-01-01','2027-01-01',60,45,'2024-01-20','Fridge 1, Shelf A');
INSERT INTO "VaccineBatch" VALUES (12,10,4,'PNE-2024-001','2024-01-01','2026-01-01',100,85,'2024-01-15','Fridge 1, Shelf B');
INSERT INTO "VaccineBatch" VALUES (13,11,5,'ROT-2024-001','2024-01-01','2025-07-01',80,60,'2024-01-20','Fridge 2, Shelf A');
INSERT INTO "VaccineBatch" VALUES (14,12,6,'CHK-2024-001','2024-01-01','2026-01-01',70,55,'2024-01-15','Freezer 1, Shelf B');
INSERT INTO "VaccineBatch" VALUES (15,17,1,'SHI-2024-001','2024-01-01','2026-01-01',90,75,'2024-01-15','Fridge 1, Shelf D');
INSERT INTO "VaccineBatch" VALUES (16,18,2,'DTA-2024-001','2024-01-01','2025-07-01',100,80,'2024-01-15','Fridge 2, Shelf C');
INSERT INTO "VaccineBatch" VALUES (17,19,3,'POL-2024-001','2024-01-01','2025-01-01',80,65,'2024-01-20','Fridge 1, Shelf B');
INSERT INTO "VaccineBatch" VALUES (18,20,4,'BCG-2024-001','2024-01-01','2025-01-01',60,50,'2024-01-15','Fridge 2, Shelf A');
INSERT INTO "VaccineBatch" VALUES (19,21,5,'MEB-2024-002','2024-01-01','2026-01-01',80,65,'2024-01-20','Fridge 1, Shelf C');
INSERT INTO "VaccineBatch" VALUES (20,22,6,'PER-2024-001','2024-01-01','2025-01-01',90,75,'2024-01-15','Fridge 2, Shelf B');
INSERT INTO "VaccineBatch" VALUES (21,13,2,'TYP-2024-001','2024-01-01','2025-07-01',65,60,'2024-01-15','Fridge 2, Shelf C');
INSERT INTO "VaccineBatch" VALUES (22,14,5,'RAB-2024-001','2024-01-01','2025-07-01',80,60,'2024-01-20','Fridge 2, Shelf A');
INSERT INTO "VaccineBatch" VALUES (23,15,5,'YEF-2024-001','2024-01-01','2025-07-01',80,60,'2024-01-20','Fridge 2, Shelf A');
INSERT INTO "VaccineBatch" VALUES (24,16,6,'CHO-2024-001','2024-01-01','2026-01-01',70,55,'2024-01-15','Freezer 1, Shelf B');
CREATE INDEX IF NOT EXISTS "idx_patient_neighbourhood" ON "Patient" (
	"neighbourhood"
);
CREATE INDEX IF NOT EXISTS "idx_patient_primaryclinic" ON "Patient" (
	"primary_clinic_id"
);
CREATE INDEX IF NOT EXISTS "idx_vaccinationrecord_clinic" ON "VaccinationRecord" (
	"clinic_id"
);
CREATE INDEX IF NOT EXISTS "idx_vaccinationrecord_patient" ON "VaccinationRecord" (
	"patient_id"
);
CREATE INDEX IF NOT EXISTS "idx_vaccinationrecord_vaccine" ON "VaccinationRecord" (
	"vaccine_id"
);
CREATE INDEX IF NOT EXISTS "idx_vaccinationrecord_worker" ON "VaccinationRecord" (
	"worker_id"
);
CREATE INDEX IF NOT EXISTS "idx_vaccinebatch_clinic" ON "VaccineBatch" (
	"clinic_id"
);
CREATE INDEX IF NOT EXISTS "idx_vaccinebatch_vaccine" ON "VaccineBatch" (
	"vaccine_id"
);
COMMIT;
