\name{addCore}
\alias{addCore}
\title{
Add a raster representing a core area to a \code{JAGSmask} object
}
\description{
Often we are interested in a core area which is smaller than the full extent of the habitat. This function enables you to define a core area and add the corresponding raster to the \code{JAGSmask} object.
}
\usage{
addCore(JAGSmask, type = c("perimeter", "traps", "polygon"),
    buffer = 0, poly=NULL, cell.overlap = c("centre", "any", "all"), plot=TRUE)
}
\arguments{
  \item{JAGSmask}{
The object of class \code{JAGSmask} as produced by \code{\link{convertMask}}.
}
  \item{type}{
The basis for the core area: \code{polygon} - uses the polygon given in \code{poly}; \code{traps} - includes all habitat pixels within distance \code{buffer} of a trap; \code{perimeter} - draws a minimum convex polygon around the traps and uses that as the polygon.
}
  \item{buffer}{
If \code{buffer > 0}, the a buffer of this width is added to the polygon.
}
  \item{poly}{
Bounding polygon for the core area; only used if type is \code{poly}; can be (1) a matrix or data frame of two columns interpreted as x and y coordinates, or (2) a SpatialPolygons or SpatialPolygonsDataFrame object as defined in the package \code{sp}.
}
  \item{cell.overlap}{
The criterion for including a pixel in the raster: \code{centre} - include if the centre of the pixel falls in the core; \code{any} - include if any corner of the pixel falls in the core; \code{all} - include if all four corners of the pixel fall in the core.
}
  \item{plot}{
If TRUE, the resulting mask and trap locations will be plotted (not yet implemented).
}
}
\value{
The original \code{JAGSmask} object supplied as input, with an additional component \code{coreMat}, a 1/0 matrix where \code{coreMat[x, y] = 1} if location (x, y) is in the core.

Note that the core only includes good habitat: pixels for which \code{habMat[x,y] == 0} will also be 0 in \code{coreMat}.
}
\author{
Mike Meredith
}

\seealso{
\code{\link{convertMask}}
}
\examples{
data(exampleData)
secrmask <- secr::make.mask(traps, spacing=2000, type="polygon", poly=patch,
  cell.overlap="any")
mymask <- convertMask(secrmask, traps, plot=TRUE)

# add a core extending 2000m beyond the perimeter of the trap array:
newmask <- addCore(mymask, type="perimeter", buffer=2000)

# Part of the reserve is in Arkadia state and we want the population
#   inside Arkadia, so we use Arkadia as the "core":
Arkadia <- cbind(x=c(140000, 140000, 200000, 200000),
  y=c(50000,805000, 805000, 50000))
Arkadiamask <- addCore(mymask, type="poly", poly=Arkadia)

# How many animals in the core area?
# ACs are on the pixel scale, so use 'floor' to get indices into
#    the coreMat matrix
index <- floor(JAGSoutput)
# Which ACs are in the core area?
inCore <- array(NA, dim(JAGSoutput)[1:2])
for(i in 1:ncol(inCore))
  inCore[, i] <- Arkadiamask$coreMat[index[, i, ]]
# 1 = AC is inside core, 0 = outside, NA = non-existent

# Look at individual animals:
( existInCore <- colSums(inCore, na.rm=TRUE)/nrow(inCore) )
# Animal #1 (almost certainly), #2 and #4 have ACs inside Arkadia,
#   #3 and #5 are outside. 
# Estimated number of ACs in the core:
sum(existInCore)

# Get a posterior distribution for number of ACs in the state:
Ncore <- rowSums(inCore, na.rm=TRUE)
mean(Ncore)
plot(table(Ncore)/nrow(inCore),
  ylab="Probability", xlab="Number of animals with ACs in Arkadia state")
}