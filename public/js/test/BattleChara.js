// That's default v4 vertex shader, just in case

const myVertex = `
attribute vec2 aVertexPosition;
attribute vec2 aTextureCoord;

uniform mat3 projectionMatrix;

varying vec2 vTextureCoord;

void main(void) {
gl_Position = vec4((projectionMatrix * vec3(aVertexPosition, 1.0)).xy, 0.0, 1.0);
vTextureCoord = aTextureCoord;
}
`;

const myFragment = `
varying vec2 vTextureCoord;

uniform sampler2D uSampler;
uniform vec4 inputSize;
uniform vec4 outputFrame;
uniform vec2 shadowDirection;
uniform float floorY;

void main(void) {
//1. get the screen coordinate
vec2 screenCoord = vTextureCoord * inputSize.xy + outputFrame.xy;
//2. calculate Y shift of our dimension vector
vec2 shadow;
//shadow coordinate system is a bit skewed, but it has to be the same for screenCoord.y = floorY
float paramY = (screenCoord.y - floorY) / shadowDirection.y;
shadow.y = paramY + floorY;
shadow.x = screenCoord.x + paramY * shadowDirection.x;
vec2 bodyFilterCoord = (shadow - outputFrame.xy) * inputSize.zw; // same as / inputSize.xy

vec4 originalColor = texture2D(uSampler, vTextureCoord);
vec4 shadowColor = texture2D(uSampler, bodyFilterCoord);
shadowColor.rgb = vec3(0.0);
shadowColor.a *= 0.5;

// normal blend mode coefficients (1, 1-src_alpha)
// shadow is destination (backdrop), original is source
gl_FragColor = originalColor + shadowColor * (1.0 - originalColor.a);
}
`;

const damageStyle = new PIXI.TextStyle({
    fontFamily: 'Kosugi Maru',
    fontSize: 28,
    // fontStyle: 'italic',
    // fontWeight: 'bold',
    fill: ['#ffffff', '#ffffff'], // gradient
    stroke: '#4a1850',
    strokeThickness: 5,
    dropShadow: true,
    dropShadowColor: '#000000',
    dropShadowBlur: 1,
    dropShadowAngle: Math.PI / 6,
    dropShadowDistance: 1,
    wordWrap: true,
    wordWrapWidth: 440,
});

export class BattleChara extends PIXI.AnimatedSprite
{
    constructor(props)
    {
        super(props.textures, props.autoUpdate);
        const self = this;

        self["移動量"] = {};
        self["移動量"]["前進"] = 0.2;
        self["移動量"]["後退"] = 0.2;
        self["移動量"]["振動"] = 8;
        self["移動量"]["移動"] = 0.4;
        self["移動量"]["フレーム"] = 0.1;
        self["速度"] = {};
        self["速度"]["前進"] = 0.5;
        self["速度"]["通常待機"] = 0.1;
        self["速度"]["突き"] = 0.5;
        self["速度"]["逃げる"] = 0.5;
        self["速度"]["振り"] = 0.5;
        self["速度"]["勝利"] = 0.5;
        self["速度"]["詠唱待機"] = 0.5;
        self["速度"]["飛び道具"] = 0.5;
        self["速度"]["瀕死"] = 0.5;
        self["速度"]["防御"] = 0.5;
        self["速度"]["汎用スキル"] = 0.5;
        self["速度"]["状態異常"] = 0.5;
        self["速度"]["ダメージ"] = 0.5;
        self["速度"]["魔法"] = 0.5;
        self["速度"]["睡眠"] = 0.5;
        self["速度"]["回避"] = 0.5;
        self["速度"]["アイテム"] = 0.5;
        self["速度"]["戦闘不能"] = 0.5;
        self["時間"] = {};
        self["時間"]["最終呼出"] = (new Date).getTime();
        self["時間"]["非アクティブ"] = (new Date).getTime(); // コマンドを実行していない時間
        self["時間"]["アクティブ"] = 0; // 最後にコマンドを実行した時間

        self.ffa2 = new Vue({
            data: {
                app: undefined,
                ui: undefined,
                chara_status: {},
                frame_animation:
                {
                    name: undefined,
                    old_name: undefined,
                },
                type: "chara",
                x: -1,
                y: -1,
                md5: undefined,
                turn_no: 1,
                path: {
                    sprite_sheet: undefined,
                },
                job: {
                    clear: undefined,
                    command: undefined,
                    args: undefined,
                    job: undefined,
                    callback: undefined,
                    commands: [],
                    callbacks: [],
                },
                buff: {},
                power: [],
                damage: [],
                children: [],
                width: 64,
                height: 64,
                object: {},
                counter: {
                    jump_power: 0,
                    jump_forward: 0,
                    jump: 0,
                },
                direction: "right",
                const_id: undefined,
                data: {},
                default: {
                    x: -1,
                    y: -1,
                    scale: {
                        x: 1,
                        y: 1,
                    },
                    anchor: {
                        x: -3000,
                        y: -3000,
                    },
                    height: 0,
                    width: 0,
                    gravity: 10,
                    jump_forward: 5,
                    jump_power: 80,
                },
                face: undefined,
                state: "stop",
                flag: {
                    ready: false,
                    completed_destroy: false,
                    destroy: false,
                    fade_in: false,
                    hp_gauge_fade_out: false,
                    standing_pose: true,
                    standing_reverse: false,
                    damage: [],
                    power: [],
                    no_ground: false,
                    jumping: false,
                },
                constitution: {},
                sprite_sheet: undefined,
                emotion_sprite_sheet: undefined,
            },
            watch: {
                chara_status: function (newVal, oldVal) {
                    // TODO: ダンジョンRPGでは遅延するので一旦コメントアウト
                    // self.setCharaPosition();
                    // self.setDefaultPosition();
                },
                "job.clear": function (newVal, oldVal) {
                    if (! newVal) {
                        return true;
                    }

                    const idx = self.ffa2.job.commands.findIndex((value ,index, obj) => {
                        return value.id === newVal.id;
                    });

                    if (idx === -1) {
                        console.error("job.commandsにない!");
                        return false;
                    }

                    const job = self.ffa2.job.commands.splice(idx, 1);
                    const cb = self.ffa2.job.callbacks.splice(idx, 1);

                    if (cb.length !== 0) {
                        cb[0].call(self, job[0]);
                    }
                    else {
                        console.error("job.commandsでspliceに失敗!", job, cb);
                    }

                    // console.error(self.ffa2.job.commands);

                    self.ffa2.job.clear = undefined;
                },
                "flag.completed_destroy": function (newVal, oldVal) {
                    console.error("111111");
                    if (newVal === true)
                    {
                        console.error("22222");
                        self.emit("completed_destroy", newVal);
                    }
                },
                "flag.ready": function (newVal, oldVal)
                {
                    if (newVal === true)
                    {
                        self.emit("ready", newVal);
                    }
                },
            }
        });

        self.emotion_sprite_sheet = props.emotion_sprite_sheet;
        self.sprite_sheet = props.sprite_sheet;
        self.const_id = props.const_id;
        self.ffa2.chara_status = props.chara_status;
        self.ffa2.constitution = props.constitution;
        self.md5 = props.md5;
        self.turn_no = props.turn_no;
        self.fade_in = props.fade_in;
        self.app = props.app;
        self.ui = props.ui;
        self.path_sprite_sheet = props.path_sprite_sheet;
        self.resources = props.resources;
        self.face = props.face;

        self.ffa2.constitution[self.md5].current = self.ffa2.constitution[self.md5][self.turn_no];
        self.ffa2.chara_status[self.md5].current = self.ffa2.chara_status[self.md5][self.turn_no];

        self["時間"]["非アクティブ"] = (new Date).getTime();
        self["時間"]["アクティブ"] = (new Date).getTime();

        // console.error(self.ffa2.chara_status, self.ffa2.constitution);

        // self.anchor.set(0.5, 1.0);
    }

    get const_id()
    {
        return this.ffa2.const_id;
    }

    set const_id(value)
    {
        this.ffa2.const_id = value;
    }

    get turn_no()
    {
        return this.ffa2.turn_no;
    }

    set turn_no(value)
    {
        this.ffa2.turn_no = value;
    }

    get md5()
    {
        return this.ffa2.md5;
    }

    set md5(value)
    {
        this.ffa2.md5 = value;
    }

    get emotion_sprite_sheet()
    {
        return this.ffa2.emotion_sprite_sheet;
    }

    set emotion_sprite_sheet(value)
    {
        this.ffa2.emotion_sprite_sheet = value;
    }

    get sprite_sheet()
    {
        return this.ffa2.sprite_sheet;
    }

    set sprite_sheet(value)
    {
        this.ffa2.sprite_sheet = value;
    }

    switch(md5, turn_no)
    {
        this.switch_constitution(md5, turn_no);
        this.switch_chara_status(md5, turn_no);
    }

    switch_turn_start(md5, turn_no)
    {
        // 現状の仕様では、どうしても、2ターン目は1ターンのデータを見に行かないといけないので1ターン目はそのまま。。。
        if (turn_no === 1) {
            this.switch_constitution(md5, turn_no);
            this.switch_chara_status(md5, turn_no);
        }
        else {
            if (this.constitution["参戦フラグ"] !== 0 || this.constitution["召喚フラグ"] !== 0) {
                this.switch_constitution(md5, turn_no);
                this.switch_chara_status(md5, turn_no);
            }
            else {
                this.switch_constitution(md5, turn_no);
                this.switch_chara_status(md5, turn_no - 1);
            }
        }
    }

    switch_turn_end(md5, turn_no)
    {
        // 次のターンのデータがあれば、読み込むが、なければswitchしない
        if (this.ffa2.constitution[md5][turn_no + 1]) {
            this.switch_constitution(md5, turn_no + 1);
            this.switch_chara_status(md5, turn_no + 1);
        }
    }

    switch_chara_status(md5, turn_no)
    {
        this.ffa2.chara_status[md5].current = this.ffa2.chara_status[md5][turn_no];
        if (! this.ffa2.chara_status[md5].current) {
            console.error("switch chara_status失敗!", md5, turn_no, this.const_id, this.ffa2.chara_status);
            this.ffa2.chara_status[md5].current = undefined;
        }
    }

    switch_constitution(md5, turn_no)
    {
        this.ffa2.constitution[md5].current = this.ffa2.constitution[md5][turn_no];
        if (! this.ffa2.constitution[md5].current) {
            console.error("switch 失敗!", md5, turn_no, this.const_id, this.ffa2.constitution);
            this.ffa2.constitution[md5].current = undefined;
        }
    }

    isValid() {
        return !(!this.constitution || !this.chara_status);
    }

    get chara_status()
    {
        return this.ffa2.chara_status[this.md5].current;
    }

    set chara_status(value)
    {
        this.ffa2.chara_status[this.md5][this.turn_no] = value;
    }

    get constitution()
    {
        return this.ffa2.constitution[this.md5].current;
    }

    set constitution(value)
    {
        this.ffa2.constitution[this.md5][this.turn_no] = value;
    }

    get fade_in()
    {
        return this.ffa2.flag.fade_in;
    }

    set fade_in(value)
    {
        this.ffa2.flag.fade_in = value;
    }

    get app()
    {
        return this.ffa2.app;
    }

    set app(value)
    {
        this.ffa2.app = value;
    }

    get ui()
    {
        return this.ffa2.ui;
    }

    set ui(value)
    {
        this.ffa2.ui = value;
    }

    get direction()
    {
        return this.ffa2.direction;
    }

    set direction(value)
    {
        this.ffa2.direction = value;
    }

    get path_sprite_sheet()
    {
        return this.ffa2.path.sprite_sheet;
    }

    set path_sprite_sheet(value)
    {
        this.ffa2.path.sprite_sheet = value;
    }

    getPartyNum()
    {
        const self = this;
        return self.chara_status["パーティー内番号"];
    }

    resetPosition()
    {
        const self = this;
        self.x = self.ffa2.default.x;
        self.y = self.ffa2.default.y;
        self.scale.x = self.ffa2.default.scale.x;
        self.scale.y = self.ffa2.default.scale.y;
        self.height = self.ffa2.default.height;
        self.width = self.ffa2.default.width;
        self.anchor.x = self.ffa2.default.anchor.x;
        self.anchor.y = self.ffa2.default.anchor.y;
    }

    setDefaultPosition()
    {
        const self = this;
        self.ffa2.default.x = self.x;
        self.ffa2.default.y = self.y;
        self.ffa2.default.scale.x = self.scale.x;
        self.ffa2.default.scale.y = self.scale.y;
        self.ffa2.default.height = self.height;
        self.ffa2.default.width = self.width;
        self.anchor.set(0.5, 1);
        self.ffa2.default.anchor.x = self.anchor.x;
        self.ffa2.default.anchor.y = self.anchor.y;
    }

    setCharaPosition()
    {
        const self = this;
        const chara = self.chara_status;
        const presetY = 48;
        const presetX = 40;
        const presetX2 = 0; // Party2Use
        const presetY2 = 90; // なぜか上に寄っているので...
        const num = self.getPartyNum();
        let constY = num % 5;
        let constX = num % 2;
        if (constY === 0) constY = 5;
        let y = constY * 35 + presetY;
        let x = constX * 20 + presetX;

        if (num === -1)
        {
            x = -5000;
            y = -5000;
        }
        if (chara["パーティーid"] === 1)
        {
            self.direction = "right";
            self.scale.x = -1;
        }
        else if (chara["パーティーid"] === 2)
        {
            x += 125;
            self.direction = "left";
            x += presetX2;
        }
        if (constX === 1)
        {
            x += 30;
        }

        if (self.isTransparent())
        {
            self.alpha = 0;
        }

        const pos = self.app.stage.toLocal({x: x, y: y}, undefined, undefined, undefined, PIXI.projection.TRANSFORM_STEP.BEFORE_PROJ);

        pos.y = -pos.y + presetY2;

        if (self.scale.x < 0) {
            self.setPosition(pos.x - (self.width * self.ffa2.default.anchor.x), pos.y + (self.height * self.ffa2.default.anchor.y));
        }
        else {
            self.setPosition(pos.x + (self.width * self.ffa2.default.anchor.x), pos.y + (self.height * self.ffa2.default.anchor.y));
        }
    }

    setPosition(x, y)
    {
        const self = this;
        self.x = x;
        self.y = y;
    }

    isTransparent()
    {
        const self = this;
        const constitution = self.constitution;

        // undefinedはこのアニメーション中の出来事
        if (constitution["召喚フラグ"] === undefined || constitution["参戦フラグ"] === undefined) {
            return true;
        }

        if (constitution["召喚フラグ"] === 0 && constitution["参戦フラグ"] === 0) {
            return false;
        }
        if (constitution["召喚フラグ"] === self.turn_no || constitution["参戦フラグ"] === self.turn_no) {
            return true;
        }
        return false;
    }

    isDead()
    {
        const self = this;

        try
        {
            const now = self.constitution;

            if (now["蘇生フラグ"] === 0) {
                // undefinedはこのアニメーション中の出来事
                if (now["死亡フラグ"] === undefined) {
                    return true;
                }
                if (now["死亡フラグ"] === 0) {
                    return false;
                }
                else if (now["死亡フラグ"] === self.turn_no) {
                    return false;
                }
                else {
                    return true;
                }
            }
            if (now["蘇生フラグ"] === self.turn_no) {
                return false;
            }
            return true;
        } catch (e) {
            console.error(self.ffa2.constitution);
            new Error(e);
        }
    }

    isReady()
    {
        const self = this;
        return self.ffa2.flag.ready;
    }

    gotoAndNext(newName)
    {
        const self = this;

        if (self.ffa2.frame_animation.name !== newName)
        {
            self.ffa2.frame_animation.old_name = self.ffa2.frame_animation.name;
            self.ffa2.frame_animation.name = newName;
            self.stop();
            if (self.sprite_sheet.animations[newName])
            {
                self.textures = self.sprite_sheet.animations[newName];
            }
            else
            {
                console.error("sprite_sheet.animations[" + newName + "]がundef!", self.sprite_sheet.animations);
            }
        }

        if (! self.playing)
        {
            self.animationSpeed = self["速度"][newName] || 1;
            self.play();

            // TODO: 影をつけたい
            const filter = new PIXI.Filter(myVertex, myFragment);
            filter.uniforms.shadowDirection = [0.4, 0.5];
            filter.uniforms.floorY = 0.0;
            filter.padding = 500;
            self.filters = [filter];
            self.ss = filter;
        }

        if (self.isDead()) {
            const colorMatrix = [
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
            ];
            const filter = new PIXI.filters.ColorMatrixFilter();
            filter.matrix = colorMatrix;
            filter.brightness(0.5, false);
            self.filters.push(filter);
        }

        self.ss.uniforms.floorY = self.toGlobal(new PIXI.Point(300, 0)).y;
    }

    redrawName()
    {
        const self = this;
        const key = "名前";
        const presetY = self.ffa2.default.height / 2;
        let presetX = -self.ffa2.default.width / 2;

        if (self.scale.x > 0) {
            presetX = self.ffa2.default.width / 6;
        }

        let richText = self.getChildAtKey(key, 0);
        let pos;

        if (! richText)
        {
            richText = new PIXI.Text(self.chara_status[key], self.ui.defaultStyle);
            self.addChildKey(key, richText);
        }

        pos = self.toFixedGlobal("stage", "temp", self.ffa2.default);

        if (self.scale.x < 0) {
            pos.x += self.ffa2.default.width * self.ffa2.default.anchor.x;
        }
        else {
            pos.x -= self.ffa2.default.width * self.ffa2.default.anchor.x;
        }

        pos.x += presetX;
        pos.y -= presetY;

        richText.x = pos.x;
        richText.y = pos.y;
    }

    toFixedGlobal(container, key, position)
    {
        const self = this;

        if (key !== "temp") {
            if (! self.ffa2.counter[container]) {
                self.ffa2.counter[container] = {};
            }
            if (self.ffa2.counter[container][key]) {
                return jQuery.extend(true, self.ffa2.counter[container][key]);
            }
        }

        const pos = self.app[container].toGlobal({ x: position.x, y: position.y }, undefined, undefined);

        if (key !== "temp") {
            if (! self.ffa2.counter[container]) {
                self.ffa2.counter[container] = {};
            }
            self.ffa2.counter[container][key] = pos;
        }

        return pos;
    }

    redrawHpGauge()
    {
        const self = this;
        const key = "HPゲージのフレーム";
        const key2 = "HPゲージ";
        const constX = 0.7; // Xの拡大率
        const constY = 0.7; // Yの拡大率
        const presetY = 30;
        const presetX = 60;

        // HPゲージ量計算
        let len = self.chara_status["HP"] / self.chara_status["最大HP"];
        if (len < 0) len = 0;

        const name = self.getChildAtKey("名前", 0);

        let hp_gauge = self.getChildAtKey(key2, 0);

        if (! hp_gauge)
        {
            hp_gauge = PIXI.Sprite.from(key2);
            self.addChildKey(key2, hp_gauge);
        }
        hp_gauge.position.set(name.x, name.y + name.height);

        let hp_gauge_frame = self.getChildAtKey(key, 0);

        if (! hp_gauge_frame)
        {
            hp_gauge_frame = PIXI.Sprite.from(key);
            self.addChildKey(key, hp_gauge_frame);
        }
        hp_gauge_frame.position.set(name.x, name.y + name.height);

        hp_gauge.scale.x = len;
        hp_gauge.scale.y = 1;
        hp_gauge_frame.scale.x = 1;
        hp_gauge_frame.scale.y = 1;

        hp_gauge.scale.x *= constX;
        hp_gauge.scale.y *= constY;
        hp_gauge_frame.scale.x *= constX;
        hp_gauge_frame.scale.y *= constY;
    }

    removeChildAtKey(key, index)
    {
        const self = this;
        if (! self.ffa2.object.hasOwnProperty(key))
        {
            self.ffa2.object[key] = [];
        }
        const child = self.ffa2.object[key].splice(index, 1);
        if (child.length !== 0)
        {
            self.app.stage.removeChild(child[0]);
            child[0].destroy({children:true, texture:false, baseTexture:false});
        }
        return child;
    }

    getChildAtKey(key, index)
    {
        const self = this;
        if (! self.ffa2.object.hasOwnProperty(key))
        {
            self.ffa2.object[key] = [];
        }
        return self.ffa2.object[key][index];
    }

    addChildKey(key, obj)
    {
        const self = this;
        self.app.stage.addChild(obj);

        if (! self.ffa2.object.hasOwnProperty(key))
        {
            self.ffa2.object[key] = [];
        }
        self.ffa2.object[key].push(obj);
    }

    hitCheck(target)
    {
        const self = this;

        if (self.ffa2.flag.jumping === false && self.ffa2.flag.no_ground === false) {
            return false;
        }

        if (self.ffa2.counter.jump_power >= 0) {
            return false;
        }

        if ((target.ffa2.default.y - target.ffa2.default.height) <= self.y) {
            return true;
        }

        return false;
    }

    calcMoveAmount(enemy)
    {
        const self = this;

        let moveX = ((enemy.x - enemy.width) - self.x) * self["移動量"]["前進"] * self["移動量"]["フレーム"];
        let moveY = (enemy.y + (enemy.height / 2) - self.y) * self["移動量"]["前進"] * self["移動量"]["フレーム"];
        if (self.ffa2.direction === "left") {
            moveX = ((enemy.x + enemy.width) - self.x) * self["移動量"]["前進"] * self["移動量"]["フレーム"];
        }

        return { x: moveX, y: moveY };
    }

    jump(args)
    {
        const self = this;
        const key = "ジャンプ";
        self.ffa2.state = key;

        let hx = self.x;
        let hy = self.y;

        const enemy = self.getCharacter(args);

        if (self.ffa2.flag.jumping === true)
        {
            self.ffa2.counter.jump_power -= self.ffa2.default.gravity;
            hy -= (self.ffa2.counter.jump_power * self["移動量"]["フレーム"]);
            hx += (self.ffa2.counter.jump_forward * self["移動量"]["フレーム"]);
            const ret = self.calcMoveAmount(enemy);
            hy += ret.y;
            hx += ret.x;
        }

        const func = () =>
        {
            self.ffa2.flag.no_ground = false;
            self.ffa2.flag.jumping = false;
            self.ffa2.counter.jump_power = 0;
            self.ffa2.counter.jump_forward = 0;
            self.ffa2.counter.jump = 0;

            self.clearCommand();
            self.clearState();
        };

        if (self.ffa2.counter.jump >= 60)
        {
            func();
        }

        if (self.ffa2.counter.jump !== 0)
        {
            if (self.hitCheck(self) === true)
            {
                func();
            }
            else
            {
                self.ffa2.flag.no_ground = true;
                self.ffa2.flag.jumping = true;
            }
        }

        if (self.ffa2.flag.jumping === false)
        {
            if (self.ffa2.flag.no_ground === false)
            {
                self.ffa2.flag.jumping = true;
                self.ffa2.counter.jump_power = self.ffa2.default.jump_power;
                self.ffa2.counter.jump_forward = self.ffa2.default.jump_forward;
            }
        }

        self.moveAt(hx, hy);

        self.ffa2.counter.jump += 1;
    }

    forward()
    {
        const self = this;
        self.ffa2.state = "move";
        self.gotoAndNext("前進");
        self.ffa2.frame_animation.counter += 1;
        let moveX = ((self.ffa2.default.x + (self.ffa2.width / 2)) - self.x) * self["移動量"]["前進"] * self["移動量"]["フレーム"];
        let moveY = (self.ffa2.default.y - self.y) * self["移動量"]["前進"] * self["移動量"]["フレーム"];
        if (self.ffa2.direction === "left") {
            moveX = ((self.ffa2.default.x - (self.ffa2.width / 2)) - self.x) * self["移動量"]["前進"] * self["移動量"]["フレーム"];
        }

        if (Math.abs(moveX) < 0.5 && Math.abs(moveY) < 0.5) {
            self.gotoAndNext("通常待機");
            self.clearCommand();
            self.clearState();
            return true;
        }
        self.moveBy(moveX, moveY);
    }

    backward()
    {
        const self = this;
        self.ffa2.state = "move";
        self.gotoAndNext("前進");
        let moveX = ((self.ffa2.default.x) - self.x) * self["移動量"]["後退"] * self["移動量"]["フレーム"];
        let moveY = ((self.ffa2.default.y) - self.y) * self["移動量"]["後退"] * self["移動量"]["フレーム"];

        if (Math.abs(moveX) < 0.5 && Math.abs(moveY) < 0.5) {
            self.setPosition(self.ffa2.default.x, self.ffa2.default.y);
            self.gotoAndNext("通常待機");
            self.clearCommand();
            self.clearState();
            return true;
        }
        self.moveBy(moveX, moveY);
    }

    rumble()
    {
        const self = this;
        const key = "rumble";

        if (self.ffa2.state !== "stop" && self.ffa2.state !== key) return true;
        self.ffa2.state = key;

        // self.gotoAndNext("通常待機");
        const x = self["移動量"]["振動"];

        if (self.ffa2.counter[key] === undefined) self.ffa2.counter[key] = 0;

        if (self.ffa2.counter[key] === 0)
        {
            self.setPosition(self.ffa2.default.x, self.ffa2.default.y);
        }
        else if (self.ffa2.counter[key] % 6 === 0)
        {
            self.moveBy(x * -1, 0);
        }
        else if (self.ffa2.counter[key] % 3 === 0)
        {
            self.moveBy(x, 0);
        }

        if (self.ffa2.counter[key] === 30)
        {
            self.ffa2.counter[key] = 0;
            self.setPosition(self.ffa2.default.x, self.ffa2.default.y);
            self.clearCommand();
            self.clearState();
            // self.gotoAndNext("通常待機");
            return true;
        }
        self.ffa2.counter[key] += 1;
    }

    summon(constKey)
    {
        const self = this;
        const target = self.getCharacter(constKey);

        if (! target)
        {
            console.error("summon", constKey, self.ffa2.turn_no, target);
            self.clearCommand();
            self.clearState();
            self.gotoAndNext("通常待機");
            return;
        }

        target.alpha = 1;
        self.clearCommand();
        self.clearState();
        self.gotoAndNext("通常待機");
    }

    getCharacter(constKey)
    {
        const self = this;

        if (constKey === 1)
        {
            return { x: 0, y: 180, ffa2: { width: 64, height: 64 } };
        }
        else if (constKey === 2)
        {
            return { x: 50, y: 180, ffa2: { width: 64, height: 64 } };
        }
        else if (constKey === 3)
        {
            return { x: 100, y: 180, ffa2: { width: 64, height: 64 } };
        }
        else if (constKey === 4)
        {
            return { x: 150, y: 180, ffa2: { width: 64, height: 64 } };
        }
        else if (constKey === 5) // エネミー:5
        {
            return { x: 200, y: 180, ffa2: { width: 64, height: 64 } };
        }
        else if (constKey === 6) // プレイヤー:1
        {
            return { x: 20 - 32, y: 250, ffa2: { width: 64, height: 64 } };
        }
        else if (constKey === 7)
        {
            return { x: 70 - 32, y: 250, ffa2: { width: 64, height: 64 } };
        }
        else if (constKey === 8)
        {
            return { x: 120 - 32, y: 250, ffa2: { width: 64, height: 64 } };
        }
        else if (constKey === 9)
        {
            return { x: 170 - 24, y: 250, ffa2: { width: 64, height: 64 } };
        }
        else if (constKey === 10)
        {
            return { x: 220 - 32, y: 250, ffa2: { width: 64, height: 64 } };
        }

        /*
        const target = window.getCharacterByMD5AndTurnNo(constKey, self.md5, self.turn_no);

        if (! target)
        {
            console.error("getCharacter", constKey, self.md5, self.turn_no, target);
        }

        return target;
        */
    }

    moveTo(constKey)
    {
        const self = this;
        const key = "move";
        if (self.ffa2.state !== "stop" && self.ffa2.state !== key) return true;
        self.ffa2.state = key;

        const enemy = self.getCharacter(constKey);
        if (!enemy) {
            console.error("どうやらいない模様。。。", constKey);
            self.clearCommand();
            self.clearState();
            self.gotoAndNext("通常待機");
            return true;
        }

        self.gotoAndNext("前進");
        let moveX = 0;
        const target = self.app.stage.toGlobal({ x: enemy.x, y: enemy.y }, undefined, undefined);
        const my = self.app.stage.toGlobal({ x: self.x, y: self.y }, undefined, undefined);

        if (self.ffa2.direction === "left") moveX = ((target.x + enemy.ffa2.width) - my.x) * self["移動量"]["移動"] * self["移動量"]["フレーム"];
        if (self.ffa2.direction === "right") moveX = (target.x - my.x - self.ffa2.width) * self["移動量"]["移動"] * self["移動量"]["フレーム"];
        let moveY = (target.y - my.y) * self["移動量"]["移動"] * self["移動量"]["フレーム"];
        if (Math.abs(moveX) < 0.5 && Math.abs(moveY) < 0.5) {
            // self.setPosition(target.x, target.y);
            self.clearCommand();
            self.clearState();
            self.gotoAndNext("通常待機");
            return true;
        }

        self.moveBy(moveX, moveY);
    }

    eraseIf(array, fn)
    {
        const self = this;

        for (let i = 0, len = array.length; i < len; ++i)
        {
            if ( fn(array[i], i, array) )
            {
                array.splice(i, 1);
                break;
            }
        }
    }

    motionWeapon(args)
    {
        const self = this;
        const key = "アイテムモーション";
        if (self.ffa2.state !== "stop" && self.ffa2.state !== key) return true;
        self.ffa2.state = key;

        if (self.ffa2.counter[key] === undefined) self.ffa2.counter[key] = 0;

        const item = self.getChildAtKey(key, 0);

        if (self.ffa2.counter[key] === 0) {
            self.gotoAndNext("突き");
            const sprite = new PIXI.Sprite.from(args);
            self.addChildKey(key, sprite);

            const pos = self.app.plane.toGlobal({x: self.x, y: self.y}, undefined, undefined);
            sprite.x = pos.x;
            sprite.y = pos.y - (self.height * self.ffa2.default.anchor.y);

            self.playVoice("attack");
        }
        else if (self.ffa2.counter[key] >= 31)
        {
            self.gotoAndNext("通常待機");
            self.removeChildAtKey(key, 0);
            self.clearCommand();
            self.clearState();
            self.ffa2.counter[key] = 0;
            return true;
        }
        else if (self.ffa2.counter[key] % 4 === 0) {
            item.scale.x *= -1;
            const pos = self.app.plane.toGlobal({x: self.x, y: self.y}, undefined, undefined);
            item.x = pos.x - item.width * 2;
        }
        else if (self.ffa2.counter[key] % 4 === 2) {
            item.scale.x *= -1;
            const pos = self.app.plane.toGlobal({x: self.x, y: self.y}, undefined, undefined);
            item.x = pos.x;
        }
        if (self.ffa2.counter[key] % 4 === 0) {
            play_sound({sound: "attack1", type: 1});
        }
        self.ffa2.counter[key] += 1;
    }

    standingPose()
    {
        const self = this;
        const key = "立ち絵";
        const constY = self.ffa2.default.scale.y * 0.96;
        const constX = self.ffa2.default.scale.x * 0.96;
        const moveY = 0.001;
        let moveX = 0.003;

        if (self.ffa2.default.scale.x < 0)
        {
            moveX *= -1;
        }

        if (self.ffa2.flag.standing_pose === false)
        {
            self.scale.x = self.ffa2.default.scale.x;
            self.scale.y = self.ffa2.default.scale.y;
            return false;
        }

        if (self.ffa2.flag.standing_reverse === false)
        {
            if (self.scale)
            {
                self.scale.y -= moveY;
                self.scale.x -= moveX;

                if (constY > self.scale.y)
                {
                    self.ffa2.flag.standing_reverse = true;
                }
            }
        }
        else
        {
            if (self.scale)
            {
                self.scale.y += moveY;
                self.scale.x += moveX;

                if (self.ffa2.default.scale.y < self.scale.y)
                {

                    self.scale.y = self.ffa2.default.scale.y;
                    self.scale.x = self.ffa2.default.scale.x;
                    self.ffa2.flag.standing_reverse = false;
                }
            }
        }
        // self.y = self.ffa2.default.y - self.height + self.ffa2.default.height;
    }

    effect(args)
    {
        const self = this;
        const key = "effect";

        if (self.state !== "stop" && self.state !== key) return true;
        self.ffa2.state = key;

        if (self.ffa2.counter[key] === undefined) self.ffa2.counter[key] = 0;

        if (self.ffa2.counter[key] === 0) {
            const tmpKey = args[0];
            const tmpOption = args[1] || {};

            if (self.resources.hasOwnProperty(tmpKey)) {
                const effect = new PIXI.AnimatedSprite(self.resources[tmpKey].spritesheet.animations.default, true);
                self.addChildKey(key, effect);
                effect.animationSpeed = tmpOption.animationSpeed || 0.5;

                if (tmpOption.hasOwnProperty("repetition")) {
                    effect.loop = true;
                }
                else {
                    effect.loop = false;
                }

                const sound = tmpOption.sound || "magic";

                if (tmpOption.fullscreen === 1) { // 画面下に基準を合わせたフルスクリーン
                    const scaleX = self.app.screen.width / effect.width;
                    const scaleY = scaleX;
                    effect.scale.x *= scaleX;
                    effect.scale.y *= scaleY;
                    effect.x = 0;
                    effect.y = self.app.screen.height - effect.height;
                    // console.error(effect.x, effect.y);
                }
                else if (tmpOption.fullscreen === 2) { // 画面上に基準を合わせたフルスクリーン

                }
                else if (! tmpOption.hasOwnProperty("fullscreen")) { // 自分の手前
                    if (self.ffa2.direction === "left")
                    {
                        const pos = self.app.stage.toGlobal({x: self.x, y: self.y}, undefined, undefined);
                        effect.x = pos.x - self.width;
                        effect.y = pos.y - (self.height * self.ffa2.default.anchor.y);
                    }
                    else
                    {
                        const pos = self.app.stage.toGlobal({x: self.x, y: self.y}, undefined, undefined);
                        effect.x = pos.x;
                        effect.y = pos.y - (self.height * self.ffa2.default.anchor.y);
                    }
                }

                if (! effect.loop) {
                    play_sound({sound: sound, type: 1});
                    effect.onComplete = () => {
                        self.clearCommand();
                        self.clearState();
                        self.ffa2.counter[key] = 0;
                        self.removeChildAtKey(key, 0);
                    };
                }
                else {
                    let repetition = tmpOption.repetition;

                    effect.onFrameChange = function (number) {
                        if (number === 1) {
                            play_sound({sound: sound, type: 1});
                        }
                        if (number === 0) {
                            repetition--;
                        }
                        if (repetition === 0) {
                            // console.error(tmpKey, number, repetition);
                            self.ffa2.counter[key] = 0;
                            self.removeChildAtKey(key, 0);
                            self.clearCommand();
                            self.clearState();
                            return true;
                        }
                    };
                }

                effect.play();
            }
            else {
                console.error("effectがない！", tmpKey, self.ui.effects);
                self.clearCommand();
                self.clearState();
                self.ffa2.counter[key] = 0;
                return false;
            }
        }

        // console.error(key, self.ffa2.counter[key]);
        self.ffa2.counter[key] += 1;

        if (self.ffa2.counter[key] > 200)
        {
            console.error("effect 時間切れ");
            self.clearCommand();
            self.clearState();
            self.ffa2.counter[key] = 0;
        }
    }

    chant()
    {
        const self = this;
        const key = "chant";
        if (self.ffa2.state !== "stop" && self.ffa2.state !== key) return true;
        if (self.ffa2.counter[key] === undefined) self.ffa2.counter[key] = 0;
        if (self.ffa2.counter[key] === 0) {
            self.ffa2.state = key;
            self.gotoAndNext("詠唱待機");
            self.playVoice("special");
        } else if (self.ffa2.counter[key] >= 1 && self.ffa2.counter[key] <= 24) {
            // noop
        } else if (self.ffa2.counter[key] >= 25 && self.ffa2.counter[key] <= 48) {
            self.gotoAndNext("魔法");
            self.loop = false;
        } else {
            self.ffa2.counter[key] = 0;
            self.clearCommand();
            self.clearState();
        }
        self.ffa2.counter[key] += 1;
    }

    damage(dmg)
    {
        const self = this;
        /*
        let hp_gauge = self.getChildAtKey("HPゲージ", 0);
        let namae = self.getChildAtKey("名前", 0);

        if (! hp_gauge)
        {
            self.redrawHpGauge();
            hp_gauge = self.getChildAtKey("HPゲージ", 0);
        }
        if (! namae)
        {
            self.redrawName();
            namae = self.getChildAtKey("名前", 0);
        }
        let hp_gauge_frame = self.getChildAtKey("HPゲージのフレーム", 0);

        hp_gauge.alpha = 1;
        hp_gauge_frame.alpha = 1;
        namae.alpha = 1;


         */
        self.popNumber("damage", dmg);

        // self.playVoice("damage");
        self.chara_status["HP"] -= dmg;
        self.clearCommand();
        self.clearState();
    }

    popNumber(type, value)
    {
        const self = this;
        const values = String(value).split("");
        const x = self.random(32);
        const y = self.random(32);
        let presetX = 0;
        const presetY = 0;

        for (let i = 0; i < values.length; i++) {
            setTimeout(() => {
                const len = self.ffa2.flag[type].length;
                const key = type + len + "_" + i;

                self.ffa2.flag[type][len] = 0;
                self.ffa2[type][len] = key;

                const damageText = new PIXI.Text(values[i], damageStyle);
                self.addChildKey(key, damageText);

                const pos = self.toFixedGlobal("stage", "temp", self.ffa2.default);

                pos.y -= self.height * self.ffa2.default.anchor.y + 50;
                damageText.x = pos.x + presetX;
                damageText.y = pos.y + presetY;
                presetX += damageText.width;
                damageText.alpha = 0;
            }, 100 * i);
        }
    }

    random(max)
    {
        return Math.floor(Math.random() * Math.floor(max));
    }

    power(pow)
    {
        // TODO: damageと同じ様にHPバーを出さないと！
        const self = this;

        self.popNumber("power", pow);

        self.chara_status["HP"] += pow;
        self.clearCommand();
        self.clearState();
    }

    join()
    {
        const self = this;
        self.alpha = 1;
        self.clearCommand();
        self.clearState();
        self.gotoAndNext("通常待機");
    }

    fadeOut()
    {
        const self = this;

        const key = "fadeOut";
        if (self.ffa2.state !== "stop" && self.ffa2.state !== key) return true;

        self.alpha -= 0.08;
        if (self.alpha <= 0)
        {
            self.alpha = 0;

            self.clearCommand();
            self.clearState();
        }
    }

    fadeIn()
    {
        const self = this;

        const key = "fadeIn";
        if (self.ffa2.state !== "stop" && self.ffa2.state !== key) return true;

        self.alpha += 0.08;
        if (self.alpha >= 1)
        {
            self.alpha = 1;

            self.clearCommand();
            self.clearState();
        }
    }

    resuscitation()
    {
        const self = this;

        for (let i = 0; i < self.filters.length; i++) {
            const filter = self.filters[i];
            // TODO: クラス名を死亡時のエフェクトと定義できないか？
            if (filter.constructor.name === "ColorMatrixFilter") {
                self.filters.splice(i--, 1);
            }
        }

        self.constitution["蘇生フラグ"] = undefined;
        self.constitution["死亡フラグ"] = 0;

        self.clearCommand();
        self.clearState();
        self.gotoAndNext("通常待機");
    }

    dead()
    {
        const self = this;
        self.constitution["死亡フラグ"] = undefined;
        self.gotoAndNext("戦闘不能");
        const key = "dead";
        if (self.ffa2.counter[key] === undefined) self.ffa2.counter[key] = 0;
        self.ffa2.counter[key] += 1;
        self.loop = false;
        if (self.ffa2.counter[key] === 1) self.playVoice("death");
        self.onComplete = function () {
            self.ffa2.counter[key] = 0;
            self.clearCommand();
            self.clearState();
        };
    }

    moveAt(x, y)
    {
        const self = this;
        self.x = x;
        self.y = y;
    }

    moveBy(moveX, moveY)
    {
        const self = this;
        self.x += moveX;
        self.y += moveY;
    }

    get command()
    {
        const self = this;
        return self.ffa2.job.commands[0];
    }

    isValidCommand(job) {
        const self = this;
        return job.md5 === self.md5;
    }

    pushCommand(job, callback) {
        const self = this;

        if (self.isValidCommand(job)) {
            self.ffa2.job.commands.push(job);
            self.ffa2.job.callbacks.push(callback);
        }
        else {
            // self.clearCommand();
            console.error("is wrong command!", self.const_id, self.md5, self.turn_no, job);
        }

    }

    setCommand(job, callback) {
        const self = this;

        self.pushCommand(job, callback);
    }

    clearCommand() {
        const self = this;
        self.ffa2.job.clear = self.command;
    }

    get state()
    {
        const self = this;
        return self.ffa2.state;
    }

    clearState()
    {
        const self = this;
        self.ffa2.state = "stop";
    }

    turn_start(ref)
    {
        const self = this;

        self.switch_turn_start(ref.md5, ref.turn_no);

        if (! jQuery.isPlainObject(self.constitution) || ! jQuery.isPlainObject(self.chara_status)) {
            console.warn("turn_start", ref.md5, ref.turn_no, self.const_id);
            self.clearState();
            self.clearCommand();
            return false;
        }

        self.turn_no = ref.turn_no;
        self.md5 = md5;
        self.setCharaPosition();
        self.setDefaultPosition();

        self.clearState();
        self.clearCommand();
    }

    turn_end(ref)
    {
        const self = this;
        self.switch_turn_end(ref.md5, ref.turn_no);
        self.clearState();
        self.clearCommand();
    }

    playVoice(type)
    {
        const self = this;
        let cv = self.ffa2.cv;
        let maxRand = 1;
        if (!cv) cv = "swordman";
        if (master_voice.hasOwnProperty(cv) && master_voice[cv].hasOwnProperty(type)) {
            maxRand = master_voice[cv][type].length;
        }
        const rand = window.random(1, maxRand - 1);
        const query = master_voice[cv][type][rand];

        if (! query) return false;

        window.play_sound({sound: query, type: 3});
    }

    destroyFake()
    {
        const self = this;

        self.clearCommand();

        if (self.parent)
        {
            self.parent.removeChild(self);
        }

        const keys = ["HPゲージ", "HPゲージのフレーム", "名前", "アイテムモーション"];

        keys.forEach(function (key)
        {
            const ele = self.getChildAtKey(key, 0);
            if (ele)
            {
                self.removeChildAtKey(key, 0);
            }
        });

        self.emit("completed_destroy", true);

        super.destroy({children:true, texture:false, baseTexture:false});
    }

    redrawStatus()
    {
        const self = this;

        self.redrawName();
        self.redrawHpGauge();

        if (self.ffa2.flag.hp_gauge_fade_out)
        {
            const hp_gauge = self.getChildAtKey("HPゲージ", 0);
            const name = self.getChildAtKey("名前", 0);
            const hp_gauge_frame = self.getChildAtKey("HPゲージのフレーム", 0);

            if (hp_gauge)
            {
                name.alpha -= 0.02;
                hp_gauge.alpha -= 0.02;
                hp_gauge_frame.alpha -= 0.02;

                if (hp_gauge.alpha <= 0)
                {
                    self.ffa2.flag.hp_gauge_fade_out = false;
                    hp_gauge.alpha = 0;
                    hp_gauge_frame.alpha = 0;
                    name.alpha = 0;
                }
            }
        }
        else
        {
            const hp_gauge = self.getChildAtKey("HPゲージ", 0);
            const name = self.getChildAtKey("名前", 0);
            const hp_gauge_frame = self.getChildAtKey("HPゲージのフレーム", 0);

            if (hp_gauge) hp_gauge.alpha = 1;
            if (hp_gauge_frame) hp_gauge_frame.alpha = 1;
            if (name) name.alpha = 1;
        }
    }

    redrawBuff()
    {
        const self = this;

        let i = 0;
        let posX = 0;
        for (const command_id in self.ffa2.buff) {
            const buff = self.ffa2.buff[command_id];
            const key = buff + ":" + command_id;
            let emo = self.getChildAtKey(key, 0);

            if (! emo) {
                // console.error(self.const_id, key);

                if (buff === "defend") {
                    emo = new PIXI.AnimatedSprite(self.emotion_sprite_sheet.animations["岩"], true);
                }
                else if (buff === "poison") {
                    emo = new PIXI.AnimatedSprite(self.emotion_sprite_sheet.animations["ぐるぐる"], true);
                }
                emo.animationSpeed = 0.1;
                emo.play();
                self.addChildKey(key, emo);
                const pos = self.app.plane.toGlobal({ x: self.x, y: self.y }, undefined, undefined);

                if (posX === 0) {
                    emo.x = pos.x + emo.width;
                    if (self.scale.x < 0) {
                        emo.x = pos.x - emo.width;
                    }
                    posX = emo.x;
                }
                else
                {
                    emo.x = posX + 5;
                    posX = emo.x;
                }

                emo.y = pos.y - 15;

                emo.y -= self.height * self.ffa2.default.anchor.y;

                emo.scale.x = Math.abs(self.scale.x) * 0.6;
                emo.scale.y = self.scale.y * 0.6;

            }

            i++;
        }
    }

    applyBuff()
    {
        const self = this;

        if (self.chara_status["バフ"].length !== 0) {
            self.chara_status["バフ"].forEach((buff) => {
                if (self.turn_no === buff["開始ターン"]) {
                    // noop
                }
                else if (self.turn_no < buff["開始ターン"]) {
                    if (buff["開始ターン"] > self.turn_no && (buff["開始ターン"] + buff["持続ターン"] <= self.turn_no)) {
                        self.ffa2.buff[buff["コマンドid"]] = buff["名称"];
                    }
                }
            });
        }
    }

    clearBuff()
    {
        const self = this;

        for (const command_id in self.ffa2.buff) {
            const buff = self.ffa2.buff[command_id];
            const key = buff + ":" + command_id;
            self.removeChildAtKey(key, 0);
        }

        self.ffa2.buff = {};
    }

    addBuff(args)
    {
        const self = this;

        self.ffa2.buff[args[1]] = args[0];

        // console.error(self.const_id, self.ffa2.buff);

        self.clearCommand();
        self.clearState();
    }

    removeBuff(args)
    {
        const self = this;

        delete self.ffa2.buff[args[1]];
        const key = args[0] + ":" + args[1];
        self.removeChildAtKey(key, 0);

        self.clearCommand();
        self.clearState();
    }

    getId()
    {
        const self = this;
        return (new Date).getTime();
    }

    updateFake()
    {
        const self = this;

        try {
            if (self.ss) {
                self.ss.uniforms.floorY = self.toGlobal(new PIXI.Point(300, 0)).y;
            }

            if (self.ffa2.flag.ready) {
                // TODO: ダンジョンRPG用では不要
                // self.redrawStatus();
                // self.redrawBuff();
            }

            // console.error(self.const_id, self.x, self.y, self.alpha, self.ffa2.flag.ready);

            if (self.fade_in) {
                if (self.isTransparent()) {
                    self.ffa2.flag.ready = true;
                }
                else {
                    self.alpha += 0.02;
                    if (self.alpha >= 1)
                    {
                        self.alpha = 1;
                        self.ffa2.flag.ready = true;
                        self.fade_in = false;
                    }
                }
            }
            else {
                if (self.alpha >= 1) {
                    self.ffa2.flag.ready = true;
                }
            }

            ["damage", "power"].forEach((name) => {
                for (let i = 0; i < self.ffa2[name].length; i++) {
                    const type = self.ffa2.flag[name][i];
                    const key = self.ffa2[name][i];
                    const obj = self.getChildAtKey(key, 0);

                    if (type === 0 && obj) {
                        obj.alpha += 0.2;
                        obj.y += 16;

                        if (obj.alpha >= 1) {
                            obj.alpha = 1;
                            self.ffa2.flag[name][i] = 2;
                        }
                    }
                    else if (type === 2 && obj) {
                        obj.alpha -= 0.02;

                        if (obj.alpha <= 0) {
                            obj.alpha = 0;
                            self.removeChildAtKey(key, 0);
                        }
                    }
                }

            });

            if (self.ffa2.flag.destroy)
            {
                self.alpha -= 0.02;
                if (self.alpha <= 0)
                {
                    self.alpha = 0;
                    self.destroyFake();
                }
            }

            self["時間"]["現在"] = (new Date).getTime();
            self["時間"]["フレーム"] = (self["時間"]["現在"] - self["時間"]["最終呼出"]) / 1000.0;
            self["時間"]["最終呼出"] = (new Date).getTime();
            self["移動量"]["フレーム"] = 80.0 * self["時間"]["フレーム"];

            // console.error(Math.abs(self["時間"]["非アクティブ"] - self["時間"]["アクティブ"]));

            self.ffa2.flag.hp_gauge_fade_out = Math.abs(self["時間"]["非アクティブ"] - self["時間"]["アクティブ"]) <= 4000;

            if (!self.app) self.app = app;

            if (! self.command)
            {
                self["時間"]["非アクティブ"] = (new Date).getTime();
            }
            else
            {
                self["時間"]["アクティブ"] = (new Date).getTime();
            }

            const job = self.command;

            if (! job) {
                if (self.isDead() === false)
                {
                    self.standingPose();
                    return;
                }
                return;
            }

            switch (job.command) {

                case "turn-start":
                    self.turn_start(job.args);
                    break;
                case "turn-end":
                    self.turn_end(job.args);
                    break;
                case "forward":
                    self.forward();
                    break;
                case "backward":
                    self.backward();
                    break;
                case "rumble":
                    self.rumble();
                    break;
                case "damage":
                    self.damage(job.args);
                    break;
                case "power":
                    self.power(job.args);
                    break;
                case "dead":
                    self.dead();
                    break;
                case "resuscitation":
                    self.resuscitation();
                    break;
                case "move_to":
                    self.moveTo(job.args);
                    break;
                case "jump_to":
                    self.jump(job.args);
                    break;
                case "motion_weapon":
                    self.motionWeapon(job.args);
                    break;
                case "effect":
                    self.effect(job.args);
                    break;
                case "join":
                    self.join(job.args);
                    break;
                case "add_buff":
                    self.addBuff(job.args);
                    break;
                case "remove_buff":
                    self.removeBuff(job.args);
                    break;
                case "chant":
                    self.chant();
                    break;
                case "summon":
                    self.summon(job.args);
                    break;
                case "fade_out":
                    self.fadeOut(job.args);
                    break;
                case "fade_in":
                    self.fadeIn(job.args);
                    break;
                default:
                    console.warn(job.command, job);
                    self.clearCommand();
                    self.clearState();
                    break;
            }
        } catch (e) {
            // console.error(self.const_id, self.isSprite, self.playing);

            console.debug("たぶん、キャラを消した後に実行されるエラーだと。。。", e);
            if (self.ffa2.job) global_manager.aborted_job(self.ffa2.job);
            self.clearCommand();
            self.clearState();
        }
    }
}

export default { BattleChara };
