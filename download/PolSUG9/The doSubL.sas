/*
The doSubL():
*/


options noNotes noSource;
resetline;
%put #############;

data _null_;
  x = '
  %put *A*;
  data _null_;
    put "*B*";
  run;
  %put *C*;
  ';

  call Execute(x);
run;

%put #############;

data _null_;
  x = '
  %put *A*;
  data _null_;
    put "*B*";
  run;
  %put *C*;
  ';

  rc = doSubL(x);
run;


%put #############;


%macro test();
  %put *1*;
  data _null_;
    put "*2*";
  run;
  %put *3*;
%mend test;

%test()

resetline;
%put #############;
data _null_;
  x = '%test()';
  call Execute(x);
run;

%put #############;

data _null_;
  x = '%test()';
  rc = doSubL(x);
run;

%put #############;

data _null_;
  x = '%nrstr(%test())';
  call Execute(x);
run;

options Notes Source;















data _null_;
  rc = doSubL('data _null_; call symputx("abc", 42); run;');
  x = symget('abc');
  put x=;
run;

data _null_;
  call execute('data _null_; call symputx("def", 17); run;');
  x = symget('def');
  put x=;
run;












/* kody w kodzie */
data _null_;
  do S = "M", "F";
    length x $ 100;

    name = 'abc_';

    f = exist(name !! S);
    put f=;

    x = 'data ' !! name !! S !! ';'
     !! ' set sashelp.class;'
     !! ' where sex =: "' !! S !! '";'
     !! 'run;'; 
    rc = doSubL(x);

    f = exist(name !! S);
    put f=;
  end;
run;

data _null_;
  do S = "M", "F";
    length x $ 100;

    name = 'def_';

    f = exist(name !! S);
    put f=;

    x = 'data ' !! name !! S !! ';'
     !! ' set sashelp.class;'
     !! ' where sex =: "' !! S !! '";'
     !! 'run;'; 
    call Execute(x);

    f = exist(name !! S);
    put f=;
  end;
run;













/* try - except z dosubl() */
filename t temp;
data _null_;
  input;
  file t;
  put _infile_;
cards4;
  data x;
    x = 17 /* <- brak srednika! */
    y = 42;
  run;
;;;;
run;

%put *&=SYSCC.*;

data _null_;
  rc = doSubL('
    options noNotes noSource;
    filename _D_ DUMMY;
    proc printto log = _D_;
    run;

    %include t / source2;

    %let try = &SYSCC.; /* the operating environment 
                           condition code */
  ');

  try = symgetn('try');

  put rc= try=;

  if 0 < try then 
    except = doSubL('%put Your previous code was bad!');
run;

%put *&=try.*;
%put *&=SYSCC.*;

filename t;












/* SQL in DATASTEP */
%macro mySQL()/PARMBUFF;
  %local rc;
  %let rc = %sysfunc(
   doSubL(
    %str(
      proc sql;
      create view _TMP_&SYSINDEX. as
        &SYSPBUFF.
      ;
      quit;
    )));
_TMP_&SYSINDEX.
%mend mySQL;


data test;
  set 
    %mySQL(select Name, Height, Weight 
           from sashelp.class 
           where sex = "F"
          ) 
    indsname=inds
  ;
  put (inds _all_) (=);
run;














/* porownywanie warunkowe */

data A1 A2;
  x = 17;
run;

data B1;
  x = 41;
run;
data B2;
  x = 42;
run;

data C1 C2;
  x = 303;
run;

data _null_;
  input base $ compare $;
  rc = doSubL('
  options nonotes nosource;
  %let result = 1;
  proc compare 
  base    = ' !! base    !! '
  compare = ' !! compare !! '
  ;
  run;

  %let result = &SYSINFO.;
  ');
  if 0 < symgetn('result') then 
    do;
      put "Error when comparing: " base "and " compare 
        / "Process will stop!" / ;

      stop;
    end;
  else put "The " base "and " compare "are equal!" / ;

cards;
A1 A2
B1 B2
C1 C2
C1 C2
... 
C1 C2
C1 C2
;
run;


/* sortowanie bez sortowania */

data have;
  call streaminit(123);
  do i = 1 to 100;
    do x = "A", "B", "C", "D", "E", "F";
      y = rand('uniform',17,42);
      output;
    end;
  end;
run;

data _null_;

  if 0 then set have;
   declare hash H(ordered:"A");
   H.defineKey("x");
   H.defineDone();
   declare hiter IH("H");

  do until (eof);
    set have(keep=x) end = eof;
    H.replace();
  end;


  length test $ 1000;
  test = 'data want;'
      !! 'set';

  do while(IH.next()=0);
    test = catt(test, ' have(where=(x="' !! x !! '")) ');
  end;

  test = strip(test)
  !! ' ;'
  !! ' by x;'
  !! ' sum + y;'
  !! ' if last.x then output;'
  !! 'run;'
  ;

  rc = doSubL(test);
run;

/*
data want;
 set
  have(where=(x="A"))
  have(where=(x="B"))
  have(where=(x="C"))
  have(where=(x="D"))
  have(where=(x="E")) 
  have(where=(x="F"))
 ;
 by x;
 sum + y;
 if last.x then output;
run;
*/







/* libname */
%put NOTE: My session work:;
%put NOTE- %sysfunc(PATHNAME(work));

data _null_;
yyy = "options DLCREATEDIR; 
 libname iwd BASE '%sysfunc(PATHNAME(work))\inside_work_dosubl'; 
 data iwd.test1;
  x = 17; 
 run;"; 
rc = dosubl(yyy); 
run;

data test2;
  set iwd.test1;
run;
