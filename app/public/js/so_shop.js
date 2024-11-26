function confirm_window(name, event)
{
    const menus = jQuery(name);
    const menu = menus.first().clone().show(); // 全てをcloseしてから、1つだけshowする
    const input = jQuery(event.target);
    const div = input.closest("div.blackboard.question");
    const offset = input.offset();
    offset.top += 16;
    menu.show();
    menu.draggable();

    if(div.css("display") === "none")
    {
        div.show();
    }

    if(menus.length === 1)
    {
        div.append(menu);
    }

    menu.zIndex = input.zIndex + 1;
    menu.offset({ top: offset.top });

    div.find("input:hidden[name='item_no']").val(input.val());
    menu.find("div.menu-close").bind("click", (event) => {
        event.stopPropagation();
        menu.remove();
    });

    menu.find(".item-submit").bind("click", (event) => {
        const form = jQuery(event.target).closest("form");
        const param = form.serializeArray();
        const tmp = {};

        param.forEach((ary) => {
            tmp[ary.name] = ary.value;
        });

        jQuery.post("/instant", tmp, (data) => {
            jQuery("#td_item").trigger("click");
            return true;
        });
    });
}
