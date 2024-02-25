<div align="center"><a href="https://github.com/aclai-lab/Sole.jl"><img src="logo.png" alt="" title="This package is part of Sole.jl" width="200"></a></div>

# MultiData.jl – Multimodal datasets

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://aclai-lab.github.io/MultiData.jl)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aclai-lab.github.io/MultiData.jl/dev)
[![Build Status](https://api.cirrus-ci.com/github/aclai-lab/MultiData.jl.svg?branch=main)](https://cirrus-ci.com/github/aclai-lab/MultiData.jl)
[![Coverage](https://codecov.io/gh/aclai-lab/MultiData.jl/branch/main/graph/badge.svg?token=LT9IYIYNFI)](https://codecov.io/gh/aclai-lab/MultiData.jl)
<!-- [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/aclai-lab/MultiData.jl/HEAD?labpath=pluto-demo.jl) -->

<!-- [![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://aclai-lab.github.io/MultiData.jl/dev) -->

## In a nutshell

*MultiData* provides a **machine learning oriented** data layer on top of DataFrames.jl for:
- Instantiating and manipulating [*multimodal*](https://en.wikipedia.org/wiki/Multimodal_learning) datasets for (un)supervised machine learning;
- Describing datasets via basic statistical measures;
- Saving to/loading from *npy/npz* format, as well as a custom CSV-based format (with interesting features such as *lazy loading* of datasets);
- Performing basic data processing operations (e.g., windowing, moving average, etc.).

<!-- - Dealing with [*(non-)tabular* data](https://en.wikipedia.org/wiki/Unstructured_data) (e.g., graphs, images, time-series, etc.); -->
<!--
If you are used to dealing with unstructured/multimodal data, but cannot find the right
tools in Julia, you will find
[*SoleFeatures.jl*](https://github.com/aclai-lab/SoleFeatures.jl/) useful!
-->

## About

The package is developed by the [ACLAI Lab](https://aclai.unife.it/en/) @ University of
Ferrara.

*MultiData.jl* was originally built for representing multimodal datasets in
[*Sole.jl*](https://github.com/aclai-lab/Sole.jl), an open-source framework for
*symbolic machine learning*.
