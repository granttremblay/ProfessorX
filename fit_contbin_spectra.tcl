# Fit each of the regions produced by contour binning

set z 0.08
set n_h 0.0248
#set abnd 0.4

# Load file list
set file [open "region_list.txt" r]
set data [read $file]
close $file
set data [split $data]

set bases [lsearch -all -inline -not -regexp $data "spec"]

foreach base $bases {

    set filenames [glob "${base}_sumc7_spec.pi"]
    #set filenames [glob "${base}_sumc7_grp20.pi"]

    for {set i 0 } { $i < [llength $filenames] } { incr i } {
     set j [expr $i+1]
     data $j [lindex $filenames $i]
    }

    chatter 10

    ignore bad
    ignore *:**-0.5
    ignore *:7.0-**
    abund angr
    cosmo ,,0.7
    statistic cstat

    query yes
   
    model phabs(mekal) & /*

    newpar 1 $n_h
    freeze 1
    thaw 4
    newpar 5 $z
    freeze 5
    newpar 6 0.

    fit
    fit
    fit
    fit
    fit
    fit

   
    error maximum 5.0 1. 2 4 7

    show param
    show fit

    # Print out results
    set outfile [open "${base}_fit_out.txt" w]

#    tclout param 1
#    scan $xspec_tclout "%f" nHval
#    tclout error 1
#    scan $xspec_tclout "%f %f" nHval_low nHval_upp
#    puts $outfile "nH $nHval"
#    puts $outfile "nH_uerr [expr $nHval_upp - $nHval]"
#    puts $outfile "nH_lerr [expr $nHval_low - $nHval]"

    tclout param 2
    scan $xspec_tclout "%f" temp
    tclout error 2
    scan $xspec_tclout "%f %f" temp_low temp_upp
    puts $outfile "kT $temp"
    puts $outfile "kT_uerr [expr $temp_upp - $temp]"
    puts $outfile "kT_lerr [expr $temp_low - $temp]"

    tclout param 4
    scan $xspec_tclout "%f" abund
    tclout error 4
    scan $xspec_tclout "%f %f" abund_low abund_upp
    puts $outfile "Z $abund"
    puts $outfile "Z_uerr [expr $abund_upp - $abund]"
    puts $outfile "Z_lerr [expr $abund_low - $abund]"

    tclout param 7
    scan $xspec_tclout "%f" norm
    tclout error 7
    scan $xspec_tclout "%f %f" norm_low norm_upp
    puts $outfile "Norm $norm"
    puts $outfile "Norm_uerr [expr $norm_upp - $norm]"
    puts $outfile "Norm_lerr [expr $norm_low - $norm]"

    # Output statistic value (chi^2 or cstat)
    tclout stat
    scan $xspec_tclout "%f" chi2
    puts $outfile "Stat $chi2"

    close $outfile

   

    model none
    data none

}

exit
/*
