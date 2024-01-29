# RISC-V Prozessor
## Requirements
- make
- ghdl
- gtkwave (optional)

---

## Build Instructions
To analyze, elaborate and run all entity testbenches use 
```bash
make all
```

To build just one specific testbench use 
```bash
make <entity>
```
with entity being one of *ram*, *regs*, *alu*, *imm*, *decoder* and *cpu* at the moment.

Make sure to clean the project by using the command 
```bash
make clean
```
before commit or push to the repository.

---

## Config / structure 
Ram size: 4096b => 4kb divided in 1kb Instruction, 3kb Data   
Instruction set: 32i Base Instructions (currently R | I | S implemented)    

## Git
### Branches
Open new Branch when
- you start working on more than one file or
- you do more than minor changes to existing code
- you plan on improving already finished parts
- you want to make changes for testing

### Commits
- Commit after every major change
- If creating a new file do
```bash
git commit
```
for only this file
- Give a brief and precice description of your changes
- Use ERROR/WARNING/BUG to indicate a problem in your commit
- Make sure to only commit important files

### Merges
- Only merge, if your branch is worked out
- Don't merge branches with errors, or bugs, unless we merge all branches together
- If filestructure was changed, do a rebase instead

---

## Code
### Comments
- Comment every entity/architecture/process/etc.
- Comments should be less than one sentence
- No comments for single statements

### Naming and Style
- avoid meaningless names for signals, ports, variables
- use 2 spaces or tabsize 2 intendation
- name every process, entity, ...
- FORMAT FILE WITH EMACS (C-c + C-b)

### Programming conventions
- reduce the use of programming control structures as far as possible
- if possible use switch case instead of if
- use if statements instead of index access to vectors (avoiding latches)
