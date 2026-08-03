# 《寻岚记》调研与决策记录

## 用户需求
- 制作一款国风修仙题材的 2D 游戏，网游名称暂定《寻岚记》。
- 先讨论并修改整体制作计划，再进入项目创建和开发。
- 使用 Codex 辅助代码开发与游戏任务管理；未来可为项目开启独立对话。
- 上线方向为微信小游戏或手机 App。
- 需要评估虚幻、Unity 或其他引擎。
- 人物模型拟由 GPT Image 2 生成；人物动画拟由豆包生成，Codex 负责提示词与流程。
- 内容气质参考“凡人流”修仙：分地图区域、修炼体系、道具、帮派／宗门等，但需原创命名与设定。
- 需要参考中国风修仙网游 2D 建模画风，并补全遗漏的制作事项。
- 需要分析《寻岚记》对世界观的启发、世界观对名称的支撑、名称是否贴切及是否需要改名。

## 初步判断
- 首个可玩版本应采用“轻量 2D 国风修仙 RPG + 弱联网社交”而非重度开放世界 MMO，以降低小程序端性能、内容生产与服务器成本。
- 商业与合规、服务端、运营活动、音频、数值与埋点都是当前需求中尚未明确但不可缺少的模块。
- 视觉参考中，《一念逍遥》以淡墨留白、少量红蓝高饱和点睛、飘逸人物与山水雾气建立“空灵修仙感”；《修真江湖 2》的宣传视觉将水墨山水与洞府经营、凡界/仙界分层结合。可借鉴这种“意境大场景 + 可读性强的角色和 UI”，但不可复制其角色、构图、图标或具体资产。
- 不建议将角色做成真实 3D 建模：首发应采用“2D 角色立绘 + 2D 骨骼/序列帧战斗动画 + 局部特效”的轻量资产方案。用户所说“人物建模”应在立项中拆为角色设定图、立绘、战斗小人、骨骼绑定四类资产。

## 待验证的行业参考
- 推荐选择“新国风工笔水墨”：水墨留白负责世界气质，工笔线条和局部材质负责人物识别，青黛/雾白为主、朱砂/鎏金为稀有度点缀。它比纯水墨更利于手机端识别、装备外观和商业化展示，也比 Q 版更贴合《寻岚记》的凡人流气质。
- Cocos Creator 官方文档显示，Creator 3.8 可直接构建到微信小游戏，并生成 `wechatgame` 发布目录及必要配置；Cocos 官方定位其为轻量跨平台 2D/3D 引擎。该路径很适合微信小游戏优先的 2D 项目。
- Unity 适合移动端 2D/3D 与更丰富的中后期表现，但对微信小游戏的直出路径、包体和适配成本不如 Cocos 明确；若首发强调微信传播与轻量性能，不应将 Unity 作为第一推荐。虚幻引擎的强项在高质量 3D，不适合本项目首发的 2D 小程序目标。

## 资料来源
- Cocos Creator 3.8《发布到微信小游戏》：https://docs.cocos.com/creator/3.8/manual/zh/editor/publish/publish-wechatgame.html
- Cocos Creator 产品页：https://www.cocos.com/creator
- Unity 官方平台页：https://unity.com/
- 《一念逍遥》官方宣传视觉：https://iw.ltgamesglobal.com/zh/news/9.html
- 《修真江湖 2》宣传视觉（第三方资料，仅作风格观察）：https://www.91084.com/yx/13574.html
- Cocos Engine MIT 许可证：https://raw.githubusercontent.com/cocos/cocos-engine/v3.8.9/LICENSE.md
- Cocos Creator 引擎仓库：https://github.com/cocos/cocos-engine
- Godot 官方许可说明：https://godotengine.org/license/
- ComfyUI 官方工作流说明：https://docs.comfy.org/development/core-concepts/workflow

## 本轮修订结论
- 产品改为“轻主线、强探索、可控随机、玩家交易与竞技共存”的 2D 修仙在线 RPG。剧情仅负责新手引导与线索，不作为玩法解锁的唯一条件。
- 随机性由个人机缘、区域岚潮、随机洞府/词条和风险回报组成；必须配套保底、定向转化和交易规则，防止养成卡死与经济失控。
- 拍卖行与 PVP 使服务端成为首发必需项：物品归属、货币、拍卖、随机奖励与战斗胜负均需服务端权威结算。
- Cocos Creator 的引擎运行时代码使用 MIT 许可证；官方提供免费下载。编辑器、商店插件、技术支持、云服务和第三方 SDK 可能各有收费或条款，正式立项时锁定版本逐项核对。
- Godot 使用 MIT 许可证、可免费商用且无版税；但本项目优先微信小游戏时，Cocos 在构建与本地生态上的匹配度更高。
- ComfyUI 可选，用于受控批量生图、局部重绘、姿态/线稿控制与风格稳定；不能替代 Spine/序列帧、特效和人工验收。每个模型、LoRA、节点与素材须单独记录商用许可。
- TypeScript 是开源编程语言，采用 Apache-2.0 许可证，可免费使用；它会编译为 JavaScript，是 Cocos Creator 项目的推荐脚本语言之一。

## “岚”专项初稿
- 岚被定义为“灵气在特定地域中受山势、水文、气候、生灵活动和人迹影响，形成的、会迁移和变化的地域性灵性天气”，区别于普遍存在的灵气。
- 该定义能推导出开放大世界的环境状态、公开资源刷新、个人奇遇、固定境界副本和基于地貌/天气/人为扰动的动态副本；其随机性遵循可观察的因果，而非无解释的纯概率。
- “岚”的起源、失衡原因、社会定位与美术表现仍待用户共同确认，草案明确保留这些创作决策。

## “岚”专项 v0.2：执行框架
- 推荐正史：岚本质为自然循环；早期修士学会观测并利用，后来的大规模截取/导引叠加自然灾害，形成如今的遗址、失衡区域和可持续资料片谜团。
- 开放地图由常驻、日内、日/周、月/赛季四层状态组成。每张区域配置地貌、境界带、稳定资源、环境变量、事件模板和视觉/音频反馈。
- 资源分为基础资源、区域竞争资源、个人机缘资源；副本分为固定境界副本、环境触发的动态副本、个人/小队奇遇副本，保障成长、社交和独特体验三者共存。
- 动态副本采用“地点锚点 + 环境触发器 + 人工模板 + 有限变体 + 境界难度层”的结构，保留现实逻辑与可攻略性。
- 首个垂直切片建议验证高山云谷的连雨—浓雾—水蚀洞触发链，及两名玩家同见公共变化、各获不同个人线索的体验。

## 宗门与 NPC 系统
- 世界宗门（正式势力）与玩家仙盟（社交组织）必须拆分。角色可拥有一个主世界宗门身份和一个玩家仙盟身份。
- 世界宗门使用外门、内门、真传、执事、堂主/护法、议事席的身份梯度；高位采用 NPC 稳定权威 + 玩家轮值权力，避免永久垄断。
- 正常退门不触发通缉；通缉只由明确门规的严重违约触发，且有范围、时限和赔偿/赎罪/辩解等恢复途径。
- NPC 以功能身份 + 社会/环境关系配置，首发五图目标为 120 名命名 NPC 和 250–350 名环境/功能 NPC；任务、关系与奖励由人工内容和服务端规则控制。

## 万物卡片与首批 NPC 提示词
- 建立制作资产卡与玩家图鉴卡两层结构，制作卡覆盖身份、玩法、关系、视觉、数据、版本和验收；图鉴卡仅展示已解锁信息。
- 建立 NPC、世界宗门、玩家仙盟、法宝、妖怪/灵兽、资源、地点、固定/动态副本、功法/事件九类卡片的专用字段。
- 雾隐原首批 15 名命名 NPC 均已具备制作资产卡与两阶段生成方案：先用四视图锁定身份，再以锚点图生成面部细节，避免角色漂移。
- 视觉方向更新为原创高品质中国 3D 修仙动画人物建模感：写实比例、精细面部与材质、克制电影光影；仅提取高层次特征，不复刻《凡人修仙传》的具体角色或画面。

## 板块设计调研（2026-08-01）
- 《问道》手游的公开资料将功能清晰分为角色/物品、宠物、任务、副本、竞技、BOSS、帮派和集市等类别；其帮派同时具备成员层级、建设度/资金、任务、共同活动和技能研发，说明“组织身份 + 共同产出 + 集体成长”比单纯聊天公会更能支撑长期社交。[来源：官方资料站，https://wd.leiting.com/home/game/game_data_list.php、https://wd.leiting.com/home/game/game_data.php?level=2&level_id=85&show_type=1]
- 《一念逍遥》官方将宗门、镇妖塔、论剑台等聚合在城镇入口，并把秘境、古宝、藏宝图、宗门、跨服和 PK 共同呈现为修仙日常；可借鉴“高频入口集中、低频系统分层”的信息架构，而不能复制其具体玩法或美术表达。[来源：官方介绍，https://xian.leiting.com/news/1.html、https://xian.leiting.com/news/37.html]
- 《新天龙八部》官方资料站并列帮会、交易市场、资源/城市争夺、副本、生活技能与门派技能，表明成熟 MMO 的板块需覆盖成长、社交、经济、竞争和休闲产出；《寻岚记》应以“寻岚”世界事件把这些板块联在一起，而不是堆叠独立日常。[来源：官方资料站，https://www.tl.changyou.com/data/index.shtml]

## 角色美术管线重建（2026-08-01）
- 用户最终确认需要三套角色资产：用于角色详情/剧情展示的原创国漫立绘、用于横版地图行走的 2D 国风卡通/迷你角色、用于 PVE 副本与 PVP 的横版 2D 动作战斗角色。
- 已生成的九张写实四视图与目标不符：低饱和、现实古装/影视感强、普通人物气质明显，且不适合直接作为小尺寸 2D 地图角色。它们只保留为旧方向样本，不作为生产锚点。
- 新管线先用“成年男性、成年女性各一张国漫立绘 + 各一张横版 2D 地图小人侧视图 + 各一张横版 2D 战斗角色侧视图”完成六张试片；通过一次风格验收后，再分批生产命名 NPC。
- 2D 地图角色建议采用约 3 头身、左右侧视、透明背景；横版战斗角色建议采用 4–5.5 头身、左右侧视，并按待机、跑跳、普攻、术法、闪避/受击等动作组制作。可参考《造梦西游》所代表的横版 2D 动作可读性，但不复制其具体表达。
- 用户指出六张风格试片远不足以完成角色资产，要求补足角色立绘四视图、地图小人完整方向，以及横版 PVE/PVP 的完整战斗动作。正式生产清单已改为：立绘“规范四视图 + 主立绘 + 表情页”、地图“八方向规范图 + 待机/行走/交互”、战斗“规范图 + 至少 17 组动作”。
- 用户进一步指出攻击特效必须属于被明确设计的每一把武器，而非先绑定给人物。当前只验证横版 2D 人物本体；此前“青锋法剑/剑气”属于未经确认的占位，已暂停。角色、武器、武器动作、武器技能和特效需解耦管理。
- 国漫立绘提示词允许将中国动漫《凡人修仙传》写作“精美国漫修仙质感”的质量参照，但必须同时写明：不复制或模仿其具体角色、脸型、发型、服装、法宝、纹样、场景或镜头；地图卡通角色不使用这一写实 3D 质量参照。
## 2026-08-02：帧动画与可运行切片

- 用户确认 GPT Image 生成的玩家男模板可作为当前游戏运行测试资产；最终角色需要支持模板、时装、武器、法宝和功法的组合，因此必须持续扩充资产而不能锁死为单一角色。
- 当前已具备八方向静止图和南向六帧行走图；其余方向的连续行走、攻击、受击、冲刺与武器特效尚未制作，测试场景不得伪造为已完成。
- 首个运行切片应优先验证：地图加载、角色移动、朝向切换、南向行走播放、场景交互和回到已有系统框架；装备/功法仅使用数据接口占位，不依赖尚未制作的外观。
## 2026-08-03: Open world framework correction

- Character frames alone do not constitute a game. The next acceptance target is a runnable world loop: large map navigation, region gates, resource nodes/NPC interaction, and a dungeon entrance that loads a visual dungeon scene.
- The initial maps are structural graybox maps rendered from reusable 2D layers. They establish scale, navigation, markers, and integration points now; AI-made background, building, and foreground layers will replace their presentation without rewriting world logic.
- Final online play still requires a server-authoritative architecture. This milestone is deliberately a local Godot gameplay prototype.

## 2026-08-03: Reference-video production decision

- The reference videos establish a production method: modular layered maps, camera-follow exploration, separate character/weapon/effect nodes, and eight-direction frame packages.
- The user wants this method and gameplay readability, but with an original polished Chinese-fantasy 2D visual language and the independent 《寻岚记》 world system.
- The procedural world visuals are now explicitly graybox-only. Future map work must be delivered as separable terrain, decoration, foreground/occlusion, collision, and interaction layers.

## 2026-08-04: Action asset integration finding

- A character action sheet must be kept weapon-free when the weapon is intended to be swappable. The body can provide stance, recoil, and cloth motion; the weapon controller supplies the held-item pose, direction, swing timing, and later its weapon-specific effects.
- South-facing cycles are accepted as the first verified production slice only. The game must not describe the template as eight-direction action-complete until the other seven directional walk and attack sheets are produced and tested.

## 2026-08-04: Reference-video reconstruction findings

- The supplied map video demonstrates a scene-building method, not a single-background workflow: a terrain image is combined with independently placed scenery, separate foreground/occlusion objects, collision geometry, transfer triggers, and a player placed by foot position.
- The supplied animation video demonstrates extracting or preparing individual assets and continuous sprite frames before placing them in Godot. A static scenic panorama with an unrelated small sprite does not reproduce this result.
- The replacement acceptance target is therefore one original Yunlan South Gate slice with: ground-only art; prop sprites that share the same camera angle; Y-sorted actor and props; high/foreground props that cover the actor; walk collisions; and a modular player root whose equipment is separate from its body.

## 2026-08-04: Yunlan South Gate spatial prototype

- Built a separate opaque terrain layer, independent alpha-cut main gate and jade pine props, rather than using the previous baked village panorama.
- The gate and pine sort against the character root by their ground contact position; the player can pass behind their crowns/roof and appear in front after walking below their base position.
- Added two gate-pillar collision bodies, a pine-trunk collision body, feet-rooted player collision, a separate ground shadow and reserved front/back weapon slots.
- The new `yunlan_south_gate.tscn` loaded cleanly in Godot headless runtime and is launched locally for visible review.

## 2026-08-04: South Gate interaction pass

- The new male map actor now alternates the validated idle atlas with a matching generated walking-key-pose atlas for all eight directions. This is an honest two-frame movement baseline, not a claim of final-frame completeness.
- Added guide NPC Shen Yan as a separate Y-sorted visual plus independent proximity `Area2D`; dialogue is activated with E.
- Added Mist-Stream Spirit Herb as a separate alpha-cut resource prop. E removes it from the scene, adds 雾溪灵草 to the inventory and grants early cultivation progress.
