package App::Rad::Plugin::MatrizPrinter;

sub write_xls {
   my $c = shift;
   my @matriz = ref $_[0] eq "ARRAY" ? @$_[0] : @_;
   my $filename = $c->stash->{filename};
    require Spreadsheet::SimpleExcel;
    my $excel = Spreadsheet::SimpleExcel->new;
    $excel->add_worksheet(
       $c->options->{worksheet} || "WorkSheet",
       {
          -headers => $c->stash->{colunas},
          -data    => $c->{output},
       }
    );
    $excel->set_data_format($c->options->{worksheet} || "WorkSheet", [ ("s") x @{ $c->stash->{colunas} } ]);
    ($filename ||= localtime (time) . ".xls") =~ s/\W/_/g;
    $excel->output_to_file($filename) || die $excel->errstr;
    $filename if -f $filename;
}
   
sub write_csv {
   my $c      = shift;
   my @matriz = @{ shift() };
   my @cols   = @{ shift() };
   my $filename = $c->stash->{filename};
   open my $FILE, "<", $filename if defined $filename;
   my $sep = $c->stash->{csv_separator} || ";";
   my $qq = $c->stash->{csv_quote} || q|"|;
   (my $qq2 = $qq) =~ tr/([{<>}])/)]}><{[(/;
   if(not exists $c->stash->{show_title} or $c->stash->{show_title}) {
      if(defined $FILE){
         print $FILE join($sep, map {s/($qq|$qq2)/\\$1/g; qq|$qq$_$qq2|} @cols), $/;
      } else {
         print join($sep, map {s/($qq|$qq2)/\\$1/g; qq|$qq$_$qq2|} @cols), $/;
      }
   }
   for my $linha (@matriz) {
      if(defined $FILE){
         print $FILE join($sep, map {s/($qq|$qq2)/\\$1/g; qq|$qq$_$qq2|} @$linha), $/;
      } else {
         print join($sep, map {s/($qq|$qq2)/\\$1/g; qq|$qq$_$qq2|} @$linha), $/;
      }
   }
   if(defined $FILE){
      print "Arquivo \"$filename\" criado$/" if -f $filename;
      close $FILE;
   }
}

sub zip {
   my $c        = shift;
   my $filename = shift;
   require Archive::Zip;
   my $zip = Archive::Zip->new;
   my $file_member = $zip->addFile($filename);
   $filename =~ s/\W/_/g;
   $filename .= ".zip";
   
   # Save the Zip file
   unless ( $zip->writeToFileNamed($filename) == AZ_OK ) {
       die 'write error';
   }
   $filename if -f $filename
}

sub mail {
   my $c = shift;
   require MIME::Lite;
   print "enviando email com o arquivo \"$filename\"...$/";
   my $subject = $c->stash->{mail_subject} || "Sent by $0 " . $c->cmd;
   $subject =~ s/\[%\s*(.+)\s*%\]/$1/gee;
   my $msg = MIME::Lite->new(
       From     => $c->stash->{mail_from} || "root\@localhost",
       To       => $c->stash->{mail_to}  ,
       Cc       => $c->stash->{mail_cc}  ,
       Subject  => $subject,
       Type    => 'multipart/mixed',
   );
   $msg->attach(
       Type     => 'TEXT',
       Data     => ($c->stash->{mail_data} || "") . $/,
   );
   $msg->attach(
       Type     => $c->stash->{filetype},
       Encoding => 'base64',
       Path     => $filename,
   );
   $msg->send('smtp', $c->stash->{mail_server},
               Debug => $c->stash->{mail_debug}) && print "Feito...$/";
   unlink $filename;
}

sub print_matriz {
   my $c      = shift;
   my @matriz = @{ shift() };
   my @cols   = @{ shift() };
   #my $sep = exists $c->stash->{separator} ? $c->stash->{separator} : " | ";
   #my $bor = exists $c->stash->{border}    ? $c->stash->{border}    : " | ";
   my $format = $c->row_format([@matriz], [@cols]);
   if(not exists $c->stash->{show_title} or $c->stash->{show_title}) {
      printf $format, @cols if @cols;;
      printf $format, ("---") x @cols
         if @cols and not exists $c->stash->{show_title_sep} or $c->stash->{show_title_sep};
   }
   for my $linha (@matriz) {
      printf $format, map {substr $_, 0, 80} @$linha;
   }
   return
}

sub row_format {
   my $c = shift;
   my @matriz = @{ shift() };
   my @cols = @{ shift() };
   my @col_sz = map {length $_} @cols;
   $_ = 3 >= $_ ? 3 : $_ for @col_sz;
   for my $line (@matriz){
      for my $col (0 .. $#$line) {
         $col_sz[$col] = length($line->[$col]) >= $col_sz[$col] ? length($line->[$col]) : $col_sz[$col];
      }
   }
   $_ = 80 <= $_ ? 80 : $_ for @col_sz;
   "| " . (join " | ", map {"\% ${_}s"} @col_sz) . " |$/"
}

42
