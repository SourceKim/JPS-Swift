# JPS-Swift
JPS (Jump Point Search) 算法 的 Swift 版实现

环境：Swift 5.1
依赖：无

## 效果：

给定一个地图：

```
=========
0 0 0 1 0 0 0 
0 0 0 1 0 0 0 
0 0 0 0 0 0 0 
0 0 0 1 0 0 0 
0 0 0 1 0 0 0 
0 0 0 1 0 0 0 
0 0 0 1 0 0 0 
=========
```

输出路径：

```
=========
0 0 0 1 0 9 9 
0 0 0 1 9 0 0 
0 0 0 9 0 0 0 
0 0 9 1 0 0 0 
0 0 9 1 0 0 0 
0 9 0 1 0 0 0 
9 0 0 1 0 0 0 
=========
```

## 简述：

以  `[[Int]]` 来存放地图，通过 `jps` 算法，找到路径（以 `[(Int, Int)]` 存放）
