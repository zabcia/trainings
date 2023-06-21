program writeif
    version 17
    syntax [, cformat(string) ]
    
    local k = colsof(e(b))
    mat b = e(b)[1,`k'] , e(b)[1, 1 .. `=`k'-1' ]
    local vars : colnames b
    tokenize `vars' 
    local i 1
    while `i'<=`k' {
        if `i'==1 {
            local todisp "b[1,1]"
        }
        else {
            if b[1,`i'] >= 0 {
                local plus "+"
            }
            else local plus ""
            local t as text
            local r as result
            local todispadd `t' "`plus'" `r' `cformat' b[1,`i'] `t' "*``i''"
            local todisp "`todisp' `todispadd'"
        }
        local ++i
    }
    display in smcl as result `cformat' `todisp'
end