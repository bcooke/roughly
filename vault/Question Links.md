---
type: note
---

# Question Links

Question links give a prompt and its context a stable address. The question route is `/questions/:slug`; `#results` points to its breakdown and `#methodology` to the result-counting explanation. The [web router](../lib/roughly_web/router.ex) and [question template](../lib/roughly_web/live/question_live.html.heex) define the implemented route and anchors.

A live result link is not an immutable citation of a historical result. Any published claim needs its sample context; [Development Fixtures](Development%20Fixtures.md) cannot support a real-world claim.

Sharing also creates prior exposure that a collection design must consider under [Results Exposure](Results%20Exposure.md). Versioned citations and writing integrations belong in work proposals until their contracts are defined, with [Polling Methodology](Polling%20Methodology.md) constraining interpretation.

The [open API and dataset release idea](discovery/ideas/open-api-and-dataset-releases.md) extends reuse beyond the website. Stable identifiers, explicit method definitions, and versioned snapshots would let downstream readers distinguish a changing result from the evidence behind a particular claim. These publication contracts remain to be designed.
