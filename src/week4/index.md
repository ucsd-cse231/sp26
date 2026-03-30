![caduceus](./caduceus.png)

## Week 4: Caduceus, Due Wednesday, May 3, 10pm

In this assignment, you'll spend time reflecting on, and learning from, the
designs you and others chose for PA3.

We will make PA3 compilers available to the class. Fill out this form by 8am on
Thursday, April 27 if you'd like your compiler to be included. We'll make the
review assignments by the end of the day on Thursday, April 27. Feel free to
clean up or modify your repository prior to sharing it; we'll download what's
at the repo link you give on Thursday:

<https://docs.google.com/forms/d/e/1FAIpQLSeF-0Ihc-MGmGOIcO2_zyzJyfosXuyc5-2CJ-VpP57V6ZG-jA/viewform>

You will be assigned 2 other compilers to review.

Your feedback will be **shared with the class (including the author of the
compiler)**, so make sure to keep what you write professional and
constructive.

### Assigned Compilers

All submitted compilers and the instructions for downloading them are available
via this EdStem post: https://edstem.org/us/courses/38748/discussion/3036419

### Tracing the Compiler

For **each** of the compilers you are reviewing, choose two programs that run
successfully on the compiler under review (e.g. they match the correct
behavior). Make sure that between them, they at least use:

  - A loop that runs several times and terminates
  - At least 2 different binary operators
  - `input`

For each program you chose, show _three_ relevant code snippets from the
compiler that are critical to its compilation. For example, you might
show the data structures used in the type checker, the code generation,
and the parsing for a particular expression. Only choose the same snippet
of code for both programs if it behaves in an interestingly different way
across the two.

For each code snippet, write a sentence of how it relates to different parts
of the program you're testing.

You can use the same two programs on both compilers if you think they
illustrate the behavior well.

This means you should have a total of **twelve** code snippets (three per
compiler, per two examples).

### Bugs, Missing Features, and Design Decisions

For **each** compiler you are reviewing, choose a program that has different
behavior than it should.

- If a key feature in the program isn't implemented, describe how you would
add it to the compiler (see below for how to do this).
- If it is implemented but produces an error, describe how you could fix the
error and make it produce the correct answer (see below for how to do
this)
- If it is implemented but produces the wrong answer, decide if you
think this was a reasonable design decision. Describe as appropriate:

  1. If you think producing this answer instead made certain parts of the
  compiler design simpler or easier than matching the spec, and identify how.
  3. If you think it's just a bug, and if so, how to fix it.
  4. If you think it's a better design decision than what was chosen for Cobra.
- If you think the compiler perfectly implements Cobra,
explain what you tested to reach this conclusion and why you are confident
that it does.

### Lessons and Advice

Answer the following questions:

1. Identify a decision made in this compiler that's different from yours.
Describe one way in which it's a **better** design decision than you made.
1. Identify a decision made in this compiler that's different from yours.
Describe one way in which it's a **worse** design decision than you made.
1. What's one improvement you'll make to your compiler based on seeing this
one?
1. What's one improvement you recommend this author makes to their compiler
based on reviewing it?

### Handin

You will this assignment as a PDF, first with the pages containing the review
of the first compiler you were assigned followed by pages containing the review
of the second. Please start the review of the second compiler on a *new page*.
(We wish you could submit and label 2 pdfs but Gradescope doesn't allow that).


