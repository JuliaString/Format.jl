# core formatting functions

### auxiliary functions

### print char n times

function _repprint(out::IO, c::AbstractChar, n::Int)
    while n > 0
        print(out, c)
        n -= 1
    end
end


### print string or char

function _pfmt_s(out::IO, fs::FormatSpec, s::Union{AbstractString,AbstractChar})
    pad = fs.width - length(s)
    if pad <= 0
        print(out, s)
    elseif fs.align == '<'
        print(out, s)
        _repprint(out, fs.fill, pad)
    elseif fs.align == '^'
        _repprint(out, fs.fill, pad>>1)
        print(out, s)
        _repprint(out, fs.fill, (pad+1)>>1)
    else
        _repprint(out, fs.fill, pad)
        print(out, s)
    end
end


### print integers

_mul(x::Integer, ::_Dec) = x * 10
_mul(x::Integer, ::_Bin) = x << 1
_mul(x::Integer, ::_Oct) = x << 3
_mul(x::Integer, ::Union{_Hex, _HEX}) = x << 4

_div(x::Integer, ::_Dec) = div(x, 10)
_div(x::Integer, ::_Bin) = x >> 1
_div(x::Integer, ::_Oct) = x >> 3
_div(x::Integer, ::Union{_Hex, _HEX}) = x >> 4

_str(x::Integer, ::_Dec) = string(x, base=10)
_str(x::Integer, ::_Bin) = string(x, base=2)
_str(x::Integer, ::_Oct) = string(x, base=8)
_str(x::Integer, ::Union{_Hex, _HEX}) = string(x, base=16)

function _ndigits(x::Integer, op)  # suppose x is non-negative
    m = 1
    q = _div(x, op)
    while q > 0
        m += 1
        q = _div(q, op)
    end
    return m
end

_ipre(op) = ""
_ipre(::Union{_Hex, _HEX}) = "0x"
_ipre(::_Oct) = "0o"
_ipre(::_Bin) = "0b"

_digitchar(x::Integer, ::_Bin) = x == 0 ? '0' : '1'
_digitchar(x::Integer, ::_Dec) = Char(Int('0') + x)
_digitchar(x::Integer, ::_Oct) = Char(Int('0') + x)
_digitchar(x::Integer, ::_Hex) = Char(x < 10 ? '0' + x : 'a' + (x - 10))
_digitchar(x::Integer, ::_HEX) = Char(x < 10 ? '0' + x : 'A' + (x - 10))

_signchar(x::Real, s::AbstractChar) = signbit(x) ? '-' :
                                s == '+' ? '+' :
                                s == ' ' ? ' ' : '\0'

function _pfmt_int(out::IO, sch::AbstractChar, ip::ASCIIStr, zs::Integer, ax::Integer,
                   op::Op) where {Op}
    # print sign
    sch != '\0' && print(out, sch)
    # print prefix
    !isempty(ip) && print(out, ip)
    # print padding zeros
    zs > 0 && _repprint(out, '0', zs)
    # print actual digits
    ax == 0 ? print(out, '0') : _pfmt_intdigits(out, ax, op)
    nothing
end

function _pfmt_intdigits(out::IO, ax::T, op::Op) where {Op, T<:Integer}
    b_lb = _div(ax, op)
    b = one(T)
    while b <= b_lb
        b = _mul(b, op)
    end
    r = ax
    while b > 0
        (q, r) = divrem(r, b)
        print(out, _digitchar(q, op))
        b = _div(b, op)
    end
end

function _pfmt_intmin(out::IO, ip::ASCIIStr, zs::Integer, s::String)
    # print sign
    print(out, '-')
    # print prefix
    isempty(ip) || print(out, ip)
    # print padding zeros
    zs > 0 && _repprint(out, '0', zs)
    # print actual digits
    print(out, SubString(s, 2))
    nothing
end

# Special case were abs would give error
function _pfmt_imin(out::IO, fs::FormatSpec, x::Integer, op::Op) where {Op}
    s = _str(x, op)
    xlen = length(s)
    # prefix (e.g. 0x, 0b, 0o)
    ip = ""
    if fs.ipre
        ip = _ipre(op)
        xlen += length(ip)
    end

    # printing
    pad = fs.width - xlen
    if pad <= 0
        _pfmt_intmin(out, ip, 0, s)
    elseif fs.zpad
        _pfmt_intmin(out, ip, pad, s)
    elseif fs.align == '<'
        _pfmt_intmin(out, ip, 0, s)
        _repprint(out, fs.fill, pad)
    elseif fs.align == '^'
        _repprint(out, fs.fill, pad>>1)
        _pfmt_intmin(out, ip, 0, s)
        _repprint(out, fs.fill, (pad+1)>>1)
    else
        _repprint(out, fs.fill, pad)
        _pfmt_intmin(out, ip, 0, s)
    end
end

function _pfmt_i(out::IO, fs::FormatSpec, x::Integer, op::Op) where {Op}
    # Specially handle edge case of typemin
    x === typemin(typeof(x)) && x isa Signed && return _pfmt_imin(out, fs, x, op)
    # calculate actual length
    ax = abs(x)
    xlen = _ndigits(ax, op)
    # sign char
    sch = _signchar(x, fs.sign)
    xlen += (sch != '\0')
    # prefix (e.g. 0x, 0b, 0o)
    ip = ""
    if fs.ipre
        ip = _ipre(op)
        xlen += length(ip)
    end

    # printing
    pad = fs.width - xlen
    if pad <= 0
        _pfmt_int(out, sch, ip, 0, ax, op)
    elseif fs.zpad
        _pfmt_int(out, sch, ip, pad, ax, op)
    elseif fs.align == '<'
        _pfmt_int(out, sch, ip, 0, ax, op)
        _repprint(out, fs.fill, pad)
    elseif fs.align == '^'
        _repprint(out, fs.fill, pad>>1)
        _pfmt_int(out, sch, ip, 0, ax, op)
        _repprint(out, fs.fill, (pad+1)>>1)
    else
        _repprint(out, fs.fill, pad)
        _pfmt_int(out, sch, ip, 0, ax, op)
    end
end


### print floating point numbers

function _pfmt_float(out::IO, sch::AbstractChar, zs::Integer, intv::Real, decv::Real, prec::Int)
    # print sign
    sch != '\0' && print(out, sch)

    # print padding zeros
    zs > 0 && _repprint(out, '0', zs)

    idecv = round(Integer, decv * exp10(prec))
    # print integer part
    if intv == 0
        print(out, '0')
    else
        _pfmt_intdigits(out, intv, _Dec())
    end
    # print decimal part
    if prec > 0
        print(out, '.')
        nd = _ndigits(idecv, _Dec())
        nd < prec && _repprint(out, '0', prec - nd)
        _pfmt_intdigits(out, idecv, _Dec())
    end
end

function _pfmt_f(out::IO, fs::FormatSpec, x::AbstractFloat)
    # separate sign, integer, and decimal part
    rax = round(abs(x); digits = fs.prec)
    sch = _signchar(x, fs.sign)
    intv = trunc(Integer, rax)
    decv = rax - intv

    # calculate length
    xlen = _ndigits(intv, _Dec()) + ifelse(fs.prec > 0, fs.prec + 1, 0)
    sch != '\0' && (xlen += 1)

    # print
    pad = fs.width - xlen
    if pad <= 0
        _pfmt_float(out, sch, 0, intv, decv, fs.prec)
    elseif fs.zpad
        _pfmt_float(out, sch, pad, intv, decv, fs.prec)
    elseif fs.align == '<'
        _pfmt_float(out, sch, 0, intv, decv, fs.prec)
        _repprint(out, fs.fill, pad)
    elseif fs.align == '^'
        _repprint(out, fs.fill, pad>>1)
        _pfmt_float(out, sch, 0, intv, decv, fs.prec)
        _repprint(out, fs.fill, (pad+1)>>1)
    else
        _repprint(out, fs.fill, pad)
        _pfmt_float(out, sch, 0, intv, decv, fs.prec)
    end
end

function _pfmt_floate(out::IO, sch::AbstractChar, zs::Integer, u::Real, prec::Int, e::Integer,
                      ec::AbstractChar)
    intv = trunc(Integer, u)
    decv = u - intv
    if intv == 0 && decv != 0
        intv = 1
        decv -= 1
    end
    _pfmt_float(out, sch, zs, intv, decv, prec)
    print(out, ec)
    if e >= 0
        print(out, '+')
    else
        print(out, '-')
        e = -e
    end
    e < 10 && print(out, '0')
    _pfmt_intdigits(out, e, _Dec())
end

function _pfmt_e(out::IO, fs::FormatSpec, x::AbstractFloat)
    # extract sign, significand, and exponent
    ax = abs(x)
    sch = _signchar(x, fs.sign)
    if ax == 0.0
        e = 0
        u = zero(x)
    else
        rax = round(ax; sigdigits = fs.prec + 1)
        e = floor(Integer, log10(rax))  # exponent
        u = round(rax * exp10(-e); sigdigits = fs.prec + 1)  # significand
        i = 0
        v10 = 1
        while isinf(u)
            i += 1
            i > 18 && (u = 0.0; e = 0; break)
            v10 *= 10
            u = round(v10 * rax * exp10(-e - i); sigdigits = fs.prec + 1)
        end
    end

    # calculate length
    xlen = 6 + fs.prec
    abs(e) > 99 && (xlen += _ndigits(abs(e), _Dec()) - 2)
    sch != '\0' && (xlen += 1)

    # print
    ec = isuppercase(fs.typ) ? 'E' : 'e'
    pad = fs.width - xlen
    if pad <= 0
        _pfmt_floate(out, sch, 0, u, fs.prec, e, ec)
    elseif fs.zpad
        _pfmt_floate(out, sch, pad, u, fs.prec, e, ec)
    elseif fs.align == '<'
        _pfmt_floate(out, sch, 0, u, fs.prec, e, ec)
        _repprint(out, fs.fill, pad)
    elseif fs.align == '^'
        _repprint(out, fs.fill, pad>>1)
        _pfmt_floate(out, sch, 0, u, fs.prec, e, ec)
        _repprint(out, fs.fill, (pad+1)>>1)
    else
        _repprint(out, fs.fill, pad)
        _pfmt_floate(out, sch, 0, u, fs.prec, e, ec)
    end
end

function _pfmt_g(out::IO, fs::FormatSpec, x::AbstractFloat)
    # number decomposition
    ax = abs(x)
    if 1.0e-4 <= ax < 1.0e6
        _pfmt_f(out, fs, x)
    else
        _pfmt_e(out, fs, x)
    end
end

function _pfmt_specialf(out::IO, fs::FormatSpec, x::AbstractFloat)
    if isinf(x)
        _pfmt_s(out, fs, x > 0 ? "Inf" : "-Inf")
    else
        @assert isnan(x)
        _pfmt_s(out, fs, "NaN")
    end
end
