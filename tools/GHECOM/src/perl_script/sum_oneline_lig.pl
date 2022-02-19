#!/usr/bin/perl
#
# <sum_oneline_lig.pl>
#
#>>FILE EXAMPLE without molecular formula <<
#1uf9A  191 pro B pro C
#1li5A  386 pro B  ZN A
#1gdjA  153 HEM -
#1yd9A  188 pro D  AU -
#1zpdA  565 pro B  MG A DPX A CIT A
#1t4wA  196  ZN -
#1dzkA  148 pro B PRZ A
#1nekB  238 pro A pro C  CA - FES B SF4 B F3S B
#1cldA   33  CD -  CD -
#1iknD  216
#2glzA  149 pro B  ZN A  NI A EDO - EDO - EDO - EDO - EDO - EDO -
#1z6nA  166  MG -
#1p82A   25
#1tifA   76 PBM -  CL -
#>>FILE EXAMPLE with molecular formula <<
#1uf9A  191:pro[R191] B:pro[R191] C
#1li5A  386:pro[R369] B: ZN[Zn1] A
#1gdjA  153:HEM[C34_N4_O4_Fe1] -
#1yd9A  188:pro[R188] D: AU[X1] -
#1zpdA  565:pro[R565] B: MG[Mg1] A:DPX[C11_N4_O8_S1_P2] A:CIT[C6_O7] A
#1t4wA  196: ZN[Zn1] -
#1dzkA  148:pro[R148] B:PRZ[C9_N2_O1] A
#1nekB  238:pro[R588] A:pro[R129] C: CA[Ca1] -:FES[S2_Fe2] B:SF4[S4_Fe4] B:F3S[S4_Fe3] B
#1cldA   33: CD[Cd1] -: CD[Cd1] -
#1iknD  216
#2glzA  149:pro[R148] B: ZN[Zn1] A: NI[Ni1] A:EDO[C2_O2] -:EDO[C2_O2] -:EDO[C2_O2] -:EDO[C2_O2] -:EDO[C2_O2] -:EDO[C2_O2] -
#1z6nA  166: MG[Mg1] -
#1p82A   25
#1tifA   76:PBM[C3_X1] -: CL[Cl1] -



@known_precipitants = ("GOL","MPD","TRS","MES","BOG","EPE","DTT");
foreach $lig (@known_precipitants){ $known_precipi{$lig} = '*'; }

$LastModDate = "Sep 15, 2008";
$OPT{'mf'}  = 'F';

if (scalar(@ARGV)<1){
 print "sum_oneline_lig.pl [sum_oneline_ligand_file]\n";
 print " for making summary for one-line Ligand file\n";
 print " coded by T.Kawabata. LastModified:$LastModDate\n";
 print " <options>\n";
 printf("  -mf : type of oneline_lig_file 'T':with molecular formulra 'F':without [%s]\n",$OPT{'mf'});
 exit(1);
}


$ligfile = $ARGV[0];
&Read_Options(\@ARGV,\%OPT);

if ($OPT{'mf'} eq 'T'){
 &Read_Oneline_Ligand_File_with_MolFormula($ligfile,\%dat,\%Nmolform);
 &Choose_Most_Popular_MOLFORM(\%Nmolform,\%LigInf);
}
else{ &Read_Oneline_Ligand_File($ligfile,\%dat); }

@PdbChlist = keys(%dat);
$Nprotein = scalar(@PdbChlist);

%Nlig = (); 
%Nligpro = ();
$Nligand = 0;
$Nprotein_with_ligand = 0;
foreach $pdbch (@PdbChlist){
 if (scalar(@{$dat{$pdbch}->{'LIGAND'}})>0){++$Nprotein_with_ligand;}
 #printf("$pdbch Nlig %d ",$dat{$pdbch}->{'Nligand'});;
 %typeligpro = ();
 foreach $lig (@{$dat{$pdbch}->{'LIGAND'}}){
  #print " $lig";
  $Nlig{$lig} += 1;
  $typeligpro{$lig} = 1;
  $Nligand += 1;
 }

 foreach $lig (keys(%typeligpro)){
   $Nligpro{$lig} += 1;  
   push(@{$pro_with_lig{$lig}},$pdbch); 
  }
}


printf("#filename             %s\n",$ligfile);
printf("#Nprotein             %6d\n",$Nprotein);
printf("#Nprotein_with_ligand %6d\n",$Nprotein_with_ligand);
printf("#Nligand              %6d\n",$Nligand);
printf("#[LIG][molform][Nheavy][Ncarbon][precipi][Nlig][Nligpro] [proteins]\n");
@liglist = sort {$Nlig{$b} <=> $Nlig{$a}} keys(%Nlig);
foreach $lig (@liglist){
 if ($known_precipi{$lig} eq "") {$pre_sym = "-";} else {$pre_sym = 'P';}
 printf("%s %-18s %3d %3d %1s %5d %4d   %s %s %s %s\n",
  $lig,$LigInf{$lig}->{'MOLFORM'},$LigInf{$lig}->{'Nheavy'},$LigInf{$lig}->{'Ncarbon'},
  $pre_sym,$Nlig{$lig},$Nligpro{$lig},
  $pro_with_lig{$lig}->[0],$pro_with_lig{$lig}->[1],$pro_with_lig{$lig}->[2],$pro_with_lig{$lig}->[3]);
}


###################
#### FUNCTIONS ####
###################

sub Choose_Most_Popular_MOLFORM{
 my($Nmolform,$liginf) = @_;

 %{$liginf} = ();
 foreach $lig (keys(%{$Nmolform})){
   @mollist = sort {$Nmolform->{$b} <=> $Nmolform->{$a} } (keys(%{$Nmolform->{$lig}}));
   #foreach $mol (@mollist){
   #  printf(" %s %d\n",$mol,$Nmolform->{$lig}->{$mol});
   #}
   $liginf->{$lig}->{'MOLFORM'} = $mollist[0]; 
   $Ncarbon = 0; $Nheavy = 0;  $Nresidue = 0;
   @mword = split(/\_/,$liginf->{$lig}->{'MOLFORM'}); 
   foreach $word (@mword){
     $num = $atom = $word;
     $num  =~s/[A-Z]+//g; 
     $num =~s/[a-z]+//g;
     $atom =~s/[0-9]+//g; 
     #print " atom '$atom' num '$num'\n";
     if ($atom eq 'C') {$Ncarbon += $num; }
     if ($atom ne 'R') {$Nheavy  += $num; }
   }
   $liginf->{$lig}->{'Nheavy'}  = $Nheavy;
   $liginf->{$lig}->{'Ncarbon'} = $Ncarbon;
  # printf(">%3s %-16s Nheavy %d Ncarbon %d\n",$lig,$liginf->{$lig}->{'MOLFORM'},$Nheavy,$Ncarbon);
 }
}



sub Read_Oneline_Ligand_File{
 my($ligfile,$dat) = @_;
 %{$dat}  = ();
 my($IF,$pdbch,$Naa,$lig,$i);

 open(IF,$ligfile)||die "#ERRRO:Can't find $ligfile";

 while (<IF>){
  chomp;
  if ($_!~/^#/){
   ($pdbch,$Naa) = split(/\s+/,$_); 
   #printf("$pdbch $Naa len %d\n",length($_));
   $dat->{$pdbch}->{'Naa'}     = $Naa;
   $dat->{$pdbch}->{'Nligand'} = 0;
   $i = 11;
   while ($i<length($_)){
    $word = substr($_,$i,5);
    $ligname  = substr($word,0,3);
    $ligchain = substr($word,4,1);
    #print " '$ligname' '$ligchain'\n";
    $i += 6;   
    $dat->{$pdbch}->{'Nligand'} += 1;
    push(@{$dat->{$pdbch}->{'LIGAND'}},$ligname);
   }
 }
}
close(IF);

} ## end of  Read_Oneline_Ligand_File() ##


sub Read_Oneline_Ligand_File_with_MolFormula{
 my($ligfile,$dat,$Nmolform) = @_;
 %{$dat}  = ();
 %{$Nmolform}  = ();
 my($IF,$pdbch,$Naa,$lig,$i,@field);

 open(IF,$ligfile)||die "#ERRRO:Can't find $ligfile";

 while (<IF>){
  chomp;
  if ($_!~/^#/){
   @field = split(/:/,$_);
   ($pdbch,$Naa) = split(/\s+/,$field[0]); 
   #print "$pdbch $Naa\n";
   $dat->{$pdbch}->{'Naa'}     = $Naa;
   $dat->{$pdbch}->{'Nligand'} = 0;
   $i = 2;
   while ($i<scalar(@field)){
    $ligname = substr($field[$i],0,3);
    $ligchain = substr($field[$i],length($field[$i])-1,1);
    $molform  = substr($field[$i],4,length($field[$i])-7);
    #print " '$ligname' '$ligchain' '$molform'\n";
    @mword = split(/_/,$molform);
    $i += 1;   
    $dat->{$pdbch}->{'Nligand'} += 1;
    push(@{$dat->{$pdbch}->{'LIGAND'}}, $ligname);
    push(@{$dat->{$pdbch}->{'MOLFORM'}},$molform);
    $Nmolform->{$ligname}->{$molform} += 1;
   }
 }
}
close(IF);

} ## end of  Read_Oneline_Ligand_File_with_MolFormula() ##








sub Get_Date_String{
 my(@Month) = ('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
 my(@date) = localtime(time());
 my($year)  = $date[5]+1900;
 my($month) = $Month[$date[4]];
 my($day)   = $date[3];
 return("$month $day $year, $date[2]:$date[1]:$date[0]");
} ## end of Get_Date() ##

                                                                                
sub Read_Options{
 # $_[0] : ref of \@ARGV
 # $_[1] : ref of \%OPT
                                                                                                                    
 # This script is reading following style options :
 #   psiscan.pl org41list -lib 95pdb01Mar4Mx -tail -I -C
 # In principle, the format is the style like  "[-option] [value]"
 # If [value] is omitted, [option] is set to '1'.
 my($x); my($x1); my($i);
 $_[1]->{'COMMAND'} = "$0 ";
 foreach $x (@ARGV) { $_[1]->{'COMMAND'} .= "$x ";}
 $i = 0;
 while ($i<scalar(@ARGV))
 {
  $x  = $_[0]->[$i];
  $x1 = $_[0]->[$i+1];
#  if ($x =~/^\-/)
#   { $x =~s/^\-//;
#     if (($x1 !~ /^\-\w+/)&&(length($x1)>0)) { $_[1]->{$x} = $x1; ++$i; }
#     else { $_[1]->{$x} = 1;}
  if ($x =~/^\-/)
   { $x =~s/^\-//;
     if (length($x1)>0) { $_[1]->{$x} = $x1; ++$i; }
     else { $_[1]->{$x} = 1;}
   }
  ++$i;
 }
} ## end of Read_Options() ##
