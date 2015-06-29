      $(function() {
        var plot1;
        plot1 = $.jqplot(
          "BTC-MONA_candle",
          [
            [] 
          ],
          {
            title: '06/24-18:00 ~ 06/26-18:27',
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
                  min: '2015-06-24 17:00',
                  max: '2015-06-26 18:00',
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
        } );
