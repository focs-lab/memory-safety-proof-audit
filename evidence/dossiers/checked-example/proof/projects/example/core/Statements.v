(** * example / core: theorem statement

    SUBJECT.  Two builds of our synthetic fuzz target [core] (example/example_core.c) (the byte-code
    dispatcher of the paper's Section 5, example/example.c), static riscv64
    Linux programs run as [<file> FILE], built by replay/example/build.sh the
    way OSS Verify's recipe builds a C fuzz target:
      plain       no sanitizer
      asan        AddressSanitizer; a report aborts
    [Images] names their memory images.  Their driver (recipe src/cli.c) reads
    FILE as [u16 config word][config bytes][u32 allocation mask][payload],
    calls LLVMFuzzerTestOneInput(payload, length) one to four times, and prints
    each return value.

    WHAT THE HARNESS DOES.  Allocates struct S { char buf[20]; unsigned char
    op; } (21 bytes), sets op = OP_READ, copies up to 21 input bytes into buf
    (an off-by-one: the 21st byte lands in op), and calls handlers[op]() from a
    constant 256-entry table whose entry 0xff is h_admin.

    Hand-written to match the generated projects/<p>/<h>/Statements.v of the
    release (template tools/oft/templates/Statements.v.tmpl): same imports,
    same definition, same documentation of the agreement statement. *)

From Stdlib Require Import QArith.
From OssFuzzTheorems.Core Require Import Shapes.
From OssFuzzTheorems.example.core Require Images.

(** ** Agreement of the sanitizer build with the plain build *)

(** On every input on which the plain build is never refused memory for
    exceeding 2 GiB, when a memory request is refused only if the budget is
    spent or no address range is free (any other request may still be refused,
    in either build): neither build ever faults, aborts or leaves the model, and
    the two write the same bytes and exit with the same status.  An ASan report
    aborts, so a proof shows that ASan reports nothing on any such input: no
    memory error that this build's ASan detects happens in the code it
    instruments (the harness and the driver, less the code the build links
    uninstrumented).

    Not claimed: anything about inputs on which the plain build needs more than
    2 GiB; memory errors ASan does not detect (for example an access that lands
    inside another live object, or one made in code it does not instrument). *)
Definition asan_agrees : Prop :=
  agrees_in Env.alloc_forced_only Budgets.Asan.lim_source Budgets.Asan.lim_target Images.plain Images.asan.
