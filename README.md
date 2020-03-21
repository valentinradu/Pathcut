Pathcut
======


Pathcut adds `intersect` to `CGPath`, a function that returns the subpaths emerging from the intersection of two `CGPaths`.
It uses a mixed approach: for lines and quadric curves it analytically solves the intersections and for cubic curves it uses an aproximation algorithm.


```
let result = path.intersect(with: otherPath)
// result is an array of CGPaths
```


