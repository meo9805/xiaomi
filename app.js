const $ = (selector, scope = document) => scope.querySelector(selector);
const $$ = (selector, scope = document) => Array.from(scope.querySelectorAll(selector));

const assets = {
  heroIdle: "assets/generated/crops/hero_idle.png",
  heroAttack: "assets/generated/crops/hero_attack.png",
  enemies: {
    slime: "assets/generated/crops/enemy_moss_slime.png",
    mushroom: "assets/generated/crops/enemy_mushroom.png",
    root: "assets/generated/crops/enemy_root_sprout.png",
  },
};

const companionData = {
  xiaomi: {
    name: "小咪猫",
    role: "主线伙伴",
    active: "亮晶晶扒拉",
    support: "亮晶晶提醒",
    image: "assets/generated/companions/companion_xiaomi_cat.png",
    desc: "所有亮晶晶的东西，最后都会被小咪认真扒拉一下。",
  },
  nico: {
    name: "nico",
    role: "狐火伙伴",
    active: "狐火领路",
    support: "狐尾标记",
    image: "assets/generated/companions/companion_nico.png",
    desc: "北美赤狐，脚步很轻，会把小怪往更好打的位置引。",
  },
  little: {
    name: "小小咪猫",
    role: "追击伙伴",
    active: "狸花追击",
    support: "草丛盯梢",
    image: "assets/generated/companions/companion_little_xiaomi_cat.png",
    desc: "狸花猫，盯着草丛的时候特别认真，像是在等一个偷袭机会。",
  },
  zizi: {
    name: "姊姊",
    role: "巡逻伙伴",
    active: "夜巡滑翔",
    support: "帐篷上方巡逻",
    image: "assets/generated/companions/companion_zizi.png",
    desc: "白色小巡逻员，总能从营地上方滑过去看一眼。",
  },
  meimei: {
    name: "妹妹",
    role: "寻物伙伴",
    active: "藏货雷达",
    support: "小材料嗅觉",
    image: "assets/generated/companions/companion_meimei.png",
    desc: "看起来慢吞吞，其实很会发现小怪藏起来的材料。",
  },
  tutu: {
    name: "图图",
    role: "营地伙伴",
    active: "木材搬运",
    support: "小木堆整理",
    image: "assets/generated/companions/companion_tutu.png",
    desc: "棕色兔子，总能从草丛里拖回一截看起来很有用的木头。",
  },
  dudu: {
    name: "嘟嘟",
    role: "任务伙伴",
    active: "奖励藏兜",
    support: "备用口袋",
    image: "assets/generated/companions/companion_dudu.png",
    desc: "棕色兔子，看起来无辜，其实很会把奖励藏进兜里。",
  },
};

const loopData = {
  battle: {
    tag: "01 / 自动推进",
    title: "小咪会自己打，但你点一下会更有参与感。",
    desc: "自动攻击、手动补刀、掉落浮字和低概率私人日志，让放置循环有一点“她真的在冒险”的感觉。",
    image: "assets/generated/crops/hero_attack.png",
    meta: ["+14G", "暖木碎片 x1"],
  },
  power: {
    tag: "02 / 战力成长",
    title: "训练、武器、护符，把小提升做得看得见。",
    desc: "数值不复杂，但每次升级都有材料缺口、套装提示和下一步目标。",
    image: "assets/generated/items/weapon_warmwood_longsword.png",
    meta: ["攻击 +8", "套装激活"],
  },
  bag: {
    tag: "03 / 背包掉落",
    title: "每个物品都有图、用途和一句能记住的话。",
    desc: "金币、月光孢子、小鱼干、月泉钥匙都会进入图鉴和详情弹窗，而不是只躺在数字里。",
    image: "assets/generated/items/item_dried_fish.png",
    meta: ["小鱼干", "伙伴零食"],
  },
  dungeon: {
    tag: "04 / 每日副本",
    title: "亮晶晶洞穴、月露矿道、孢子巢穴。",
    desc: "副本是每天 3 到 8 分钟回来的理由：定向拿金币、材料和后续 Boss 门票。",
    image: "assets/generated/items/item_moon_crystal.png",
    meta: ["3 次挑战", "战力检测"],
  },
  friend: {
    tag: "05 / 伙伴营地",
    title: "一个出战位，多个辅助位，先小而清楚。",
    desc: "小咪、nico、图图、嘟嘟都有真实素材和能力定位，像真正的营地伙伴一样被展示出来。",
    image: "assets/generated/companions/companion_nico.png",
    meta: ["7 位伙伴", "上阵 / 辅助"],
  },
};

const lootData = {
  bell: {
    type: "圣遗物",
    title: "听见铃声，就说明亮晶晶要被小咪认真收好了。",
    desc: "小咪羁绊 1 级后生效：每次扒拉金币 +1G。",
  },
  drinker: {
    type: "营地摆件",
    title: "一直咕噜咕噜的小饮水机，放在营地里会让人觉得很安心。",
    desc: "营地 1 级后解锁：巡逻和离线金币 +1G/分钟。",
  },
  sword: {
    type: "武器",
    title: "月森外围的阶段性毕业装备，适合准备挑战更大的敌人。",
    desc: "月森守护套：攻击 +8，任务和副本金材收益提高。",
  },
  crystal: {
    type: "稀有材料",
    title: "像月光凝成的小石头，后续可用于稀有强化。",
    desc: "来自月露矿道和签到奖励，是 Boss 试炼前的储备材料。",
  },
  key: {
    type: "门票",
    title: "可以打开月泉试炼入口的旧钥匙。",
    desc: "当前先作为后续 Boss 门票储备，也为月泉试炼留下入口。",
  },
};

function initNav() {
  const nav = $(".site-nav");
  const toggle = $(".nav-toggle");
  const links = $(".nav-links");

  const sync = () => {
    nav.classList.toggle("scrolled", window.scrollY > 24);
  };
  sync();
  window.addEventListener("scroll", sync, { passive: true });

  toggle.addEventListener("click", () => {
    const open = !links.classList.contains("open");
    links.classList.toggle("open", open);
    document.body.classList.toggle("menu-open", open);
    toggle.setAttribute("aria-expanded", String(open));
  });

  $$(".nav-links a").forEach((link) => {
    link.addEventListener("click", () => {
      links.classList.remove("open");
      document.body.classList.remove("menu-open");
      toggle.setAttribute("aria-expanded", "false");
    });
  });
}

function initCanvas() {
  const canvas = $("#world-canvas");
  const ctx = canvas.getContext("2d");
  const motion = !window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const colors = ["#ffd4a3", "#ffb5c0", "#e8dff5", "#8fbf7a", "#5db7ff"];
  let width = 0;
  let height = 0;
  let dpr = 1;
  let mouse = { x: -999, y: -999, active: false };
  let particles = [];

  const resize = () => {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    width = window.innerWidth;
    height = window.innerHeight;
    canvas.width = Math.floor(width * dpr);
    canvas.height = Math.floor(height * dpr);
    canvas.style.width = `${width}px`;
    canvas.style.height = `${height}px`;
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    const count = Math.max(42, Math.floor((width * height) / 23000));
    particles = Array.from({ length: count }, () => ({
      x: Math.random() * width,
      y: Math.random() * height,
      size: Math.random() < 0.72 ? 2 : 3,
      speed: 0.08 + Math.random() * 0.34,
      phase: Math.random() * Math.PI * 2,
      color: colors[Math.floor(Math.random() * colors.length)],
    }));
  };

  const draw = (time) => {
    ctx.clearRect(0, 0, width, height);
    for (const p of particles) {
      if (motion) {
        p.y -= p.speed;
        p.x += Math.sin(time * 0.001 + p.phase) * 0.12;
      }
      if (p.y < -8) {
        p.y = height + 8;
        p.x = Math.random() * width;
      }
      const dx = p.x - mouse.x;
      const dy = p.y - mouse.y;
      const near = mouse.active && dx * dx + dy * dy < 12000;
      const alpha = near ? 0.9 : 0.28 + Math.sin(time * 0.002 + p.phase) * 0.18;
      ctx.globalAlpha = Math.max(0.12, alpha);
      ctx.fillStyle = p.color;
      ctx.fillRect(Math.round(p.x), Math.round(p.y), p.size, p.size);
      if (near) {
        ctx.globalAlpha = 0.12;
        ctx.fillRect(Math.round(p.x - 2), Math.round(p.y - 2), p.size + 4, p.size + 4);
      }
    }
    ctx.globalAlpha = 1;
    requestAnimationFrame(draw);
  };

  resize();
  window.addEventListener("resize", resize);
  window.addEventListener("pointermove", (event) => {
    mouse = { x: event.clientX, y: event.clientY, active: true };
  });
  window.addEventListener("pointerleave", () => {
    mouse.active = false;
  });
  requestAnimationFrame(draw);
}

function initRevealAndCounters() {
  const revealObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("visible");
          revealObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12, rootMargin: "0px 0px -40px 0px" }
  );

  $$(".reveal").forEach((item) => revealObserver.observe(item));

  const counterObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        const el = entry.target;
        const target = Number(el.dataset.count);
        let current = 0;
        const steps = 18;
        const timer = window.setInterval(() => {
          current += 1;
          el.textContent = String(Math.round((target * current) / steps));
          if (current >= steps) {
            el.textContent = String(target);
            window.clearInterval(timer);
          }
        }, 45);
        counterObserver.unobserve(el);
      });
    },
    { threshold: 0.5 }
  );
  $$("[data-count]").forEach((item) => counterObserver.observe(item));
}

function initBattle() {
  const enemies = [
    { name: "苔影史莱姆", hp: 28, sprite: assets.enemies.slime, drop: "苔影露珠", gold: 7, xp: 8 },
    { name: "夜巡蘑菇", hp: 38, sprite: assets.enemies.mushroom, drop: "月光孢子", gold: 10, xp: 11 },
    { name: "树根小怪", hp: 52, sprite: assets.enemies.root, drop: "暖木碎片", gold: 14, xp: 15 },
  ];

  const state = { enemyIndex: 0, hp: enemies[0].hp, gold: 544, snacks: 20 };
  const fighter = $("#fighter");
  const target = $("#target");
  const slash = $("#slash");
  const enemyName = $("#enemy-name");
  const enemyHp = $("#enemy-hp");
  const enemyBar = $("#enemy-bar");
  const log = $("#battle-log");
  const goldCount = $("#gold-count");
  const snackCount = $("#snack-count");
  const logs = [
    "小咪把掉落金币扒拉到你脚边。",
    "背包里多了一张便签：记得保存。",
    "营地火堆噼啪响了一下，看起来更像家了。",
    "树根小怪倒下前表示今天也很累。",
    "月光落在口袋边上，亮了一小下。",
  ];

  const update = () => {
    const enemy = enemies[state.enemyIndex];
    enemyName.textContent = enemy.name;
    enemyHp.textContent = `${Math.max(0, state.hp)} / ${enemy.hp}`;
    target.src = enemy.sprite;
    enemyBar.style.width = `${Math.max(0, (state.hp / enemy.hp) * 100)}%`;
    goldCount.textContent = String(state.gold);
    snackCount.textContent = String(state.snacks);
  };

  const nextEnemy = () => {
    state.enemyIndex = (state.enemyIndex + 1) % enemies.length;
    state.hp = enemies[state.enemyIndex].hp;
    update();
  };

  const attack = () => {
    const enemy = enemies[state.enemyIndex];
    const damage = 8 + Math.floor(Math.random() * 9);
    state.hp -= damage;
    fighter.src = assets.heroAttack;
    fighter.classList.add("attack");
    target.classList.add("hit");
    slash.classList.remove("show");
    void slash.offsetWidth;
    slash.classList.add("show");

    window.setTimeout(() => {
      fighter.src = assets.heroIdle;
      fighter.classList.remove("attack");
      target.classList.remove("hit");
    }, 220);

    if (state.hp <= 0) {
      state.gold += enemy.gold;
      log.textContent = `击败${enemy.name}，获得 ${enemy.gold} 金币、${enemy.xp} 经验和 1 个${enemy.drop}。`;
      window.setTimeout(nextEnemy, 520);
    } else {
      log.textContent = `小咪造成 ${damage} 点伤害，${enemy.name}还在努力站稳。`;
      update();
    }
  };

  $("#attack-btn").addEventListener("click", attack);
  $(".mini-attack").addEventListener("click", attack);
  $("#claim-btn").addEventListener("click", () => {
    state.gold += 28;
    state.snacks += 1;
    log.textContent = logs[Math.floor(Math.random() * logs.length)];
    update();
  });

  update();
  window.setInterval(() => {
    if (document.visibilityState === "visible") attack();
  }, 5600);
}

function initLoopTabs() {
  const buttons = $$(".loop-tabs button");
  const tag = $("#loop-tag");
  const title = $("#loop-title");
  const desc = $("#loop-desc");
  const visual = $("#loop-visual");

  const setLoop = (key) => {
    const data = loopData[key];
    buttons.forEach((button) => button.classList.toggle("active", button.dataset.loop === key));
    tag.textContent = data.tag;
    title.textContent = data.title;
    desc.textContent = data.desc;
    visual.innerHTML = `
      <img src="${data.image}" alt="" />
      <div>
        <strong>${data.meta[0]}</strong>
        <span>${data.meta[1]}</span>
      </div>
    `;
  };

  buttons.forEach((button) => {
    button.addEventListener("click", () => setLoop(button.dataset.loop));
  });
}

function initCompanions() {
  const image = $("#companion-image");
  const role = $("#companion-role");
  const name = $("#companion-name");
  const desc = $("#companion-desc");
  const active = $("#companion-active");
  const support = $("#companion-support");
  const buttons = $$(".companion-picker button");

  const setCompanion = (key) => {
    const data = companionData[key];
    buttons.forEach((button) => button.classList.toggle("active", button.dataset.companion === key));
    image.src = data.image;
    image.alt = data.name;
    role.textContent = data.role;
    name.textContent = data.name;
    desc.textContent = data.desc;
    active.textContent = data.active;
    support.textContent = data.support;
  };

  buttons.forEach((button) => {
    button.addEventListener("click", () => setCompanion(button.dataset.companion));
  });
}

function initLoot() {
  const detail = $("#loot-detail");
  $$(".loot-card").forEach((card) => {
    card.addEventListener("click", () => {
      const data = lootData[card.dataset.loot];
      $$(".loot-card").forEach((item) => item.classList.toggle("active", item === card));
      detail.innerHTML = `
        <span>${data.type}</span>
        <h3>${data.title}</h3>
        <p>${data.desc}</p>
      `;
    });
  });
}

function resolveGameSrc() {
  return window.location.pathname.includes("/website/") ? "game/index.html" : "game/index.html";
}

function initPlayableGame() {
  const frame = $("#game-frame");
  const placeholder = $("#game-placeholder");
  const shell = $("#game-shell");
  const launchButton = $("#launch-game");
  const reloadButton = $("#reload-game");
  const fullscreenButton = $("#fullscreen-game");
  const openLink = $("#game-open-link");
  const status = $("#game-status");

  if (!frame || !placeholder || !shell || !launchButton || !reloadButton || !fullscreenButton || !openLink || !status) {
    return;
  }

  const gameSrc = resolveGameSrc();
  openLink.href = gameSrc;

  const setStatus = (text, active = false) => {
    status.textContent = text;
    status.classList.toggle("active", active);
  };

  const loadGame = (forceReload = false) => {
    placeholder.classList.add("hidden");
    frame.classList.add("active");
    setStatus("加载中", true);
    frame.src = forceReload ? `${gameSrc}?t=${Date.now()}` : gameSrc;
  };

  launchButton.addEventListener("click", () => loadGame(false));
  reloadButton.addEventListener("click", () => loadGame(true));
  frame.addEventListener("load", () => setStatus("运行中", true));

  fullscreenButton.addEventListener("click", async () => {
    try {
      await shell.requestFullscreen();
      setStatus("全屏中", true);
    } catch (error) {
      setStatus("浏览器限制全屏", false);
    }
  });
}

function initTilt() {
  if (window.matchMedia("(pointer: coarse)").matches) return;
  const cards = $$(".moon-card, .game-card, .play-console, .loop-panel, .companion-showcase, .loot-card, .road-card");
  cards.forEach((card) => {
    card.classList.add("tilt");
    card.addEventListener("pointermove", (event) => {
      const rect = card.getBoundingClientRect();
      const x = (event.clientX - rect.left) / rect.width - 0.5;
      const y = (event.clientY - rect.top) / rect.height - 0.5;
      card.style.transform = `rotateX(${y * -2.5}deg) rotateY(${x * 2.5}deg)`;
    });
    card.addEventListener("pointerleave", () => {
      card.style.transform = "";
    });
  });
}

function initSignup() {
  $(".signup").addEventListener("submit", (event) => {
    event.preventDefault();
    const form = event.currentTarget;
    const name = new FormData(form).get("name")?.toString().trim();
    $("#signup-note").textContent = name
      ? `${name}，月森营地已经记下你的名字。`
      : "月森营地已经收到这次内测登记。";
    form.reset();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  initNav();
  initCanvas();
  initRevealAndCounters();
  initBattle();
  initLoopTabs();
  initCompanions();
  initLoot();
  initPlayableGame();
  initTilt();
  initSignup();
});
