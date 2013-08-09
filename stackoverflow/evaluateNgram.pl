#! /usr/bin/perl

for ($order=1; $order<11; $order++){
  $logfile="$order"."-gram"."-eval.log";
  `cp /dev/null $logfile`;
  open (MYFILE, ">> $logfile"); 
  for ($dataSet=1; $dataSet<11; $dataSet++){
    $sumPerplexity=0, $sumCrossEntropy=0;  
    for ($trainModel=0;$trainModel<9;$trainModel++){
        $dest="$order"."-gram"."/"."DS"."$dataSet";
        $lmFile="$dest"."/"."$trainModel"."_"."$order".".lm";
        $dataFile="$dest"."/"."9.dat";
       
        $perplexity = `/home/pankaj_k/entropy/mitlm/evaluate-ngram -order $order -lm $lmFile -eval-perp $dataFile | sed -n 4,4p | awk '{FS = " "; print \$3}'`;
        chop $perplexity;
        $sumPerplexity=$sumPerplexity+$perplexity;
        
        $crossEntropy = log($perplexity)/log(2) if $perplexity > 0;
        $sumCrossEntropy=$sumCrossEntropy+$crossEntropy;    
        
        print "$dest    $lmFile   $dataFile  $perplexity  $crossEntropy\n";
        print MYFILE "$dest    $lmFile   $dataFile  $perplexity  $crossEntropy\n";
      }
      $avgPerplexity = $sumPerplexity/9;
      $avgCrossEntropy = $sumCrossEntropy/9;
      print "$dest    $lmFile   $dataFile";
      printf "  %.3f  %.3f (Average)\n\n",$avgPerplexity,$avgCrossEntropy;
      printf MYFILE "$dest    $lmFile   $dataFile";
      printf MYFILE "  %.3f  %.3f (Average)\n\n",$avgPerplexity,$avgCrossEntropy;
   }
  $avgCSForAllDS = `grep Average $logfile | awk '{FS = " "; print \$5}'|awk '{total = total + \$1}END{print total/10}'`;
  printf MYFILE "\n\n Average Cross Entropy for $order-gram is : $avgCSForAllDS";
}
 

