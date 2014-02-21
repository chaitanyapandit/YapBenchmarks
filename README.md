YapBenchmarks
=============

Yap Database Benchmarks Vs CoreData

```
Test results for inserting 10k objects:

Core Data:

iPhone:                  iPad:
21.096069 sec            16.128649 sec
20.831175 sec            15.810642 sec
20.161888 sec            15.962831 sec

YapDatabase on 2.4 branch (37af705719), with optimized cache size:

iPhone:                  iPad:
19.871475 sec            13.361987 sec
19.255095 sec            13.347013 sec
19.317682 sec            13.040845 sec
```