# So, you want to learn x86_64 assembly?

This is the repo of someone who has managed to conquer the basics of x86_64 assembly without any tutorials or guides, just pure willpower and insanity.

In this github repo I have collected many small algorithm projects over time that have helped me learn to program in x86_64 assembly in Linux, ranging from sorting algorithms, to simple data structures, and even LeetCode problems solved in assembly. I'll try to comment and explain as much as I can. But still, **this is not a tutorial**. You should try to make these projects on your own, and maybe come here for inspiration or help.

There is also some shared wisdom for those interested in learning as well. I hope to make this repo useful not just for me, but for anyone who is just as crazy as I am.

Don't come here looking for tutorials or guides. This is a place for those who want to learn by doing, and by failing **(mostly this)**. If you are not ready to spend too much time debugging a single line of code, maybe this is not for you.

## Why bother?

Yes, learning to program in assembly is painful (but still very fun), and it is not a skill that is too relevant nowadays... *or is it?*.

Also pretty much anything you can do in assembly you can do in a higher level language, and probably faster.

Even the most barebone languages like C are already pretty high level compared to assembly.

And, of course, don't even think about using assembly for anything that is not small-scale (kudos to you if you manage to do it).

**Still, learning to program in assembly is great for a bunch of obvious reasons:**
- You will learn how a computer actually works at the hardware level.
- You will understand how to make code faster and more memory efficient.
- You will be a better C programmer (duh!).

**And some not so obvious reasons:**
- You will never fear pointers again.
- A mere segmentation fault will not scare you anymore.
- Learning to debug what is essentially slightly more readable 0s and 1s means you can debug anything.
- You will learn to appreciate the work of the people who made the high level languages you use.
- Also, if you can understand assembly, every code is open source B).
- **IT'S FUN!!!**

The takeaway should be:

**learning assembly is not a waste of time, and you will become a better programmer because of it.**


## About the code

Most of the code in this repo is x86_64 assembly for Linux, using GNU Assembler (GAS) syntax with the help of the standard C library. Compiled with as and linked with gcc.
```bash
as -o asem.o asem.s [-g]
gcc -o asem asem.o [-no-pie] [-no-startfiles] [-g]
```
The -g flag is for debugging **(which you WILL need)**, the -no-pie flag is to mark the code as not being Position Independent (which makes accessing global variables easier), and the -no-startfiles flag is used if you don't want to use a `main()` function.


I know GAS is not the most popular syntax, even I consider it a bit ugly and slightly confusing, but since its the one that Linux uses, I decided to stick with it for compatibility reasons. *Yes, you can get used to it.*

Still, I'm not here to argue about which is my favourite flavour of 0s and 1s. You can use whatever syntax or assembler you want and learn the same skills.


## About the projects

Here are some of the projects I have collected in this repo, with a ranking of difficulty:

| Project | Description | Difficulty |
| --- | --- | --- |
| hello_world | Printing to stdout using syscalls. | 2 |
| fibo | A recursive fibonacci function. | 3 |
| fibo_dp | A fibonacci function with dynamic programming. | 3 |
| quicksort | A simple quicksort with pivot as last element. | 4 |
| mergesort | The CLRS version of mergesort. | 6 |
| LC merge_two_ordered_lists | LeetCode problem 21 | 4 |

Mind that this difficulties are relative to someone who knows the basics of assembly. They might seem harder for most, and easier for a few.

And yes, hello_world is relatively easy, but it's not a 1 because you need to know about the .data segment and how to use syscalls. Also, **nothing is easy in assembly!!**

I will be adding more projects as I go, and I will try to make them more challenging as I learn more about assembly. I will also try to make them more interesting, and maybe even useful.


## For those who want to learn/improve

Learning assembly is hard, but very rewarding. Initially, you might feel like you are not making any progress, and you might get stuck with se faults or other weird bugs that just don't make sense. But don't worry, it gets better.

**Here's a few tips to start:**
- First of all, get used to assembly in general. It might be easier to start with a simpler architecture like ARM or MIPS with an emulator like [cpulator](https://cpulator.01xz.net/?sys=arm-de1soc), since using assembly on the OS is a lot trickier.
- Learn about data processing, memory access, and branching. These are the basics of any assembly language.
- Then, learn how to translate simple C code to assembly. If else statements, for, while and do while loops.
- Finally, learn how to use the stack, and how to call functions. This is the most important part of programming in assembly. If you manage to do recursion, you can oficially call yourself an assembly programmer.

**Once you're done with the basics, here's a few tips to get good at x86_64:**
- Learn about the register calling convention. If you can standardize how you use registers for your own functions, you will have a much easier time programming.
- The stack is your friend. Learn how to use it properly, and you'll never worry about losing your precious data between function calls. It also helps a lot with the tip above.
- Another tip for using the stack, is to draw a little diagram in your comments. Knowing which value has which offset will save you a lot of headaches. For example:
```
##################
# rbp - 8  = arg1
# rbp - 16 = arg2
# rbp - 24 = int1
# rbp - 28 = char1
# rbp - 29 = char2
# ...
##################
```

- GDB is your best friend. Learn how to use it, and how to finally find what the heck is causing that seg fault.
- If you are not sure of how to make something in assembly, try to make it in C first. You can then either try implementing it based on that code, or you can compile it with the -S flag to get the gcc assembly output.

**And, some of the pitfalls that have scarred me the most:**
- Most registers are volatile, and you **should not trust them** to keep their values between function calls. Learn which registers are safe to use.
- Division and multiplication use the **RDX** and **RAX** registers for a combined 16-byte integer, and you should clear them before using them.
- Many functions expect the stack pointer to be 16-byte aligned, and it might crash if it's not a multiple of 16.
- Variadic functions like printf check the **RAX** register for the number of floating point arguments passed, and if it's not zero, it may crash.
- Always take into consideration memory padding and alignment. If you combine data of different sizes, you will need to keep space between them to keep them aligned.

Once you get the hang of assembly, most of the pitfalls you will encounter will be due to lack of knowledge of the particular architecture / OS. Or at least that's what happened to me.


## TL;DR

Assembly is hard, but fun, and it will make you a better programmer.


