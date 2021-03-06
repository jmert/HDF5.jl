################################
## Generic DataFile interface ##
################################
# This provides common methods that could be applicable to any
# interface for reading variables out of a file, e.g. HDF5,
# JLD, or MAT files. This is the super class of HDF5.File, HDF5.Group,
# JldFile, JldGroup, Matlabv5File, and MatlabHDF5File.
#
# Types inheriting from DataFile should have names, read, and write
# methods

abstract type DataFile end

# Convenience macros
macro read(fid, sym)
    if !isa(sym, Symbol)
        error("Second input to @read must be a symbol (i.e., a variable)")
    end
    esc(:($sym = read($fid, $(string(sym)))))
end
macro write(fid, sym)
    if !isa(sym, Symbol)
        error("Second input to @write must be a symbol (i.e., a variable)")
    end
    esc(:(write($fid, $(string(sym)), $sym)))
end

# Read a list of variables, read(parent, "A", "B", "x", ...)
Base.read(parent::DataFile, name::AbstractString...) =
	tuple([read(parent, x) for x in name]...)

# Read one or more variables and pass them to a function. This is
# convenient for avoiding type inference pitfalls with the usual
# read syntax.
Base.read(f::Base.Callable, parent::DataFile, name::AbstractString...) =
	f(read(parent, name...)...)

# Read every variable in the file
function Base.read(f::DataFile)
    vars = keys(f)
    vals = Vector{Any}(undef,length(vars))
    for i = 1:length(vars)
        vals[i] = read(f, vars[i])
    end
    Dict(zip(vars, vals))
end
