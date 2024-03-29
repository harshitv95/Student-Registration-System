create or replace package body srs as

-- Problem 2
-- Only SQLPlus
procedure show_students is
begin
    declare
        cursor cur is (select * from students);
        cur_row cur%rowtype;
        has_records boolean := false;
    begin
        if (not cur%isopen) then
            open cur;
        end if;
        fetch cur into cur_row;
        while cur%found
        loop
            dbms_output.put(cur_row.sid || ', ');
            dbms_output.put(cur_row.firstname || ', ');
            dbms_output.put(cur_row.lastname || ', ');
            dbms_output.put(cur_row.status || ', ');
            dbms_output.put(cur_row.gpa || ', ');
            dbms_output.put(cur_row.email);
            dbms_output.new_line;
            fetch cur into cur_row;
            has_records := true;
        end loop;
        if (not has_records) then
            dbms_output.put_line('No Records found in Students table');
        end if;
        close cur;
    end;
end;

function get_students
return refcursor as
rc refcursor;
begin
    open rc for
    select * from students order by sid;
    return rc;
end;

-- Only SQLPlus
procedure show_courses is
has_records boolean := false;
begin
    for cur in (select * from courses)
    loop
        dbms_output.put(cur.DEPT_CODE || ', ');
        dbms_output.put(cur.COURSE_NO || ', ');
        dbms_output.put(cur.TITLE);
        dbms_output.new_line;
        has_records := true;
    end loop;
    if (not has_records) then
        dbms_output.put_line('No Records found in Courses table');
    end if;
end;

function get_courses
return refcursor as
rc refcursor;
begin
    open rc for
    select * from courses order by dept_code, course_no;
    return rc;
end;

-- Only SQLPlus
procedure show_classes is
has_records boolean := false;
begin
    for cur in (select * from classes)
    loop
        dbms_output.put(cur.CLASSID || ', ');
        dbms_output.put(cur.DEPT_CODE || ', ');
        dbms_output.put(cur.COURSE_NO || ', ');
        dbms_output.put(cur.SECT_NO || ', ');
        dbms_output.put(cur.YEAR || ', ');
        dbms_output.put(cur.SEMESTER || ', ');
        dbms_output.put(cur.LIMIT || ', ');
        dbms_output.put(cur.CLASS_SIZE);
        dbms_output.new_line;
    end loop;
    if (not has_records) then
        dbms_output.put_line('No Records found in Classes table');
    end if;
end;

function get_classes
return refcursor as
rc refcursor;
begin
    open rc for
    select * from classes;
    return rc;
end;

-- Only SQLPlus
procedure show_enrollments is
has_records boolean := false;
begin
    for cur in (select * from enrollments)
    loop
        dbms_output.put(cur.SID || ', ');
        dbms_output.put(cur.CLASSID || ', ');
        dbms_output.put(cur.LGRADE);
        dbms_output.new_line;
    end loop;
    if (not has_records) then
        dbms_output.put_line('No Records found in Enrollments table');
    end if;
end;

function get_enrollments
return refcursor as
rc refcursor;
begin
    open rc for
    select * from enrollments order by sid;
    return rc;
end;

-- Only SQLPlus
procedure show_prerequisites is
has_records boolean := false;
begin
    for cur in (select * from prerequisites)
    loop
        dbms_output.put(cur.DEPT_CODE || ', ');
        dbms_output.put(cur.COURSE_NO || ', ');
        dbms_output.put(cur.PRE_DEPT_CODE || ', ');
        dbms_output.put(cur.PRE_COURSE_NO);
        dbms_output.new_line;
    end loop;
    if (not has_records) then
        dbms_output.put_line('No Records found in Prerequisites table');
    end if;
end;

function get_prerequisites
return refcursor as
rc refcursor;
begin
    open rc for
    select * from prerequisites;
    return rc;
end;

-- Only SQLPlus
procedure show_logs is
has_records boolean := false;
begin
    for cur in (select * from logs order by logid)
    loop
        dbms_output.put(cur.logid || ', ');
        dbms_output.put(cur.WHO || ', ');
        dbms_output.put(cur.TIME || ', ');
        dbms_output.put(cur.TABLE_NAME || ', ');
        dbms_output.put(cur.OPERATION || ', ');
        dbms_output.put(cur.KEY_VALUE);
    end loop;
    if (not has_records) then
        dbms_output.put_line('No Logs Records found in Database');
    end if;
end;

function get_logs
return refcursor as
rc refcursor;
begin
    open rc for
    select * from logs order by logid;
    return rc;
end;
-- End Problem 2

-- Problem 3
procedure add_student (
    sid students.sid%type,
    firstname students.firstname%type,
    lastname students.lastname%type,
    status students.status%type,
    gpa students.gpa%type,
    email students.email%type,
    status_out out varchar2
) is
begin
    insert into students (sid, firstname, lastname, status, gpa, email)
    values (sid, firstname, lastname, status, gpa, email);
    status_out := 'Successfully created new student record';
exception
    when others then
        status_out := 'Failed to create new student record; Caused by:' || chr(10) || sqlerrm;
        dbms_output.put_line(status_out);
end;
-- End Problem 3


-- Problem 4
function get_enrollment_details (
    student_id students.sid%type
)
return refcursor
as
rc refcursor;
begin
    open rc for
    select s.sid, s.lastname, s.status,
    cl.classid, cl.dept_code || cl.course_no as course,
    c.title, cl.year, cl.semester
    from (select * from students where sid = student_id) s
    left outer join enrollments e
    on s.sid = e.sid
    left outer join classes cl
    on e.classid = cl.classid
    left outer join courses c
    on c.dept_code = cl.dept_code and c.course_no = cl.course_no;
    return rc;
end;

-- Only SQLPlus
procedure show_enrollment_details (
    student_id students.sid%type
)
is
cursor cr is
    select s.sid, s.lastname, s.status,
    cl.classid, cl.dept_code || cl.course_no as course,
    c.title, cl.year, cl.semester
    from (select * from students where sid = student_id) s
    left outer join enrollments e
    on s.sid = e.sid
    left outer join classes cl
    on e.classid = cl.classid
    left outer join courses c
    on c.dept_code = cl.dept_code and c.course_no = cl.course_no;
has_records boolean := false;
cur_row cr%rowtype;
begin
    if (not cr%isopen) then
        open cr;
    end if;
    fetch cr into cur_row;
    if (cr%notfound) then
        dbms_output.put_line('The sid is invalid');
    elsif cur_row.classid is null then
        dbms_output.put_line('The student has not taken any course');
    else
        while cr%found
        loop
            has_records := true;
            if (cur_row.classid is null) then
                exit;
            end if;
            dbms_output.put_line(
                cur_row.sid || ', ' ||
                cur_row.lastname || ', ' ||
                cur_row.status || ', ' ||
                cur_row.classid || ', ' ||
                cur_row.course || ', ' ||
                cur_row.title || ', ' ||
                cur_row.year || ', ' ||
                cur_row.semester
                );

            fetch cr into cur_row;
        end loop;
    end if;
    if (cr%isopen) then
        close cr;
    end if;
end;
-- End Problem 4


-- Problem 5
function get_prerequisites(
    deptcode courses.dept_code%type,
    courseno courses.course_no%type
) return refcursor
as
rc refcursor;
begin
    open rc for
    select PRE_DEPT_CODE || PRE_COURSE_NO as pre_course
    from prerequisites
    start with dept_code = deptcode and course_no = courseno
    connect by prior PRE_COURSE_NO = course_no
    and prior PRE_DEPT_CODE = dept_code;
    return rc;
end;

-- Only SQLPlus
procedure show_prerequisites(
    deptcode courses.dept_code%type,
    courseno courses.course_no%type
)
is
begin
    for cur_row in (
        select PRE_DEPT_CODE || PRE_COURSE_NO as pre_course
        from prerequisites
        start with dept_code = deptcode and course_no = courseno
        connect by prior PRE_COURSE_NO = course_no
        and prior PRE_DEPT_CODE = dept_code
    ) loop
        dbms_output.put_line(cur_row.pre_course);
    end loop;
end;
-- End Problem 5


-- Problem 6
function get_class_students(
    class_id classes.classid%type
) return refcursor
as
rc refcursor;
begin
    open rc for
    select classid, title, semester, year, sid, lastname
    from (select * from classes where classid = class_id)
    left outer join enrollments using (classid)
    left outer join courses using (dept_code, course_no)
    left outer join students using (sid)
    order by classid;
    return rc;
end;

-- Only SQLPlus
procedure show_class_students(
    class_id classes.classid%type
) is
cursor c is
select classid, title, semester, year, sid, lastname
from (select * from classes where classid = class_id)
left outer join enrollments using (classid)
left outer join courses using (dept_code, course_no)
left outer join students using (sid)
order by classid;
has_records boolean := false;
begin
    for cur_row in c loop
        has_records := true;
        if (cur_row.sid is null) then
            dbms_output.put_line('No student is enrolled in the class');
            exit;
        end if;
        dbms_output.put_line(
            cur_row.classid || ', ' ||
            cur_row.title || ', ' ||
            cur_row.semester || ', ' ||
            cur_row.year || ', ' ||
            cur_row.sid || ', ' ||
            cur_row.lastname
        );
    end loop;
    if (not has_records) then
        dbms_output.put_line('The cid is invalid');
    end if;
end;
-- End Problem 6


-- Problem 7
procedure enroll_student(
    student_id students.sid%type,
    class_id classes.classid%type,
    status_out out varchar2
) is
class_limit classes.limit%type;
deptcode classes.dept_code%type;
courseno classes.course_no%type;
begin
    -- Checking if sid is valid
    declare
        studentid students.sid%type;
    begin
        select sid into studentid from students where sid = student_id;
    exception
        when no_data_found then
            status_out := 'The sid is invalid';
            dbms_output.put_line(status_out);
            return;
    end;

    -- Checking if cid is valid
    declare
        class_full exception;
        cid classes.classid%type;
        class_size classes.class_size%type;
    begin
        select classid, class_size, limit, dept_code, course_no
        into cid, class_size, class_limit, deptcode, courseno
        from classes where classid = class_id;
        if (class_size = class_limit) then
            raise class_full;
        end if;
    exception
        when no_data_found then
            status_out := 'The cid is invalid';
            dbms_output.put_line(status_out);
            return;
        when class_full then
            status_out := 'The class is full';
            dbms_output.put_line(status_out);
            return;
    end;

    -- Checking if the student is already enrolled in the class
    declare
        ctr_enrollments integer := 0;
    begin
        for cur_row in (select classid from enrollments where sid = student_id)
        loop
            if (cur_row.classid = class_id) then
                status_out := 'The student is already in this class';
                dbms_output.put_line(status_out);
                return;
            end if;
            ctr_enrollments := ctr_enrollments + 1;
        end loop;
        if (ctr_enrollments = 3) then
            status_out := 'You are overloaded';
            dbms_output.put_line(status_out);
        elsif (ctr_enrollments >= 4) then
            status_out := 'Students cannot be enrolled in more than four classes in the same semester';
            dbms_output.put_line(status_out);
            return;
        end if;
    end;

    -- Checking if all prerequisites are completed
    begin
        for cur_row in (select pre_course, lgrade from 
        (
            select PRE_DEPT_CODE || PRE_COURSE_NO as pre_course
            from prerequisites
            start with dept_code = deptcode and course_no = courseno
            connect by prior PRE_COURSE_NO = course_no
            and prior PRE_DEPT_CODE = dept_code) pre
            left outer join (
                select dept_code || course_no as course, lgrade
                from enrollments join classes using (classid)
                where sid = student_id
            ) cl
            on pre.pre_course = cl.course
            where (lgrade is null or lgrade > 'C')
        )
        loop
            status_out := 'Prerequisite courses have not been completed';
            dbms_output.put_line(status_out);
            return;
        end loop;
    end;

    -- Enroll student when all checks pass
    begin
        insert into enrollments
        values (student_id, class_id, null);
        status_out := trim(status_out || chr(10) || 'Student [' || student_id || '] enrolled into [' || class_id || '] successfully');
    exception
        when others then
            status_out := 'Failed to enroll student; Caused by' || chr(10) || sqlerrm;
    end;
    dbms_output.put_line(status_out);
end;
-- End Problem 7


-- Problem 8
procedure drop_class(
    student_id students.sid%type,
    class_id classes.classid%type,
    status_out out varchar2
) is
    deptcode classes.dept_code%type;
    courseno classes.course_no%type;
    num_classes_enrolled integer := 0;
    class_size classes.class_size%type;
begin
    -- Checking if sid is valid
    declare
        studentid students.sid%type;
    begin
        select sid into studentid from students where sid = student_id;
    exception
        when no_data_found then
            status_out := 'The sid is invalid';
            dbms_output.put_line(status_out);
            return;
    end;

    -- Checking if cid is valid,
    -- and if the student is enrolled in the course
    declare
        class_not_taken exception;
        cid classes.classid%type;
        studentid students.sid%type;
    begin
        select classid, class_size, dept_code, course_no, sid
        into cid, class_size, deptcode, courseno, studentid
        from classes
        left outer join
        (select * from enrollments where sid = student_id) e
        using (classid)
        where classid = class_id
        ;
        if (studentid is null) then
            raise class_not_taken;
        end if;
    exception
        when no_data_found then
            status_out := 'classid not found';
            dbms_output.put_line(status_out);
            return;
        when class_not_taken then
            status_out := 'The student is not enrolled in the class';
            dbms_output.put_line(status_out);
            return;
    end;

    -- Checking if the class to be dropped is
    -- a prerequisite of another course
    declare
        is_prerequisite exception;
    begin
        for cur_row in (
            select dept_code, COURSE_NO
            from (select * from enrollments where sid = student_id and classid != class_id)
            join classes using (classid)
        ) loop
            num_classes_enrolled := num_classes_enrolled + 1;
            declare
                temp_course_no classes.course_no%type;
            begin
                select PRE_COURSE_NO into temp_course_no
                from (
                    select PRE_DEPT_CODE, PRE_COURSE_NO
                    from prerequisites
                    start with
                        dept_code = cur_row.dept_code and
                        course_no = cur_row.course_no
                    connect by prior PRE_COURSE_NO = course_no
                    and prior PRE_DEPT_CODE = dept_code
                );
                raise is_prerequisite;
            exception
                when no_data_found then
                    null;
            end;
        end loop;
    exception
        when is_prerequisite then
            status_out := 'The drop is not permitted because another class uses it as a prerequisite';
            dbms_output.put_line(status_out);
            return;
    end;

    if (num_classes_enrolled = 1) then
        status_out := 'This student is enrolled in no class' || chr(10);
    end if;
    if (class_size = 1) then
        status_out := status_out || 'The class now has no students' || chr(10);
    end if;

    begin
        delete from enrollments
        where classid = class_id
        and sid = student_id;
        status_out := status_out || 'Successfully dropped [' || student_id || '] from [' || class_id || ']';
    exception
        when others then
            status_out := 'Failed to drop class [' || class_id || '] for student [' || student_id || ']; Caused by:' || chr(10) || sqlerrm;
    end;
    dbms_output.put_line(status_out);
end;
-- End Problem 8


-- Problem 9
procedure delete_student(
    student_id students.sid%type,
    status_out out varchar2
) is
begin
    delete from students where sid = student_id;
    if (sql%rowcount = 0) then
        status_out := 'sid not found';
        dbms_output.put_line(status_out);
        return;
    else
        status_out := 'Student [' || student_id || '] deleted successfully';
    end if;
exception
    when others then
        status_out := 'Failed to delete student [' || student_id || ']';
        dbms_output.put(status_out);
end;
-- End Problem 9

end; -- End Package Declaration
/
show errors;