function update_amt() {
    var rate = parseFloat($('#order_rate').val());
    var amt_a = parseFloat($('#order_amt_a').val());
    var rate_s = parseFloat($('#order_rate_s').val());
    var amt_a_s = parseFloat($('#order_amt_a_s').val());
    console.log('here');

    if (rate > 0 && amt_a > 0) {
        var amt_b = rate * amt_a;
        console.log(amt_b);
        $('#order_amt_b').val(Math.round(amt_b * 1e9) / 1e9);
    }
    if (rate_s > 0 && amt_a_s > 0) {
        var amt_b_s = rate_s * amt_a_s;
        console.log(amt_b_s);
        $('#order_amt_b_s').val(Math.round(amt_b_s * 1e9) / 1e9);
    }
}

function update_amt_coinio() {
    var amt = parseFloat($('#coinio_amt').val());
    var fee = parseFloat($('#coinio_fee').val());
    if (amt > 0) {
        var total = amt + fee;
        $('#coinio_flag').val(Math.round(total * 1e9) / 1e9);
    }
    else
        $('#coinio_flag').val(0);
}


