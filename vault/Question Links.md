---
type: note
---

# Question Links

Question links give a prompt and its context a stable address. The question route is `/questions/:slug`; `#results` points to its breakdown and `#methodology` to the result-counting explanation. The [web router](../lib/roughly_web/router.ex) and [question template](../lib/roughly_web/live/question_live.html.heex) define the implemented route and anchors.

A live result link is not an immutable citation of a historical result. Any published claim needs its sample context; [Development Fixtures](Development%20Fixtures.md) cannot support a real-world claim.

Sharing also creates prior exposure that a collection design must consider under [Results Exposure](Results%20Exposure.md). Versioned citations and writing integrations belong in work proposals until their contracts are defined, with [Polling Methodology](Polling%20Methodology.md) constraining interpretation.

The [open API and dataset release idea](discovery/ideas/open-api-and-dataset-releases.md) extends reuse beyond the website. Stable identifiers, explicit method definitions, and versioned snapshots would let downstream readers distinguish a changing result from the evidence behind a particular claim. These publication contracts remain to be designed.


Public slugs describe the question; internal instrument UUIDs remain separate. [Route claims](../lib/roughly/questions/slugs.ex) reserve a name before publication. Only a real collision adds a numbered suffix, such as `do-you-like-coffee-2`. Claims serialize per actual route, including collisions with a naturally numbered prompt, rather than relying on a lagging read-model uniqueness check. A reserved route whose publication fails remains reserved; recovery can retry the same instrument identity.

[Answer Discovery](Answer%20Discovery.md) defines readable option-specific routes and canonical metadata. [Response History](Response%20History.md) and [Population Analysis](Population%20Analysis.md) define shareable live exploration state; none of these views constitutes an immutable evidence release.

Closing collection preserves the question and answer evidence addresses. Active browsing can omit closed instruments while direct reads and the sitemap retain them; collection admission remains closed.
