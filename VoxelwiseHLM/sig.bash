#!/usr/bin/env bash


img="HLMimages/AScorrBeta.nii+tlrc"
sig=.005
# always in this order
# 3dcalc -a $img'[age.p0]'    -b $img'[age.p1]'                          \
#        -c $img'[invAge.p0]' -d $img'[invAge.p1]'                       \
#        -e $img'[ageSq.p0]'  -f $img'[ageSq.p1]' -g $img'[ageSq.p2]'    \
#        -h $img'[age.b0]'    -i $img'[age.b1]'                          \
#        -j $img'[invAge.b0]' -k $img'[invAge.b1]'                       \
#        -l $img'[ageSq.b0]'  -m $img'[ageSq.b1]' -n $img'[ageSq.b2]'    \


######################
#          invageB0 invageB1 ageB0 invageB1 agesqB0 agesqB1 agesqB2  v_ageB0  v_ageB1 v_invageB1 v_agesqB2
# Group 1:   n.s.    n.s.    n.s.    n.s.     n.s.    n.s.     n.s.                                        | No devt change or activity

[ -r "sig/1-notSig+tlrc.BRIK" ] ||                                      \
 3dcalc -a $img'[age.p0]'    -b $img'[age.p1]'                          \
        -c $img'[invAge.p0]' -d $img'[invAge.p1]'                       \
        -e $img'[ageSq.p0]'  -f $img'[ageSq.p1]' -g $img'[ageSq.p2]'    \
        -expr "ispositive(min(a,min(b,min(c,min(d,min(e,min(f,g)))))) - $sig)" -prefix 'sig/1-notSig'
       # if the smallest value minus what is sig is still positive, it's not significant


######################
#    invageB0 invageB1  ageB0 ageB1  agesqB0 agesqB1 agesqB2   ValueageB0 
# 2a    sig     n.s.     sig   n.s.     -      n.s.    n.s.     pos        | No devt change, but positive intercept 
# 2b    sig     n.s.     sig   n.s.     -      n.s.    n.s.     neg        | No devt change, but negative intercept
#
# if the smallest value minus what is sig is still positive, it's not significant
# interecept has to be sig
# intercept is postive/negative


# AGE  a and b
######################

[ -r "sig/2a-posInt-age+tlrc.BRIK" ] ||                                 \
 3dcalc -a $img'[age.p0]'    -b $img'[age.p1]'                          \
                             -d $img'[invAge.p1]'                       \
                             -f $img'[ageSq.p1]' -g $img'[ageSq.p2]'    \
        -h $img'[age.b0]'                                               \
        -expr "and(ispositive(min(b,min(d,min(f,g))) - $sig),
               isnegative(a - $sig),
               ispositive(h) )" -prefix 'sig/2a-posInt-age' -overwrite

[ -r "sig/2b-negInt-age+tlrc.BRIK" ] ||                                 \
 3dcalc -a $img'[age.p0]'    -b $img'[age.p1]'                          \
                             -d $img'[invAge.p1]'                       \
                             -f $img'[ageSq.p1]' -g $img'[ageSq.p2]'    \
        -h $img'[age.b0]'                                               \
        -expr "and(ispositive(min(b,min(d,min(f,g))) - $sig),
               isnegative(a - $sig),
               isnegative(h) )" -prefix 'sig/2b-negInt-age' -overwrite

# INVAGE a and b 
######################
[ -r "sig/2b-posInt-invAge+tlrc.BRIK" ] ||                              \
 3dcalc                      -b $img'[age.p1]'                          \
        -c $img'[invAge.p0]' -d $img'[invAge.p1]'                       \
                             -f $img'[ageSq.p1]' -g $img'[ageSq.p2]'    \
                                                                        \
        -j $img'[invAge.b0]'                                            \
        -expr "and(ispositive(min(b,min(d,min(f,g))) - $sig),
               isnegative(c - $sig),
               ispositive(j) )" -prefix 'sig/2b-posInt-invAge' -overwrite

[ -r "sig/2b-negInt-invAge+tlrc.BRIK" ] ||                              \
 3dcalc                      -b $img'[age.p1]'                          \
        -c $img'[invAge.p0]' -d $img'[invAge.p1]'                       \
                             -f $img'[ageSq.p1]' -g $img'[ageSq.p2]'    \
                                                                        \
        -j $img'[invAge.b0]'                                            \
        -expr "and(ispositive(min(b,min(d,min(f,g))) - $sig),
               isnegative(c - $sig),
               isnegative(j) )" -prefix 'sig/2b-negInt-invAge' -overwrite

######################
#     invageB0 invageB1  ageB0 ageB1  agesqB0 agesqB1 agesqB2 
# 3ab:   -      sig       -     -         -      -       -    | Sig devt change - inverse (not mutually exclusive)
######################

# age
[ -r "sig/3a-ageSigSlope-pos+tlrc.BRIK" ] || \
 3dcalc                      -b $img'[age.p1]'                          \
                             -i $img'[age.b1]'                          \
        -expr "isnegative( b - $sig )*ispositive(i)"                    \
        -prefix 'sig/3a-sigSlope-age' -overwrite

# inv Age
[ -r "sig/3b-ageSigSlope-neg+tlrc.BRIK" ] || \
 3dcalc                                                                 \
                             -d $img'[invAge.p1]'                       \
                             -i $img'[age.b1]'                          \
        -expr "isnegative( b - $sig )*isnegative(i)"                    \
        -prefix 'sig/3b-sigSlope-invAge' -overwrite



######################
#     invageB0 invageB1  ageB0 ageB1  agesqB0 agesqB1 agesqB2 
#4a&b:   -       -        -     sig      -      -         -      | Sig devt change - linear (not mutually exclusive)     
######################
# age
[ -r "sig/3a-sigSlope-age+tlrc.BRIK" ] ||  \
 3dcalc                      -b $img'[age.p1]'                          \
                             -i $img'[age.b1]'                          \
        -expr "isnegative( b - $sig )*ispositive(i) "                   \
        -prefix 'sig/3a-sigSlope-age' -overwrite

# inv Age
[ -r "sig/3b-sigSlope-invAge+tlrc.BRIK" ] ||                            \
 3dcalc                                                                 \
                             -d $img'[invAge.p1]'                       \
        -expr "isnegative( d - $sig )" -prefix 'sig/3b-sigSlope-invAge' -overwrite

