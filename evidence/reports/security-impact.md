# Security impact: documented allocator-related memory errors

## Purpose and conclusion

This is a **new targeted literature check requested by the user**, completed on 29 October 2026. It asks whether errors involving custom allocation can have serious security consequences and whether ordinary ASan can miss them. It adds no allocator audits and makes no vulnerability claim about the verified binaries in this evidence package. No exploit or sanitizer experiment was reproduced here.

**PHP CVE-2015-2787 is the strongest example found for the paper.** Primary sources separately establish a lifetime error, an arbitrary-code-execution exploit evaluation, and an ASan false negative with the allocator shim disabled. These are complementary findings from different evaluations. They must not be presented as one experiment on an identical binary.

## PHP CVE-2015-2787: lifetime error and security impact

### Original disclosure

Taoguang Chen reported [PHP security bug #68976](https://bugs.php.net/bug.php?id=68976), “Use After Free Vulnerability in unserialize(),” on **3 February 2015**. The report explains that an operation during `__wakeup()` can free a value and its children, while the deserializer still permits references to that freed memory. It attributes arbitrary code execution to the resulting use-after-free. The discussion addresses whether existing application classes can provide the necessary behavior, rather than requiring attacker-supplied PHP class definitions. Exploitability therefore depends on the application's deserialization path and available classes.

The tracker records the fix committed and the issue closed on **17 March 2015**. Relevant locations are the initial description, its explanation following the example, and the February 16 discussion. This is a lifetime error in allocator-managed objects, not evidence that the allocator implementation itself caused the original error.

Ubuntu's [USN-2572-1](https://ubuntu.com/security/notices/USN-2572-1), dated **20 April 2015**, independently lists CVE-2015-2787 under its “Details” section. It reports remote denial of service or possible arbitrary code execution. This advisory supports security impact; it does not establish an ASan limitation.

### Published exploit evaluation

Chanyoung Park and Hyungon Moon's **HushVac** paper, *Efficient Use-After-Free Prevention with Opportunistic Page-Level Sweeping* (NDSS 2024), evaluates public proof-of-concept exploits. **Table I lists PHP 5.5.14, CVE-2015-2787, use-after-free, and an original attack of arbitrary code execution.** Section VI.G says the protection prevents the evaluated exploits by preventing reuse of the vulnerable chunks.

Primary source: [HushVac paper](https://www.ndss-symposium.org/wp-content/uploads/2024-804-paper.pdf), **Table I and §VI.G, printed page 13 / PDF page index 12**. Reference [1] identifies PHP bug #68976. This is a published exploit-evaluation claim. We did not reproduce it, and the cited discussion does not specify an allocator configuration that can be equated with CMASan's experiment.

### Documented ASan false negative

The **CMASan** paper (IEEE S&P 2025) includes CVE-2015-2787 in **Table 4**, its collection of known custom-memory-allocator bugs. The row records a PHP use-after-free missed by ASan and detected by CMASan. **Section 5.5 states the decisive condition: the allocator shim is disabled in both configurations.** The paper also says that these known bugs are detectable through the shim.

Primary source: [CMASan paper](https://yonghwi-kwon.github.io/data/cmasan_sp25.pdf), **Table 4 and §5.5, PDF page index 10**. The introduction explains that a shim replaces custom allocation with standard allocation for testing. Consequently, the defensible claim is a false negative when testing the custom allocator without that shim. “ASan cannot detect this vulnerability” without the configuration qualification would be too broad.

### Suggested paper wording

> These gaps can have serious consequences. PHP's CVE-2015-2787 allowed deserialization to retain references to freed values. A later security study evaluated an arbitrary-code-execution exploit for this vulnerability. Separately, CMASan's evaluation found that ASan missed the same vulnerability when the allocator shim was disabled.

Cite the original PHP report, HushVac, and CMASan at the corresponding sentences. This wording preserves the distinction between security impact and sanitizer visibility. It does not identify an error in the verification corpus or claim that its harnesses reach this historical PHP behavior.

## Optional supporting cases

### Exim CVE-2018-6789: demonstrated RCE, no established ASan miss

[DEVCORE's original report](https://devco.re/blog/2018/03/06/exim-off-by-one-RCE-exploiting-CVE-2018-6789-en/), published **6 March 2018**, describes a one-byte overflow in a base64-decoding buffer obtained through Exim's custom `store_get()` interface. The researchers report developing a pre-authentication remote-code-execution exploit against Exim 4.88/4.89 with a relevant authentication configuration enabled. See “Vulnerability Analysis,” the opening of “Exploitation,” and “Memory allocation.” The report records disclosure on February 5 and patch release on February 10, 2018.

This is strong evidence of security impact involving custom allocation. **It is not evidence of an ASan false negative.** The documented exploit corrupts backing-heap metadata, so it should not be described as a purely intra-pool overflow invisible to ASan.

### ProFTPD CVE-2020-9273: potential post-authentication RCE

Antonio Morales's [GHSL-2020-009 advisory](https://securitylab.github.com/advisories/GHSL-2020-009-ProFTPD/) documents a use-after-free and memory-pool corruption. The “Impact” section reports potential post-authentication RCE; the demonstrated behavior includes a crash and out-of-bounds writes. **The reproduction explicitly produces an ASan trace.** Do not describe the complete published test as an ASan miss. The page is dated April 7, 2020; its disclosure timeline records public release on February 18, 2020.

The same researcher's [custom-interceptor tutorial](https://github.blog/security/vulnerability-research/fuzzing-sockets-apache-http-part-2-custom-interceptors/), published **30 March 2021**, explains an APR-style pool example where a suballocation overflow remains inside the backing allocation and triggers no ASan alert. See “Custom interceptors → Motivation.” It connects this class of problem to ProFTPD, but the tutorial's explanatory example and the advisory's observed crash remain distinct evidence.
