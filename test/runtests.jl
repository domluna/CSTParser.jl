using Parser
import Parser: remlineinfo!
include("parser.jl")

const examplemodule = readstring("fullspecexample.jl")

function timeParser(n)
    for i =1:n
        Parser.parse(examplemodule)
    end
end

function timeBase(n)
    for i =1:n
        Base.parse(examplemodule)
    end
end

function timeTokenize(n)
    for i =1:n
        collect(Tokenize.tokenize(examplemodule))
    end
end

# using BenchmarkTools

timeParser(1)
timeBase(1)
timeTokenize(1)
tp = @elapsed timeParser(500)
tb = @elapsed timeBase(500)
tt = @elapsed timeTokenize(500)
println(tb/tp)


if VERSION.major <=6 && VERSION.prerelease[1] == "dev" && VERSION.prerelease[2]<=2084
    p = joinpath(dirname(dirname(Base.functionloc(Base.eval, Tuple{Void})[1])),"base")
    N = 0
    nF = 0
    failed  =[]
    wontparse = []
    @time for f in readdir(p)
        str = readstring(joinpath(p,f))
        ps = ParseState(str)
        try
            next(ps)
            while ps.nt.kind != Tokenize.Tokens.ENDMARKER 
                x = Expr(parse_expression(ps))
            end
            # failed, cnt = check_file(joinpath(p,f))
            # N+=cnt
            # nF += length(failed)
            # append!(allfailed, failed)
        catch
            push!(wontparse, f)
        end
        if ps.errored
            push!(wontparse, f)
        end
    end
    println("These files failed to parse: ")
    for f in wontparse
        println("    ", f)
    end
    println("failed to parse: $(length(wontparse))")
   
end
