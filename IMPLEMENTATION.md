# Implementation Notes

## Label Width Handling

For the purpose of discussing this benchmark code, a _label_ is a a short text string describing a benchmark observation (which is implemented as an instance of class `Benchmark::Tms`). This label string is stored in the `Tms` instance.

The label _width_ can be specified to ensure that there is enough horizontal space to accommodate all the labels in the output. If it is not specified in a call to `bm`, then the output may be skewed:

```
       user     system      total        real
An operation  0.000004   0.000001   0.000005 (  0.000001)
Another operation  0.000001   0.000000   0.000001 (  0.000001)
```

However, `bmbm` manages to calculate maximum label width before printing any data, so the lines are all aligned correctly:

```
                     user     system      total        real
An operation        0.000002   0.000000   0.000002 (  0.000001)
Another operation   0.000001   0.000000   0.000001 (  0.000001)
```

