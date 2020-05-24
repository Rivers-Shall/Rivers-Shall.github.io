---
title: NJU-OS-M1-pstree
date: 2019-03-05 22:14:41
tags:
- OS
---

## Intro

`pstree` is a program in the package `psmisc` and can be downloaded on [the site of Ubuntu packages](https://packages.ubuntu.com/bionic/psmisc).  And now it is used as a Minilab(M1) of OS Course in NJU.

According to the handout of M1, I only need to implement a simplified version of `pstree`, including option `Vpn` and the corresponding long options.  To accomplish the target, the whole program can be divided into three parts:
1. Read and process the options
2. Read the info of processes(pid, ppid(pid of the parent process), name)
3. Save the info of processes and build the data structure of them
4. Print the processes as a tree

Actually, the 2nd and 3rd parts are done simultaneously.

<!-- more -->
## How to read and process the options

Certainly, I can use fancy pointer operations to deal with options.  But that is very error-prone and time-consuming.  And it is unworthy since Linux already has a library function `getopt_long` to deal with both the short and long options.

`man getopt_long` or reading the standard source code to know more.

## How to read the info of processes

There are many ways to read the info.  After reading the standard code, I used a similar way to do it---Use _directory stream_\* to get pid and process the status file `stat` of every process to get name and ppid.

\*directory stream: a stream of `struct dirent *` objects, each one points to an object in the directory on which the directory stream is created.
 
### Use directory stream to get pid

Why can we do that?  Well, in Linux, _Everything is file_.  So the info of all processes are stored under "/proc/" as files.  

Since every process has a unique pid, Linux uses the pid as the name of the directory under "/proc/" to store unique info of every process.  For example, the info of the process with pid 1711 is stored in "/proc/1711/".  

And there is no other file or directory whose name is number under "/proc/".  So we are free to use directory stream to process every object under "/proc/" and once we get an object whose name is a number, we know the number is pid.

#### A few details

- `DIR *opendir(const char *name);` returns a `DIR *` as a directory stream on `name`.

- `struct dirent *readdir(DIR *dirstream);` returns a `struct dirent *`, if there is more and returns `NULL` if the directory stream is empty.

- the `d_name` componemt of `struct dirent` stores the name of the `struct dirent`, which in our case is the pid.

- `d_name` is a string, but we can use `strtol` to transform it into number.  And if `strtol` failed, we know it is not the pid-named directory and can be ignored for good.

`man opendir readdir strtol` to know more, especially the error-detection mechanisms for these library functions.

#### Code
The code below also includes some error-detection mechanisms.

```C
#define PROC_DIR "/proc"

...

  /* open a directory stream on PROC_DIR */
  DIR *procDir = opendir(PROC_DIR);
  if (procDir == NULL) {
    perror(PROC_DIR);
    exit(1);
  }

  struct dirent *pidDir;
  errno = 0; // preset to detect error in readdir
  while ((pidDir = readdir(procDir)) != NULL) {
    char *endptr;
    pid_t pid = strtol(pidDir->d_name, &endptr, 10);
    if (pidDir->d_name[0] != '\0' && *endptr == '\0') { // condition for valid number, from `man strtol`
      ...
    }
  }
  if (errno != 0) {
    perror("readdir");
	exit(1);
  }
```

### Use `stat` file to get name and ppid

As we said before, all the info of a process is stored under "/proc/[pid]".  In particular, the status info is stored in "/proc/[pid]/stat" as a regular text file.  The first four words in the text file are pid, **process name in parentheses**, status and ppid.

Since the name is surrounded in parentheses, we only need to locate the leftmost '(' and the rightmost ')'. (Search for the leftmost '(' or rightmost ')' is wrong because the name itself may have parentheses in it.)

Once we find the rightmost ')', we can start from it to read the ppid.  The 'status' is a single capital character and can be ignored.

#### A few details

- Use `strchr` to find leftmost '(' and `strrchr` to locate the rightmost ')'

- By using [assignment-surppressing character](https://stackoverflow.com/questions/11109750/what-is-the-difference-between-cc-and-c-as-a-format-specifier-to-scanf) in `sscanf`, we can ignore 'status' info character.

#### Code

`add_proc` is for building the data structure.

```C
sprintf(path, "%s/%d/stat", PROC_DIR, pid);
FILE *fp = fopen(path, "r");
if (fp != NULL) {
  char readBuf[BUFSIZ + 1];
  size_t size = fread(readBuf, 1, BUFSIZ, fp);
  readBuf[size] = '\0'; // terminator
  if (ferror(fp) == 0) {
  char *comm;
  char *rest;
  pid_t ppid;

  /* construct comm str and
  handle threads */
  if ((comm = strchr(readBuf, '(')) &&
    (rest = strrchr(readBuf, ')'))) {
    ++comm;
    *rest = '\0';

    rest += 2;
    if ((sscanf(rest, "%*c %d", &ppid)) == 1) {
      add_proc(comm, pid, ppid, 0);
	  
	  /* handle threads */
	  ....
    }
  }
}
```

The code to handle threads is very similar to the code to handle processes.  Threads info is stored in "/proc/[pid]/task/[tid]".  And its status info is stored in "/proc/[pid]/task/[tid]/stat".

## How to save the info and build the data structure

The first thing we need to do is design the data structure to represent a process.  After that, we may use a convenient way to save it while reading it from part 2.

### The `PROC` struct

Since we need to print the `name`, `pid` of a process, these two components must be in `PROC` struct.  But the rest is hard to say.  The final result is a tree, so we may build a real tree in the computer, with every node being a `PROC` struct.  

But after reading the standard source code, I found a better way to represent the processes and the relation between them.  That is, use a linked list of `PROC` to store all the processes and the order does not matter.  However, in every `PROC` struct, we have a linked list of `PROC *`, of which each cell points to a child process.

It is like this:
![](data-structure/data-structure.jpg)

So the `PROC` and `CHILD` definition should be:
```C
typedef struct proc {
  struct proc *next; // next proc in the list
  struct proc *parent;
  struct child *children;
  pid_t pid;
  char comm[COMM_LEN + 2 + 1 + PID_LEN]; // 1 for '\0', 2 for threads brackets, 10 for the pid
  char isThread;
} PROC;

typedef struct child {
  const PROC *proc;
  struct child *next; // next pointer to proc in the list of child
} CHILD;

```

### Build the whole data structure

Now that we have the definition of structs, we may proceed to figure out how to build the data structure.  One way to do it is:
1. read the info of all the processes, build the `PROC` linked list
2. traverse the `PROC` list again and build parent-child relation(`CHILD` list of every proc) according to the ppid of every `PROC`.

Note that when we first add a `PROC`, we may not be able to find its parent because it may have not been added to the `PROC` list.  But after reading the standard source code, there is another way:
1. When we add a `PROC` whose parent is not in the `PROC` list, we add the parent `PROC` into the list.  Even though we don't know the name of the parent `PROC`, we know its pid(i.e., ppid of current process) and that is enough because we search `PROC` by pid, which is unique for every process.
2. When we try to add a `PROC`, we first check whether it is added by its children.  If it is, we rename it.  Otherwise we add it.

Both of the ways are effective.  And they are equally (in)efficient for having $O(n^2)$ time complexity.(it is OK because we normally have <1000 processes in out system.)  The choice is up to you.  I believe the second one involves some kind of cyclic processing, which is neat.  Of course, someone may claim it is error-prone and confusing.  But as I said, it is up to you.

#### Code
```C
PROC *add_proc(const char *comm, pid_t pid, pid_t ppid, char isThread) {
  /* add {} to comm if it is a thread */
  char *real_comm = (char *) malloc(strlen(comm) + 2 + 1); // 2 for '{}', 1 for '\0'
  if (isThread) {
    sprintf(real_comm, "{%s}", comm);
  } else {
    strcpy(real_comm, comm);
  }

  PROC *this;
  if ((this = find_proc(pid)) != NULL) {
    /* already in the list, probably 
       because of the adding-parent process */
    rename_proc(this, real_comm);
  } else {
    /* not in the list */
    this = new_proc(real_comm, pid);
    this->next = list;
    list = this;
  }

  /* add the parent */
  PROC *parent;
  if ((parent = find_proc(ppid)) == NULL) {
    parent = new_proc("?", ppid);
    parent->next = list;
    list = parent;
  }
  this->parent = parent;
  add_child(parent, this);

  free(real_comm);
  return this;
}

```
## How to print the processes as a tree

The simple answer is _recursion_.  Normally when it comes to problems about tree, we came up with some recursion algorithm.  And this is a simple one.  To print the tree, we need to:
1. print the root process
2. print the tree rooted at children processes

But someone thinks that the 2nd step is like this:
![wrong-print](wrong-print/wrong-print.jpg)

It is wrong.  Actually, it is like this:
![right-print](right-print/right-print.jpg)

That is why I need to add an argument `indent` to `print_proc`.

Code:
```C
typedef struct _formatter {
  const char *single;
  const char *first;
  const char *branch;
  const char *vertical;
  const char *last;
  const char *blank;
} FORMAT;

FORMAT formatter = {
		    "---", "-+-", " |-", " | ", " `-", "   "
};

void print_tree(const PROC *root, const char *indent) {
  char *comm = (char *) malloc(strlen(root->comm) + 10);
  if (showPid) {
    sprintf(comm, "%s(%d)", root->comm, root->pid);
  } else {
    strcpy(comm, root->comm);
  }
  printf("%s", comm);
  char *new_indent = (char *) malloc(strlen(indent) + strlen(comm) + 3 + 1 + 10); // 3 for formatter, 1 for terminator

  if (root->children == NULL) { // no children
    puts("");
    free(new_indent);
    free(comm);
    return;
  } else if (root->children->next == NULL) { // one child
    printf("%s", formatter.single);
    sprintf(new_indent, "%s%s%*s", indent, formatter.blank, (int) strlen(comm), "");
    print_tree(root->children->proc, new_indent);
  } else { // multiple children
    CHILD *child_p = root->children;
    printf("%s", formatter.first);
    sprintf(new_indent, "%s%*s%s", indent, (int) strlen(comm), "", formatter.vertical);
    print_tree(child_p->proc, new_indent);
    child_p = child_p->next;

    for (; child_p->next; child_p = child_p->next) {
      printf("%s%*s%s", indent, (int) strlen(comm), "", formatter.branch);
      sprintf(new_indent, "%s%*s%s", indent, (int) strlen(comm), "", formatter.vertical);
      print_tree(child_p->proc, new_indent);
    }
    
    printf("%s%*s%s", indent, (int) strlen(comm), "",  formatter.last);
    sprintf(new_indent, "%s%s%*s", indent, formatter.blank, (int) strlen(comm), "");
    print_tree(child_p->proc, new_indent);
  }
  free(new_indent);
  free(comm);
}

```

## Other

- `_()` is a function for internationalization and localization and originates from `gettext`. Some resources about `_()`:
  - [wiki](https://en.wikipedia.org/wiki/Gettext)
  - [official gnu gettext site](https://www.gnu.org/software/gettext/gettext.html)
  
