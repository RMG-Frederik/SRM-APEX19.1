Number.prototype.formatMoney = function(decPlaces, thouSep, decSep) {
    /* this function taken from http://stackoverflow.com/questions/9318674/javascript-number-currency-formatting */
    var n = this,
        decPlaces = isNaN(decPlaces = Math.abs(decPlaces)) ? 2 : decPlaces,
        decSep = decSep == undefined ? "." : decSep,
        thouSep = thouSep == undefined ? "," : thouSep,
        sign = n < 0 ? "-" : "",
        i = parseInt(n = Math.abs(+n || 0).toFixed(decPlaces)) + "",
        j = (j = i.length) > 3 ? j % 3 : 0;
    return sign + (j ? i.substr(0, j) + thouSep : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thouSep) + (decPlaces ? decSep + Math.abs(n - i).toFixed(decPlaces).slice(2) : "");
};

function parseNumeric(v) {
    //strip any non-numeric characters and return a non-null numeric value
    return parseFloat(v.replace(/[^\d.-]/g, '')) || 0;
}

$(document).ready(function() {
    //automatically format any item with the "edit_money" class
    $(document).on('change', '.edit_money', function() {
        var i = "#" + $(this).attr("id"),
            v = $(i).val();
        if (v) { $(i).val(parseNumeric(v).formatMoney()); }
    });
});