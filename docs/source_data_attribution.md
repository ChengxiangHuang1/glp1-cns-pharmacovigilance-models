# Regulatory-source attribution and dataset terms

The study is based on independent analyses of publicly available, de-identified
pharmacovigilance material from **FDA FAERS/AERS (United States)**,
**PMDA Japanese Adverse Drug Event Report database (JADER, Japan)**,
and **Health Canada Canada Vigilance (Canada)**.

The two `results/*.csv` files contain the authors' derived model estimates,
uncertainty measures, status labels and numerical replay comparisons. They do
**not** include regulator report identifiers, source case records, quarterly
numerator/denominator cells, or regulated terminology files. They are not a
reconstruction of the regulators' databases.

## FDA FAERS/AERS

- FDA's original quarterly FAERS/AERS files are documented at:
  https://www.fda.gov/drugs/fda-adverse-event-reporting-system-faers/fda-adverse-event-reporting-system-faers-latest-quarterly-data-files
- FDA publishes an openFDA data-licensing policy:
  https://open.fda.gov/license/
- **Do not automatically extend openFDA's CC0 statement to every component
  of historical FDA quarterly files or to third-party terminology:** the
  FDA terms explicitly note possible third-party copyrighted content.
- Source attribution: derived statistical analyses using publicly
  available U.S. FDA FAERS/AERS data; not FDA analyses or endorsements.

## PMDA JADER

- Database-specific user terms:
  https://www.pmda.go.jp/safety/info-services/drugs/adr-info/suspected-adr/0003.html
- JADER download information:
  https://www.pmda.go.jp/safety/info-services/drugs/adr-info/suspected-adr/0004.html
- PMDA's database-specific terms require explicit attribution to the
  **Japanese Adverse Drug Event Report database (JADER)** in publications,
  respect for intellectual-property rights and compliance with database
  conditions. Its copyright section reserves underlying database rights.
- The agency's general website policy has a Public Data License default,
  but this does **not** displace these separate JADER database terms.
- This archive does not distribute JADER underlying case CSVs or the
  restricted JADER derived quarter-level input cells.
- Attribution: Independent analysis using the Japanese Adverse Drug Event
  Report database (JADER), provided by PMDA. Not authored or endorsed by PMDA.

## Health Canada Canada Vigilance

- Official open-data catalogue entry:
  https://open.canada.ca/data/en/dataset/9cbaef00-b52c-4a70-9fed-d9aa8263ab74
- **Licence:** Open Government Licence – Canada:
  https://open.canada.ca/en/open-government-licence-canada
- Required source statement when applicable:
  **"Contains information licensed under the Open Government Licence – Canada."**
- The Canadian licence allows reuse subject to attribution, exclusions
  for personal information and third-party rights, and non-endorsement.
  Source-specific Canada Vigilance interpretive limitations must also
  be respected:
  https://www.canada.ca/en/health-canada/services/drugs-health-products/medeffect-canada/adverse-reaction-database/medeffect-canada-caveat-privacy-statement-interpretation-data-search-canada-vigilance-adverse-reaction-online-database.html
- The archive does not distribute original Canadian case records or
  the withheld low-cell quarterly grouped inputs.

## Other rights and analytic cautions

MedDRA and other third-party terminology assets are not released.
No regulatory agency reviewed or endorsed these model outputs.
Spontaneous reports cannot establish incidence, clinical risk, or
causality; these are reporting-association statistics only.

**Publication decision:** The official source policies reviewed here do
not establish a blanket prohibition on separately derived, non-identifying
model estimates with proper attribution. They also do **not** by themselves
certify local institutional permission, source-data licensing of every
historical input component, or the right to apply an unrestricted licence
to third-party material. Regulatory-source rights must still be respected and the two CSVs require
file-specific reuse metadata before public deposit.
