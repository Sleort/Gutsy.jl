# Gutsy.jl

[![Build Status](https://github.com/Sleort/Gutsy.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Sleort/Gutsy.jl/actions/workflows/CI.yml?query=branch%3Amain)

An attempt at (semi-)automatically tracking *in vitro* fish intestines in a video.

> [!WARNING]
> This package is **experimental** *and* **under development**. Expect functionality to not work perfectly (or at all) - contact me if you need help, have wishes/suggestions etc.

## Installation
In the Julia terminal ("REPL" - Read Eval Print Loop), type `]` to get to `pkg` ("package") mode, and then: 
```
pgk> add https://github.com/Sleort/Gutsy.jl
```
(If it ever evolves to becoming a registered package, you may get away with just `add Gutsy`. But that is currently not the case.)

## Usage:

* Mask seeding:
    * Mark blob by `shift` + left click
    * Mark outside blob by `shift` + right click
    * Delete single mark point by `shift`-clicking it again
    * Delete all marks by `D` + click
* Thickness tracing:
    1. Select region, mask, and "frame span"
    1. If you want, choose a "frame stride" (type the number and hit `Enter`). 
        * It is smart to start with a large stride and make sure that everything is okay, before you go "all in", as that may be computationally expensive/slow...
    1. When you are happy with the outcome, have a look at the examples in `src/playground.jl` to get a feel for how to proceed...
* FYI: Gutsy is built with the help of the wonderful visualization library [Makie](https://docs.makie.org/stable/). Check it out if you'd like to know more about how to create, tweak, and save plots.
