# Computation environment

Historical successful runs:

- Windows 11 x64
- R 4.6.0
- `brglm2` 1.1.0 for mean-bias-reduced fits
- `data.table` 1.18.4, `Matrix` 1.7-5, `digest` 0.6.39 recorded in historical workflow

The replay scripts primarily use base R (`stats`, `utils`, `tools`); bias-reduced replay requires `brglm2` version 1.1.0. The scripts do not install packages. They verify inputs by MD5 and byte length and write outputs to a new directory, leaving supplied input files unchanged.

Dependency versions alone are not proof of reproduction across platforms. An independent external-environment test is recommended before describing a published package as widely portable.
