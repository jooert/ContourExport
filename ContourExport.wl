(* ::Package:: *)

BeginPackage["ContourExport`"]
ContourExport::usage="Export background and contour lines of the passed ContourPlot to a PNG and a CSV file, respectively."
SampleStep::usage="SampleStep is an option for ContourExport which specifies the number of steps between contour line samples."
WriteTikz::usage="WriteTikz is an option for ContourExport that controls whether to write a TikZ picture to a file."
PrintColorbar::usage="PrintColorbar is an option for ContourExport that specifies whether to print the PgfPlots colorbar definitions."
Standalone::usage="Standalone is a setting for the WriteTikz option. It specifies that a standalone TikZ picture should be created."


Begin["`Private`"]


getSurface[Graphics[GraphicsComplex[v_,{d_,__}],___],size_,ar_]:=
	Rasterize[
		Graphics[GraphicsComplex[v,d],PlotRangePadding->None,AspectRatio->ar],
		"Image",
		ImageSize->size
	]


getLines[Graphics[GraphicsComplex[v_,{_,d_}],___]]:=Block[{l},
	l=d//.{{}->Nothing,Directive[__]->Nothing,Tooltip[e_,_]->e};
	Flatten[l]/.Line[c_]:>v[[c]]
]


getHeights[Graphics[GraphicsComplex[_,{_,d_}],___]]:=Reverse[d/.{Tooltip[_,v_]:>v,{}->Nothing}]


getColors[Graphics[GraphicsComplex[_,{d_,_}],___]]:=d[[All,2]]


exportLines[f_String,l:{{{_?NumericQ,_?NumericQ}..}..}]:=
	(
		WriteString[f,StringRiffle[ExportString[#,"CSV"]&/@l,"\n\n"]];
		Close[f]
	)


safeRange[max_,step_]:=DeleteDuplicates[Append[Range[1,max,step],max]]


decimate[step_][lis_]:=
	Table[
		Through[(Interpolation/@Transpose[lis])[x]],
		{x,safeRange[Length[lis],step]}
	]


formatColor[RGBColor[c__]]:=StringRiffle[Round[{c}*255],{"rgb255=(",",",")"}]


colorBarString[g:Graphics[GraphicsComplex[___],___]]:=Block[{h=getHeights[g]},
	StringTemplate["colormap={}{``},\ncolorbar style={\n  ytick={1,...,``},\n  yticklabels={``}\n},"]
		[StringRiffle[formatColor/@getColors[g],","],
		Length[h],
		StringRiffle[h,","]]
]


labelString[labels:{{_,_},{_,_}}]:=Block[{l=labels/.None->Nothing},
	StringRiffle[{
		If[Length[l[[2]]]==1,"xlabel = {$x$},",Nothing],
		If[Length[l[[1]]]==1,"ylabel = {$y$},",Nothing]},
		"\n"
	]
]


tikzString[fprefix_String,g:Graphics[GraphicsComplex[___],o_]]:=
Block[{r=PlotRange/.o,l=FrameLabel/.o,ls=labelString[l]},
	StringTemplate[
"\\begin{tikzpicture}
  \\begin{axis}[
      domain = <* #r[[1,1]] *>:<* #r[[1,2]] *>,
      y domain = <* #r[[2,1]] *>:<* #r[[2,2]] *>,`labels`
      minor tick num = 4,
      colorbar as palette,
      colorbar style={
        grid=major,
        grid style={black},
        ytick style={draw=none},
      },
      enlargelimits = false,
      axis on top,
      % Output from PrintColorbar
      `colorbar`
    ]

    % Colored background
    \\addplot graphics[xmin = <* #r[[1,1]] *>, xmax = <* #r[[1,2]] *>, ymin = <* #r[[2,1]] *>, ymax = <* #r[[2,2]] *>] {`fprefix`.png};
    % Contour lines
    \\addplot[mark=none] table[col sep=comma] {`fprefix`.csv};

  \\end{axis}
\\end{tikzpicture}\n"][
	<|"fprefix"->fprefix,
	  "colorbar"->StringReplace[colorBarString[g],"\n"->"\n      "],
	  "labels"->If[ls=="",ls,StringReplace["\n"<>ls,"\n"->"\n      "]],
	  "r"->r|>
	  ]
]


writeTikz[fprefix_String,g:Graphics[GraphicsComplex[___],_]]:=
Block[{f=fprefix<>".tex"},
	(
		WriteString[f,tikzString[fprefix,g]];
		Close[f]
	)
]


writeTikzStandalone[fprefix_String,g:Graphics[GraphicsComplex[___],_]]:=
Block[{f=fprefix<>".tex"},
	(
		WriteString[f,
"\\documentclass{standalone}
\\usepackage{pgfplots}

\\begin{document}\n"
<>tikzString[fprefix,g]<>
"\\end{document}\n"];
		Close[f]
	)
]


printColorbar[g:Graphics[GraphicsComplex[___],___]]:=
	Print[colorBarString[g]]


ContourExport[fprefix_String,g:Graphics[GraphicsComplex[___],___],OptionsPattern[]]:=
	(
		If[OptionValue[PrintColorbar],printColorbar[g]];
		{
			exportLines[fprefix<>".csv",decimate[OptionValue[SampleStep]]/@getLines[g]],
			Export[fprefix<>".png",getSurface[g,OptionValue[ImageSize],OptionValue[AspectRatio]],"CompressionLevel"->1],
			Switch[OptionValue[WriteTikz],True,writeTikz[fprefix,g],Standalone,writeTikzStandalone[fprefix,g],_,Nothing]
		}
	)
Options[ContourExport]={SampleStep->5,ImageSize->Automatic,AspectRatio->Automatic,WriteTikz->True,PrintColorbar->False}


End[]
EndPackage[]
