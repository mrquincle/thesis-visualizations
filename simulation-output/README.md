# Violin / boxplots

The data from the data.txt files can be extracted by the `extract.sh` file. Then you can plot the original plots by
the `plotbars.m` file. 

```
./extract.sh algorithm2-lines/twolines.pnts.Sun_Aug_30_00:27:55_2015.19391.data.txt fig_4.6a
```

To plot adjust the `plot_results` variable and run `octave-cli plotbars`. To plot in `R` go to `clustering_performance`
and plot using something like:

```
./visualize.R algorithm2 segment ../performance-output/stairs/fig_4.6a fig_4.6a
```
