# 2D 背景分层与角色抠图流程

## 对用户提供教程链接的说明

该抖音短链接未能通过网页端解析，平台也没有返回可读取的文字或视频画面。因此本规范不声称复述该视频的具体步骤；它采用同一类 Godot 2D 背景/抠图问题的工程化做法，并按 Godot 官方文档的 `Parallax2D`、`Sprite2D`/图集区域能力落实。

## 横版副本背景的推荐层级

从后向前组织，不把可碰撞地面与纯背景画在同一张图中：

1. `Sky`：天空、月亮、远云，固定或极慢速。
2. `FarMountains`：远山、远建筑，视差比例 `0.10–0.20`。
3. `MidMist`：中景雾、远树、瀑布，视差比例 `0.25–0.45`。
4. `StageArt`：洞府墙体、桥梁、地表主视觉，视差比例 `0.70–0.90`。
5. `Gameplay`：TileMap、碰撞、跳台、机关触发器；不与美术背景合并。
6. `Foreground`：近景草、石、雾、檐角，视差比例 `1.05–1.25`，允许遮挡角色下半身。
7. `UI`：血条、技能、提示，使用 `CanvasLayer`，永不参与视差。

Godot 中每个非 UI 层放在对应 `Parallax2D` 节点下，使用不同 `scroll_scale`。`Parallax2D` 是 Godot 当前推荐的 2D 视差节点；远景移动慢、近景移动快，形成深度而不影响碰撞逻辑。

## 绿幕资产抠图顺序

1. **保留原图**：将 Image 生成的纯绿底原图放入 `source_green/`，绝不覆盖。
2. **统一背景色**：生成时固定纯绿 `#00FF00`，人物服装避免使用同色荧绿边缘。
3. **外部去绿**：在图像编辑器中按色彩范围选择绿幕，保留发丝、透明纱袖和半透明法术边缘；输出带 Alpha 的 PNG。
4. **边缘修正**：收缩选区 1–2 像素、去除绿色溢色，再用人工蒙版修发丝、饰品孔洞、透明布料。
5. **切图**：方向图按 4×2 切为八方向；动作图先按动作分组，再为每个动作制作连续帧。不能直接将“一张九姿态参考图”当作最终动画。
6. **导入 Godot**：透明 PNG 放入 `processed_alpha/`；对单图使用 `Sprite2D`，对规则序列使用 `hframes/vframes` 或图集区域；将碰撞盒和受击盒单独配置。
7. **验收**：浅色/深色背景都检查绿边；在 0.75×、1×、1.5× 缩放下检查动作可读性和锯齿。

## 推荐目录

```text
assets/art/characters/<角色ID>/
  source_green/       # 原始生成图，只读保留
  processed_alpha/    # 去绿后的透明 PNG
  sheets/             # 已切好或带图集说明的序列图
  animations/         # Godot 动画资源与命名表
  cards/              # 角色、武器、法宝卡
```

## 引擎接入原则

- `Sprite2D` 可以展示整张纹理、规则图集的一帧或纹理区域；这适合方向图和动作图的接入。
- 大世界角色与横版战斗角色分用不同节点/动画控制器，不能强行共用比例和动作节奏。
- 背景是表现层；TileMap、碰撞、事件触发、资源点和副本逻辑是玩法层，必须拆开维护。

## 参考

- Godot 官方 `Parallax2D`：https://docs.godotengine.org/en/4.4/classes/class_parallax2d.html
- Godot 官方 2D 视差教程：https://docs.godotengine.org/en/4.5/tutorials/2d/2d_parallax.html
- Godot 官方 `Sprite2D`：https://docs.godotengine.org/en/4.6/classes/class_sprite2d.html
