#! /usr/bin/perl

for ($order=1; $order<11; $order++){
  for ($dataSet=1; $dataSet<11; $dataSet++){
    for ($trainModel=0;$trainModel<9;$trainModel++){
      $dest="$order"."-gram"."/"."DS"."$dataSet";
      $textFile="$dest"."/".$trainModel.".dat";
      $opFile="$dest"."/".$trainModel."_".$order.".lm";
      
      print  "$dest    $textFile   $opFile \n";
      
      `/home/pankaj_k/entropy/mitlm/estimate-ngram -order $order -text $textFile  -write-lm $opFile`;
    }
  }
}
 

