# ContourExport
> Beautiful contour plots using Mathematica and TikZ

When you export a `ContourPlot` from Mathematica to a PDF file for inclusion in
another document it will by default export it as a vector graphics. This results
in good print quality at the cost of a huge file. Additionally, the font of text
elements in the plot might not match the font in your document. An alternative
is to export a rasterized version of your plot. This gives a lower file size but
you need a rather high resolution so lines, text and other vector elements do
not appear blurred on print. The font matching problem is not solved by this
either.

Wouldn't it be nice if you could simply export only parts of the plot (like axes
and text) as a vector graphics and only rasterize the rest? This Mathematica
package provides the command `ContourExport` that takes a `ContourPlot` and
exports the background to a PNG file while writing the contour lines to a CSV.
These files can then be combined using TikZ and plot elements like axes, ticks
and labels matching your document's style can be added at will.

## Installing

To install this package, download the [latest
tarball](https://github.com/jooert/ContourExport/tarball/master) and extract it.
Copy `ContourExport.wl` to the Mathematica Applications directory
(`~/.local/share/mathematica/Applications` on Linux). You can then load the
package in Mathematica using

``` mathematica
<< ContourExport`
```

or

``` mathematica
Needs["ContourExport`"]
```

## Using ContourExport

Let's suppose you have stored the result of `ContourPlot` in a variable named
`plot`. To export this plot you can use

``` mathematica
ContourExport["myplot", plot]
```

and three files will be written to your current directory:

  * `myplot.csv` contains points that describe the contour lines,
  * `myplot.png` contains an image of the regions between the contour lines,
  * `myplot.tex` contains a `tikzpicture` environment that draws the contour
    lines from `myplot.csv` on top of `myplot.png` and adds axes, labels (if
    your plot had ones) and a colorbar using PgfPlots.

You may pass the `ImageSize` as an option to `ContourExport` to set the
resolution of the PNG file. For example,

``` mathematica
ContourExport["myplot", plot, ImageSize -> 500]
```

will output a 500x500 image. Using `AspectRatio` as an option you can set the
aspect ratio (height/width) of the PNG file, e.g.

``` mathematica
ContourExport["myplot", plot, ImageSize -> 500, AspectRatio -> 2]
```

will output a 500x1000 image.

You can control the resolution of the contour lines using the `SampleStep`
option. A bigger value will output less points.

Using the `WriteTikz` option you can control the output of the `myplot.tex`
file:

  * `WriteTikz -> False` will disable writing a TeX file,
  * `WriteTikz -> True` outputs the TeX file with only a `tikzpicture`
    environment (default),
  * `WriteTikz -> Standalone` outputs the TeX file as a complete TeX document
    with the `standalone` documentclass.

When you use `PrintColorbar -> True` the `ContourExport` function will print the
part of the TeX file with the colorbar definition to your notebook. This might
be useful when you have manually added other graphical elements to the TeX file
and just want to tune the contour part. If the domain of the plot has not
changed it should be enough to just replace the colorbar definitions with the
output due to `PrintColorbar -> True`.

 You can find a working example in `example/randomsin.nb`.

## Contributing

If you find any bugs or want to propose some enhancement, feel free to send a
pull request.

## Licensing

The code in this project is licensed under the MIT license (see LICENSE).
