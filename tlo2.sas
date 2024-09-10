
  data carsAllCnt;
    declare hash H();
    H.defineKey("make");
    H.defineData("make");
    H.defineData("cnt");
    H.defineDone();

    do until (EOF);
      cnt = 0;
      base = 0;
      do until(last.make);
        set sashelp.cars end = EOF;
          by make;
        cnt + (type = "Sedan");
        output;
      end;
      if cnt then put make= cnt=;
      _N_ = H.add();
    end;

    H.output(dataset:"sedanCnt");
    keep make model cnt;
  run;

  proc sort data = sedanCnt;
    by cnt;
  run;

  proc print data = sedanCnt;
    format cnt best.;
  run;
  
