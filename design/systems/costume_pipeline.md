# 时装系统与美术管线

## 已实现的游戏规则

- 时装拥有独立的 `owned_costumes` 与 `equipped_costume` 存档字段，不占用武器、法宝、护具或足部装备栏。
- 时装档案只能包含名称、外观描述、美术资源和动画状态；禁止存放攻击、防御、移速、掉率、修炼效率、PVP、市场或副本次数数值。
- 衣柜会显示已拥有时装的概念卡，可试穿或卸下，并可通过本地存档恢复。
- 首批 `流岚游衣` 是概念资产，明确标记为 `concept_only`。它**不会**把静态立绘盖到大世界或副本角色上。

## 当前原创概念资产

| 时装 ID | 名称 | 适用模板 | 概念图 | 状态 |
|---|---|---|---|---|
| `liulan_wayfarer` | 流岚游衣 | 男 | `game-client/assets/art/costumes/liulan_wayfarer/concept/liulan_wayfarer_concept_v01.png` | 概念已审核；八方向待机、八方向各六帧行走透明源图已通过，攻击动作待制作 |
| `jiangyun_rainbow` | 绛云霓裳 | 女 | `game-client/assets/art/costumes/jiangyun_rainbow/concept/jiangyun_rainbow_concept_v01.png` | 概念已审核；南向、西南向待机与对应六帧行走生产候选已抠图，其余方向、攻击动作待制作，尚不可接入地图 |

概念图生成规范：原创高品质中国动画修仙服装设计；男装为云白、青碧、银纹，女装为绛红、黛紫、云白纱袖；无武器、无文字、无现有 IP 角色或徽标。它只用于确认材质、色彩和服装层次，不用作 2D 游戏人物帧。

`流岚游衣` 正南待机源图与抠图结果：

- 源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_idle_south_v01_key.png`
- 透明运行候选：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_south_v01_alpha.png`
- 西南源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_idle_south_west_v01_key.png`
- 西南透明运行候选：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_south_west_v01_alpha.png`
- 正西源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_idle_west_v01_key.png`
- 正西透明运行候选：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_west_v01_alpha.png`
- 西北源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_idle_north_west_v01_key.png`
- 西北透明运行候选：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_north_west_v01_alpha.png`
- 正北源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_idle_north_v01_key.png`
- 正北透明运行候选：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_north_v01_alpha.png`
- 东北源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_idle_north_east_v01_key.png`
- 东北透明运行候选：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_north_east_v01_alpha.png`
- 正东源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_idle_east_v01_key.png`
- 正东透明运行候选：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_east_v01_alpha.png`
- 东南源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_idle_south_east_v01_key.png`
- 东南透明运行候选：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_idle_south_east_v01_alpha.png`
- 正南行走序列表源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_walk_south_v01_sheet.png`
- 正南行走透明帧：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_v01_f1_alpha.png` 至 `liulan_wayfarer_walk_south_v01_f6_alpha.png`（6 帧、9 FPS、循环）
- 西南行走序列表源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_walk_south_west_v01_sheet.png`
- 西南行走透明帧：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_west_v01_f1_alpha.png` 至 `liulan_wayfarer_walk_south_west_v01_f6_alpha.png`（6 帧、9 FPS、循环、最低脚点已对齐）
- 正西行走序列表源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_walk_west_v01_sheet.png`
- 正西行走透明帧：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_west_v01_f1_alpha.png` 至 `liulan_wayfarer_walk_west_v01_f6_alpha.png`（6 帧、9 FPS、循环、最低脚点已对齐、格线残留已清除）
- 西北行走序列表源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_walk_north_west_v01_sheet.png`
- 西北行走透明帧：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_west_v01_f1_alpha.png` 至 `liulan_wayfarer_walk_north_west_v01_f6_alpha.png`（6 帧、9 FPS、循环、最低脚点已对齐）
- 正北行走序列表源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_walk_north_v01_sheet.png`
- 正北行走透明帧：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_v01_f1_alpha.png` 至 `liulan_wayfarer_walk_north_v01_f6_alpha.png`（6 帧、9 FPS、循环、最低脚点已对齐）
- 东北行走序列表源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_walk_north_east_v01_sheet.png`
- 东北行走透明帧：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_north_east_v01_f1_alpha.png` 至 `liulan_wayfarer_walk_north_east_v01_f6_alpha.png`（6 帧、9 FPS、循环、最低脚点已对齐）
- 正东行走序列表源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_walk_east_v01_sheet.png`
- 正东行走透明帧：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_east_v01_f1_alpha.png` 至 `liulan_wayfarer_walk_east_v01_f6_alpha.png`（6 帧、9 FPS、循环、最低脚点已对齐）
- 东南行走序列表源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_walk_south_east_v01_sheet.png`
- 东南行走透明帧：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_walk_south_east_v01_f1_alpha.png` 至 `liulan_wayfarer_walk_south_east_v01_f6_alpha.png`（6 帧、9 FPS、循环、最低脚点已对齐）
- 青篁练气剑南向攻击序列表源图：`game-client/assets/art/costumes/liulan_wayfarer/source_magic2/liulan_wayfarer_attack_south_qinghuang_qi_sword_v01_sheet.png`
- 青篁练气剑南向攻击透明帧：`game-client/assets/art/costumes/liulan_wayfarer/processed_alpha/liulan_wayfarer_attack_south_qinghuang_qi_sword_v01_f1_alpha.png` 至 `liulan_wayfarer_attack_south_qinghuang_qi_sword_v01_f6_alpha.png`（6 帧、14 FPS、非循环；仅命中帧使用短促青白剑痕）
- 绛云霓裳南向待机候选源图：`game-client/assets/art/costumes/jiangyun_rainbow/source_magic2/jiangyun_rainbow_idle_south_v01_key.png`
- 绛云霓裳南向待机候选透明图：`game-client/assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_idle_south_v01_alpha.png`（仅作方向、服装层次与抠图质量确认；未达到整套时装的运行门槛）
- 绛云霓裳西南待机候选源图：`game-client/assets/art/costumes/jiangyun_rainbow/source_magic2/jiangyun_rainbow_idle_south_west_v01_key.png`
- 绛云霓裳西南待机候选透明图：`game-client/assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_idle_south_west_v01_alpha.png`（仅作方向、服装层次与抠图质量确认；未达到整套时装的运行门槛）
- 绛云霓裳南向行走序列表候选源图：`game-client/assets/art/costumes/jiangyun_rainbow/source_magic2/jiangyun_rainbow_walk_south_v01_sheet.png`
- 绛云霓裳南向行走候选透明帧：`game-client/assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_v01_f1_alpha.png` 至 `jiangyun_rainbow_walk_south_v01_f6_alpha.png`（6 帧、9 FPS、循环、最低脚点已对齐；未达到整套时装的运行门槛）
- 绛云霓裳西南行走序列表候选源图：`game-client/assets/art/costumes/jiangyun_rainbow/source_magic2/jiangyun_rainbow_walk_south_west_v01_sheet.png`
- 绛云霓裳西南行走候选透明帧：`game-client/assets/art/costumes/jiangyun_rainbow/processed_alpha/jiangyun_rainbow_walk_south_west_v01_f1_alpha.png` 至 `jiangyun_rainbow_walk_south_west_v01_f6_alpha.png`（6 帧、9 FPS、循环、最低脚点已对齐；未达到整套时装的运行门槛）
- 已拒绝的八方向合图样张：`game-client/assets/art/costumes/liulan_wayfarer/review/rejected/README.md`

## 进入地图角色层的验收门槛

每套可运行时装必须为同一性别模板制作：

1. 八方向待机帧；
2. 八方向六帧行走序列；
3. 至少南向六帧攻击序列，其余攻击方向按战斗需求补齐；
4. 对应身体的脚点、尺寸、透明边缘、手部与武器遮挡规范；
5. 武器、法宝、护具、足部装备同时穿戴时的层级测试；
6. 女模板的独立版本，不能仅对男装换色或缩放；
7. 抠图检查、运行时导入检查和 PVP 外观无数值影响检查。

满足后，将资源写入时装档案的 `runtime_asset`，状态改为 `ready`，再由 `SpatialTestPlayer` 创建独立 `CostumePivot`。未满足时禁止在地图中显示，避免静态立绘破坏 2D 动作可读性。

## 单方向生产队列（流岚游衣）

当前只验收了正南待机关键帧；它是颜色、比例、脚点和透明边缘的基准，并不构成可运行外观。后续必须按以下顺序逐张生成、逐张抠图、逐张验收：

| 顺序 | 帧组 | 目标 | 放行条件 |
|---|---|---|---|
| 1 | 待机 | 西南、西、西北、北、东北、东、东南 | 与正南图等高、双脚共用基线、方向不可互相替代 |
| 2 | 行走 | 八方向各 6 帧 | 躯干不漂移，脚步轮替清晰，第一/最后一帧可循环 |
| 3 | 施放/攻击 | 南向 6 帧，按武器大类分别制作 | 手、武器与披帛层级不穿帮，攻击前摇/命中/收势可读 |
| 4 | 验收 | 地图、战斗、换装、PVP 外观测试 | 不改变任何属性；不遮挡交互、血条或特效 |

第 1 项合格后，`runtime_state` 可标记为 `idle_8dir_ready`，仅表示待机方向素材齐备；第 2–3 项未全部合格前，地图角色层仍不得引用该图，也不得标记为 `ready`。

## 下一批 Image 2 提示词

```text
Use case: precise object edit. Use the approved 《寻岚记》 male costume reference “流岚游衣” to preserve exactly the same adult male face, cloud-white and pale-celadon robe, silver embroidery, hair crown, shoulder silhouette, scale and costume layers.
Asset type: one isolated 2D RPG animation-production key frame only.
Primary request: [DIRECTION] facing idle pose, neutral arms, no weapon. The camera and character height must exactly match the approved SOUTH idle key frame; both soles sit on one clean horizontal baseline near the lower canvas edge.
Style/medium: refined original Chinese xianxia 2D game character source art, readable at map scale, clear silhouette and layered cloth; no existing franchise or character.
Background: perfectly flat #ff00ff chroma-key background; no floor, no cast shadow, no glow, no gradient, no text, no border, no watermark.
Constraints: a single centered full-body character only; fully visible feet; no duplicate character; no weapon; no magical effect; no companion; no chibi proportions; no perspective distortion; do not use #ff00ff anywhere in clothing or hair.
```

将 `[DIRECTION]` 替换为 `south-west`、`west`、`north-west`、`north`、`north-east`、`east` 或 `south-east`。一张图只生成一个方向；不再使用多格合图直接充当运行时素材。
