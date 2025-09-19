/* Create a table medication_stock in your Smart Old Age Home database. The table must have the following attributes:
 1. medication_id (integer, primary key)
 2. medication_name (varchar, not null)
 3. quantity (integer, not null)
 Insert some values into the medication_stock table. 
 Practice SQL with the following:
 */
CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    specialization TEXT NOT NULL
);

CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INT NOT NULL,
    room_no INT NOT NULL,
    doctor_id INT REFERENCES doctors(doctor_id)
);

CREATE TABLE treatments (
    treatment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    nurse_id INT ,
    treatment_type TEXT NOT NULL,
    treatment_time TIMESTAMP NOT NULL
);

CREATE TABLE sensors (
    sensor_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    sensor_type TEXT NOT NULL,
    reading NUMERIC NOT NULL,
    reading_time TIMESTAMP NOT NULL
);

INSERT INTO doctors (name, specialization) VALUES
('Dr. Smith', 'Geriatrics'),
('Dr. Johnson', 'Cardiology'),
('Dr. Lee', 'Neurology'),
('Dr. Patel', 'Endocrinology'),
('Dr. Adams', 'General Medicine');

INSERT INTO patients (name, age, room_no, doctor_id) 
VALUES
('Alice', 82, 101, 1),
('Bob', 79, 102, 2),
('Carol', 85, 103, 1),
('David', 88, 104, 3),
('Ella', 77, 105, 2),
('Frank', 91, 106, 4);

INSERT INTO treatments (patient_id, nurse_id, treatment_type, treatment_time) VALUES
(1, 1, 'Physiotherapy', '2025-09-10 09:00:00'),
(2, 2, 'Medication', '2025-09-10 18:00:00'),
(1, 3, 'Medication', '2025-09-11 21:00:00'),
(3, 1, 'Checkup', '2025-09-12 10:00:00'),
(4, 2, 'Physiotherapy', '2025-09-12 17:00:00'),
(5, 5, 'Medication', '2025-09-12 18:00:00'),
(6, 4, 'Physiotherapy', '2025-09-13 09:00:00');

create table nurses(
	nurses_id SERIAL PRIMARY KEY,
	nurses_name TEXT NOT NULL,
	nurses_shift TEXT NOT NULL
);


INSERT INTO nurses (nurses_name, nurses_shift) VALUES
('Nurse Ann', 'Morning'),
('Nurse Ben', 'Evening'),
('Nurse Eva', 'Night'),
('Nurse Kim', 'Morning'),
('Nurse Omar', 'Evening');


CREATE TABLE medication_stock (
    medication_id SERIAL PRIMARY KEY,
    medication_name VARCHAR(30) NOT NULL,
    quantity INT NOT NULL
);

INSERT INTO medication_stock (medication_name, quantity) 
VALUES
('Loratadine', 50),
('Amoxicillin', 100),
('Paracetamol', 25),
('Omeprazole', 5);


 -- Q!: List all patients name and ages 
select name, age from patients;

 -- Q2: List all doctors specializing in 'Cardiology'
select name, specialization from doctors where specialization = 'Cardiology';

 
 -- Q3: Find all patients that are older than 80
select name, age from patients where age > 80;



-- Q4: List all the patients ordered by their age (youngest first)
select name, age from patients order by age ASC;



-- Q5: Count the number of doctors in each specialization
select specialization, count(doctor_id) AS doctor_count from doctors group by specialization;


-- Q6: List patients and their doctors' names
select p.name AS patient_name,d.name AS doctor_name from patients p join doctors d on p.doctor_id = d.doctor_id;


-- Q7: Show treatments along with patient names and doctor names
select t.treatment_id,t.treatment_type,t.treatment_time,p.name as patient_name,d.name as doctor_name from treatments tJOIN patients p on t.patient_id = p.patient_id join doctors d on p.doctor_id = d.doctor_id;


-- Q8: Count how many patients each doctor supervises
select d.name as doctor_name, count(p.patient_id) as patient_count from doctors d join patients p on d.doctor_id = p.doctor_id group by d.doctor_id, d.name;


-- Q9: List the average age of patients and display it as average_age
select avg(age) as average_age from patients;


-- Q10: Find the most common treatment type, and display only that
with treatment_counts as(select treatment_type, count(*) as type_count from treatments group by treatment_type) select treatment_type from treatment_counts where type_count = (select max (type_count) from treatment_counts);


-- Q11: List patients who are older than the average age of all patients
select name, age from patients where age > (select avg(age) from patients);


-- Q12: List all the doctors who have more than 5 patients
select d.name as doctor_name, count(p.patient_id) as patient_count from doctors d join patients p on d.doctor_id = p.doctor_id group by d.doctor_id, d.name having count(p.patient_id) > 5;



-- Q13: List all the treatments that are provided by nurses that work in the morning shift. List patient name as well. 
select t.treatment_id,t.treatment_type,t.treatment_time,p.name AS patient_name,n.nurses_name AS nurse_name from treatments t JOIN nurses n ON t.nurse_id = n.nurses_id JOIN patients p ON t.patient_id = p.patient_id WHERE n.nurses_shift = 'Morning';



-- Q14: Find the latest treatment for each patient
WITH ranked_treatments AS (SELECT*,ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY treatment_time DESC) AS rank FROM treatments)SELECT rt.treatment_id,p.name AS patient_name,rt.treatment_type,rt.treatment_time FROM ranked_treatments rt JOIN patients p ON rt.patient_id = p.patient_id WHERE rank = 1;


-- Q15: List all the doctors and average age of their patients
SELECT d.name AS doctor_name,AVG(p.age) AS average_patient_age FROM doctors d JOIN patients p ON d.doctor_id = p.doctor_id GROUP BY d.doctor_id, d.name;


-- Q16: List the names of the doctors who supervise more than 3 patients
SELECT d.name AS doctor_name,COUNT(p.patient_id) AS patient_count FROM doctors d JOIN patients p ON d.doctor_id = p.doctor_id GROUP BY d.doctor_id, d.name HAVING COUNT(p.patient_id) > 3;


-- Q17: List all the patients who have not received any treatments (HINT: Use NOT IN)
SELECT name FROM patients WHERE patient_id NOT IN (SELECT DISTINCT patient_id FROM treatments);



-- Q18: List all the medicines whose stock (quantity) is less than the average stock
SELECT medication_name, quantity FROM medication_stock WHERE quantity < (SELECT AVG(quantity) FROM medication_stock);



-- Q19: For each doctor, rank their patients by age
SELECT d.name AS doctor_name,p.name AS patient_name,p.age,RANK() OVER (PARTITION BY d.doctor_id ORDER BY p.age) AS age_rank FROM doctors d JOIN patients p ON d.doctor_id = p.doctor_id;


-- Q20: For each specialization, find the doctor with the oldest patient
WITH doctor_patient_max_age AS (SELECT d.doctor_id,d.name AS doctor_name,d.specialization, MAX(p.age) AS max_patient_age FROM doctors d JOIN patients p ON d.doctor_id = p.doctor_id GROUP BY d.doctor_id, d.name, d.specialization),specialization_top_age AS (SELECT specialization,MAX(max_patient_age) AS highest_age FROM doctor_patient_max_age GROUP BY specialization) SELECT dpm.specialization,dpm.doctor_name,dpm.max_patient_age FROM doctor_patient_max_age dpm JOIN specialization_top_age sta ON dpm.specialization = sta.specialization AND dpm.max_patient_age = sta.highest_age;






