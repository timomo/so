const pool_sound = {};
master_sound = [];

music = new Vue({
    data: {
        request: undefined,
        play: undefined,
        past: undefined,
    },
    watch: {
        request: function (newVal, oldVal)
        {
            const self = this;
            self.play = newVal;
        },
        play: function (newVal, oldVal)
        {
            const self = this;
            self.past = oldVal;
            change_music(newVal);
        },
    },
});

function change_music(id)
{
    if (chara_config["楽曲"] !== "あり") return true;
    const soundObj = get_sound_object({sound: music.past, type: 2});
    if (soundObj)
    {
        soundObj.fade(0.6, 0, 1000);
        soundObj.on("fade", function ()
        {
            stop_sound({sound: music.past, type: 2});
            play_sound({sound: id, type: 2});
        });
        return true;
    }
    if (id)
    {
        play_sound({sound: id, type: 2});
    }
}

function play_cv(cv, type)
{
    const id = cv + "-" + type;
    const option = {};
    option.type = 3;
    option.sound = id;
    play_sound(option);
}

function play_sound(option)
{
    const opts = {};
    if (option.type === 1)
    {
        if (chara_config["戦闘効果音"] === "なし") return true;
    } else if (option.type === 2)
    {
        if (chara_config["戦闘楽曲"] === "なし") return true;
        opts.loop = true;
    } else if (option.type === 3)
    {
        if (chara_config["音声"] === "なし") return true;
    }
    const conf = get_master_sound(option.sound);
    if (conf === undefined)
    {
        console.warn(option.sound);
        return false;
    }
    if (option.sound.match(/^music-etc/))
    {
        opts.volume = 0.6;
    } else if (option.type === 3)
    {
        opts.volume = 0.8;
    } else if (option.sound === "battle-music6" || option.sound === "battle-music7" || option.sound === "town1" || option.sound === "town2" || option.sound === "orchestra26" || option.sound === "fantasy03")
    {
        opts.volume = 0.6;
    }
    opts.src = ["/public/sound/" + conf["ファイル名"]];
    const se = new Howl(opts);
    se.play();

    if (option.type === 2)
    {
        jQuery.jGrowl("BGM: " + option.sound);
        pool_sound[option.sound] = se;
    }
}

function stop_sound(option)
{
    if (pool_sound[option.sound] === undefined) return false;
    pool_sound[option.sound].pause();
    pool_sound[option.sound] = undefined;
    return true;
}

function get_sound_object(option)
{
    if (pool_sound[option.sound] === undefined) return false;
    return pool_sound[option.sound];
}

function get_master_sound(name)
{
    for (let i = 0; i < master_sound.length; i++)
    {
        if (master_sound[i]["名称"] === name) {
            return master_sound[i];
        }
    }
}