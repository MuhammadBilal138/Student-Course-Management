CREATE TABLE students(
	student_id SERIAL PRIMARY KEY,
	student_name VARCHAR(100) NOT NULL,
	age SMALLINT NOT NULL,
	city VARCHAR(50) NOT NULL
);

CREATE TABLE courses(
	course_id SERIAL PRIMARY KEY,
	course_name VARCHAR(100) NOT NULL,
	fee INT NOT NULL
);

CREATE TABLE enrollments (
    enroll_id SERIAL PRIMARY KEY,
    student_id INT,
    course_id INT,
    enroll_date DATE DEFAULT CURRENT_DATE,
    CONSTRAINT fk_student
        FOREIGN KEY (student_id)
        REFERENCES students(student_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_course
        FOREIGN KEY (course_id)
        REFERENCES courses(course_id)
);

CREATE PROCEDURE add_student(
	s_name VARCHAR(100),
	s_age SMALLINT,
	s_city VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO students(student_name, age, city) 
	VALUES (s_name, s_age, s_city);

	RAISE NOTICE 'Student Added Successfully';
END;
$$;

CALL add_student('Hasan', 23::SMALLINT, 'Karachi');

SELECT * FROM students;

CREATE PROCEDURE add_course(
	c_name VARCHAR(100),
	c_fee INT
)
LANGUAGE plpgsql
AS $$
BEGIN 
	INSERT INTO courses(course_name, fee) 
	VALUES (c_name, c_fee);

	RAISE NOTICE 'Course Added Sucessfully';
END;
$$

CALL add_course('UI/UX', 3000);

SELECT * FROM courses;

CREATE PROCEDURE add_enrollments(
	e_student_id INT,
	e_course_id INT
)
LANGUAGE plpgsql
AS $$ 
BEGIN 
	INSERT INTO enrollments(student_id, course_id)
	VALUES (e_student_id, e_course_id);

	RAISE NOTICE 'Student Enrolled';
END;
$$;

CALL add_enrollments(4,4);

SELECT * FROM enrollments;

SELECT s.student_name, 
	   c.course_name
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id;

SELECT s.student_name,
	   COUNT(e.course_id) AS total_courses
FROM enrollments e
JOIN students s ON e.student_id = s.student_id
GROUP BY s.student_id, s.student_name
HAVING COUNT(e.course_id) > 1;

SELECT c.course_name
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
WHERE e.course_id IS NULL;

SELECT s.student_name,
       c.course_name
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE s.city = 'Karachi';

SELECT c.course_name,
       COUNT(e.student_id) AS total_students
FROM courses c
LEFT JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY total_students DESC;

SELECT s.student_name,
       SUM(c.fee) AS total_fee
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
GROUP BY s.student_id, s.student_name
ORDER BY total_fee DESC;

SELECT c.course_name,
       COUNT(e.student_id) AS total_students
FROM courses c
JOIN enrollments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_name
ORDER BY total_students DESC
LIMIT 1;

CREATE VIEW student_course_view AS
SELECT s.student_name,
       c.course_name,
       c.fee
FROM students s
JOIN enrollments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id;

SELECT * FROM student_course_view WHERE fee > 3000;