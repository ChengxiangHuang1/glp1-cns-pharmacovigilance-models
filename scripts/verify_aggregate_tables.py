#!/usr/bin/env python3
"""Verify the integrity of the released aggregate result TABLES only.

This does NOT refit models, access withheld grouped inputs, or validate any
upstream original-report processing. Python 3 standard library only.

Usage: python scripts/verify_aggregate_tables.py [path/to/repository]
"""
from __future__ import annotations
import csv
import sys
from collections import Counter
from decimal import Decimal, InvalidOperation
from pathlib import Path


def check(condition, message):
    if not condition:
        raise SystemExit('FAIL: ' + message)


def read_rows(path):
    check(path.is_file(), 'File not found: ' + str(path))
    with path.open('r', encoding='utf-8-sig', newline='') as fh:
        return list(csv.DictReader(fh))


def number(x, field):
    try:
        result = Decimal(str(x))
    except (InvalidOperation, ValueError):
        raise SystemExit('FAIL: Invalid numeric value in ' + field)
    check(result.is_finite(), 'Non-finite value in ' + field)
    return result


def yes(x):
    return str(x).strip().upper() in ('TRUE', '1')


def identity(row):
    return (row['database'], row['analysis_id'], row['method'])


def verify(root):
    est = read_rows(root / 'results' / 'model_estimates.csv')
    rep = read_rows(root / 'results' / 'model_replay_comparison.csv')
    check(len(est) == 67, 'Expected 67 Stage6M estimate/status records')
    check(len(rep) == 55, 'Expected 55 numeric replay records')
    expected_methods = {
        'standard_grouped_binomial_glm': 42,
        'bias_reduced_grouped_binomial_glm': 13,
        'none': 12,
    }
    check(Counter(x['method'] for x in est) == expected_methods,
          'Unexpected method-type distribution')
    key_est = [identity(x) for x in est]
    key_rep = [identity(x) for x in rep]
    check(len(key_est) == len(set(key_est)), 'Duplicate frozen model keys')
    check(len(key_rep) == len(set(key_rep)), 'Duplicate replay model keys')
    lookup = {identity(x): x for x in est}
    check(set(key_rep) == {k for k in key_est if k[2] != 'none'},
          'Replay keys must correspond exactly to 55 estimable records')
    check(Counter((r['database'], r['method']) for r in rep) == {
        ('FAERS/AERS', 'standard_grouped_binomial_glm'): 16,
        ('FAERS/AERS', 'bias_reduced_grouped_binomial_glm'): 1,
        ('JADER', 'standard_grouped_binomial_glm'): 10,
        ('JADER', 'bias_reduced_grouped_binomial_glm'): 6,
        ('Canada Vigilance', 'standard_grouped_binomial_glm'): 16,
        ('Canada Vigilance', 'bias_reduced_grouped_binomial_glm'): 6,
    }, 'Database by model-type counts differ')
    max_ror_diff = Decimal(0)
    max_se_diff = Decimal(0)
    for row in rep:
        key = identity(row)
        frozen = lookup[key]
        check(yes(row['comparison_pass']) and yes(row['converged']),
              'Missing success/convergence flag for ' + repr(key))
        model_ror = number(frozen['ROR'], 'ROR')
        model_se = number(frozen['standard_error'], 'standard_error')
        f_ror = number(row['frozen_ROR'], 'frozen_ROR')
        r_ror = number(row['independent_ROR'], 'independent_ROR')
        f_se = number(row['frozen_standard_error'], 'frozen_standard_error')
        r_se = number(row['independent_standard_error'], 'independent_standard_error')
        claimed_ror = number(row['ROR_absolute_difference'], 'ROR_absolute_difference')
        claimed_se = number(row['SE_absolute_difference'], 'SE_absolute_difference')
        check(abs(model_ror - f_ror) < Decimal('1e-9'),
              'Frozen ROR comparison mismatch: ' + repr(key))
        check(abs(model_se - f_se) < Decimal('1e-9'),
              'Frozen SE comparison mismatch: ' + repr(key))
        # Values in the CSV are rounded decimal representations of doubles.
        check(abs(abs(r_ror-f_ror)-claimed_ror) < Decimal('1e-9'),
              'Reported ROR difference mismatch: ' + repr(key))
        check(abs(abs(r_se-f_se)-claimed_se) < Decimal('1e-9'),
              'Reported SE difference mismatch: ' + repr(key))
        check(claimed_ror < Decimal('1e-6'), 'ROR tolerance failed: ' + repr(key))
        check(claimed_se < Decimal('1e-4'), 'SE tolerance failed: ' + repr(key))
        check(model_ror > 0 and model_se >= 0,
              'Invalid fitted ROR or standard error: ' + repr(key))
        check(number(frozen['CI_lower_95'], 'CI_lower_95') <= model_ror <=
              number(frozen['CI_upper_95'], 'CI_upper_95'),
              'Model ROR outside confidence interval: ' + repr(key))
        max_ror_diff = max(max_ror_diff, claimed_ror)
        max_se_diff = max(max_se_diff, claimed_se)
    for row in est:
        if row['method'] == 'none':
            check(not row['ROR'].strip() and not row['standard_error'].strip(),
                  'A no-estimate row has numeric values')
    print('PASS: 67 model/status rows, 55 replay rows, 42 standard, 13 bias-reduced, 12 no estimate')
    print('PASS: model keys, database counts, numerical differences, and model convergence flags')
    print('Maximum reported absolute ROR difference:', max_ror_diff)
    print('Maximum reported absolute SE difference:', max_se_diff)
    print('SCOPE: Aggregate table integrity ONLY; this does not rerun statistical models.')


if __name__ == '__main__':
    repo = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
    verify(repo.resolve())
