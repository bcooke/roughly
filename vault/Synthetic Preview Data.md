---
type: note
---

# Synthetic Preview Data

Synthetic result counts support interface exploration without representing real respondents. They need explicit labeling at the point of use and must remain separate from collected data and persistent response history.

The [preview catalog](../priv/preview/questions.json) supplies examples through the [Preview entry point](../lib/roughly/preview.ex). It does not seed fictional users or votes. Percentages derived from those counts illustrate presentation, not a population estimate or a validated participation method.

[Synthetic examples and real read models](Read%20Models.md) have different provenance even if their presentation is similar. [Polling Methodology](Polling%20Methodology.md) governs how readers interpret real data. Use [Project Status](../PROJECT_STATUS.md) for dated capabilities and limitations rather than treating a fixture as proof of implemented collection.
