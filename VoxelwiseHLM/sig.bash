#!/usr/bin/env bash


img="HLMimages/AScorrBeta.nii+tlrc"
sig=.001

while getopts :r:l:p:o:q:t: switch; do
case $switch in
   i) img="$OPTARG" ;;        # LOG FILE
   p) sig="$OPTARG" ;;        # Process name
   #*) sed -n // ;;               
esac
done


dir="sig/$(basename $img +tlrc)$sig"
[ -d $dir ] || mkdir $dir


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

name="$dir/1-notSig"
[ -r "$name+tlrc.BRIK" ] ||                                      \
 3dcalc -a $img'[age.p0]'    -b $img'[age.p1]'                          \
        -c $img'[invAge.p0]' -d $img'[invAge.p1]'                       \
        -e $img'[ageSq.p0]'  -f $img'[ageSq.p1]' -g $img'[ageSq.p2]'    \
        -expr "ispositive(
                 min(a,min(b,min(c,min(d,min(e,min(f,g)))))) - $sig  )" \
        -prefix $name -overwrite
       # if the smallest value minus what is sig is still positive, it's not significant


######################
#    invageB0 invageB1  ageB0 ageB1  agesqB0 agesqB1 agesqB2   ValueageB0 
# 2a    sig     n.s.     sig   n.s.     -      n.s.    n.s.     pos        | No devt change, but positive intercept 
# 2b    sig     n.s.     sig   n.s.     -      n.s.    n.s.     neg        | No devt change, but negative intercept
#
# if the smallest value minus what is sig is still positive, it's not significant
# interecept has to be sig
# intercept is postive/negative

######################

# both invAge and Age pos intercepts (insig slopes)
name="$dir/2a-posIntc"
[ -r "$name+tlrc.BRIK" ] ||                                 \
 3dcalc -a $img'[age.p0]'    -b $img'[age.p1]'                          \
        -c $img'[invAge.p0]' -d $img'[invAge.p1]'                       \
                             -f $img'[ageSq.p1]' -g $img'[ageSq.p2]'    \
        -h $img'[age.b0]'                                               \
        -j $img'[invAge.b0]'                                            \
        -expr "and(ispositive(min(b,min(d,min(f,g))) - $sig),
               isnegative(a - $sig),
               isnegative(c - $sig),
               ispositive(h),
               ispositive(j) )" -prefix $name -overwrite

# both invAge and Age neg intercepts (insig slopes)
name="$dir/2a-negIntc"
[ -r "$name+tlrc.BRIK" ] ||                                 \
 3dcalc -a $img'[age.p0]'    -b $img'[age.p1]'                          \
        -c $img'[invAge.p0]' -d $img'[invAge.p1]'                       \
                             -f $img'[ageSq.p1]' -g $img'[ageSq.p2]'    \
        -h $img'[age.b0]'                                               \
        -j $img'[invAge.b0]'                                            \
        -expr "and(ispositive(min(b,min(d,min(f,g))) - $sig),
               isnegative(a - $sig),
               isnegative(c - $sig),
               isnegative(h),
               isnegative(j) )" -prefix $name -overwrite




######################
#     invageB0 invageB1  ageB0 ageB1  agesqB0 agesqB1 agesqB2 
#3a&b:   -       -        -     sig      -      -         -      | Sig devt change - linear (not mutually exclusive)     
######################
#all
name="$dir/3a-ageSigSlope-all"
#[ -r "$name+tlrc.BRIK" ] || \
 3dcalc                      -b $img'[age.p1]'                          \
        -expr "b*isnegative( b - $sig )"                    \
        -prefix $name -overwrite

# age pos sig slop
name="$dir/3a-ageSigSlope-pos"
[ -r "$name+tlrc.BRIK" ] || \
 3dcalc                      -b $img'[age.p1]'                          \
                             -i $img'[age.b1]'                          \
        -expr "isnegative( b - $sig )*ispositive(i)"                    \
        -prefix $name -overwrite

# age neg sig slope
name="$dir/3b-ageSigSlope-neg"
[ -r "$name+tlrc.BRIK" ] || \
 3dcalc                      -b $img'[age.p1]'                          \
                             -i $img'[age.b1]'                          \
        -expr "isnegative( b - $sig )*ispositive(i)"                    \
        -prefix $name -overwrite



######################
#     invageB0 invageB1  ageB0 ageB1  agesqB0 agesqB1 agesqB2 
# 4ab:   -      sig       -     -         -      -       -    | Sig devt change - inverse (not mutually exclusive)
######################

# inv age pos sig slope
name="$dir/4a-invAgeSigSlope-pos"
[ -r "$name+tlrc.BRIK" ] || \
 3dcalc                                                                 \
                             -d $img'[invAge.p1]'                       \
                             -k $img'[invAge.b1]'                       \
        -expr "isnegative( d - $sig )*ispositive(k) "                   \
        -prefix $name -overwrite


# inv age neg sig slope
name="$dir/4a-invAgeSigSlope-neg"
[ -r "$name+tlrc.BRIK" ] || \
 3dcalc                                                                 \
                             -d $img'[invAge.p1]'                       \
                             -k $img'[invAge.b1]'                       \
        -expr "isnegative( d - $sig )*isnegative(k) "                   \
        -prefix $name -overwrite


######################
#     invageB0 invageB1  ageB0 ageB1  agesqB0 agesqB1 agesqB2 
#5a&b      -       -       -     -        -      -       sig    | Sig devt change - quadratic (not mutually exclusive)
######################

# inv age pos sig slope
name="$dir/5a-ageSqSig-pos"
[ -r "$name+tlrc.BRIK" ] || \
 3dcalc                                                                 \
                                                 -g $img'[ageSq.p2]'    \
                                                 -n $img'[ageSq.b2]'    \
        -expr "isnegative( g - $sig )*ispositive(n) "                   \
        -prefix $name -overwrite

name="$dir/5b-ageSqSig-neg"
[ -r "$name+tlrc.BRIK" ] || \
 3dcalc                                                                 \
                                                 -g $img'[ageSq.p2]'    \
                                                 -n $img'[ageSq.b2]'    \
        -expr "isnegative( g - $sig )*isnegative(n) "                   \
        -prefix $name -overwrite

#Group 6a&b:    AIC is max for invage model
#Group 7a&b:    AIC is max for age model
#Group 8a&b:    AIC is max for agesq model
name="$dir/6-7-8-AICbestForAgeInvSq"
[ -r "$name+tlrc.BRIK" ] || \
 3dcalc -a $img'[age.AIC]' -b $img'[invAge.AIC]' -c $img'[ageSq.AIC]'   \
        -expr 'argmax(-1*a,-1*b,-1*c)' -prefix $name -overwrite

# 3dcalc -a $img'[age.Deviance]' -b $img'[invAge.Deviance]' -c $img'[ageSq.Deviance]'   \
        #-expr 'argmax(-1*a,-1*b,-1*c)' -prefix 678-Dev -overwrite
