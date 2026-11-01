# Simdjson proof coverage and custom allocation safety

Evidence dossier for research and blog preparation

Prepared 25 October 2026. The analysis is pinned to a specific public proof-repository snapshot and a specific upstream simdjson commit. It is a technical evidence record, not a vulnerability report.

## 1 Principal findings

The published simdjson results prove agreement between particular compiled plain and sanitizer builds, together with freedom from the errors forbidden by the execution model. Their supporting proofs establish additional facts about the string arena. In the DOM traversal proof examined here, successful parses satisfying the strengthened contracts have sequential string records within the used part of the buffer, with well-formed length headers and terminators. The proof also preserves previously completed string bytes at relevant boundaries. The On-Demand string decoder has a bounded region whose final contents may change and a bounded returned end pointer. These are meaningful properties that ordinary ASan would not establish simply by observing the backing allocation.

The strongest concrete lifetime scenario absent from the released harnesses is a client retaining a string view across another parse with the same parser and then using the invalidated view. The API explicitly invalidates such views. None of the ten proved harnesses performs that sequence. It is therefore a boundary of the verified client context, not a demonstrated bug in simdjson and not a counterexample to a published theorem. [S01] [S09] [H01] [H07]

Many entries in a generic custom-allocator checklist do not describe the exercised simdjson string arena. There is no per-string free, sized free, pool selection, or per-string realloc operation on the inspected paths. During a parse, strings are appended to a shared buffer. Treating every generic pool operation as an unverified simdjson feature would misstate the implementation.

The evidence supports four central distinctions:

- A property can be absent from the public top-level statement and still be established by a supporting lemma.
- A safe internal layout does not supply a general guarantee for every possible client use of returned views.
- An unexercised operation is a scope limit. It is not evidence that the operation is implemented incorrectly.
- A proof about final memory contents or a function boundary does not, by that fact alone, prove a restriction on every intermediate memory access.

Several broader properties remain outside the established conclusions of this review: general C++ lifetime and pointer-provenance safety, arbitrary client indexing into returned views, a full semantic specification of decoded string contents, general initialization or confidentiality guarantees, and concurrent use. No reachable implementation vulnerability was constructed. No Rocq replay or independent binary rebuild was performed.

## 2 Evidence scope and interpretation

### 2 1 Pinned identities

| Component | Identity used in this dossier |
|---|---|
| Public proof repository | theorem-labs/oss-verify-proofs |
| Proof repository commit | 98e995d4daced70a0a4aa2c810854b88720735f1 |
| Binary release | v2026.10.0 |
| Upstream library | simdjson/simdjson |
| Upstream simdjson commit | f807de973580fb22cc0db6b3b896716684b0266c |
| Static ASan source commit | b05061352064fa2be1813ac5429149f3de5f057d |
| Formal execution model | rocq-linux-process-semantics |
| Model commit documented for the release | f1006fe8178338a499b5e5c41be83006c4edd058 |
| Compiler and platform | clang 20.1.8, static riscv64 Linux, musl |
| Proof checker version documented by the repository | Rocq 9.2.0 |

The upstream tree is accompanied by one recorded simdjson patch. The patch changes assertion reporting in fuzz_ndjson; it does not add per-string ASan instrumentation. This dossier does not infer that an unrelated source patch fixes the allocator. Build provenance and the patch itself are separately available. [S01] [S04] [S05] [S06] [S07]

### 2 2 Material inspected

The review examined the public project inventory and statements; the fuzz_parser agreement wrapper and supporting specification files; DOM tape and string invariants in fuzz_dump; the corresponding compiled stage-two and printing interfaces; On-Demand string-decoder contracts, proof entry points, and harness call sites; allocation ownership specifications; upstream buffer allocation, cursor, and lifetime documentation; and all ten harness source files with published simdjson proofs.

The most detailed spatial inspection concerns fuzz_dump and fuzz_ondemand. The dossier does not assert that every file in every simdjson proof directory was read line by line. The project contains thousands of machine-walk and generated files. A property established in one harness is attributed to that harness or explicitly identified shared contract. It is not silently promoted to a theorem about all simdjson APIs or all architectures.

The attached custom-allocator checklist supplies the questions numbered 1 through 17 and three additional categories. It is an input taxonomy, not independent evidence that a particular simdjson operation exists. This review does not independently reproduce every claim in the CMASan paper cited by that checklist.

### 2 3 Evidence labels

| Label | Meaning |
|---|---|
| Published theorem | A named result reported as proved in the pinned repository. This review inspected source but did not rerun the checker. |
| Supporting property | A concrete invariant, contract, or lemma established in the inspected proof sources under its preconditions. |
| Outside harness | The relevant API sequence is absent from the compiled client context under review. |
| Not applicable | The generic checklist operation is absent from this string arena's exercised interface. |
| Not established by this review | The inspected statement or supporting material does not justify the broader claim. This is not a claim of logical independence or proof impossibility. |
| Inference | A conclusion drawn from the inspected source and contract, rather than a separately named theorem. |

These distinctions matter when quoting the dossier. In particular, 'outside harness' and 'not established' should not be rewritten as 'a bug escaped verification.' A successful proof is assessed against its actual specification and assumptions.

## 3 What the published results say

### 3 1 The subject is an executable client context

A fuzz harness is compiled together with the library and a small driver. The driver reads an input file and invokes LLVMFuzzerTestOneInput. There are plain, ASan, UBSan, and ASan plus UBSan configurations. A published agreement result relates the memory images of the particular binaries. It is not a source-level theorem quantified over every program that might link against simdjson. [S02] [S03]

For fuzz_parser, the client creates a local DOM parser, calls parse once, extracts an element, discards the error code, and returns zero. The harness makes no substantive assertion about JSON values. A proof of this harness therefore does not acquire full JSON semantic correctness merely because the parser is part of the binary. [H01]

### 3 2 Agreement and error freedom

For the ASan agreement statement, the documented premise limits the plain build to a 2 GiB memory budget. Memory requests may be refused only when the budget or available address range forces refusal; other modeled requests may still fail. Under the stated conditions, neither build faults, aborts, or leaves the model, and their observable behaviors agree. ASan reports abort, so the result excludes every report that this build's ASan configuration would produce. The UBSan-only agreement uses the documented 16 GiB plain-build budget. [S02] [S03]

The sanitizer target has the documented 512 GiB budget. This larger allowance and the forced-only memory-refusal policy are part of the comparison setup. They should be reported with the source budget when describing what resource failures are covered. The model also has an 8 MiB stack limit, no signal-handler execution, restricted path arguments, and a simplified file system. A proof in this model is conditional on its stated correspondence assumptions. [S03] [S04]

The observations include process input/output traces, exit status, and modeled final file contents. Equal observations do not automatically imply that every internal record has the intended semantic value. Two builds can compute the same wrong result. For fuzz_parser, returning zero after ignoring the parse result supplies little observational information about that result.

The statement explicitly excludes a stronger inference: memory errors ASan does not detect are not excluded merely by sanitizer silence. This is the reason to inspect the supporting proof, rather than stop at the headline agreement theorem. A supporting invariant can establish a stronger property, but it must be identified and interpreted under its actual preconditions. [S02]

### 3 3 Termination and memory budgets

The simdjson project records published agreement proofs, while its halting statements are open at this snapshot. Agreement does not rule out every execution that continues forever. The memory budget is a premise, not a theorem that every possible input stays within it. The file-input driver rejects files of 64 MiB or more and has a header format before the payload. These details narrow the quantified client context. [S01] [S02] [S03]

The theorem is still universal over the accepted modeled inputs and executions under its assumptions. Reading a particular fuzz harness does not reduce the proof to a finite test suite. The restriction concerns which client program and model are quantified over, not merely the number of testcases tried.

There is a further build-specific size distinction in the fuzz_parser raw-pointer parse path. FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION makes allocate_padded_buffer return null when input length plus 64 padding bytes exceeds 2^20 bytes. The recipe enables that macro. Consequently, payloads above 1048512 bytes can reach the harness but fail the padded-copy allocation before the parser's main implementation is called; they are not silently truncated to that size. The compiled PC_pid proof explicitly separates copy_made=false from copy_made=true. This explains the smaller input bound used by local parsing lemmas without reducing the complete theorem's file-input quantification to 1 MiB. Do not generalize this raw-pointer routing argument to every other API overload without checking its route. [S19] [S20] [P04]

### 3 4 Build configuration matters

The sanitizer flags are applied to the library and fuzz target. The driver is compiled without sanitizer flags; its allocations still use the linked allocator. Toolchain runtime code, including musl and C++ runtime libraries, is also uninstrumented. The formal executable includes this code, and supporting machine-code proofs cover reached routines. Thus 'uninstrumented' does not mean 'omitted from the formal execution.' It does mean that sanitizer checks add no coverage inside those routines. [S05]

Leak detection is disabled in the sealed ASan configuration. Consequently, a leak does not by itself falsify the ASan statement. Enabled UBSan checks include alignment, array bounds, object size, pointer overflow, shifts, and signed integer overflow. Not every undefined-behavior or arithmetic check is enabled: examples excluded by the documented configuration include unsigned integer overflow, implicit conversion, local bounds, vptr, and the function check. Supporting arithmetic arguments can still prove facts beyond that configuration. [S05]

The documented compile-time configurations are:

```text
ASan
  -fsanitize=address

UBSan
  -fsanitize=undefined -fno-sanitize-recover=all
  -fsanitize-trap=all -fno-sanitize=function

Combined
  both flag sets above
```

The complete enabled UBSan list recorded for this compiler is alignment, array-bounds, bool, builtin, enum, float-cast-overflow, integer-divide-by-zero, nonnull-attribute, null, object-size, pointer-overflow, return, returns-nonnull-attribute, shift-base, shift-exponent, signed-integer-overflow, unreachable, and vla-bound. This list concerns enabled checks in instrumented code, not every property that supporting lemmas might prove. [S05]

ASan options are sealed rather than supplied through ASAN_OPTIONS. allocator_may_return_null is enabled, detections abort silently, leak detection is off, and start-up address-space reservation failure can lead the runtime to spin. This last behavior helps explain why an unrestricted ASan halting-under-arbitrary-allocation-failure statement would be inappropriate for the build. [S05]

The model describes a single thread and a partial Linux process environment. It does not supply a theorem about multithreaded parser sharing, a different compiler, or an x86 SIMD backend. The portable fallback is the relevant backend for these riscv64 binaries. Cross-backend comparisons in some harnesses therefore do not establish agreement among multiple real backends in this build. [S04] [S08]

### 3 5 Exact statement and proof entry point

The published fuzz_parser statement contains the following definition, shown with whitespace adjusted for readability. Its arguments expose the environment policy, the two budgets, and the two exact program images. [S02]

```coq
Definition asan_agrees : Prop :=
  agrees_in_abort_modelled Env.alloc_forced_only
    Budgets.Asan.lim_source Budgets.Asan.lim_target
    Images.plain Images.asan.
```

The short Proof.v wrapper proves Statements.asan_agrees using the supporting theorem named fuzz_parser_asan_cfg in lib/Theorems.v. That theorem closes an error-free agreement result through ClosedP.base_asan_mc and the plain and ASan client proofs. The wrapper does not directly state str_at, string generation identities, or semantic decoding. Those stronger or different properties have to be sought in the supporting specifications. [S17] [S18]

This gives a useful dependency view: the published agreement wrapper depends on a closed executable theorem; the executable theorem depends on the client and runtime proofs; the client proofs use local contracts; and the arena properties are expressed in selected local contracts and invariants. Finding a suggestive definition is only the first step. The next steps are finding its proof, its caller, and the discharge of its local preconditions.

### 3 6 Trusted components and source correspondence

The documented trusted base includes the Rocq kernel and its bytecode computation, permitted axioms for primitive types and the listed classical principles, the LPS definitions, ELF-to-memory-image tools, and the checker wrapper and assumption-list handling. The checker is documented to reject assumptions outside its allowlist. These are statements of the repository's checking policy; this review did not independently execute that policy. [S22]

The compiler, build process, and binary-to-source correspondence are explicitly outside that trusted base: the theorem is about the bytes identified by the binary hash. Reading pinned upstream source and build provenance helps explain what the binary is intended to implement, but it is not a formal compiler-correctness theorem. This dossier keeps the source-level mechanism evidence separate from the compiled contracts that were inspected. Agreement definitions being identified with LPS definitions also does not prove that the Linux model is complete or correct. [S22]

## 4 The custom allocation mechanism in simdjson

### 4 1 The DOM string arena

document::allocate obtains a string byte buffer and a tape array as separate new[] allocations. The tape contains tagged entries describing JSON values. A string tape entry identifies a record inside the shared string buffer. Its record has a four-byte decoded-length header, the payload, and a zero terminator. The builder advances current_string_buf_loc as it appends each record. [S10] [S11]

The string capacity is rounded from an expression based on 5 times capacity divided by 3, plus SIMDJSON_PADDING. The factor accounts for inputs with many short strings and their per-record overhead. The buffer can therefore contain unused capacity and scratch space beyond the completed records. A proof must relate record sizes and cursor growth to that capacity; knowing only the size of the outer allocation would be weaker.

on_start_string appends the current byte offset to the tape and returns a destination after the length header. on_end_string writes the decoded length, writes the terminator, and advances the cursor to the byte after the terminator. These implementation operations explain the length plus five arithmetic in the formal record invariant. [S11] [D01] [D02]

There is no individual free operation for a string record. All records belong to the document buffer. This is an arena in the sense of shared backing storage and internal placement, but it does not provide the free-list behavior of a general malloc replacement. During construction of one document, completed records remain part of the retained prefix.

### 4 2 Reuse and invalidation

The source initializes the builder's current string cursor to the beginning of doc.string_buf for a new parse. The API documentation says that returned DOM strings and string_views are invalidated by the next parse or destruction of the parser. If the next document fits within the existing capacity, its strings can occupy the same backing storage. [S09] [S11] [S12]

This is the most relevant temporal distinction for this arena. A view can become invalid under the API contract while its numerical address still lies inside accessible storage. Ordinary ASan need not diagnose that event. The inspected harnesses avoid the sequence by creating fresh parser objects and consuming or discarding results before destruction.

Reallocation is different from that in-place reuse case. document::allocate replaces unique_ptr-managed new[] buffers and deallocates the old backing arrays. The specific generic scenario in which a moving suballocation leaves its old bytes retained inside a pool is not what this operation does. There can still be an invalid client view after replacement, but that is a different mechanism and is outside these harnesses. [S10]

### 4 3 The On Demand string buffer

The On-Demand parser also allocates a shared output buffer. Unescaping a string produces a view into the buffer and advances a destination cursor. The implementation does not allocate a separate backing object for every string. The inspected harness calls one selected accessor per iterated item and discards returned views. [S13] [H07]

The API places restrictions on consumption. In particular, value::get_string documents that calling it twice on the same value is an error. The iterator's internal unescape documentation similarly requires a raw string to be unescaped once. A general client that repeatedly consumes the same value is not covered just because one-accessor-per-item code was verified. [S14]

On-Demand rewind resets the string cursor. The proved harness does not call rewind. This establishes an unexercised reuse path; it does not by itself settle the validity of every possible view across every rewind context. The exact API lifetime contract must be checked before claiming such a view is invalid. [S15]

### 4 4 Padding is part of the implementation contract

String decoding can write scratch bytes beyond the eventual returned payload. In the portable fallback, the copy-and-find operation copies a byte before examining whether it is the closing quote. The destination at the final output end can therefore be touched during construction. DOM completion writes a zero terminator there; an On-Demand string_view excludes that final byte. [S16]

The final view length is not necessarily the decoder's entire permitted scratch footprint. An audit that labels every construction-time access beyond that eventual length as a bug would reject intentional implementation behavior. The useful questions are whether the scratch region is authorized, stays within the backing buffer, and preserves previously completed records. It is also necessary to distinguish the encoded input span from the decoded payload length, since escapes can shorten the output.

## 5 Additional properties established by the supporting proofs

### 5 1 DOM string records are structurally well formed

In fuzz_dump/lib/Sj/SjTape.v, str_at describes a string record using its offset o, stored length l, byte function S, and used length sn. Its essential conditions are:

```text
0 <= o
0 <= l
o + l + 5 <= sn
le32(S, o) = l
S(o + 4 + l) = 0
```

The record fits inside the used prefix, not merely somewhere in the allocated capacity. Its header describes the payload extent used by traversal, and its terminator lies at the end of that extent. This gives a concrete positive answer to part of the logical-length concern in checklist item 15. [D01]

The predicate alone does not require the payload to equal a mathematical JSON decoding of the corresponding input token. Stored length is an implementation quantity in this invariant. It should not be renamed 'the semantic decoded length' without an additional correspondence argument.

### 5 2 Records occupy consecutive regions

SjTapeTile.v strengthens the tape structure with a string cursor. str_rec requires a string tape entry to point to the current cursor c and sets the next cursor to c + l + 5. The recursive tilesS and elemS predicates thread this cursor through scalar values, arrays, object keys, and object values. tape_wfS starts at cursor zero and finishes at the used byte length. [D02]

The consequence is sequential record layout. Two distinct records in this construction do not receive overlapping payload/header/terminator regions. The string buffer and tape are also separate from the input, implementation object, structural-index array, and other working arrays under the relevant machine preconditions. This is stronger than a proof that every store landed in some live malloc block. [D02] [D04]

This fact is about the produced document structure and the cursor discipline. It does not attach a fresh C++ allocation identity to each record, and it does not establish a general provenance theorem for every pointer a client might manufacture.

### 5 3 Completed prefixes are preserved

frameS in SjTapeInv.v requires the byte function for a completed prefix to retain its values after a transition. The concrete tape_img invariant records tape and string bytes in machine memory. The helper tape_img_write_sbuf maintains that image when writing into the area after the completed prefix. The stage-two proof uses these invariants as it appends new records. [D03] [D05]

The precise established statement is preservation at the proof boundaries where the predicates are asserted. A final-memory preservation relation does not by itself exclude a temporary clobber that is restored before the next boundary. Some inspected machine-store proof fragments separately discharge concrete address bounds, but a universal claim about every intermediate source-level store requires inspecting or proving the relevant trace property. This dossier does not promote frameS alone into that stronger theorem.

The distinction does not make boundary preservation unimportant. In a single-threaded client that receives a completed document, preserving earlier string contents across subsequent construction is a useful invariant. It is simply a different assertion from an origin-sensitive prohibition on all transient accesses.

### 5 4 These invariants describe compiled execution

The successful-result predicate s2_okres in the plain stage-two interface quantifies concrete tape and string byte lists and requires tape_wfS for them. The used lengths must remain within their capacities. stage2t_of_walk connects the stage-two walk to that strengthened interface. The proof maintains its stronger tape invariant through s2_labels. [D04] [D06] [D12]

Corresponding successful-layout interfaces exist for the ASan and UBSan builds of fuzz_dump. The ASan s2a_okres similarly includes tape_wfS, and stage2at_closed constructs the strengthened compiled-function contract once its runtime and numeric-helper premises are supplied. Its premises include art_facts, rt_contracts_f, numa_stmt, numo_stmt, and rootnum_stmt. This avoids an unjustified assumption that a property found for the plain executable automatically transfers to a differently compiled sanitizer executable. Each relevant variant has its own connection. The inspected fuzz_dump inventory contains no published combined ASan plus UBSan agreement result. [D09] [D10] [D13] [D14] [S01]

These successful-result contracts have explicit local premises: valid stage-one output, padded readable input, disjoint backing regions, sufficient capacities and stack space, and blen bs <= 1048512. They are obligations for the enclosing proof to establish. The local bound should not be mistaken for an independently inferred restriction on the complete executable or confused with the driver's 64 MiB file limit. Failed parses need not produce a well-formed successful document; the stronger final tape predicate applies to the success branch. [D04] [D09]

The smaller fuzz_parser proof has a different goal. Its stage-two postcondition permits mutation of the tape and string arena while preserving the heap and other regions. Its pure winv and sbuf_room invariants bound cumulative string-buffer usage, output growth, and working-array indices. Because the harness discards the document, its exposed stage-two result need not carry the stronger traversal-ready tape structure. This is a reason to use fuzz_dump when making positive claims about record structure and reads. [P01] [P02]

### 5 5 Traversal reads the payload slice described by the record

The pj_str machine proof in Dmp_pj_leaf.v takes an is_str premise. It reads the four header bytes, obtains l through str_at_bounds, and uses sbuf_slice to construct the payload slice of exactly that length. It then passes that slice to the output operation. Thus the exercised printing code has a specific length argument stronger than 'the arena is accessible.' [D07]

This establishes safe use of the length encoded in the proved record structure. It does not establish that a client may index beyond a returned string_view, that every source field access is safe in every API, or that the printed payload equals the intended JSON-decoded input. Those are different statements.

### 5 6 The On Demand decoder has a bounded footprint

pstr_post_g specifies either failure or a returned pointer SB + sbo_prime, where:

```text
sbo <= sbo_prime <= sbo + (j - i - 1)
```

Its memory relation munch preserves final memory outside the decoder's stack frame and the interval from SB + sbo to SB + sbo + (j - i). The upper bound is derived from the encoded input string's span. Its permitted changed region can extend beyond the returned view's logical end; the contract does not identify the two intervals. The precondition separately requires sufficient buffer capacity, a closing quote, padded input bytes, and separation between input and output. [O01] [O02]

pstr_spec proves the plain compiled decoder contract. The compiled harness string arm invokes it, and the global cursor invariant bounds the next append position. UBSan, ASan, and combined ASan plus UBSan decoder contracts also use pstr_post_g, with additional variant-specific premises. pstra_spec and pstrb_spec prove the two ASan-bearing versions. The stronger footprint is therefore not confined to an uninstrumented reference function. [O03] [O04] [O05] [O06] [O11] [O14] [O15]

The local capacity premise is discharged by the enclosing cursor invariant. sbo_ok bounds the append cursor by the current structural input position. The closing quote j lies inside the input, and the allocated output capacity exceeds the input length. In the live string case, sbo is at most its opening quote i, so sbo + (j - i) is at most j and fits within capacity. The machine call sites supply these inequalities and the required separation premises. The ASan variants also discharge readable/unpoisoned shadow premises for the whole backing buffer; this is not per-string poisoning. [O04] [O06] [O10] [O16]

Again, munch is an end-state relation. Its definition is equality at every address outside the permitted windows between the initial and final memories. It is not a log of all accesses. The safe formulation is that the contract preserves earlier bytes and bounds the returned end under the stated preconditions. A claim that the contract alone forbids every transient write outside a source-level suballocation would be stronger than its definition. [O02]

### 5 7 The string contract does not specify semantic decoded contents

The DOM string-end machine proof constructs a record around the concrete bytes found in the output region. Its continuation accepts a payload cb of the produced length, without requiring an equality cb = decode(input_token). The On-Demand PS invariant similarly tracks the input closing quote, input cursor, and output count bound rather than a semantic decoded-byte sequence. [D08] [O07]

This observation limits what can be cited from those contracts. It does not demonstrate that the implementation decodes incorrectly. It shows that correct payload semantics cannot be inferred from those particular layout and footprint statements. Establishing semantic decoding would require an additional model and correspondence theorem.

Likewise, bytes_at records concrete values in the machine state. It is not itself a source-level definedness or dataflow assertion proving that every payload byte was written by the current parse before being read. The concrete helper timg_sbytes extracts a byte list from an in-capacity writable region using stk_bytes, without requiring a preceding decoding write. This makes the distinction visible in the supporting proof itself. The absence of an initialization predicate in the inspected contract should be recorded as an unestablished property, not as a discovered uninitialized read. [D11]

### 5 8 Backing allocations are accounted for

The inspected specifications model allocation and deallocation of the backing string buffer, tape, parser implementation, and other temporary arrays. In fuzz_parser, parser_dtor_spec_c consumes the owned parser blocks, and fuzz_one_spec_c restores the original ownership list. In the On-Demand proof, fuzz_one_mspecN similarly restores own X and returns zero. [P03] [O08] [O09]

These are meaningful allocation-accounting facts under the allocator model and specification. They prevent an accurate review from claiming that all deallocation or leak-related obligations were ignored. However, returning to an ownership predicate is not by itself a proof that no extra live allocations remain. In the concrete On-Demand instantiation, GI X is OWN X Gso. OWN requires the addresses represented by X to be a duplicate-free subset of the allocator's live list, rather than requiring equality with that entire list. An extra live block can therefore be compatible with this postcondition. The model explicitly pairs named allocations and deletions, but the cited ownership-restoration postcondition alone is not a complete no-leak specification, even for a terminating run. [O12] [O13]

The relevant part of the concrete definition is:

```text
incl (map fst X) (ld_live L)
```

It is inclusion, not equality. This should remain explicit in any blog claim about leak guarantees. Leak detection is also off, no top-level halting result is published here, and logical arena usage is separate from backing-allocation accounting. No unrestricted theorem that all real executions of all simdjson APIs eventually release all resources is established by this review.

## 6 Assessment of every checklist item

The following compact matrix gives the result before the detailed entries. 'Internal support' refers to the identified contracts and invariants, with their stated limits. It does not mean a universal source-level memory-safety theorem.

| Item | Topic | Assessment |
|---|---|---|
| 1 | Suballocation bounds | Substantial internal support |
| 2 | Internal per-object free | Not applicable to individual strings |
| 3 | Custom double free | Not applicable to individual strings |
| 4 | Bulk reset with retained views | Outside the exercised client sequences |
| 5 | Per-string shrink | No such exercised operation |
| 6 | Moving realloc retaining old pool bytes | Does not describe buffer replacement here |
| 7 | Stale view after address reuse | Outside harness and no general generation theorem |
| 8 | Stale custom free | Not applicable to individual strings |
| 9 | Invalid custom free or wrong pool | Not applicable to individual strings |
| 10 | Other logical invalidation | Reparse and rewind sequences unexercised |
| 11 | Arena implementation correctness | Layout and accounting support with semantic limits |
| 12 | Logical pool leaks | Per-string release not required and backing accounting present |
| 13 | Redzone jumping | Explicit bounds support internal paths only |
| 14 | Intra-object field overflow | No general source-subobject theorem established |
| 15 | Length versus capacity | Specific record and traversal support |
| 16 | Lifetime without deallocation | General client lifetime safety outside coverage |
| 17 | Uninstrumented accesses | Reached code modeled but sanitizer coverage absent |

### 6 1 Suballocation overflow and underflow

The generic concern is an access beyond a small object that still lands in the live backing allocation. ASan's outer allocation boundary does not identify the intended smaller object. In the inspected DOM traversal proof, string records have explicit extents, consecutive placement, and used-prefix bounds. The printing proof reads the stored payload slice. On-Demand decoding has a bounded output allowance and preserves earlier bytes at function boundaries. These facts address important instances of the concern. [D01] [D02] [D07] [O01]

The justified conclusion is specific: important internal construction and traversal properties are proved. An unrestricted statement that every possible string-relative read or write respects its originating record would require more. A client can manufacture an out-of-range pointer, and such client code is not quantified over by the harness theorem. The final-state-versus-transient-store distinction also remains relevant.

### 6 2 Use after an internal free

The checklist imagines pool_free invalidating one record while leaving its bytes accessible. There is no corresponding operation for an individual DOM or On-Demand string on the exercised paths. Strings are slices/records within one retained byte array. The arena lifetime is controlled by the parser/document context.

It would therefore be misleading to say that simdjson's per-string free is unverified. The relevant actual lifetime questions are parser reuse, replacement, destruction, and On-Demand consumption restrictions. Those are discussed separately in items 4, 6, 7, 10, and 16. [S09] [S10] [S13]

### 6 3 Custom double free

There is no individual string free operation to call twice. Deallocation of the backing buffers does occur and is modeled in the ownership specifications. The proof accounts for the parser destructor's sequence of releases on the harness path. This is different from verifying all arbitrary destructor calls or every hypothetical client ownership error. [P03] [O08]

For blog use, classify this item as inapplicable at the per-string arena level, with positive backing-allocation accounting in the harness. Do not equate this finding with a general proof of double-free freedom for all C++ clients.

### 6 4 Use after a bulk clear or reset

A new parse resets placement to the beginning of the existing string buffer when capacity can be reused. The API invalidates old DOM views. A client that retains and then uses such a view violates the documented contract. The bytes may remain accessible, which explains why outer-allocation ASan checks are insufficient to enforce this API lifetime rule. [S09] [S11] [S12]

No proved harness performs a second parse with the same parser and then reads a retained first-document view. The correct finding is an unexercised lifetime scenario. The example is not an internal parser bug demonstrated under valid use.

### 6 5 Access beyond a reduced allocation

The inspected string API has no operation that shrinks an individual string's granted storage while retaining a larger slot. String length is determined during construction, and record traversal uses that stored length. Buffer capacity management is a different operation. [S10] [S11] [D07]

General clients retaining views across capacity changes are outside the harness sequences. No claim about a hypothetical per-string shrink checker is warranted. It is still useful to distinguish a string's payload length, its record extent, decoder scratch allowance, used arena prefix, and total allocated capacity; these are separate boundaries.

### 6 6 Use after moving reallocation

The generic custom-pool example moves an object but retains its old location in accessible pool storage. Here, backing-array replacement uses unique_ptr::reset and genuinely releases the previous new[] allocation. Thus that specific retention mechanism does not describe document::allocate. [S10]

If a client retains a view through a replacement, it can be invalid, and normal ASan may detect an access while the old backing allocation is poisoned. Later address reuse can still defeat an address-only lifetime check. The inspected proofs do not verify arbitrary clients across buffer growth, replacement, and subsequent old-view access. No such reachable misuse occurs in the supplied single-document harness sequences.

### 6 7 Stale pointers after address reuse

The proof's string layout identifies offsets and byte regions. It does not attach a generation token to every returned client pointer. A later parse may reuse the same address for new string contents while invalidating old views under the API contract. This is the most direct instance of the user's allocation-identity concern for this library. [S09] [S11]

The result should be stated carefully: no general client lifetime theorem for that sequence is established. It does not follow that the proof is unsound or that a valid library client can reach a memory error. The published theorem fixes a harness that does not keep the stale pointer.

### 6 8 Stale free releasing a new object

Individual strings cannot be passed to a custom string-free operation because no such operation is offered on these paths. The stale-free example from the checklist therefore has no direct counterpart in the arena interface. It should be marked not applicable, rather than counted as an additional missing feature.

Backing-buffer owners and destructor accounting are modeled separately. That does not turn arbitrary incorrect C++ client destruction into verified behavior. [S10] [P03]

### 6 9 Invalid custom frees and ownership violations

Interior-pointer frees, unused-pool-space frees, wrong-pool frees, wrong deallocation-family calls, and incorrect sized/aligned frees require a custom deallocation interface. Individual simdjson strings do not have that interface. The parser owns the backing arrays, and clients receive views or pointers rather than ownership of separate allocated strings. [S09] [S10]

The supporting allocation model does carry ownership of backing blocks. This supports the destructor/accounting argument, but it is not a theorem about every illegal operation a client could attempt on an exposed address.

### 6 10 Other invalidation operations

The relevant concrete operations are another parse, parser destruction, and On-Demand rewind or consumption-related changes. The inspected On-Demand harness does not rewind or retain a view across a second iterate call. The cursor-reset code is real; the exact validity of a particular retained view across rewind remains an API-contract question and was not fully classified here. [S15] [H07]

Other generic examples in the checklist, such as returning an object to a cache, destroying a pool retained in an upstream cache, or recycling a slab, do not describe the exercised string arena. Their absence should be recorded rather than converted into additional simdjson defects.

### 6 11 Bugs in the allocator itself

Several relevant implementation obligations do receive proof support: sequential record placement, non-overlap, consistency of each record's length header, payload extent, and terminator, buffer-capacity bounds, and backing-allocation accounting. These are not automatic consequences of ASan silence. [D01] [D02] [P01] [P03] [O08]

Other listed defects concern interfaces that do not exist here, such as releasing the wrong individual slot or corrupting a per-string free list. Full decoded-content correctness is also not supplied by the record invariant. The inspected record completion proof accepts the payload bytes found in memory without specifying semantic equality to the decoded input. A complete allocator-and-decoder correctness theorem would need to state the intended semantic obligations explicitly. [D08]

### 6 12 Logical leaks inside a retained pool

An arena designed to retain all strings until document invalidation does not leak merely because there is no individual release. For the successful DOM layout, records occupy the completed prefix consecutively. Backing allocations are also accounted for by the harness specifications. This supplies more evidence than a bare sanitizer result. [D02] [P03] [O08]

LeakSanitizer is disabled, so the top-level sanitizer claim alone is not a leak-freedom result. The On-Demand ownership predicate admits a subset of the live list, so restoring it does not alone exclude extra live blocks even on return. The explicit modeled deletion sequence supplies cleanup evidence; an exact live-set or allocation-balance theorem would be needed for a stronger leak claim. The ownership lemmas also do not prove eventual release on every infinite execution or all future parser-use patterns. Confidentiality of residual bytes retained in unused storage is a further property, separate from a logical leak. [O12] [O13]

### 6 13 An access jumping over a redzone

ASan can miss a distant access whose destination is another accessible allocation. The proof's stronger bounds and layout invariants do not rely only on the presence of redzones. For example, the printing proof obtains a specific bounded slice from a valid string record. [D07]

There is nevertheless no universal origin-sensitive pointer theorem for arbitrary clients. If code outside the verified harness computes an invalid offset and lands in a different string record, the published result about the fixed harness does not cover that new program. Redzone jumping is therefore not a blanket flaw in the inspected internal spatial proof, but arbitrary client uses remain outside it.

### 6 14 Overflow between fields within an object

The inspected machine contracts describe structure layouts and concrete offsets, but some preservation windows permit mutation of an entire structure. For example, a stage-two interface permits changes within the 96-byte implementation object. Such a window does not itself enforce each source field's boundary. [D04]

This review has not established a general theorem enforcing every C++ source-level field boundary or subobject lifetime. The compiled execution model is not a full C++ abstract machine with universal subobject provenance. The safe classification is that broad field-level safety is unestablished here, while the concrete offsets and footprints that were proved should be credited. [P02] [D04]

### 6 15 Logical length versus capacity

This item has specific positive evidence. str_at bounds a record by the used prefix; tape_wfS establishes its place in the record sequence; and pj_str passes exactly the header-described payload slice to the output operation. The exercised printing path therefore has a logical record-length argument, rather than merely an outer capacity argument. [D01] [D02] [D07]

The record length is not independently specified as the mathematical decoded length in the inspected contracts. Clients arbitrarily indexing beyond a returned view's length are outside the harness. Decoder scratch writes also have a larger permitted region than the final payload, so not every construction-time access beyond the eventual view length is invalid. [D08] [O01] [S16]

### 6 16 Lifetime ending while storage remains

The source API explicitly invalidates DOM views at the next parse or parser destruction. The inspected proofs verify clients that finish using results within the local parser context. They do not establish a general C++ lifetime theorem for references retained through destruction, placement reconstruction, reuse, or other unexercised client sequences. [S09] [H01] [H02] [H07]

The lifecycle within one parse is simpler than a recycling allocator: completed records remain in the live document prefix. There is no per-string free/reallocate transition that would require the proof to distinguish two successive individual allocations at the same record address during that construction.

### 6 17 Accesses without sanitizer instrumentation

The release links runtime code and a driver compiled without sanitizer flags. This is an actual instrumentation limitation. It does not mean the formal proof assumes these routines are correct without examining compiled execution. The supporting corpus contains machine-code specifications and proofs for reached standard-library and runtime operations. [S05] [S08]

The right questions are which concrete routines are reached, what their contracts establish, and how those contracts connect to the top-level result. Sanitizer silence inside uninstrumented code contributes nothing by itself. The published machine-error and agreement theorem also does not supply every source-level memory-safety rule. This dossier has not exhaustively audited every uninstrumented runtime routine's contract.

### 6 18 Uninitialized data and residual contents

Neither ASan agreement nor the inspected string-layout predicate provides a general theorem that every exposed byte was initialized by the current parse, that no earlier occupant's data can be observed, or that sensitive bytes are cleared. Concrete machine bytes in bytes_at are not equivalent to a provenance-of-initialization assertion. [D08] [O07]

The inspected contracts do not establish these broad properties. No concrete uninitialized read or disclosure was found. A stronger proof would track the produced byte sequence, its dependence on input, the initialized prefix, and the behavior of unused or invalidated storage where relevant.

### 6 19 Misalignment and size arithmetic

The compiled proofs contain concrete arithmetic bounds for capacities, cursor growth, array indices, and alignment premises. The UBSan agreement proofs also rule out failures of their enabled checks. Thus an assertion that no relevant arithmetic reasoning was performed would be false. [P01] [O01] [S05]

This does not establish that every possible source arithmetic issue is diagnosed. Unsigned overflow, for example, is not among the enabled UBSan checks here. Input limits, precise machine-width reasoning, and separate lemmas determine the actual guarantee. The dossier does not generalize a 64-bit compiled result to legacy 32-bit configurations.

### 6 20 Data races

The formal model is single-threaded and has no scheduler. These results do not establish synchronization correctness or race freedom when parsers, documents, or buffers are shared among threads. They also do not model another thread observing a temporary clobber that is restored before a function returns. [S04]

Concurrent use is a separate scope boundary. No concurrency bug is inferred from it.

## 7 The harness coverage record

### 7 1 Published simdjson inventory

At the pinned snapshot, simdjson has ten entry points with 24 published agreement statements: nine standalone ASan agreements, eight UBSan agreements, and seven combined ASan plus UBSan agreements. These counts describe compiled configurations of one upstream source snapshot, not 24 source versions. [S01]

| Harness | ASan | UBSan | Both | Client sequence relevant to the arena |
|---|---|---|---|---|
| fuzz_atpointer | Yes | Yes | Yes | Fresh DOM parser, one parse, lookup and local string view |
| fuzz_dump | Yes | Yes | No | Fresh DOM parser, one parse, recursive printing |
| fuzz_dump_raw_tape | Yes | Yes | No | Fresh DOM parser, one parse, tape dump |
| fuzz_element | No | No | Yes | Fresh DOM parser, one parse, selected accessor |
| fuzz_implementations | Yes | Yes | No | Fresh per-backend parser objects, one parse each |
| fuzz_minifyimpl | Yes | Yes | Yes | Direct backend minification, no string arena |
| fuzz_ondemand | Yes | Yes | Yes | Fresh parser, one iterate, selected accessors |
| fuzz_parser | Yes | Yes | Yes | Fresh DOM parser, one parse, result discarded |
| fuzz_print_json | Yes | No | Yes | Fresh DOM parser, one parse, output traversal |
| fuzz_utf8 | Yes | Yes | Yes | Direct backend UTF-8 checking, no string arena |

The larger simdjson inventory also contains targets without published agreement proofs. In particular, fuzz_minify and fuzz_ndjson have statements but no proof recorded in this snapshot; fuzz_padded has model-blocked halting statements; api-driver is held from the release; and fuzz_atpath is not built yet. Their presence does not extend the guarantees of the ten proved targets. No reason for a withheld target should be inferred beyond what the record states. [S01]

### 7 2 Why driver repetition is not parser reuse

The driver may invoke the harness one to four times, using the same payload. Each invocation of these parsing harnesses constructs its local parser anew and destroys it before returning an integer. The driver does not receive a string view or document from the callback. Repeating the callback therefore does not test a client that retains a view across multiple parse calls on one parser. [S02] [H01] [H11]

This distinction is easy to lose in an informal summary. 'The driver calls the parser several times' can be true as a broad statement while 'the verified client reuses one parser and checks old views' is false.

### 7 3 Individual harness observations

fuzz_atpointer obtains a string view only after a lookup on the one parsed document. It never reparses before the view leaves the local context. fuzz_element chooses an accessor and discards results; exceptions are caught. The dump and print harnesses traverse while the parser is still alive. The raw-tape harness discards the dump operation's boolean result. [H02] [H03] [H04] [H05] [H09]

fuzz_implementations constructs per-backend parser objects and parses once with each. On this riscv64 build, the supported list contains only the portable fallback, so cross-backend comparison conditions have no distinct implementations to compare. fuzz_minifyimpl and fuzz_utf8 similarly have a single supported backend and do not exercise the DOM/On-Demand string arena. [H06] [H08] [H10] [S08]

fuzz_ondemand constructs a parser and padded input, calls iterate once, then chooses one of twelve access patterns for each item. The get_string result is discarded at the end of its case. There is no retained-view comparison after another document or rewind. This supplies a concrete basis for the lifetime scope classification rather than relying on a guess about what a generic fuzzer might do. [H07]

## 8 Illustrative scenarios and their interpretation

The following examples explain boundaries. They are not testcases executed in this review and are not demonstrated vulnerabilities. Error handling is abbreviated where stated.

### 8 1 Retaining a DOM view across a second parse

```cpp
// Illustrative client sequence; error handling omitted.
simdjson::dom::parser parser;
simdjson::dom::element first;
parser.parse("\"old\"", 5).get(first);
std::string_view old_view;
first.get_string().get(old_view);

simdjson::dom::element second;
parser.parse("\"new\"", 5).get(second);
char c = old_view[0]; // The API has invalidated old_view.
```

A second parse can reuse backing storage. The old view's address can therefore remain readable while its contract has expired. The source documents that expiration. No proved harness follows this client sequence. It illustrates missing client-context coverage, not a claim that simdjson promises the view remains valid. [S09] [S11] [H01]

An invalidated library view is not automatically a C++ use-after-deallocation: the underlying byte array can still be alive. The documented borrowing contract has expired, which is the precise issue illustrated here. A claim of C++ object-lifetime undefined behavior would need its own language-level analysis.

### 8 2 An arbitrary client overread

```text
view = get_string_from_successful_parse()
read(view.data + view.length + 20)
```

The access might land inside another string record or unused capacity. The verified printing path does not do this: it obtains the exact stored-length slice. Adding the arbitrary read produces a different client program and requires a different theorem. This explains why a fixed-harness proof can establish safe internal traversal without certifying every user-written view access. [D07]

### 8 3 A bounded but semantically wrong payload

Imagine an implementation that produced a payload of the right length, with a consistent header and terminator, but with one decoded byte wrong. The layout predicate alone would not distinguish that payload from the correct one. A separate decoded-content relation would be needed.

This is a specification-separation example, not an assertion that the published binary can behave that way. The evidence is that the inspected record completion contract quantifies payload bytes without a decode-equality condition. It identifies what cannot be concluded from that contract alone. [D08]

### 8 4 Temporary modification followed by restoration

```text
saved = previous_record[k]
previous_record[k] = another_value
previous_record[k] = saved
return
```

A relation comparing only initial and final bytes can hold for this sequence. It does not follow that the actual decoder performs such stores; the example simply demonstrates why final preservation is logically weaker than a trace-level restriction. A stronger audit needs invariants at every store or an explicit event property. This matters when describing frameS and munch. [D03] [O02]

### 8 5 Allocator release that never existed

The generic sequence allocate A, free A, allocate B at A's address, then use A is appropriate for a recycling allocator. For simdjson's individual string records, the free step is absent. The corresponding real sequence is parse document A, invalidate A by parsing B, then use an old view. Replacing the real API with an imagined per-string free can make an otherwise accurate ASan explanation misleading when applied to this library.

## 9 Claims suitable for a blog post

### 9 1 Claim register

| Claim | Evidence assessment |
|---|---|
| The simdjson results are only a finite collection of successful fuzz tests | Incorrect description of the universal theorem |
| The theorem verifies every possible simdjson client | Unsupported and outside its fixed-harness scope |
| Ordinary ASan does not automatically track individual string records | Correct background distinction |
| Therefore the actual proofs establish no internal string boundaries | Incorrect inference; explicit record invariants exist |
| The DOM traversal proof establishes sequential string records and length bounds | Supported for the inspected compiled paths |
| frameS alone proves no intermediate store ever touches an old string | Too strong; frameS is boundary preservation |
| The inspected string-layout contract proves correct JSON decoding | Unsupported; no decoded-content equality in that contract |
| Old views across parser reuse are covered by the published harnesses | Unsupported; the sequence is absent |
| The stale-view example is a simdjson vulnerability | Unsupported; it violates the documented client contract |
| The proof checker or theorem is unsound because the harness is narrow | Unsupported; scope and soundness are different questions |
| Per-string custom double-free safety is missing | Misleading for an arena with no individual string-free API |
| Every leak-related obligation is ignored | Too broad; backing-allocation ownership is accounted for |
| LeakSanitizer establishes leak freedom here | Incorrect; leak detection is disabled |
| All uninstrumented routines are assumed away | Unsupported; reached routines remain in the executable proof |
| These results establish concurrent parser safety | Outside the single-threaded model |

### 9 2 A defensible central observation

The release's public theorem is expressed as agreement between particular plain and sanitizer executables, but its supporting proofs sometimes contain stronger facts. For simdjson, the inspected DOM proof tracks the layout and length bounds of individual string records inside a shared buffer. That addresses some limitations of outer-allocation ASan checking. The scope remains the compiled client harness. It does not establish safety of clients that keep a view after the API has invalidated it, and it does not automatically provide every source-level lifetime or initialization property.

This observation can support a discussion of specification quality and reporting. It avoids two errors: treating sanitizer agreement as a complete source-level memory-safety theorem, and assuming every ASan blind spot necessarily remains open in the supporting argument.

### 9 3 Earlier wording that requires care

The earlier conversational assessment used phrases such as 'restricts writes' and 'preserves earlier decoded strings.' The precise dossier formulation is a bounded contract with final-memory preservation and returned-pointer bounds, plus separately inspected per-store reasoning. It does not infer an all-intermediate-access trace theorem from the final-memory relation alone.

The earlier phrase 'clearest uncovered case' should be read as an uncovered client sequence. It is not evidence of an error occurring within the verified harness. Calling it a custom-allocator use-after-free bug in the verified program would overstate the finding.

The earlier observation that a harness restores its ownership list also needs qualification. The concrete On-Demand predicate tracks a subset of live allocations, so restoration alone does not establish exact absence of extra live blocks. The stronger supported observation is that allocation and deletion operations are modeled and checked under their ownership preconditions.

Likewise, 'string bounds are covered' needs its object: successful record layout, particular decoder footprints, and exercised traversal slices have proof support. Arbitrary client pointer arithmetic and semantic correctness of every decoded byte are different properties.

## 10 Further work that would strengthen the evidence

### 10 1 Replay the exact published results

The repository documents an oft-based checker workflow. A reproducibility run should use the pinned repository, its matching binaries and SHA-256 hashes, the specified checker image, and the release's LPS version. It should retain the checker output and allowed-assumption results. The review in this dossier did not perform that run. [S03] [S06]

The output of a successful replay would establish that the published proof terms check under that toolchain. It would not by itself expand the statement to a new client program, backend, platform, or property.

### 10 2 State the stronger properties directly

A more explicit assurance package could export named theorems for record non-overlap, semantic decoded contents, initialized output ranges, and permitted view lifetimes. Each should identify the binary/client context and its assumptions. A separate theorem about every intermediate access would make the distinction from boundary preservation explicit.

For client lifetime checking, one must first define whether the intended guarantee assumes contract-compliant clients or detects misuse by arbitrary clients. A proof that a well-behaved client drops old views is different from a mechanism that rejects a stale view dynamically. The expected behavior of rewind, parser reuse, and buffer replacement needs a precise API-level model.

### 10 3 Audit an expanded client harness

A new verification target could parse several documents through one parser, retain only the views permitted by the API, exercise capacity growth and failure paths, and verify observations while those views are valid. This would establish additional valid-use coverage. An intentionally invalid retained-view access can illustrate a detector limitation, but it should not be presented as a valid-use implementation vulnerability.

On-Demand extensions should separately cover repeated consumption restrictions, rewind, and result retention. A harness cannot simply call every accessor in every order and assume the API promises safety and meaningful results for that sequence.

### 10 4 Questions left unsettled

- Whether every intermediate store in every relevant decoder variant satisfies a formally exported per-record trace property.
- Whether another supporting lemma elsewhere in the full corpus establishes stronger initialized-byte or decoded-content facts than the contracts examined here.
- The complete contract for every possible view across On-Demand rewind and related cursor changes.
- Every source-level field and subobject boundary in all linked runtime routines.
- Valid-use behavior of broader parser-reuse, allocation-failure, and capacity-change sequences absent from the published harnesses.
- The corresponding guarantees for x86 SIMD builds, other compiler configurations, and concurrent clients.

These are research and audit questions. Their presence in this list is not evidence that a defect exists.

## 11 Evidence source register

Every proof-repository link below uses commit 98e995d4daced70a0a4aa2c810854b88720735f1. Every upstream simdjson link uses commit f807de973580fb22cc0db6b3b896716684b0266c. Line anchors are navigation aids for that snapshot. Source identifiers in the body link directly to these files.

### 11 1 Release statements and implementation

- **S01** simdjson project inventory and published-result table. [Open source][S01]
- **S02** fuzz_parser Statements.v including process-input scope, budgets, agreement definitions, and explicit ASan limitations. [Open source][S02]
- **S03** Statement vocabulary and agreement forms. [Open source][S03]
- **S04** LPS version, model assumptions, and single-threaded scope. [Open source][S04]
- **S05** Build flags, sanitizer checks, disabled leak detection, and uninstrumented components. [Open source][S05]
- **S06** fuzz_parser binary provenance and hashes. [Open source][S06]
- **S07** The simdjson patch changing fuzz_ndjson assertion reporting. [Open source][S07]
- **S08** Guide to internal proof properties and single-backend comparisons. [Open source][S08]
- **S09** DOM element string and string_view lifetime contract. [Open source][S09]
- **S10** DOM document backing-array allocation and replacement. [Open source][S10]
- **S11** DOM string builder cursor initialization and record completion. [Open source][S11]
- **S12** DOM parser buffer reuse documentation. [Open source][S12]
- **S13** On-Demand parser buffer allocation and unescape operation. [Open source][S13]
- **S14** On-Demand get_string consumption restriction. [Open source][S14]
- **S15** On-Demand rewind string-cursor reset. [Open source][S15]
- **S16** String parser and its scratch/padding behavior. [Open source][S16]
- **S17** Published fuzz_parser ASan agreement proof wrapper. [Open source][S17]
- **S18** Supporting fuzz_parser_asan_cfg theorem and closure. [Open source][S18]
- **S19** Fuzzing-mode 1 MiB padded-allocation cap in the upstream source. [Open source][S19]
- **S20** Recipe enabling FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION. [Open source][S20]
- **S21** Portable fallback copy-and-find byte behavior. [Open source][S21]
- **S22** Documented trusted base and absence of a certified source-correspondence claim. [Open source][S22]

### 11 2 DOM proof evidence

- **D01** SjTape.v str_at and is_str at lines 107 onward. [Open source][D01]
- **D02** SjTapeTile.v str_rec, tape_wfS, and cursor lemmas at lines 71 onward. [Open source][D02]
- **D03** SjTapeInv.v frameS and record-preservation invariants. [Open source][D03]
- **D04** Plain stage-two s2_okres and concrete successful-layout interface. [Open source][D04]
- **D05** Concrete tape_img and string-buffer write preservation machinery. [Open source][D05]
- **D06** Plain stage-two main proof maintaining the stronger invariant. [Open source][D06]
- **D07** Dmp_pj_leaf.v pj_str and sbuf_slice in compiled printing. [Open source][D07]
- **D08** Sj_stage2_strend.v seg_str_end_o and arbitrary produced payload bytes. [Open source][D08]
- **D09** ASan successful-layout predicate and interface. [Open source][D09]
- **D10** ASan strengthened compiled-function contract constructor with explicit helper premises. [Open source][D10]
- **D11** timg_sbytes extracting existing bytes without an initialization-history premise. [Open source][D11]
- **D12** Plain stage2t_of_walk constructor. [Open source][D12]
- **D13** UBSan successful-layout interface. [Open source][D13]
- **D14** UBSan strengthened-interface constructor. [Open source][D14]

### 11 3 Parser and On Demand proof evidence

- **P01** fuzz_parser SjS2Inv.v cumulative capacity invariant, sbuf_room, and string output-count bounds. [Open source][P01]
- **P02** fuzz_parser PC_s12iface.v stage-two postcondition and preservation windows. [Open source][P02]
- **P03** fuzz_parser TargetSafe.v allocation ownership, parser_dtor_spec_c, and fuzz_one_spec_c. [Open source][P03]
- **P04** Compiled large-input and padded-copy branch split in fuzz_parser. [Open source][P04]
- **O01** On-Demand pstr_post_g and pstr_stmt_g footprint and preconditions. [Open source][O01]
- **O02** munch final-memory preservation definition. [Open source][O02]
- **O03** Plain compiled decoder pstr_spec. [Open source][O03]
- **O04** Plain compiled harness get_string arm and decoder call. [Open source][O04]
- **O05** UBSan decoder contract using pstr_post_g. [Open source][O05]
- **O06** ASan decoder contract using pstr_post_g. [Open source][O06]
- **O07** SjLeaves.v output-count invariant without decoded-content relation. [Open source][O07]
- **O08** On-Demand fuzz_one_mspecN allocation ownership restoration. [Open source][O08]
- **O09** On-Demand model allocating and releasing backing arrays. [Open source][O09]
- **O10** On-Demand cursor transition and global cursor invariant. [Open source][O10]
- **O11** Combined ASan plus UBSan decoder contract. [Open source][O11]
- **O12** Concrete OWN predicate using inclusion in the live allocation list. [Open source][O12]
- **O13** GI instantiated as OWN with the output-state predicate. [Open source][O13]
- **O14** Compiled ASan decoder theorem pstra_spec. [Open source][O14]
- **O15** Compiled combined decoder theorem pstrb_spec. [Open source][O15]
- **O16** ASan string-arm call site discharging capacity and shadow premises. [Open source][O16]

### 11 4 Harness source evidence

- **H01** fuzz_parser. [Open source][H01]
- **H02** fuzz_atpointer. [Open source][H02]
- **H03** fuzz_dump. [Open source][H03]
- **H04** fuzz_dump_raw_tape. [Open source][H04]
- **H05** fuzz_element. [Open source][H05]
- **H06** fuzz_implementations. [Open source][H06]
- **H07** fuzz_ondemand. [Open source][H07]
- **H08** fuzz_minifyimpl. [Open source][H08]
- **H09** fuzz_print_json. [Open source][H09]
- **H10** fuzz_utf8. [Open source][H10]
- **H11** Driver adapter repeated-callback logic. [Open source][H11]

## 12 Binary identities and reproducibility record

The following hashes are recorded in the release provenance for fuzz_parser. They are evidence identifiers, not hashes independently recomputed from downloaded binaries during this review. [S06]

| Build | Bytes | SHA 256 prefix |
|---|---|---|
| Plain | 411344 | 5b36de478a7eb927 |
| ASan | 1022712 | bf85b04f5b21cd38 |
| UBSan | 452400 | 70d2dab914a7c1a3 |
| ASan plus UBSan | 1070712 | f11d124a2b1c243d |

Full hashes for exact matching:

```text
plain
5b36de478a7eb9271b397d7d2bb168042cdbd5c0d7884e9e68900a4ee0668d72

asan
bf85b04f5b21cd389081e27d513ab1a39e84fcc873928b8927c7608cc9ff32ba

ubsan
70d2dab914a7c1a39d371a3cf7a8211be35d4453a8551359320901e10956a384

asan plus ubsan
f11d124a2b1c243dfc68890f138076e81b431746e9cc218a22a0c918289ef3d9
```

The checker image documented by the release is pinned by SHA-256, and the proof checker checks assumptions against an allowlist. For an independent replay, use the repository's exact checking instructions rather than treating this dossier's source inspection as a substitute for kernel checking. A future update should record which targets were replayed, the elapsed time and resources, resulting logs, and any failures without inferring that a tooling failure refutes the theorem.

## 13 Terminology for subsequent writing

**Backing allocation** is the new[]-allocated byte array visible to ordinary allocation instrumentation. **String record** is a smaller DOM region inside that array, with a header, payload, and terminator. **String view** is a client-visible pointer and length; it does not own a separate allocation.

**Payload length** is the stored string length used by the record and traversal. **Record extent** includes the extra five bytes. **Scratch footprint** is the decoder's permitted temporary output region. **Used prefix** ends at the current cursor. **Capacity** is the total backing storage available. These boundaries must not be substituted for one another.

**Spatial safety** concerns the intended regions of accesses. **Temporal safety** concerns when a view or object is valid. **Generation identity** distinguishes successive logical objects at the same address. **Boundary preservation** compares memory at specified program points. **Trace safety** constrains the accesses occurring throughout execution.

**Published agreement** is the top-level relation between executable behaviors and errors. **Supporting lemma** is an internal proved property used to construct that result. **Harness scope** is the fixed client program whose behavior the theorem quantifies over. **API precondition violation** is a client sequence the library contract does not authorize; demonstrating one does not establish an implementation vulnerability under valid use.

## 14 Instructions for using this dossier as source material

When asking another model to help draft a blog post, supply the editable Markdown alongside the intended argument and audience. Ask it to retain the evidence labels in section 2 and to cite the pinned source identifiers for technical claims. Require it to distinguish published statements, supporting lemmas, source-level observations, inferences, and unresolved questions.

In particular, do not let a downstream draft turn an absent client sequence into a discovered vulnerability, a final-memory relation into an every-access theorem, a stored length into semantic decoded correctness, or ownership subset restoration into leak freedom. Keep the raw-pointer padded-copy limit separate from the driver's accepted-file size. Attribute the stronger DOM layout statements to the inspected success contracts and variants, rather than to every simdjson API.

Before publication, verify any source quotations and line references against the pinned commit. If a stronger claim is important to the argument, obtain the corresponding theorem or experiment instead of treating an unestablished item as a negative result. Preserve the distinction between a proof's scope, the usefulness of its specification, and the soundness of its reasoning.

[S01]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/README.md
[S02]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_parser/Statements.v
[S03]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/statements.md
[S04]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/semantics.md
[S05]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/building.md
[S06]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/provenance/PROVENANCE.md
[S07]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/provenance/recipe/patches/github.com/simdjson/simdjson/f807de973580fb22cc0db6b3b896716684b0266c/0001-fuzz-ndjson-assertions-abort.patch
[S08]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/exploring.md
[S09]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/dom/element.h#L85
[S10]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/dom/document-inl.h#L29
[S11]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/src/generic/stage2/tape_builder.h#L184
[S12]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/dom/parser.h#L154
[S13]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/generic/ondemand/parser-inl.h#L24
[S14]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/generic/ondemand/value.h#L228
[S15]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/generic/ondemand/json_iterator-inl.h#L81
[S16]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/src/generic/stage2/stringparsing.h#L143
[D01]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/Sj/SjTape.v#L107
[D02]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/Sj/SjTapeTile.v#L71
[D03]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/Sj/SjTapeInv.v#L15
[D04]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/P/Sj_stage2_iface.v#L98
[D05]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/P/Sj_stage2_defs.v#L349
[D06]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/P/Sj_stage2_main.v#L111
[D07]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/P/Dmp_pj_leaf.v#L322
[D08]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/P/Sj_stage2_strend.v#L35
[D09]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/A/Sj_stage2_iface.v#L87
[D10]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/A/Sj_stage2_closed.v#L13
[P01]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/lib/Spec/SjS2Inv.v#L116
[P02]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/lib/Plain/PC_s12iface.v#L155
[P03]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/lib/Spec/TargetSafe.v#L168
[O01]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/P/Od_pstr_kit.v#L17
[O02]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Lib/Frame.v#L68
[O03]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/P/Od_pstr.v#L119
[O04]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/P/Od_arm_str.v#L52
[O05]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/U/Od_pstr_defs.v#L21
[O06]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/A/Od_pstr_defsA.v#L28
[O07]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Sj/SjLeaves.v#L14
[O08]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Spec/TargetSafe.v#L139
[O09]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Spec/OdModel.v#L35
[O10]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Sj/SjOd.v#L174
[O11]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/B/Od_pstr_defsB.v#L29
[H01]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_parser/source/fuzz_parser.cpp
[H02]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_atpointer/source/fuzz_atpointer.cpp
[H03]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_dump/source/fuzz_dump.cpp
[H04]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_dump_raw_tape/source/fuzz_dump_raw_tape.cpp
[H05]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_element/source/fuzz_element.cpp
[H06]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_implementations/source/fuzz_implementations.cpp
[H07]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_ondemand/source/fuzz_ondemand.cpp
[H08]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_minifyimpl/source/fuzz_minifyimpl.cpp
[H09]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_print_json/source/fuzz_print_json.cpp
[H10]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_utf8/source/fuzz_utf8.cpp
[H11]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/provenance/recipe/src/ossfuzz_adapter.h#L331
[S17]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/asan_agrees/Proof.v
[S18]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/lib/Theorems.v
[D11]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/P/Sj_stage2_defs.v#L487
[O12]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Spec/KStep.v#L1320
[O13]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Spec/ModelInv.v#L233
[O14]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/A/Od_pstrA.v#L129
[O15]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/B/Od_pstrB.v#L137
[O16]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/A/Od_arm_strA.v#L87
[D12]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/P/Sj_stage2_adapt.v#L112
[D13]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/U/Sj_stage2_iface.v#L101
[D14]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/U/Sj_stage2_adapt.v#L115
[S19]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/padded_string-inl.h#L35
[S20]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/provenance/recipe/tools/ossfuzz/recipes.sh#L182
[P04]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_parser/lib/Plain/PC_pid.v#L583
[S21]: https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/fallback/stringparsing_defs.h#L14
[S22]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/trust.md
