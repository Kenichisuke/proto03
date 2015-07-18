      (function() {
        var plot1;
        plot1 = $.jqplot(
          "MONA-DOGE_candle",
          [
            [] 
          ],
          {
            title: '07/16-21:00 ~ 07/18-21:00',
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
                  min: '2015-07-16 20:00',
                  max: '2015-07-18 21:00',
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
