jQuery(document).ready(() => {
    jQuery(":submit").on("click", function () {
        /*
        const formObj = jQuery(this).closest("form");
        const data = formObj.serializeArray();
        const param = {};

        data.forEach((hash) => {
            param[hash.name] = hash.value;
        });

        jQuery.ajax({
            type: formObj.attr("method"),
            url: "./app",
            data: param,
        }).done(function (content) {
            jQuery("#stage").html(content);
        });

        return false;

         */
    });
});
