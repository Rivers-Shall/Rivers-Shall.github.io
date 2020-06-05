---
title: 常见的git工作流
tags:
- git
categories:
- good practice
---

本文介绍了作者了解到的三种常见的*单仓库*的git工作流，它们是:

1. Centralized工作流
   - 仅使用master一个分支
2. Feature Branch工作流
   - 使用一个master分支管理稳定版本
   - 使用多个feature分支管理需求开发
3. Gitflow工作流
   - 使用一个master分支管理发布版本历史
   - 使用一个develop分支管理开发流程
   - 使用多个feature分支管理需求开发
   - 使用多个release分支管理版本发布
   - 使用多个hotfix分支修复紧急bug

<!-- more -->

## Centralized工作流