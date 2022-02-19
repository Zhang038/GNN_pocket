##
## <ligand.py>
##  dealing with ligand-contacting residue file generated by the program "Ligand"
##  
##>> FILE FORMAT EXAMPLE <<
#PDB        4hhb
#FILENAME   /DB/PDBv3/hh/pdb4hhb.ent
#FILEID     4hhb
#HEADER     OXYGEN TRANSPORT                        07-MAR-84   4HHB
#EXPDTA     X-RAY DIFFRACTION
#NMOL       10
#NPRO       4
#NNUC       0
#NLIG       6
#SELECTION  protein T dnarna T hetero T water F min_len_pro 10
##DATE      Sep 22,2008 10:8:33
##COMMAND   Ligand /DB/PDBv3/hh/pdb4hhb.ent -M P -ch A
##           No|   |ATMHET|C|#atm|AnumS|AnumE|#res|RnumS|RnumE|MolFormula|MolString
#MOLECULE     1|pro|ATOM  |A|1069|    1| 1069| 141|   1 | 141 |C685_N187_O194_S3|
#MOLECULE     2|pro|ATOM  |B|1123| 1071| 2193| 146|   1 | 146 |C724_N195_O201_S3|
#MOLECULE     3|pro|ATOM  |C|1069| 2195| 3263| 141|   1 | 141 |C685_N187_O194_S3|
#MOLECULE     4|pro|ATOM  |D|1123| 3265| 4387| 146|   1 | 146 |C724_N195_O201_S3|
#MOLECULE     5|PO4|HETATM|-|   1| 4389| 4389|   1|   1 |   1 |P1|PHOSPHATE ION
#MOLECULE     6|PO4|HETATM|-|   1| 4390| 4390|   1|   2 |   2 |P1|PHOSPHATE ION
#MOLECULE     7|HEM|HETATM|A|  43| 4391| 4433|   1|   1 |   1 |C34_N4_O4_Fe1|PROTOPORPHYRIN IX CONTAINING FE
#MOLECULE     8|HEM|HETATM|B|  43| 4434| 4476|   1|   1 |   1 |C34_N4_O4_Fe1|PROTOPORPHYRIN IX CONTAINING FE
#MOLECULE     9|HEM|HETATM|C|  43| 4477| 4519|   1|   1 |   1 |C34_N4_O4_Fe1|PROTOPORPHYRIN IX CONTAINING FE
#MOLECULE    10|HEM|HETATM|D|  43| 4520| 4562|   1|   1 |   1 |C34_N4_O4_Fe1|PROTOPORPHYRIN IX CONTAINING FE
#MODE       P
#CHAIN      A
#PROTEIN      1|pro|A|
# PARTNER     2|pro|B|146|C724_N195_O201_S3|
## [RNUM] [CHAIN] [RES] [Nc_atm_self] [Nc_atm_tar] [Dc_min] [Plain_Rnum]
#    31  A ARG  7 10 2.807   31
#    34  A LEU  2  3 3.600   34
#    35  A SER  2  7 3.530   35
#    36  A PHE  1  2 3.798   36
#   103  A HIS  4  8 2.881  103
#   107  A VAL  3  3 3.684  107
#   118  A THR  3  3 3.390  118
#   119  A PRO  5  8 3.544  119
#   126  A ASP  3  4 3.272  126
# PARTNER     3|pro|C|141|C685_N187_O194_S3|
## [RNUM] [CHAIN] [RES] [Nc_atm_self] [Nc_atm_tar] [Dc_min] [Plain_Rnum]
#   126  A ASP  4  3 2.711  126
#   127  A LYS  3  4 2.815  127
#   141  A ARG  8  8 2.779  141
# PARTNER     4|pro|D|146|C724_N195_O201_S3|
## [RNUM] [CHAIN] [RES] [Nc_atm_self] [Nc_atm_tar] [Dc_min] [Plain_Rnum]
#    37  A PRO  1  1 3.754   37
#    38  A THR  2  2 3.672   38
#    40  A LYS  2  3 2.582   40
#    41  A THR  4  7 3.511   41
#    42  A TYR  5  5 2.383   42
#    44  A PRO  1  3 3.861   44
#    97  A ASN  3  2 2.866   97
#   140  A TYR  3  4 3.515  140
#   141  A ARG  4  7 2.844  141
# PARTNER     7|HEM|A|1|C34_N4_O4_Fe1|PROTOPORPHYRIN IX CONTAINING FE
## [RNUM] [CHAIN] [RES] [Nc_atm_self] [Nc_atm_tar] [Dc_min] [Plain_Rnum]
#    42  A TYR  1  1 3.267   42
#    43  A PHE  3  4 3.506   43
#    45  A HIS  2  2 2.976   45
#    46  A PHE  2  2 3.563   46
#    58  A HIS  2  5 3.366   58
#    61  A LYS  3  1 3.487   61
#    62  A VAL  1  1 3.923   62
#    83  A LEU  2  1 3.772   83
#    86  A LEU  1  1 3.497   86
#    87  A HIS  3  8 2.143   87

import sys
import os 

LastModDate = 'Sep 22, 2008'
  
class ResLigand:
  
  def __init__(self):
      self.filename = ''  
      self.conligseq   = {}  ### list of [list of triname ligands]
      self.seq         = {}
      self.conligand   = []  ### list of class ConLigand
    
  def read(self,fname):
      print "#resacc.SolventAcc.read(\"%s\") "%(fname)
      self.filename = fname
      flag_conres = 0
      f = open(fname)
      start_align = 0 
      for line in f: 
        if line:
          line = line.rstrip('\n')
        if (line.startswith("#")==0):
          if (line.startswith(" ")) and (flag_conres == 1) and  (line.startswith(" PARTNER")==0):
# [RNUM] [CHAIN] [RES] [Nc_atm_self] [Nc_atm_tar] [Dc_min] [Plain_Rnum]
#    42  A TYR  1  1 3.267   42
#    43  A PHE  3  4 3.506   43
            column = line.split()
            print column
            res = ConRes()
            res.rnum         = column[0]
            res.chain        = column[1]
            res.res          = column[2]
            res.Nc_atm_self  = column[3]
            res.Nc_atm_tar   = column[4]
            res.Dc_min       = column[5]
            res.plain_rnum   = column[6]
            self.conligand[-1].conres.append(res)
            if (self.conligseq.has_key(res.rnum)==0):
              self.conligseq[res.rnum] = []
            self.conligseq[res.rnum].append(self.conligand[-1].triname)
            self.seq[res.rnum] = res.res

          if (line.startswith(" PARTNER")):
# PARTNER     7|HEM|A|1|C34_N4_O4_Fe1|PROTOPORPHYRIN IX CONTAINING FE
            lig = ConLigand() 
            column = line[8:].split('|')
            #print column
            lig.lignum  = int(column[0])
            lig.triname = column[1]
            lig.chain   = column[2]
            lig.Ngroup  = int(column[3])
            lig.molform = column[4]
            lig.molname = column[5]
            lig.conres  = []
            #print "%d '%s' '%s' '%s'"%(lig.lignum,lig.triname,lig.molform,lig.molname) 
            self.conligand.append(lig)
            flag_conres = 1


      f.close

  def __str__(self):
      s = "#ligand.ResLigand:'%s' "%(self.filename)
      return s  
  
class ConLigand:
  def __init__(self):
      lignum  = 0
      triname = ''
      chain   = ''
      Ngroup  = ''
      molform = ''
      molname = ''
      conres = []
      pass
  def __str__(self):
      s = "#ConLigand %d %s %s %d %s %s"%(self.lignum,self.triname,self.chain,self.Ngroup,self.molform,self.molname)
      return s  

class ConRes:
  def __init__(self):
      rnum  = ''
      chain = '' 
      res   = '' 
      Nc_atm_self  = '' 
      Nc_atm_tar   = '' 
      Dc_min       = '' 
      plain_rnum   = '' 
      pass
  def __str__(self):
      s = "#ConRes %s %s %s"%(self.rnum,self.chain,self.res)
      return s  


 
def _main():
    if (len(sys.argv)<2):
      print "#ERROR:Insufficient arguments"
      sys.exit()
    L = ResLigand()   
    L.read(sys.argv[1]) 
    print L
    print "#number of contacted ligand:%d"%(len(L.conligand))
    for lig in (L.conligand):
      print "%s Nconlig %d"%(lig.triname,len(lig.conres)) 
    for rnum in (L.conligseq.keys()):
      print "%s %s %s"%(rnum,L.seq[rnum],L.conligseq[rnum])
if __name__ == '__main__':_main()
