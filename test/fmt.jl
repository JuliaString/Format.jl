# some basic functionality testing
x = 1234.56789

@test fmt(x) == "1234.567890"
@test fmt(x;prec=2) == "1234.57"
@test fmt(x,10,3) == "  1234.568"
@test fmt(x,10,3,:left) == "1234.568  "
@test fmt(x,10,3,:ljust) == "1234.568  "
@test fmt(x,10,3,:right) == "  1234.568"
@test fmt(x,10,3,:lrjust) == "  1234.568"
@test fmt(x,10,3,:zpad) == "001234.568"
@test fmt(x,10,3,:zeropad) == "001234.568"
@test fmt(x,:commas) == "1,234.567890"
@test fmt(x,10,3,:left,:commas) == "1,234.568 "
@test fmt(x,:ipre) == "1234.567890"
@test fmt(x,12) == " 1234.567890"

i = 1234567

@test fmt(i) == "1234567"
@test fmt(i,:commas) == "1,234,567"

fmt(3//4, 10) == "      3//4"
fmt(2 - 3im, 10) == "   2 - 3im"
fmt(pi - 3im, 15, 2) == "  3.14 - 3.00im"
fmt(1//2 + 6//2 * im, 15) == " 1//2 + 3//1*im"

fmt_default!(Int, :commas, width = 12)
@test fmt(i) == "   1,234,567"
@test fmt(x) == "1234.567890"  # default hasn't changed

fmt_default!(:commas)
@test fmt(i) == "   1,234,567"
@test fmt(x) == "1,234.567890"  # width hasn't changed, but added commas

fmt_default!(Int) # resets Integer defaults
@test fmt(i) == "1234567"
@test fmt(i,:commas) == "1,234,567"

reset!(Int)
fmt_default!(UInt16, 'd', :commas)
@test fmt(0xffff) == "65,535"
fmt_default!(UInt32, UInt16, width=20)
@test fmt(0xfffff) == "           1,048,575"

v = pi
@test fmt(v) == "π"
@test fmt(v; width=10) == "         π"

v = MathConstants.eulergamma
@test fmt(v, 10, 2) == "         γ"
@test pyfmt("10.2f", v) == "      0.58"
