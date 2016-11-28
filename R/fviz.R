#' @include utilities.R
NULL
#' Visualizing Multivariate Analyse Outputs
#' @description Generic function to create a scatter plot of multivariate analyse outputs, including PCA, CA, MCA and MFA.
#' @inheritParams facto_summarize
#' @param geom a text specifying the geometry to be used for the graph. Default value is "auto". Allowed 
#'   values are the combination of c("point", "arrow", "text"). Use "point" (to 
#'   show only points); "text" to show only labels; c("point", "text") or 
#'   c("arrow", "text") to show both types.
#' @param label a text specifying the elements to be labelled. Default value is 
#'   "all". Allowed values are "none" or the combination of c("ind", "ind.sup", 
#'   "quali", "var", "quanti.sup"). "ind" can be used to label only active 
#'   individuals. "ind.sup" is for supplementary individuals. "quali" is for 
#'   supplementary qualitative variables. "var" is for active variables. 
#'   "quanti.sup" is for quantitative supplementary variables.
#' @param invisible a text specifying the elements to be hidden on the plot. 
#'   Default value is "none". Allowed values are the combination of c("ind", 
#'   "ind.sup", "quali", "var", "quanti.sup").
#' @param labelsize font size for the labels
#' @param pointsize the size of points
#' @param pointshape the shape of points
#' @param title the title of the graph
#' @param repel a boolean, whether to use ggrepel to avoid overplotting text 
#'   labels or not.
#' @param habillage an optional factor variable for coloring the observations by
#'   groups. Default value is "none". If X is a PCA object from FactoMineR 
#'   package, habillage can also specify the supplementary qualitative variable 
#'   (by its index or name) to be used for coloring individuals by groups (see 
#'   ?PCA in FactoMineR).
#' @param addEllipses logical value. If TRUE, draws ellipses around the 
#'   individuals when habillage != "none".
#' @param ellipse.level the size of the concentration ellipse in normal 
#'   probability.
#' @param ellipse.type Character specifying frame type. Possible values are 
#'   'convex' or types supporeted by \code{\link[ggplot2]{stat_ellipse}} 
#'   including one of c("t", "norm", "euclid").
#' @param ellipse.alpha Alpha for ellipse specifying the transparency level of 
#'   fill color. Use alpha = 0 for no fill color.
#' @param col.circle a color for the correlation circle. Used only when X is a PCA output.
#' @param axes.linetype linetype of x and y axes.
#' @param color color to be used for the specified geometries (point, text). 
#'   Possible values include also : "cos2", "contrib", "coord", "x" or "y". In 
#'   this case, the colors for individuals/variables are automatically 
#'   controlled by their qualities of representation ("cos2"), contributions 
#'   ("contrib"), coordinates (x^2+y^2, "coord"), x values ("x") or y values 
#'   ("y"). To use automatic coloring (by cos2, contrib, ....), make sure that 
#'   habillage ="none".
#' @param alpha controls the transparency of individual and 
#'   variable colors, respectively. The value can variate from 0 (total 
#'   transparency) to 1 (no transparency). Default value is 1. Possible values 
#'   include also : "cos2", "contrib", "coord", "x" or "y". In this case, the 
#'   transparency for the individual/variable colors are automatically 
#'   controlled by their qualities ("cos2"), contributions ("contrib"), 
#'   coordinates (x^2+y^2, "coord"), x values("x") or y values("y"). To use 
#'   this, make sure that habillage ="none".
#'@param col.col.sup,col.row.sup colors for the supplementary column and row 
#'  points, respectively.
#' @param select a selection of individuals/variables to be 
#'   drawn. Allowed values are NULL or a list containing the arguments name, 
#'   cos2 or contrib: \itemize{ \item name: is a character vector containing 
#'   individuals/variables to be drawn \item cos2: if cos2 is in [0, 1], ex: 
#'   0.6, then individuals/variables with a cos2 > 0.6 are drawn. if cos2 > 1, 
#'   ex: 5, then the top 5 individuals/variables with the highest cos2 are 
#'   drawn. \item contrib: if contrib > 1, ex: 5,  then the top 5 
#'   individuals/variables with the highest contrib are drawn }
#' @inheritParams ggpubr::ggpar
#' @param ... Arguments to be passed to the functions ggpubr::ggscatter() & ggpubr::ggpar().
#'   
#' @return a ggplot
#' @author Alboukadel Kassambara \email{alboukadel.kassambara@@gmail.com}
#' 
#' @rdname fviz
#' @examples
#' \donttest{
#' # Principal component analysis
#' # +++++++++++++++++++++++++++++
#' data(decathlon2)
#' decathlon2.active <- decathlon2[1:23, 1:10]
#' res.pca <- prcomp(decathlon2.active,  scale = TRUE)
#' fviz(res.pca, "ind") # Individuals plot
#' fviz(res.pca, "var") # Variables plot
#' 
#' # Correspondence Analysis
#' # ++++++++++++++++++++++++++
#' # Install and load FactoMineR to compute CA
#' # install.packages("FactoMineR")
#' library("FactoMineR")
#' data("housetasks")
#' res.ca <- CA(housetasks, graph = FALSE)
#' fviz(res.ca, "row") # Rows plot
#' fviz(res.ca, "col") # Columns plot
#' 
#' # Multiple Correspondence Analysis
#' # +++++++++++++++++++++++++++++++++
#' library(FactoMineR)
#' data(poison)
#' res.mca <- MCA(poison, quanti.sup = 1:2, 
#'               quali.sup = 3:4, graph=FALSE)
#'               
#' fviz(res.mca, "ind") # Individuals plot
#' fviz(res.mca, "var") # Variables plot
#' 
#'  }
#' @export
fviz <- function(X, element, axes = c(1, 2), geom = "auto",
                          label = "all", invisible="none", labelsize=4, 
                          pointsize = 1.5, pointshape = 19,
                          habillage="none", addEllipses=FALSE, ellipse.level = 0.95, 
                          ellipse.type = "norm", ellipse.alpha = 0.1,
                          color = "black", alpha = 1, gradient.cols = NULL,
                          col.row.sup = "darkblue", col.col.sup="darkred",
                          select = list(name = NULL, cos2 = NULL, contrib = NULL),
                          title = NULL, axes.linetype = "dashed",
                          repel = FALSE, col.circle ="grey70", ggtheme = theme_gray(),
                           ...)
  {
  
  .check_axes(axes, .length = 2)
  facto.class <- .get_facto_class(X)
  # Deprecated arguments: jitter
  extra_args <- list(...)
  if(!is.null(extra_args$jitter)) repel <- .facto_dep("jitter", "repel", TRUE)
  # Elements to be labelled or hidden
  lab <- .label(label)
  hide <- .hide(invisible)
  
  # Define parameters
  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  # Define title if NULL
  if(is.null(title)){
    element_desc <- list(ind = "Individuals", var = "Variables",
                         col = "Column points", row = "Row points",
                         mca.cor = "Variables", quanti.sup = "Quantitative variables")
    if(facto.class == "MCA") element_desc$var <- "Variable categories"
    title <- paste0(element_desc[[element]], " - ", facto.class)
  }
  # Define geometry if auto
  if(geom[1] == "auto"){
    geom <- c("point", "text")
    if(element == "var" & facto.class == "PCA") geom <- c("arrow", "text")
  }
  # Define color if missing
  if(facto.class %in% c("CA", "MCA")){
    if(element %in% c("row", "ind") & missing(color)) color = "blue"
    else if(element %in% c("col", "var", "mca.cor") & missing(color)) color = "red"
  }

  # Data preparation
  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  # Data frame to be used for plotting
  df <- facto_summarize(X, element = element, axes = axes,
                         result = c("coord", "contrib", "cos2"))
  colnames(df)[2:3] <-  c("x", "y")
  # augment data, if qualitative variable is used to color points by groups
  if(!("none" %in% habillage)){
    dd <- .add_ind_groups(X, df, habillage)
    df <- dd$ind
    color <- dd$name.quali
    if(missing(pointshape)) pointshape <- dd$name.quali
  }
  # Selection
  df.all <- df
  if(!is.null(select)) df <- .select(df, select)
  
  # Special cases: data transformation
  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  # Used by fviz_pca_biplot() only:  Multiply the variables data by scale. before biplotting
  if(facto.class == "PCA" & element == "var" & !is.null(extra_args$scale.) )
    df[, c("x", "y")] <- df[, c("x", "y")]*extra_args$scale.
  # (M)CA: scale coords according to the type of map
  if(facto.class %in% c("CA", "MCA") & !(element %in% c("mca.cor", "quanti.sup"))){
  if(!is.null(extra_args$map)) df <- .scale_ca(df, res.ca = X,  element = element, 
                                               type = extra_args$map, axes = axes)
  }
  # Main plot
  #%%%%%%%%%%%%%%%%%%%
  point <- ("point" %in% geom) & (!hide[[element]]) # to show points, should be TRUE
  mean.point <- (!("none" %in% habillage)) & ("point" %in% geom) & (!hide[["quali"]]) # to show mean point
  
  label <- NULL
  if(lab[[element]] & "text" %in% geom & !hide[[element]]) label <- "name"
  
  p <- ggplot() 
  if(hide[[element]]) p <-ggplot()+geom_blank(data = df, aes_string("x","y"))
  else p <- ggpubr::ggscatter(data = df, x = "x", y = "y",
                         color = color, alpha = alpha, shape = pointshape, 
                         point = point, size = pointsize, mean.point = mean.point,
                         label = label, font.label = labelsize*3, repel = repel,
                         ellipse = addEllipses, ellipse.type = ellipse.type,
                         ellipse.alpha = ellipse.alpha, ellipse.level = ellipse.level,
                         main = title, ggtheme = ggtheme, ...)
  if(alpha %in% c("cos2","contrib", "coord", "x", "y"))
    p <- p + scale_alpha(limits = range(df.all[, alpha]))
  if(!is.null(gradient.cols) & color %in% c("cos2","contrib", "coord", "x", "y"))
    p <- p + ggpubr:::.gradient_col(gradient.cols)
  if(is.null(extra_args$legend)) p <- p + theme(legend.position = "right" )
  # Add arrows
  if("arrow" %in% geom & !hide[[element]]) 
    p <- p + .arrows(data = df, color = color, alpha = alpha)
  # Add correlation circle if PCA & element = "var" & scale = TRUE
  if(facto.class == "PCA" & element == "var"){
    if(.get_scale_unit(X) & is.null(extra_args$scale.)) 
      p <- .add_corr_circle(p, color = col.circle)
  }
  else if(facto.class == "MCA" & element == "quanti.sup"){
      p <- .add_corr_circle(p, color = col.circle)
  }
  # Faceting when multiple variables are used to color individuals
  # (e.g., habillage = 1:2, or data.frame)
  # in this case there is a column "facet_vars" in df
  if("facet_vars" %in% colnames(df)){
    groups <- c("facet_vars", "Groups")
    xx <- ggpubr::desc_statby(df, measure.var = "x", grps = groups)[, c(groups, "mean")]
    colnames(xx)[ncol(xx)] <- "x"
    yy <- ggpubr::desc_statby(df, measure.var = "y", grps = groups)[, c(groups, "mean")]
    xx$y <- yy$mean
    grp_coord <- xx
   
    p <- p+ggpubr::geom_exec(geom_text, data = grp_coord, x = "x", y = "y",
                             label = "Groups", color = color) 
    p <- p + facet_wrap(~facet_vars) + theme(legend.position = "none") 
  }
  
  # Supplementary elements: available only for FactoMineR
  #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  scale. <- ifelse(is.null(extra_args$scale.), 1, extra_args$scale.)
  esup <- .define_element_sup(X, element, geom = geom, lab = lab, hide = hide,
                              col.row.sup = col.row.sup, col.col.sup = col.col.sup,...) 
  ca_map = extra_args$map
  if(element == "mca.cor") ca_map = NULL
  
  if(!is.null(esup)) p <- .add_supp (p, X, element = esup$name, axes = axes, select = select,
                                geom = geom, color = esup$color, shape = esup$shape, pointsize = pointsize,
                                labelsize = labelsize, addlabel = esup$addlabel, repel = repel, linetype = 2,
                                scale. = scale., ca_map = ca_map)
  
  
  p <- .fviz_finish(p, X, axes, axes.linetype, ...) +
    labs(title = title) 
  
  p
}


#+++++++++++++++++++++
# Helper functions
#+++++++++++++++++++++

# X : an object of class PCA, princomp, prcomp, dudi
# Return TRUE if the data are scaled to unit variance
.get_scale_unit <-function(X){
  scale_unit <- FALSE
  if(inherits(X, 'PCA')) scale_unit <- X$call$scale.unit
  else if(inherits(X, "prcomp" )) scale_unit <- is.numeric(X$scale) 
  else if(inherits(X, "princomp")) scale_unit <- length(unique(X$scale))>1 
  else if(inherits(X, 'pca') & inherits(X, 'dudi')) scale_unit <- length(unique(X$norm))>1 
  else {
    warning(".get_scale_unit function: can't handle an object of class ",
            class(X))
  }
  scale_unit
}

# Add correlation circle to variables plot
.add_corr_circle <- function(p, color = "grey70"){
  theta <- c(seq(-pi, pi, length = 50), seq(pi, -pi, length = 50))
  circle <- data.frame(xcircle = cos(theta), ycircle = sin(theta))
  p + 
    geom_path(mapping = aes_string("xcircle", "ycircle"), data = circle, color = color)
  
}

# Add arrow to the plot
.arrows <- function(data, color = "black", alpha = 1, 
                    origin = 0, xend = "x", yend = "y"){
  origin <- rep(origin, nrow(data))
  dd <- cbind.data.frame(data, xstart = origin, ystart = origin)
  ggpubr::geom_exec(geom_segment, data = dd, 
                    x = "xstart", y = "ystart", xend = xend, yend = yend,
                    arrow = grid::arrow(length = grid::unit(0.2, 'cm')),
                    color = color, alpha = alpha)
}



# Define element sup if any
# lab,hide: element to be labelled or hidden as returned by .hide() and .label()
.define_element_sup <- function(X, element, geom, lab, hide,
                                col.row.sup = "darkblue", col.col.sup = "darkred", 
                                 ...){
  
  extra_args <- list(...)
  shape.sup <- ifelse(is.null(extra_args$shape.sup), 19, extra_args$shape.sup)
  res <- NULL
  # Supplementary individuals
  if(element == "ind" & inherits(X, c('PCA', "MCA")) & !hide$ind.sup) {
    res <- list(name = "ind.sup", color = col.row.sup, shape = shape.sup,
                addlabel = (lab$ind.sup & "text" %in% geom))
  }
  # Supplementary quantitative variables
  else if(element == "var" & inherits(X, 'PCA') & !hide$quanti){
    res <- list(name = "quanti", color = col.col.sup, shape = shape.sup, 
                addlabel = (lab$quanti & "text" %in% geom))
  }
  else if(element == "mca.cor" & inherits(X, 'MCA') & !hide$quanti){
    res <- list(name = c("quanti.sup", "quali.sup$eta2"), color = col.col.sup, shape = shape.sup, 
                addlabel = (lab$quanti & "text" %in% geom))
  }
  else if(element %in% "var" & inherits(X, 'MCA') & !hide$quali.sup){
    res <- list(name = "quali.sup", color = col.col.sup, shape = shape.sup, 
                addlabel = (lab$quali.sup & "text" %in% geom))
  }
  # Supplementary rows
  else if(element == "row" & inherits(X, c('CA', 'ca')) & !hide$row.sup){
    res <- list(name = "row.sup", color = col.row.sup, shape = shape.sup,
                addlabel = (lab$row.sup & "text" %in% geom))
  }
  # Supplementary cols
  else if(element == "col" & inherits(X, c('CA', 'ca')) & !hide$row.sup){
    res <- list(name = "col.sup", color = col.col.sup, shape = shape.sup,
                addlabel = (lab$col.sup & "text" %in% geom))
  }
  res
}
