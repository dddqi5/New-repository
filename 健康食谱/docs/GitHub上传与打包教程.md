# GitHub 上传与云端打包 · 手把手教程

> 阶段 6/8 ｜ 适用：完全没写过代码、只用网页的人
> 目标：把电脑 `D:/AI应用/健康食谱` 里的项目传到 GitHub，让 GitHub 在云端帮你打包出手机能装的 APK。

---

## 开始前你需要

1. 一个邮箱（QQ 邮箱、163、Gmail 都行）。
2. 能上网的电脑，用 **Chrome 或 Edge 浏览器**（不要用 IE）。
3. 项目文件夹：`D:/AI应用/健康食谱`（已经做好，里面共 58 个文件）。
4. 大约 20 分钟耐心。第一次慢，之后很熟练。

### 三个词先说清楚

| 词 | 白话解释 |
|---|---|
| 仓库 Repository | 你在 GitHub 上的「项目文件夹」 |
| Actions | GitHub 的「自动打包机器人」，你电脑不用装任何软件 |
| Artifact | 机器人打包好的「成品文件」，也就是 APK |

---

## 第 1 步：注册 GitHub

1. 浏览器地址栏输入 `https://github.com` 回车。
2. 点右上角 **Sign up**（注册）。
3. 依次填写
   - **Email**：你的邮箱。
   - **Password**：密码（至少 8 位，含大小写字母和数字）。
   - **Username**：用户名（英文/数字，例如 `zhangsan-health`）。
   - 国家选 **China**，勾选「我不是机器人」并完成验证。
4. 点 **Create account**。
5. 去邮箱收 **GitHub 验证码邮件**，填入 8 位验证码。
6. 若问套餐选 **Free（免费）**；若问用途选 **Just me**。

> 注册成功后右上角会出现你的头像。

---

## 第 2 步：新建仓库

1. 登录后点右上角 **➕ 号** → **New repository**（或直接打开 `https://github.com/new`）。
2. 填写
   - **Repository name**：`healthy-recipe`（英文，别用中文/空格）。
   - **Description**：可留空。
   - 选 **Public** 或 **Private** 都行（私有也能打包）。
   - **不要**勾选 Add a README file，**不要**添加 .gitignore / license。
3. 点绿色 **Create repository**。
4. 出现带 `Quick setup` 的空仓库页面，说明建好了。

---

## 第 3 步：上传项目文件（不用命令行）

### 方法 A：拖拽整个文件夹（先试这个）

1. 仓库页面点 **Add file** → **Upload files**。
2. 打开「文件资源管理器」，进入 `D:/AI应用`。
3. 把 **`健康食谱` 整个文件夹** 拖到网页中间的虚线区域。
   - 拖的是**文件夹本身**，浏览器会自动带上里面的 `lib`、`android`、`.github` 等子文件夹。
4. 等进度条走完。下方会列出文件名，应能看到 `.github/workflows/build.yml`、`pubspec.yaml`、`lib/...`。
5. 拉到最下方，**Commit changes** 输入框随便写 `first upload`。
6. 点绿色 **Commit changes**。

> 如果文件列表里**看不到 `.github` 文件夹**，说明浏览器没带隐藏文件夹。先 Commit 完成上传，再按「方法 B」补上。

### 方法 B：补充 `.github`（仅当方法 A 没带上时）

1. 回到仓库首页，点 **Add file** → **Create new file**。
2. 文件名输入框里**一字不差**输入：`.github/workflows/build.yml`
   - 输入 `/` 时 GitHub 会自动建文件夹，显示成 `.github / workflows / build.yml` 是对的。
3. 用记事本打开电脑上的 `D:/AI应用/健康食谱/.github/workflows/build.yml`，**全选复制**全部内容。
4. 粘贴到网页右侧编辑框。
5. 点 **Commit changes** → 再点一次 **Commit changes**。

> `.gitignore` 同理：新建文件名叫 `.gitignore`，内容从 `D:/AI应用/健康食谱/.gitignore` 复制。

---

## 第 4 步：确认机器人说明书在位

1. 回到仓库首页，应能看到文件夹列表里有 **`.github`**。
2. 依次点进 `.github` → `workflows`，确认里面有 **`build.yml`**。
3. 点开 `build.yml`，能看到绿色的 YAML 内容，说明成功。

> 有的浏览器不显示以点开头的文件夹，可点击仓库页面上方的齿轮/视图设置，或直接在地址栏打开
> `https://github.com/你的用户名/healthy-recipe/tree/main/.github/workflows`
> 能看到 `build.yml` 即代表成功。

---

## 第 5 步：触发构建

通常上传时自动就开始构建了，也可以手动触发：

1. 仓库顶部点 **Actions** 标签。
2. 左侧点 **Build APK**。
3. 若提示「Workflows aren't being run」，点右侧 **Enable Actions** / **I understand my workflows, go ahead and enable them**。
4. 右侧点 **Run workflow** → 绿色 **Run workflow**。
5. 刷新页面，会出现一条带黄色圆点（转圈）的记录，说明正在打包。
6. 点进去可看实时日志。首次约 **5～12 分钟**。
7. 圆点变成 **绿色✅** 表示成功；**红色❌** 表示失败（见第 7 步）。

---

## 第 6 步：下载 APK

1. 在成功的这次构建页面，拉到最下方 **Artifacts** 区域。
2. 点击 **healthy-recipe-apk** 下载，得到一个 `.zip`。
3. 解压 zip，里面就是 **`app-release.apk`**，这就是能装到手机的安装包。
4. 先别装，第 8 阶段会教你怎么装。建议先把 APK 传到自己手机（微信/QQ 发给自己、或用数据线）。

---

## 第 7 步：常见构建错误与解决办法

| 现象 | 原因 | 怎么解决 |
|---|---|---|
| Actions 里没有 Build APK | `.github/workflows/build.yml` 没上传成功 | 按第 3 步「方法 B」手动创建该文件 |
| 提示 workflows 未启用 | 仓库禁用了 Actions | Settings → Actions → General → 选 Allow all actions → Save |
| 第 5 步报 `gradlew: No such file` | wrapper 生成失败 | 到 Actions 里点 **Re-run all jobs** 重跑一次 |
| `flutter pub get` 超时/网络错误 | 云端临时网络问题 | 点 **Re-run all jobs** 重试 |
| `Could not resolve ...` 依赖报错 | 某个库版本冲突 | 把红色日志复制给我，我来改版本 |
| 构建成功但找不到 APK | 没展开 Artifacts | 页面最下方找 **Artifacts**，点名字下载 zip |
| Java 版本相关报错 | 环境不匹配 | 工作流已固定 Java 17，直接 **Re-run** 即可 |

> 只要看到红色，最省事的办法：先点 **Re-run all jobs** 重试一次；仍失败就把红色日志整段发给我。

---

## 第 8 步：以后改了代码怎么重新打包

1. 把改好的文件在仓库里：点文件 → 右上角铅笔图标 → 粘贴新内容 → **Commit changes**。
2. 提交后会自动重新构建，重复第 5、6 步即可拿到新 APK。

---

## 小贴士

- APK 的 Artifact 默认保留 30 天，过期需重新构建下载。
- 仓库建议保持 **Private**，这样别人看不到你的项目。
- 全程不需要安装任何软件，也不需要复制任何命令行。

---

## 下一步

项目已能打包成 APK。接下来的 **阶段 7** 会教你申请 DeepSeek / Brave / Spoonacular 的 API Key（让 App 联网检索权威营养来源），并填进 App。
