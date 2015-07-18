      (function() {
        var plot1;
        plot1 = $.jqplot(
          "MONA-DOGE_candle",
          [
            [] 
          ],
          {
<<<<<<< HEAD
            title: '07/16-14:00 ~ 07/18-14:00',
=======
            title: '07/16-21:00 ~ 07/18-21:00',
>>>>>>> prgpattern
            seriesDefaults: {
              renderer: jQuery . jqplot . OHLCRenderer,
              rendererOptions: {
                  candleStick: true,
                  fillUpBody: true,
                  fillDownBody: true,
                  upBodyColor: 'blue',
                  downBodyColor: 'red'
              }
            },
            axes:{
              xaxis:{
                  renderer: jQuery . jqplot . DateAxisRenderer,
<<<<<<< HEAD
                  min: '2015-07-16 13:00',
                  max: '2015-07-18 14:00',
=======
                  min: '2015-07-16 20:00',
                  max: '2015-07-18 21:00',
>>>>>>> prgpattern
                  tickInterval: '2 hours',
                  tickOptions:{
                      formatString: '%H'
                  }
              },
              yaxis: {
                  tickOptions:{formatString:'$%d'}
              }
            }
          }
        );
        plot1.replot();
        } )();
