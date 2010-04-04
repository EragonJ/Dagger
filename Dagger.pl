#!/usr/bin/perl -w

  my $filename;
  my $output;
  my $header;
  my $insert;
  my $remainder;
  my $outfile;
  my $size;
  my @sql;

  print "Your input file (Like: \\w*.sql)\n >>";
  chomp($filename = <STDIN>);

  print "Your output filename (P.S. Dont put '.sql' here)\n >>";
  chomp($output   = <STDIN>);
  $output = $output || "default";

  print "What's the size of each chunk ? (Like: 1024)\n >>";
  chomp($size     = <STDIN>);
  $size = ($size < 0) ? 1024 : $size;

  open IN , "<" , $filename or die "Read file error!\n";

  # use slurp mode
  local $/; 


  # get the whole file ! because there is only 1 line, I store it as a scalar
  my $content = <IN>;

  # get the header, insert and the remainder part
  if($content =~ /(.*?)(INSERT INTO.*?VALUES)(.*)/s)
  {
    $header    = $1;
    $insert    = $2;
    $remainder = $3;
  }

  $_ = $remainder;
  # split the remainder into sub SQLs
  while(/(\(.*?\))(?:,|;)/sg)
  {
    push @sql,$1;
  }

  for(my $i=0;$i<int($#sql/$size)+1;$i++)
  {
    my @sub;

    if(($i+1)==int($#sql/$size)+1)
    {
      @sub = @sql[$i*$size .. $#sql];
    }
    else 
    {
      @sub = @sql[$i*$size .. ($i+1)*$size - 1];
    }

    # will be named like abc_0 , abc_1 ... etc
    $outfile = $output."_".$i.".sql";
    open OUT , ">" , $outfile or die "Output file error!\n";
    print OUT $header;
    print OUT $insert;
    print OUT join("," , @sub);
    close OUT;
  }
  
  close IN;
