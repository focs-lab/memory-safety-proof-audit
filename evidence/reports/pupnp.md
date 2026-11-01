# pupnp: FreeList caching and the FuzzHttp proof boundary

## Status

This report records the completed selected source/specification inspection of pupnp's `FuzzHttp` proof. It preserves positive allocator reasoning as well as the specific reuse boundary. It is not a new comprehensive audit, an independent Rocq replay, or a report of an actual bad execution.

The evidence supports this formulation:

> The proof tracks backing allocations separately from cached nodes, enforces cached-node uniqueness, and accounts for destruction. Its inspected allocation contracts require an empty cache. They do not provide a general guarantee about successive logical leases of a cached and reused node.

Do not say that the proof ignores the custom allocator, ignores all internal frees, or establishes nothing about duplicate returns.

## Immutable scope

| Item | Identity / interpretation |
| --- | --- |
| Proof repository | `theorem-labs/oss-verify-proofs` |
| Proof commit | `98e995d4daced70a0a4aa2c810854b88720735f1` |
| Upstream repository | `pupnp/pupnp` |
| Upstream commit | `b46bc77ac9ae2ff1351d0f4ce544d97283b6e149` |
| Harness with released proofs | `FuzzHttp` |
| Sanitizer-agreement variants | ASan; ASan+UBSan |
| Count | 1 harness; 2 statements; no standalone UBSan agreement in this inventory |
| Allocator inspected | `FreeList`, used for fixed-size nodes on the HTTP parsing path |
| Execution/replay status | Selected source/specification review; no independent Rocq replay |

The [pinned project manifest](../source-snapshots/pupnp/project.yaml) also lists `FuzzIxml`; listing a target is not evidence that it has a released proof. Use the public proof inventory for the 1/2 counts above. A later release or moving tag must not silently replace this audit snapshot.

## The harness actually being verified

The [pinned upstream harness](../source-snapshots/pupnp/upstream/fuzzer/FuzzHttp.c) is `fuzzer/FuzzHttp.c`.

Its API sequence is:

1. Return immediately if the input is empty.
2. Use the leading input byte to choose request versus response parsing.
3. Initialize one local `http_parser_t` with `parser_request_init` or `parser_response_init`.
4. Call `parser_append` once on the remaining bytes.
5. Call `httpmsg_destroy` and return.

This is a fixed parsing client. The input can influence parsing, but the harness is not an arbitrary sequence generator for `FreeListInit`, allocation, free, reuse, and destruction. The proof still quantifies over the admitted inputs of this fixed client; “fixed harness” does not mean only a collection of tested inputs.

## What FreeList does

Pinned implementation: [upnp/src/threadutil/FreeList.c](../source-snapshots/pupnp/upstream/upnp/src/threadutil/FreeList.c).

| Operation | Source lines | Behavior |
| --- | --- | --- |
| `FreeListInit` | 38–49 | Sets element size/cache limit and initializes an empty head and zero cached length. |
| `FreeListAlloc` | 52–69 | Pops the cache head if nonempty; otherwise calls `malloc(element_size)`. |
| `FreeListFree` | 72–90 | Caches a nonnull returned element when below its cache limit; otherwise calls ordinary `free`. |
| `FreeListDestroy` | 93–108 | Frees all cached nodes and empties the cache. |

This is primarily a logical-lifetime example, rather than the classic example of two independently allocated slices inside a single large `malloc` block. A node can have its own backing allocation, while its lifetime as a client-owned node ends when it is returned to the cache. The allocator retains that storage and may use the same bytes as its own list metadata.

An invalid illustrative client sequence would be:

~~~c
void *p = FreeListAlloc(&fl);
FreeListFree(&fl, p);        /* may retain p's backing allocation */
/* client access through p is now logically invalid */
void *q = FreeListAlloc(&fl); /* may return the same address */
/* an old p must not acquire q's new logical lease merely by equality */
~~~

This is a specification example, not a sequence found in the verified `FuzzHttp` binary. Client access rights and allocator metadata rights must be distinguished; the allocator's permitted access to a cached node is not itself a use-after-free bug.

## Positive proof evidence

The inspected ASan proof is saved as [A0/AW/H_freelist.v](../source-snapshots/pupnp/proof/A0/AW/H_freelist.v). Its full pinned repository path is:

`proofs/pupnp/FuzzHttp/lib/A0/AW/H_freelist.v`

The contracts distinguish:

- `LB`: the list of underlying live backing blocks.
- `FB`: the cached free-list nodes.
- Block identity `k`, address `N`, and size 24 in a block tuple `(k, N, 24)`.
- `flseg`: the linked cached-node representation.
- `NoDup (map blk_id FB)`: uniqueness of cached backing identities.

The inspected specialization uses 24-byte nodes and a cache-limit field of 100. `fl_cells` at line 22 lays out the head pointer, element size, maximum cached length, and current cached length. The postconditions use a bound of 99 because the source caches when the incremented count is strictly below the configured maximum.

### Internal return is modeled explicitly

`FreeListFree_post_A`, lines 262–273, contains the two possible outcomes:

~~~coq
(LB' = LB /\ FB' = (k, N, 24) :: FB)
\/
(LB' = lbrm k LB /\ FB' = FB)
~~~

The first outcome caches the node while retaining its backing allocation. The second removes the backing allocation and leaves the cache unchanged. This is direct evidence that the proof represents internal release separately from system deallocation.

The same postcondition requires cached-node uniqueness at line 271. Its input contract `FreeListFree_stmt_A`, lines 275–290, requires at line 285:

~~~coq
In (k, N, 24) LB
...
NoDup (map blk_id ((k, N, 24) :: FB))
~~~

Consequently, returning an already cached node cannot satisfy that local contract. These are proof obligations and preserved facts, not a claim that the runtime allocator detects every misuse by arbitrary clients. The released end-to-end proof is about calls arising in its fixed harness.

### Destruction accounts for owned backing blocks

`FreeListDestroy_post_A`, lines 427–437, requires, among other facts:

~~~coq
(forall b, In b OWNED -> ~ In b LB')
rw_cells asegs m' FL (fl_cells 0 0)
~~~

This records removal of the specified owned blocks and an empty cache. It is positive cleanup evidence. It must not be inflated into general leak freedom for every pupnp API or every possible allocator client.

Supporting subset, uniqueness, and separation lemmas are preserved in [A0/AW/HObjA.v](../source-snapshots/pupnp/proof/A0/AW/HObjA.v). For example, `bsub_disjoint` derives disjointness of distinct represented backing blocks using the underlying allocator invariant.

## The concrete cached-reuse boundary

The inspected allocation contracts require a zero cache head. The ASan `FreeListAlloc_stmt_A` is at lines 222–236, with the following precondition at line 229:

~~~coq
rw_cells asegs m FL (fl_cells 0 fk)
~~~

The proof invokes the ordinary allocation contract for 24 bytes at lines 252–254. It covers the source's empty-cache branch.

The same restriction was independently checked in the other saved variants:

| Variant | Saved file | Relevant lines |
| --- | --- | --- |
| ASan | [A0/AW/H_freelist.v](../source-snapshots/pupnp/proof/A0/AW/H_freelist.v) | `FreeListAlloc_stmt_A` 222–236; head-zero precondition 229; malloc call 252–254 |
| ASan+UBSan | [B0/AW/H_freelist.v](../source-snapshots/pupnp/proof/B0/AW/H_freelist.v) | `FreeListAlloc_stmt_A` 230–244; head-zero precondition 237 |
| Plain binary support | [P0/H_freelist.v](../source-snapshots/pupnp/proof/P0/H_freelist.v) | Head-zero preconditions at 450 and 467 |

The exact theorem names of the plain-binary statements at those two locations were not separately recorded in the completed inspection; the saved source contains the surrounding declarations. Do not invent a theorem name.

**Supported conclusion:** these inspected allocation lemmas do not cover popping a node from a populated cache. They do not supply a contract that distinguishes the old client lease from a later lease of the same cached backing node.

**Unsupported inference:** the original verified client therefore contains a stale-node access, or its stated agreement theorem is false. Restricting an internal lemma to the states needed by the fixed caller can be entirely correct. A claim about all conceivable allocator clients would require a different theorem.

Do not infer absence of every possible reuse-related invariant in the entire repository from these selected lemmas. The paper's phrasing should remain tied to the inspected contracts and the lack of a demonstrated general lease theorem.

## Property assessment without overstating absence

| Concern | Evidence-supported assessment |
| --- | --- |
| Physical node allocation bounds | Backing block size and ownership are represented. These particular nodes are separately allocated rather than adjacent slices of one large pool. |
| Cached-node list integrity | `flseg`, subset relations, and cached identity uniqueness provide direct positive evidence. |
| Duplicate internal return | The `FreeListFree` contract requires the returned identity not to duplicate a cached one. This is not an ignored obligation. |
| Internal free versus standard free | Explicitly distinguished by the `LB/FB` postcondition. |
| Cleanup on destruction | Owned blocks are removed from `LB'`, and the cache is emptied. Scoped cleanup, not a library-wide leak theorem. |
| Use of a node after logical return | No general client-access-to-current-lease theorem was derived by this audit. Backing liveness alone would be insufficient, but other fixed-client invariants must also be considered. |
| Stale reference after cached reuse | The inspected allocation lemma does not cover nonempty-cache reuse; no generation-sensitive lease guarantee is supplied by that lemma. |
| Stale free of a later occupant | A general successive-lease theorem was not established. The existing backing identity/uniqueness facts should not be called completely absent ownership reasoning. |
| Shrinking or moving a custom allocation | `FreeList` has no custom realloc/shrink operation in the inspected source. Other pupnp buffers may use ordinary realloc; do not conflate them with this node-cache API. |
| Wrong-size or wrong-pool arbitrary frees | Not established as a general allocator-client theorem. The inspected proof is a 24-byte-node specialization, not all `FreeListInit` configurations. |
| Initialization, residual-data erasure, confidentiality | Not established by this selected audit. Do not interpret cached-node cleanup as a zeroization or noninterference guarantee. |
| Concurrent allocation/free | Outside the single-threaded verification model. No concurrency result follows. |

## Reproduction and open questions

The [source manifest](../source-snapshots/pupnp/manifest.json) records all seven saved files' pinned URLs, repository paths, byte counts, and SHA-256 hashes. The selected source bundle includes the upstream allocator/harness, the project manifest, and the four proof files named above. It is not the full proof corpus.

The next substantive proof task would be to specify a nonempty-cache allocation contract, assign a fresh logical lease when the node is returned to a client, and show that all relevant client accesses and frees respect that lease. A ghost-state proof could establish this without changing runtime data structures. Whether that work is needed for a particular client depends on which allocator histories the client can actually produce.

No full machine-access trace was reconstructed, no independent Rocq replay was performed, and no reachable violating input was obtained. The existing evidence supports a precise specification-boundary argument, not a vulnerability report.

