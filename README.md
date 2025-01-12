# How to use 3D Gaussian Splatting on macOS

これは，macOS上で3D Gaussian Splattingを動作させたときのメモになります

下記リンクを参考に実行しました

https://www.softbank.jp/biz/blog/cloud-technology/articles/202412/3d-gaussian-splatting/

## My environment

- OS

  macOS 15.1.1（24B91）

- Chip

  Apple M2

- Memory

  24 GB

## Used Programs

I installed following programs then use in my script run.bash

- COLMAP

  https://colmap.github.io/index.html

- OpenSplat

  https://github.com/pierotofy/OpenSplat

- GaussianSplats3D

  https://github.com/mkkellogg/GaussianSplats3D

## Steps

### Recode Movies

3Dにしたい物体の周りをぐるっと一周するように動画撮影をします

私はiPhone SE 2nd Genを使いました

これを以下に保存しました

```bash
~/Desktop/IMG_1086.MOV
```

### Build 3D Gaussian

```bash
./run.bash /path/to/video
```

### Estimate Camera Trajectory by using COLMAP

COLMAPというSfMを実装したプログラムを使います

SfMの説明は以下が詳しいです

```
```

COLMAPのインストールは下記リンクを参考にしました

https://colmap.github.io/install.html

下記コマンドがエラーなく動作することを確認しました

```bash
colmap -h
colmap gui
```

トラブル

- cmake実行時にCeres Solverが参照しているEigenが見つからない

  ```
  CMake Error at /opt/homebrew/lib/cmake/Ceres/CeresConfig.cmake:85 (message):
  Failed to find Ceres - Found Eigen dependency, but the version of Eigen
  found () does not exactly match the version of Eigen Ceres was compiled
  with (3.4.0).  This can cause subtle bugs by triggering violations of the
  One Definition Rule.  See the Wikipedia article
  http://en.wikipedia.org/wiki/One_Definition_Rule for more details
Call Stack (most recent call first):
  /opt/homebrew/lib/cmake/Ceres/CeresConfig.cmake:204 (ceres_report_not_found)
  cmake/FindDependencies.cmake:41 (find_package)
  CMakeLists.txt:116 (include)


CMake Error at cmake/FindDependencies.cmake:41 (find_package):
  Found package configuration file:

    /opt/homebrew/lib/cmake/Ceres/CeresConfig.cmake

  but it set Ceres_FOUND to FALSE so package "Ceres" is considered to be NOT
  FOUND.
Call Stack (most recent call first):
  CMakeLists.txt:116 (include)
  ```

  Eigenを入れ直すことで解消しました

  ```bash
  brew reinstall eigen
  ```

- opensplat実行時にlibomp.dylibが開けない

  署名をし直すことで対処できます

  ```bash
  codesign --force --sign - /path/to/library.dylib
  ```


次に特徴点を抽出しDBに保存します

```bash
colmap feature_extractor \
  --image_path ~/Desktop/images \
  --database_path ~/Desktop/out/database.db \
  --ImageReader.single_camera 1 \
  --ImageReader.camera_model PINHOLE
```

特徴点をマッチングします

これにより，カメラの移動量の推定をすることができるようになります

画像サイズによっては時間がかかります



## References


- COLMAPのインストール

