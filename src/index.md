![doodle](./doodle.jpg)

# UCSD CSE 231 (Spring 2026)

## Crew

- [Ranjit Jhala](https://ranjitjhala.github.io) (Instructor)
- Cole Kurashige (TA)

(with **many thanks** to [Joe Politz](https://jpolitz.github.io) from whom much of this material is gratefully borrowed!)

[Basics](#basics) -
[Resources](#resources) -
[Schedule](#schedule) -
[Staff](#staff) -
[Grading](#grading) -
[Policies](#policies)

In this course, we'll explore the implementation of **compilers**: programs that
transform source programs into other useful, executable forms. This will
include understanding syntax and its structure, checking for and representing
errors in programs, writing programs that generate code, and the interaction
of generated code with a runtime system.

We will explore these topics interactively in lecure, you will implement
an increasingly sophisticated series of compilers throughout the course to
learn how different language features are compiled, and you will think
through design challenges based on what you learn from implementation.

This web page serves as the main source of announcements and resources for the
course, as well as the syllabus.

## Basics

- **Lecture:** _CENTER 115_ Tu-Th 12:30-1:50pm
- **Discussion:** _CENTER 115_ Fr 3:00-3:50pm
- **Midterm Exams:** _(In Friday Discussion Section)_ **May 1** (Week 5), **May 29** (Week 9) and Monday **June 8** (finals week), 1:00-2:30pm (TBA)
- **Q&A Forum:** [Piazza](https://piazza.com/ucsd/spring2026/cse231)

## Office Hours

- Ranjit (Tu 1pm - 2pm in CSE 3110)
- Cole (Fri 4pm - 5pm in CSE 3217)

## Resources

Textbook/readings: There's no official textbook, but we will link to
different online resources for you to read to supplement lecture. Versions
of this course have been taught at several universities, so sometimes I'll
link to those instructors' materials as well.

Some useful resources are:

- [The Rust Book](https://doc.rust-lang.org/book/) (also [with embedded quizzes](https://rust-book.cs.brown.edu/))
- [An Incremental Approach to Compiler Construction](http://scheme2006.cs.uchicago.edu/11-ghuloum.pdf)
- [UMich EECS483](https://maxsnew.com/teaching/eecs-483-fa22/)
- [Northeastern CS4410](https://courses.ccs.neu.edu/cs4410/)

## Schedule

The schedule below outlines topics, due dates, and links to assignments. The
schedule of lecture topics might change slightly, but I post a general plan so
you can know roughly where we are headed.

**Assignments** are generally due on Friday evening.

### Week 1 - Rust and Source to Assembly Conversion

- [Assignment (due Friday, April 5, 23:59:59)](./week1/index.md)
- [Assignment on Github Classroom](https://classroom.github.com/a/8_IhC3V5)
- Reading and resources:
  - [Tue 4/1 Handout](https://drive.google.com/file/d/1AOZ-MRYc1DYdbBlz6xkMrETaeCfHujZI/view?usp=share_link)
  - [Thu 4/3 Handout](https://drive.google.com/file/d/1eYTybBS3QNRYkhIbsEnPCHXGACMqEJ5p/view?usp=share_link) [(pptx)](https://docs.google.com/presentation/d/1gGeC4Wp68sHLZLR6YbPAAdJk3NevdYcM/edit?usp=share_link&ouid=117453768726816085396&rtpof=true&sd=true)
  - [Week 1 markup](./static/week1.pdf)
  - [Rust Book Chapters 1-6](https://doc.rust-lang.org/book)
  - [x86-64 quick reference (Stanford)](https://web.stanford.edu/class/archive/cs/cs107/cs107.1196/guide/x86-64.html)
  - [x86-64 quick reference (Brown)](https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf)

## Staff

**Office hours** are concentrated on Wed, Thu, Fri, since most
assignments are due Friday evening. Please check the calendar before you come
in case there have been any changes. When you come to the office hour, we may
ask you to put your name in the queue using the whiteboard. Read the
description about [collaboration below](#policies) for some context about
office hours. The office hours schedule is below; each event has details about
remote/in-person:

## Grading

Your grade will be calculated from **assignments**, **exams** and **worksheets**.

- **(8-9) Assignments [30%]** are given periodically, typically at one or two week intervals.
  On each you'll get a score from 0-3 (Incomplete/No Pass, Low Pass, Pass, High Pass).

- **(2/3) Midterm Exams [50%]** There are three exams in the course,
  one in week 5 and one in week 9, given in the Friday discussion sections,
  and one in the finals week. Your top two exams will be counted.

- **(daily) Worksheets [20%]** Every lecture will come with a 1-2 page handout,
  that must be filled in and submitted _at the end of the lecture_.
  Credit is given for reasonable effort in engaging with the notes
  from the day on the handout. Turn in 75% of the worksheets to get full credit.

**Comprehensive Exam**: For graduate students using this course for a
comprehensive exam requirement, you must get "A" achievement on the exams. Note
that you can use the final exam make-up time to do this!

## Policies

### Lectures and Exams

1. We will **not podcast** lectures.
2. We will have **worksheets** to be filled in and submitted in every lecture.
3. We have a **no-screens** policy: students must keep their devices off during lectures.
4. We require all exams be taken on the [announced dates and times](https://ucsd-cse230.github.io/wi26/contact.html)

### Integrity of Scholarship

University rules on integrity of scholarship will be strictly enforced. By
taking this course, you implicitly agree to abide by the UCSD Policy on
Integrity of Scholarship described [here](http://www-senate.ucsd.edu/manual/Appendices/app2.htm).

### Programming Assignments

**Eight** programming assignments, _done individually_.
Will be assigned approximately every two weeks,
and instructions on turning them in will be posted with
each assignment.

### Late Work

You have a total of _six late days_ that you can use throughout the quarter,
but no more than _four late days_ per assignment.

- A late day means anything between 1 second and 23
  hours 59 minutes and 59 seconds past a deadline
- If you submit past the late day limit, you get 0 points for that assignment
- There is no penalty for submitting late but within the limit

### Regrades

Mistakes occur in grading. Once grades are posted for an assignment, we will
allow a short period for you to request a fix (announced along with grade
release). If you don't make a request in the given period, the grade you were
initially given is final.

### Exams

There will be three "midterm exams" during the quarter.
The first two will be held in discussion section, and
the third during the final exam slot.
We will take the **best two of three** scores from the three exams
to calculate your grade. (So, if you score high enough
on the exams during the quarter, you can skip the final.)
You can use one **single sheet of notes (front and back)**
on the exams, but no other study aids.

You cannot discuss the content of exams with others in the course until grades
have been released for that exam.

Some past exams are available at the link below for reference on format
(content changes from offering to offering so this may not be
representative):

- [sample exam 1](static/compilers-sample-exam-1.pdf)
- [sample exam 2](static/compilers-sample-exam-2.pdf)
- [sample exam 3](static/compilers-sample-exam-3.pdf)
- [sample exam 4](static/compilers-sample-exam-4.pdf)
- [x86 reference](static/x86-reference.pdf)
