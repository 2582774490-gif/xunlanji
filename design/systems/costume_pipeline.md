# 时装系统与美术管线

## 已实现的游戏规则

- 时装拥有独立的 `owned_costumes` 与 `equipped_costume` 存档字段，不占用武器、法宝、护具或足部装备栏。
- 时装档案只能包含名称、外观描述、美术资源和动画状态；禁止存放攻击、防御、移速、掉率、修炼效率、PVP、市场或副本次数数值。
- 衣柜会显示已拥有时装的概念卡，可试穿或卸下，并可通过本地存档恢复。
- 首批 `流岚游衣` 是概念资产，明确标记为 `concept_only`。它**不会**把静态立绘盖到大世界或副本角色上。

## 当前原创概念资产

| 时装 ID | 名称 | 适用模板 | 概念图 | 状态 |
|---|---|---|---|---|
| `liulan_wayfarer` | 流岚游衣 | 男 | `game-client/assets/art/costumes/liulan_wayfarer/concept/liulan_wayfarer_concept_v01.png` | 概念已审核，动作帧待制作 |
| `jiangyun_rainbow` | 绛云霓裳 | 女 | `game-client/assets/art/costumes/jiangyun_rainbow/concept/jiangyun_rainbow_concept_v01.png` | 概念已审核，动作帧待制作 |

概念图生成规范：原创高品质中国动画修仙服装设计；男装为云白、青碧、银纹，女装为绛红、黛紫、云白纱袖；无武器、无文字、无现有 IP 角色或徽标。它只用于确认材质、色彩和服装层次，不用作 2D 游戏人物帧。

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

## 下一批 Image 2 提示词

```text
Use case: stylized-concept
Asset type: 2D game costume animation-production key sheet for 《寻岚记》
Primary request: original male cultivator costume “流岚游衣”, matching the approved cloud-white, pale-celadon and silver embroidery concept.
Subject: adult male cultivator only; no weapon, no companion, no effects.
Composition: a strict 8-direction turnaround key sheet, exactly eight full-body poses in a 4x2 grid: south, south-west, west, north-west, north, north-east, east, south-east. Every pose uses identical scale, foot baseline, camera distance and neutral idle stance. Leave clear even gutters between poses.
Style/medium: polished original Chinese xianxia 2D game character art, clear silhouette and cloth layers, designed for a readable diagonal top-down RPG; no existing franchise or character.
Background: perfectly flat solid #ff00ff chroma-key background; no floor, shadow, glow, gradient, text, border, watermark or decorative props.
Constraints: no weapon, no magical effects, no duplicate poses, no cropped feet, no perspective distortion, no chibi proportions. Keep all costume colors free of #ff00ff.
```

后续必须逐方向、逐动作生成并审核；不能因为有一张好看的立绘就声称已完成可用时装。
