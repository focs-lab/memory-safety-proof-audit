# simdjson: string arenas, lifetime contracts, and proof scope

**Report assembled:** 29 October 2026.  
**Evidence basis:** the completed source audit prepared on 25 October 2026, with selected primary-file rechecks performed while drafting the paper on 29 October.  
**Original record:** [Simdjson_Proof_Evidence_Dossier.md](../dossiers/Simdjson_Proof_Evidence_Dossier.md). The recovered file retains the earlier detailed audit and source register. Its text was recovered through the file service; byte identity with the original upload is not asserted.

This is a consolidation of the completed investigation for a portable evidence handoff. It is not a new comprehensive audit. No Rocq replay, independent executable rebuild, test execution, or exploit reproduction was performed.

## 1. Finding and limits

The public simdjson results concern fixed compiled clients. Their supporting proofs contain genuine internal reasoning about individual records within shared string buffers. In the inspected DOM development, records have explicit extents, length headers, terminators, and sequential placement within a used prefix. On-Demand decoding has an output bound and a memory-preservation contract.

These facts directly contradict the claim that the proof checks only the outer allocation or ignores all custom-allocation boundaries. The unresolved issue is the relationship between the top-level sanitizer-agreement result, these local facts, and broader client lifetime or source-language properties.

The relevant temporal scenario is **parser reuse while a client retains a previously issued view**. The DOM API invalidates old strings/views at the next parse, even when backing storage remains allocated. The inspected harnesses do not perform a second parse on the same parser and then read a retained first-document view. This is outside their client histories; it is not a discovered internal parser bug.

Individual DOM and On-Demand strings have no per-string free interface on the exercised paths. Generic custom double-free, wrong-pool free, or per-string shrink examples are therefore inapplicable at that level. The real operations are parser reuse, buffer replacement, destruction, On-Demand consumption, and rewind.

### Evidence labels

| Label | Meaning |
| --- | --- |
| Published theorem | A result reported as proved in the pinned corpus; this report did not independently replay it. |
| Positive internal evidence | An identified contract, invariant, lemma or instantiation supports a property under stated premises. |
| Outside harness | The relevant client sequence is absent from the fixed program being proved. |
| Not applicable | The operation is not offered by the exercised string-arena interface. |
| Not established | The reviewed material does not justify the broader proposition; this is not a proof of falsity or impossibility. |
| Contract countermodel | A mathematical or hypothetical execution distinguishing two kinds of specifications, without demonstrated reachability in the released binary. |
| Reached bug | A concrete violating execution admitted by the actual theorem and all its premises. None was produced. |

## 2. Exact identities and inventory

| Component | Recorded identity |
| --- | --- |
| Proof repository | theorem-labs/oss-verify-proofs |
| Audited proof snapshot | 98e995d4daced70a0a4aa2c810854b88720735f1 |
| Binary release | v2026.10.0 |
| Upstream repository | simdjson/simdjson |
| Upstream commit | f807de973580fb22cc0db6b3b896716684b0266c |
| Static ASan source commit | b05061352064fa2be1813ac5429149f3de5f057d |
| LPS dependency recorded for the release | f1006fe8178338a499b5e5c41be83006c4edd058 |
| Compiler / platform | clang 20.1.8; static riscv64 Linux; musl; portable fallback backend |
| Checker version documented by the release | Rocq 9.2.0 |
| Recorded patch | One patch changing assertion reporting in fuzz_ndjson |
| Initial project inventory | 13 of 14 OSS-Fuzz targets have statements; 52 binaries; 179 statements, 24 proved, 4 model-blocked, 151 open |
| Targets with proofs | 10 |
| Initial agreement counts | ASan 9; UBSan 8; ASan+UBSan 7; total 24 |

The patch is unrelated to per-string ASan instrumentation. Its existence must not be interpreted as an allocator instrumentation fix. The patch text is linked separately from provenance. [S01] [S06] [S07]

These are 24 compiled-configuration results for one upstream snapshot, not 24 source versions. The audited proof commit and the binary-release tag are separate identifiers; no claim is made that the tag currently resolves to the audited commit.

### Material inspected in the completed audit

The earlier audit examined the project inventory and statements, the fuzz_parser wrapper and supporting contracts, DOM invariants and compiled interfaces in fuzz_dump, On-Demand decoder contracts and call sites, backing-allocation ownership specifications, upstream placement and lifetime APIs, and all ten harness source files with published proofs. The deepest spatial inspection concerned fuzz_dump and fuzz_ondemand.

It did not read every generated or machine-walk file in every directory. Properties found in one harness or variant cannot be silently promoted to every simdjson API or every compiled configuration.

## 3. Per-harness result and client inventory

A = standalone ASan agreement; U = UBSan agreement; B = combined ASan+UBSan agreement. “No” means no such published agreement in the audited snapshot, not a statement known false. [S01]

| Harness | A | U | B | Client sequence relevant to the arena |
| --- | --- | --- | --- | --- |
| fuzz_atpointer | Yes | Yes | Yes | Fresh DOM parser; one parse; pointer lookup and local string view |
| fuzz_dump | Yes | Yes | No | Fresh DOM parser; one parse; recursive output traversal |
| fuzz_dump_raw_tape | Yes | Yes | No | Fresh DOM parser; one parse; tape dump; boolean result discarded |
| fuzz_element | No | No | Yes | Fresh DOM parser; one parse; selected accessor; results discarded |
| fuzz_implementations | Yes | Yes | No | Fresh per-backend parser objects; one parse per object |
| fuzz_minifyimpl | Yes | Yes | Yes | Direct backend minification; no DOM/On-Demand string arena |
| fuzz_ondemand | Yes | Yes | Yes | Fresh parser; one iterate; selected accessors; returned views discarded |
| fuzz_parser | Yes | Yes | Yes | Fresh DOM parser; one parse; result/error discarded |
| fuzz_print_json | Yes | No | Yes | Fresh DOM parser; one parse; output traversal |
| fuzz_utf8 | Yes | Yes | Yes | Direct backend UTF-8 validation; no DOM/On-Demand string arena |

The inventory also includes fuzz_minify and fuzz_ndjson, which had statements but no proof recorded at this snapshot; fuzz_padded had model-blocked halting statements; api-driver was held; fuzz_atpath was not built. Their presence in the project inventory extends neither the ten proved client contexts nor the audited allocator paths.

The riscv64 build has only the portable fallback among supported backends. Cross-backend comparisons in fuzz_implementations therefore do not compare distinct implementations in this artifact. The same single-backend qualification applies to the backend-selection structure of fuzz_minifyimpl and fuzz_utf8. This is not a theorem about x86 SIMD implementations. [S08] [H06] [H08] [H10]

### 3.1 The simplest concrete client

The archived fuzz_parser source creates a local DOM parser, parses once into a local element, ignores the error, and returns zero:

    dom::parser parser
    dom::element elem
    error = parser.parse(Data, Size).get(elem)
    return 0

It does not compare a parsed JSON value with a semantic oracle. A universal proof of this client does not thereby acquire the complete JSON specification. [H01]

The other DOM harnesses consume or discard results before parser destruction. The On-Demand harness performs one iterate, chooses one of twelve accessor patterns for each item, and discards a get_string result at the end of its case. It does not rewind or compare a retained string after another document. [H02]–[H07] [H09]

### 3.2 Driver repetition is not parser reuse

The driver may invoke a callback one to four times using the payload. The parser is local to each invocation and is destroyed before returning. The callback returns an integer, not a view for the driver to preserve.

Thus “the callback can be invoked repeatedly” and “the client retains a view across a second parse on the same parser” describe different histories. The former does not establish coverage of the latter. [S02] [H01] [H11]

## 4. Top-level theorem, names, premises, and configuration

For fuzz_parser the public ASan statement is recorded as:

    Definition asan_agrees : Prop :=
      agrees_in_abort_modelled Env.alloc_forced_only
        Budgets.Asan.lim_source Budgets.Asan.lim_target
        Images.plain Images.asan.

The short proof wrapper proves Statements.asan_agrees using the supporting theorem **fuzz_parser_asan_cfg** in lib/Theorems.v. That theorem closes the executable result through **ClosedP.base_asan_mc** and the plain/ASan client proofs. These exact names are recorded in the original audit. The wrapper does not itself state the string-record predicates, a generation discipline, or semantic decoded contents. [S02] [S17] [S18]

The exact supporting top-level theorem names for every other harness and sanitizer configuration were not recorded as a complete catalog in the earlier audit. They remain unconfirmed here; no names are extrapolated from naming patterns. Public result labels asan_agrees, ubsan_agrees, and asan_ubsan_agrees are recorded in the inventory.

### 4.1 Guarantee and budgets

The agreements establish that neither corresponding binary reaches a modeled error and that their sets of observable process behaviors agree, under the stated conditions. A sanitizer report aborts, so reports produced by the configured sanitizer are excluded. Observations include ordered process input/output, exit status, and modeled final file contents. [S02] [S03]

| Item | Recorded scope |
| --- | --- |
| ASan-bearing comparison | Plain build has a 2 GiB no-budget-refusal premise |
| UBSan-only comparison | Plain build has a 16 GiB no-budget-refusal premise |
| Sanitizer target budget | 512 GiB |
| Memory-refusal policy | Refusal must be forced by budget/address-space conditions; other modeled request failures may remain allowed |
| Driver file bound | Files of 64 MiB or more are rejected before the harness |
| Initial halting results | Open at the audited snapshot; agreement is not a termination theorem |

The budget restriction is a premise, not a theorem that every input satisfies it. The proof remains universal over admitted modeled inputs and behaviors; it is not a finite set of passing tests. Later releases added halting results, so the initial status must remain dated.

### 4.2 The additional padded-copy limit

A separate build-specific restriction affects the raw-pointer fuzz_parser parse path. The recipe enables FUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION. Under that setting, allocate_padded_buffer returns null when input length plus 64 padding bytes exceeds 2^20 bytes. Payloads above **1,048,512 bytes** can therefore reach the harness but fail its padded-copy allocation before the parser's main implementation runs. [S19] [S20]

The compiled PC_pid proof distinguishes copy_made=false and copy_made=true. This explains a smaller bound in local parsing lemmas. It does not mean the complete theorem silently truncates every file to 1 MiB, and it must not be generalized to every overload without checking its call route. [P04]

### 4.3 Instrumentation and patch details

The library and fuzz target receive sanitizer flags; the driver and runtime components are uninstrumented. Reached uninstrumented instructions remain part of the formal binary execution, so “uninstrumented” is not equivalent to “assumed away.” [S05]

Recorded configurations include:

    ASan:
      -fsanitize=address

    UBSan:
      -fsanitize=undefined -fno-sanitize-recover=all
      -fsanitize-trap=all -fno-sanitize=function

    Combined:
      both groups above

Leak detection is disabled. The recorded UBSan groups include alignment, array-bounds, bool, builtin, enum, float-cast-overflow, integer-divide-by-zero, nonnull-attribute, null, object-size, pointer-overflow, return, returns-nonnull-attribute, shift-base, shift-exponent, signed-integer-overflow, unreachable and vla-bound. That list is not every source undefined behavior; omitted groups include unsigned-integer-overflow, implicit-conversion, local-bounds, vptr and function checking. Direct proof reasoning may establish facts beyond the enabled checks. [S05]

ASan options are sealed. Allocation failure can return null; reports abort silently; startup reservation failure can spin. These configuration facts are part of the fixed artifact and should not be silently replaced by ordinary desktop ASan defaults.

## 5. The actual custom-allocation mechanisms

### 5.1 DOM records inside a shared array

document::allocate obtains a byte buffer for strings and a separate tape array through new[]. A string tape entry points into the shared byte buffer. Each DOM record consists of a four-byte length header, payload bytes, and a zero terminator. The builder advances current_string_buf_loc after each record. [S10] [S11]

The recorded capacity calculation is rounded from an expression based on five times capacity divided by three plus SIMDJSON_PADDING. This accounts for record overhead. The buffer can contain unused capacity and temporary scratch space, so these extents must be distinguished:

| Term | Meaning |
| --- | --- |
| Payload length | Bytes returned as the string contents |
| Record extent | Header + payload + terminator; payload length plus five |
| Scratch footprint | Temporary region permitted during decoding |
| Used prefix | Portion occupied by completed records/current construction |
| Capacity | Entire allocated backing buffer |

There is no individual free operation for a DOM string record. During construction of one document, completed records remain within the retained prefix. This is shared arena storage, not a recycling malloc replacement.

### 5.2 Actual invalidation by reuse

A new parse resets the builder cursor to the beginning of the document's string buffer. If capacity suffices, the backing storage can be reused. The pinned DOM API explicitly says returned strings and string_views are invalidated by the parser's next parse or destruction. [S09] [S11] [S12]

That is the concrete temporal contract at issue. An old view may still hold a numerically readable address while no longer being authorized by the API. It need not be a C++ use-after-deallocation: the byte array can remain alive.

### 5.3 Buffer replacement differs from pool-slot relocation

document::allocate replaces unique_ptr-managed new[] arrays and genuinely deallocates the prior backing arrays. The generic custom-pool example in which a moved object's old location remains inside a live pool does not describe that replacement operation. An old view can still be invalid, but the mechanism and potential sanitizer behavior differ. [S10]

### 5.4 On-Demand strings and consumption

The On-Demand parser also uses a shared output buffer. Unescaping yields a view and advances an output cursor. It does not allocate a separate standard heap object for each string. [S13]

The API restricts consumption: calling value::get_string twice on the same value is documented as an error; the iterator's unescape operation is likewise intended once per raw string. The verified one-accessor-per-item client cannot be generalized to arbitrary repeated accessor sequences. [S14] [H07]

On-Demand rewind resets the string cursor, and the harness does not call it. The earlier audit did not fully classify the exact validity of every view across every possible rewind context. It is safe to record the absent client sequence; it is not safe to assert an unconditional invalidation rule for all rewind uses. [S15]

## 6. Positive supporting proof evidence

### 6.1 Record extent and length are explicit

In fuzz_dump/lib/Sj/SjTape.v, **str_at** requires:

    0 <= o
    0 <= l
    o + l + 5 <= sn
    le32(S,o) = l
    S(o + 4 + l) = 0

Here o is the record offset, l its stored payload length, S the string-buffer byte function, and sn the used length. This bounds the record by the used prefix rather than only the backing capacity, relates its header to its payload extent, and places the terminator. **str_at_bounds** extracts the corresponding bounds for consumers. [D01]

The predicate does not say that the payload equals a mathematical JSON decoding of the input token. “Stored length” must not be renamed “semantic decoded length” without a separate correspondence theorem.

### 6.2 Consecutive placement

In SjTapeTile.v, **str_rec** places the record at cursor c and advances the cursor to c+l+5. **tilesS**, **elemS**, and **tape_wfS** thread the cursor through scalar values, arrays and object fields, beginning at zero and ending at the used string length. [D02]

This is positive evidence of sequential, non-overlapping record placement in the constructed document. It is not a universal provenance theorem for every pointer a client could fabricate. It also does not require the implementation to store a fresh generation token in each record.

### 6.3 Preservation and the machine-level connection

**frameS** in SjTapeInv.v preserves completed-prefix bytes at specified proof boundaries. The concrete **tape_img** invariant represents tape/string bytes in machine memory, and **tape_img_write_sbuf** supports writes after the completed prefix. [D03] [D05]

For the plain stage-two implementation, **s2_okres** carries concrete tape/string data satisfying tape_wfS, with used lengths within capacities. **stage2t_of_walk** connects the walk to the strengthened contract, and the stage-two proof maintains the corresponding invariant through **s2_labels**. [D04] [D06] [D12]

The ASan **s2a_okres** and **stage2at_closed** expose corresponding structure with variant-specific runtime/numeric-helper premises. UBSan has a corresponding successful-layout interface. These variant connections matter: a fact proved for plain code does not automatically transfer to differently compiled sanitizer code. No combined agreement for fuzz_dump was published in this snapshot. [D09] [D10] [D13] [D14]

Local premises include valid stage-one output, padded input, separated backing regions, sufficient capacities and stack, and blen(bs) <= 1,048,512. The stronger well-formed final document is a success-branch result; failed parses need not yield that successful structure.

### 6.4 Traversal uses the recorded payload extent

The compiled **pj_str** proof in Dmp_pj_leaf.v starts from an is_str premise, reads the header, obtains the length via str_at_bounds, and constructs an exact payload slice with **sbuf_slice** for output. [D07]

This is a concrete logical-length argument. It proves more than arena addressability for the exercised printing path. It does not justify arbitrary indexing by external clients or establish decoded-content correctness.

### 6.5 The smaller parser contract has a different purpose

fuzz_parser discards the result. Its stage-two interface permits mutation of tape/string storage while retaining the needed heap/frame properties; it need not expose the same traversal-ready tape structure as fuzz_dump. Its **winv** and **sbuf_room** invariants bound cumulative arena use, output growth and working-array indices. [P01] [P02]

Use the fuzz_dump proof for claims about complete DOM record layout and traversal. Do not present one harness's postcondition as the postcondition of all ten.

### 6.6 On-Demand returned-pointer and frame bounds

**pstr_post_g** in Od_pstr_kit.v states either failure or return of SB+sbo_prime, where:

    sbo <= sbo_prime <= sbo + (j - i - 1)

Its **munch** relation permits final-memory changes only in the decoder stack frame and:

    [SB+sbo, SB+sbo+(j-i))

The precondition requires a closing quote, padded readable input, writable output capacity, input/output separation, and enough room for the permitted footprint. [O01] [O02]

**pstr_spec** proves the plain decoder contract. The plain string arm invokes it; the global **sbo_ok** cursor invariant and input closing-quote bound discharge the capacity requirement. UBSan, ASan, and combined contracts also use pstr_post_g, with variant-specific premises. **pstra_spec** and **pstrb_spec** prove the ASan-bearing variants. The ASan string arm discharges capacity and unpoisoned-shadow premises for the whole backing buffer, not per-string poisoning. [O03]–[O06] [O10] [O11] [O14]–[O16]

The output allowance may be longer than the final returned view. Decoder scratch bytes and padding are intentional parts of the contract. A construction-time write beyond the eventual payload length is not automatically an invalid access.

## 7. What these contracts do not establish by themselves

### 7.1 Boundary preservation is weaker than trace safety

frameS and munch compare memory at selected boundaries. A hypothetical sequence that temporarily changes an earlier record and restores it can satisfy a final-memory equality. This is a **contract-separation example**, not an allegation that the decoder performs such a sequence.

Some inspected machine-store arguments separately establish bounds. A universal every-intermediate-access claim would require following those obligations through all relevant stores or exporting an explicit trace property. It does not follow from the frame condition alone. [D03] [O02]

### 7.2 Layout is weaker than semantic decoding

The inspected DOM completion contract accepts the concrete produced payload bytes without a condition equating them to decode(input_token). The On-Demand invariant tracks the closing quote, cursor and output count, not a semantic decoded sequence. A hypothetical wrong payload with the correct layout could satisfy those predicates. [D08] [O07]

This demonstrates the limits of the predicates, not a wrong result in the actual implementation. A different supporting lemma might establish additional semantic facts; the audit did not establish that no such lemma exists anywhere.

### 7.3 Readable bytes do not record initialization history

bytes_at records concrete machine byte values. It is not itself a source-level definedness or information-flow statement. The helper **timg_sbytes** obtains a byte list from writable in-capacity storage using stk_bytes without requiring an earlier decoder write in that contract. [D11]

No concrete uninitialized read or data disclosure was found. The broader initialization/clearing guarantee remains unestablished by the inspected contracts.

### 7.4 Ownership restoration is weaker than exact leak freedom

The proofs model backing allocations and deletions. **parser_dtor_spec_c** consumes parser ownership, **fuzz_one_spec_c** restores the original ownership list, and On-Demand **fuzz_one_mspecN** restores own X. These are meaningful positive accounting facts. [P03] [O08] [O09]

In the concrete On-Demand instantiation, GI X is OWN X Gso. OWN requires named addresses to be a duplicate-free subset of the allocator's live list. Its relevant clause is:

    incl (map fst X) (ld_live L)

Inclusion is weaker than equality. Restoring this predicate alone can coexist with an extra live block, so it is not an exact no-leak theorem. Explicit deletion sequences still supply cleanup evidence. Leak detection is disabled, and eventual release on all runs would also require appropriate progress/termination premises. [O12] [O13]

### 7.5 Invalid client uses are not valid-use implementation bugs

An illustrative client can retain a DOM string_view, parse a second document with the same parser, and read the old view. The API says the view is invalid after the second parse; the backing address can nevertheless remain readable. This explains a detector/contract distinction.

The example is not a traced behavior of a proved harness and does not show that the library violates a promise to valid clients. A future assurance statement must decide whether it assumes contract-compliant callers or detects misuse by arbitrary callers. Those are different goals.

## 8. Checklist coverage

| # | Property or scenario | Classification and interpretation |
| ---: | --- | --- |
| 1 | Suballocation overflow/underflow | **Substantial positive internal support.** Record extents, consecutive layout, payload slices and decoder footprints are explicit; no universal client provenance claim follows. |
| 2 | Internal per-string free | **Not applicable.** No such individual-string operation on exercised paths. |
| 3 | Per-string double free | **Not applicable.** Backing-array destructor/accounting is a separate present obligation. |
| 4 | Reset with retained views | **Outside harness.** Reparse can retain storage while invalidating old views. |
| 5 | Per-string shrinking | **Not applicable to exercised interface.** Capacity changes and final payload length are different concepts. |
| 6 | Moving a suballocation while retaining old pool bytes | **Does not describe document buffer replacement.** Old backing arrays are actually deallocated; retained clients are outside the histories. |
| 7 | Stale view after address reuse | **Outside harness; general client lifetime theorem not established.** A missing generation field alone is not proof of a defect. |
| 8 | Stale custom free releases a new string | **Not applicable.** No individual string-free operation. |
| 9 | Wrong-pool/interior/sized custom free | **Not applicable to individual strings.** Clients receive views; parser ownership covers backing storage. |
| 10 | Other invalidation | **Unexercised histories.** Reparse and rewind/consumption require their actual API contracts; exact rewind lifetime rules remain partly unclassified. |
| 11 | Arena implementation correctness | **Mixed positive support.** Placement, extents, capacity and backing accounting are modeled; decoded semantics is separate. |
| 12 | Logical leaks | **No general leak theorem.** Bulk retention is intentional; exact live-set equality is not established by ownership restoration alone. |
| 13 | Redzone jumping | **Local bounds evidence present.** Arbitrary client pointer arithmetic remains outside the fixed harness. |
| 14 | Intra-object field overflow | **General source-subobject theorem not established.** A whole-structure preservation window can be broader than individual C++ fields. |
| 15 | Logical length versus capacity | **Specific positive support.** str_at, tape_wfS and pj_str use record/payload lengths, not only outer capacity. |
| 16 | Lifetime ends while storage remains | **General client lifetime outside scope.** DOM API invalidation is concrete; source C++ lifetime is not fully modeled. |
| 17 | Uninstrumented accesses | **Instrumentation boundary, not automatic proof omission.** Reached runtime instructions remain modeled. |
| 18 | Initialization, residual data, confidential clearing | **Not established generally.** Concrete bytes/layout are not a full initialization or information-flow contract. |
| 19 | Alignment and size arithmetic | **Positive inspected evidence.** Cursor/capacity/arithmetic premises and enabled UBSan checks contribute; not every source arithmetic issue is covered. |
| 20 | Data races | **Outside single-threaded model.** No interleaving or concurrent observer theorem is supplied. |

## 9. Binary provenance and portable archive

The following fuzz_parser fingerprints were transcribed in the original audit from provenance. They are not newly computed executable hashes. [S06]

| Build | Bytes | SHA-256 |
| --- | ---: | --- |
| plain | 411344 | 5b36de478a7eb9271b397d7d2bb168042cdbd5c0d7884e9e68900a4ee0668d72 |
| ASan | 1022712 | bf85b04f5b21cd389081e27d513ab1a39e84fcc873928b8927c7608cc9ff32ba |
| UBSan | 452400 | 70d2dab914a7c1a39d371a3cf7a8211be35d4453a8551359320901e10956a384 |
| ASan+UBSan | 1070712 | f11d124a2b1c243dfc68890f138076e81b431746e9cc218a22a0c918289ef3d9 |

Six already-read primary files are archived locally. [SOURCES.json](../source-snapshots/simdjson/SOURCES.json) records immutable URLs, commits, repository paths, capture dates, byte counts and local text hashes.

| Archived file | Purpose |
| --- | --- |
| [Project README](../source-snapshots/simdjson/oss-verify-proofs/98e995d4/projects/simdjson/README.md) | Inventory, source pin, variants and counts |
| [fuzz_parser.cpp](../source-snapshots/simdjson/oss-verify-proofs/98e995d4/projects/simdjson/fuzz_parser/source/fuzz_parser.cpp) | Concrete one-parse client |
| [SjTape.v](../source-snapshots/simdjson/oss-verify-proofs/98e995d4/proofs/simdjson/fuzz_dump/lib/Sj/SjTape.v) | Exact str_at and related bounds |
| [SjTapeTile.v](../source-snapshots/simdjson/oss-verify-proofs/98e995d4/proofs/simdjson/fuzz_dump/lib/Sj/SjTapeTile.v) | Consecutive records, tape_wfS |
| [Od_pstr_kit.v](../source-snapshots/simdjson/oss-verify-proofs/98e995d4/proofs/simdjson/fuzz_ondemand/lib/P/Od_pstr_kit.v) | Decoder postcondition, capacity and separation premises |
| [DOM element.h](../source-snapshots/simdjson/simdjson/f807de97/include/simdjson/dom/element.h) | API invalidation of strings/views |

This selected source archive is not a complete repository checkout or executable/replay package. Local hashes identify captured UTF-8 text only. The original detailed dossier retains all inspected source links, including variant-specific compiled connections.

### Source map for the proof chain

| Group | Purpose |
| --- | --- |
| [S01]–[S08], [S17]–[S20] | Inventory, statements, semantics, build and patch, provenance, wrapper, theorem and padded-copy behavior |
| [S09]–[S16], [S21] | Upstream allocation, invalidation, builder cursor, consumption, rewind, scratch behavior |
| [D01]–[D07], [D09], [D10], [D12]–[D14] | DOM record predicates, strengthened layout interfaces, machine-level links and traversal |
| [D08], [D11] | Limits of semantic-content and initialization claims |
| [P01]–[P04] | Smaller parser contract, ownership and padded-copy branch |
| [O01]–[O07], [O10], [O11], [O14]–[O16] | On-Demand contract, proof variants and client instantiation |
| [O08], [O09], [O12], [O13] | Ownership accounting and subset-versus-live-set qualification |
| [H01]–[H11] | Harness sources and repeated-callback driver |

## 10. Reporting rules and remaining questions

Use: “The inspected DOM proof establishes string-record layout and traversal bounds, and the On-Demand proof establishes returned-pointer/footprint contracts under explicit premises.”

Do not replace that with: “Every string-relative access in every client is proved safe.” Likewise, a final-memory frame condition is not automatically a trace invariant, stored length is not automatically semantic decoded length, and restored named ownership is not automatically exact leak freedom.

The unresolved questions retained from the original audit are:

1. Whether an exported trace theorem can connect every intermediate access on the relevant compiled paths to its authorized record or scratch region.
2. Whether other parts of the full development establish stronger initialized-byte or decoded-content properties than the reviewed contracts.
3. The complete API contract for retained views across all On-Demand rewind/consumption contexts.
4. Broader valid client histories involving parser reuse, capacity growth and failure, while respecting documented invalidation.
5. Corresponding guarantees for other architectures, compiler configurations and concurrent use.

No new investigation of those questions was undertaken for this handoff. A checker replay would establish derivability under the selected toolchain and assumptions; it would not expand a fixed statement to a new client, platform or property. The existing evidence establishes a specification boundary and substantial positive proof content, with no witnessed implementation vulnerability.

## Pinned references

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
